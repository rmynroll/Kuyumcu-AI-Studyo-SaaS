package ai

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"
)

// PostgresRepository, `Repository` arayüzünü implemente eder.
type PostgresRepository struct {
	db *pgxpool.Pool
}

func NewPostgresRepository(db *pgxpool.Pool) *PostgresRepository {
	return &PostgresRepository{db: db}
}

// CreditIfNotAlreadyProcessed, `ON CONFLICT (provider, provider_payment_id)
// DO NOTHING` deseniyle idempotency'yi veritabanı seviyesinde garanti eder.
// `RowsAffected() == 0` ise bu ödeme zaten daha önce kaydedilmiş demektir
// — webhook_handler.go bu durumda krediyi TEKRAR yüklemez.
func (r *PostgresRepository) CreditIfNotAlreadyProcessed(
	ctx context.Context,
	provider, providerPaymentID, companyID, planID string,
	creditAmount int, amountTRY float64, rawPayload json.RawMessage,
) (bool, error) {
	const query = `
		INSERT INTO payments (company_id, provider, provider_payment_id, plan_id, credit_amount, amount_try, raw_provider_payload)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		ON CONFLICT (provider, provider_payment_id) DO NOTHING
	`

	tag, err := r.db.Exec(ctx, query, companyID, provider, providerPaymentID, planID, creditAmount, amountTRY, rawPayload)
	if err != nil {
		return false, fmt.Errorf("payment kaydı oluşturulamadı: %w", err)
	}

	return tag.RowsAffected() > 0, nil
}
