// Package credits, `companies.credit_balance` ve `credit_transactions`
// tabloları üzerinde çalışan, `internal/ai.CreditService` arayüzünü
// karşılayan gerçek implementasyonu barındırır.
//
// Akış (bkz. internal/ai/credit.go'daki sözleşme):
//  1. Reserve  → bakiyeyi düşürür, status='reserved' bir kayıt açar.
//  2. Commit   → o kaydı status='committed' yapar (kredi kalıcı harcandı).
//  3. Refund   → bakiyeyi geri ekler, kaydı status='refunded' yapar.
//
// Tüm işlemler tek bir DB transaction'ı içinde ve `companies` satırı
// `SELECT ... FOR UPDATE` ile kilitlenerek yapılır; bu, aynı firmanın
// eşzamanlı iki generation isteğinin bakiyeyi yarış durumunda (race
// condition) yanlış düşürmesini engeller.
package credits

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"kuyumcu-backend/internal/ai"
)

// Service, `ai.CreditService` arayüzünü implemente eder.
type Service struct {
	db *pgxpool.Pool
}

func NewService(db *pgxpool.Pool) *Service {
	return &Service{db: db}
}

// Reserve, bir generation başlamadan önce gereken krediyi düşer.
//
// Idempotency notu: `credit_transactions` tablosunda
// `uq_credit_transactions_reserved_per_generation` (bkz. migration 0002)
// aynı `generation_id` için birden fazla 'reserved' kaydı oluşmasını
// veritabanı seviyesinde engeller; bu yüzden aynı task Asynq tarafından
// yanlışlıkla iki kez işlenirse (örn. retry sırasında) ikinci Reserve
// çağrısı, bu fonksiyonun kendi ön-kontrolüyle (aşağıdaki `existing`
// sorgusu) yakalanır ve bakiye tekrar düşürülmez.
func (s *Service) Reserve(ctx context.Context, companyID, generationID string, amount int) error {
	tx, err := s.db.Begin(ctx)
	if err != nil {
		return fmt.Errorf("kredi rezervasyonu için transaction başlatılamadı: %w", err)
	}
	defer tx.Rollback(ctx) // Commit edilmezse (hata durumunda) otomatik geri alınır.

	var existing int
	err = tx.QueryRow(ctx,
		`SELECT count(*) FROM credit_transactions WHERE generation_id = $1 AND status = 'reserved'`,
		generationID,
	).Scan(&existing)
	if err != nil {
		return fmt.Errorf("mevcut rezervasyon kontrol edilemedi: %w", err)
	}
	if existing > 0 {
		// Zaten rezerve edilmiş — tekrar bakiye düşmeden başarıyla dön.
		return tx.Commit(ctx)
	}

	// Firma satırını kilitle: eşzamanlı iki generation isteği aynı
	// firmanın bakiyesini aynı anda okuyup ikisi de "yeterli" sonucuna
	// ulaşamasın (klasik race condition).
	var currentBalance int
	err = tx.QueryRow(ctx,
		`SELECT credit_balance FROM companies WHERE id = $1 FOR UPDATE`,
		companyID,
	).Scan(&currentBalance)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return fmt.Errorf("firma bulunamadı (id=%s): %w", companyID, err)
		}
		return fmt.Errorf("firma bakiyesi okunamadı: %w", err)
	}

	if currentBalance < amount {
		// Kalıcı hata: internal/ai/credit.go bu sentinel değeri
		// service.go'da `err == ai.ErrInsufficientCredit` ile
		// karşılaştırıp kullanıcıya sade mesaj gösteriyor.
		return ai.ErrInsufficientCredit
	}

	if _, err := tx.Exec(ctx,
		`UPDATE companies SET credit_balance = credit_balance - $1, updated_at = now() WHERE id = $2`,
		amount, companyID,
	); err != nil {
		return fmt.Errorf("bakiye düşürülemedi: %w", err)
	}

	if _, err := tx.Exec(ctx,
		`INSERT INTO credit_transactions (company_id, generation_id, amount, status)
		 VALUES ($1, $2, $3, 'reserved')`,
		companyID, generationID, amount,
	); err != nil {
		return fmt.Errorf("rezervasyon kaydı oluşturulamadı: %w", err)
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("kredi rezervasyonu commit edilemedi: %w", err)
	}
	return nil
}

// Commit, rezerve edilen krediyi kalıcı harcama olarak işaretler.
// Bakiye zaten Reserve() sırasında düşürüldüğü için burada bakiyeye
// dokunulmaz — sadece transaction kaydının durumu güncellenir (denetim/
// raporlama amaçlı).
func (s *Service) Commit(ctx context.Context, generationID string) error {
	tag, err := s.db.Exec(ctx,
		`UPDATE credit_transactions
		 SET status = 'committed', updated_at = now()
		 WHERE generation_id = $1 AND status = 'reserved'`,
		generationID,
	)
	if err != nil {
		return fmt.Errorf("kredi commit edilemedi (generation_id=%s): %w", generationID, err)
	}
	if tag.RowsAffected() == 0 {
		return fmt.Errorf("commit edilecek 'reserved' kredi kaydı bulunamadı (generation_id=%s)", generationID)
	}
	return nil
}

// Refund, rezerve edilen krediyi kullanıcıya geri iade eder: bakiyeyi
// geri ekler ve transaction kaydını 'refunded' yapar. Tek transaction
// içinde yapılır ki bakiye güncellemesi ile kayıt durumu asla
// tutarsız kalmasın.
func (s *Service) Refund(ctx context.Context, generationID string, reason string) error {
	tx, err := s.db.Begin(ctx)
	if err != nil {
		return fmt.Errorf("kredi iadesi için transaction başlatılamadı: %w", err)
	}
	defer tx.Rollback(ctx)

	var companyID string
	var amount int
	err = tx.QueryRow(ctx,
		`SELECT company_id, amount FROM credit_transactions
		 WHERE generation_id = $1 AND status = 'reserved'
		 FOR UPDATE`,
		generationID,
	).Scan(&companyID, &amount)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			// Rezervasyon yok — muhtemelen zaten commit/refund edilmiş.
			// Çift iade riskini önlemek için burada sessizce başarıyla
			// dönmek YERİNE açıkça hata döndürüyoruz; çağıran taraf
			// (service.go) bunu best-effort olarak çağırıyor ve
			// loglanması yeterli.
			return fmt.Errorf("iade edilecek 'reserved' kredi kaydı bulunamadı (generation_id=%s)", generationID)
		}
		return fmt.Errorf("rezervasyon kaydı okunamadı: %w", err)
	}

	if _, err := tx.Exec(ctx,
		`UPDATE companies SET credit_balance = credit_balance + $1, updated_at = now() WHERE id = $2`,
		amount, companyID,
	); err != nil {
		return fmt.Errorf("bakiye iadesi yapılamadı: %w", err)
	}

	if _, err := tx.Exec(ctx,
		`UPDATE credit_transactions
		 SET status = 'refunded', reason = $1, updated_at = now()
		 WHERE generation_id = $2 AND status = 'reserved'`,
		reason, generationID,
	); err != nil {
		return fmt.Errorf("iade kaydı güncellenemedi: %w", err)
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("kredi iadesi commit edilemedi: %w", err)
	}
	return nil
}