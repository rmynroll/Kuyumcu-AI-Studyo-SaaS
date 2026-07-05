// Package payments, iyzico/PayTR webhook'larını karşılayan ve paket
// satışı sonrası krediyi İDEMPOTENT şekilde yükleyen mantığı barındırır.
//
// KRİTİK KURAL: Webhook body'sine körü körüne güvenilmez. Webhook sadece
// "bir şey oldu, gel kontrol et" sinyalidir; gerçek durum, token/paymentId
// ile provider'ın KENDİ API'sine tekrar sorularak doğrulanır. Bu, sahte
// bir webhook isteğiyle bedava kredi yüklenmesini engeller.
package ai

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"net/http"
)

// ---------------------------------------------------------------------
// Provider arayüzü — iyzico ve PayTR aynı sözleşmeyi implemente eder
// ---------------------------------------------------------------------



// VerifiedPayment, provider'ın (iyzico/PayTR) KENDİ API'sinden dönen,
// doğrulanmış ödeme sonucudur. Webhook body'si asla bu tipe DOĞRUDAN
// çevrilmez — her zaman bu doğrulama adımından geçer.
type VerifiedPayment struct {
	PaymentID        string
	CompanyID        string
	Status           string // "success" | "failure"
	PlanID           string
	PlanCreditAmount int
	AmountTRY        float64
	RawPayload       json.RawMessage
}

// PaymentProvider, iyzico ve PayTR'nin ortak arayüzüdür. Yeni bir
// provider eklemek (örn. Stripe) bu arayüzü implemente etmekten ibarettir;
// webhook handler'ı hangi provider olduğunu bilmez.
type PaymentProvider interface {
	Name() string
	// RetrieveCheckoutForm, webhook'taki token ile provider'ın kendi
	// API'sine sorup GERÇEK ödeme durumunu döner (iyzico'da
	// "checkoutform/auth/detail", PayTR'de imza doğrulama + durum sorgusu).
	RetrieveCheckoutForm(ctx context.Context, token string) (*VerifiedPayment, error)
}

// ---------------------------------------------------------------------
// Repository — idempotency garantisi burada
// ---------------------------------------------------------------------

// Repository, `payments` tablosuna dair sözleşmedir.
type Repository interface {
	// CreditIfNotAlreadyProcessed, `provider_payment_id` üzerindeki UNIQUE
	// kısıttan (bkz. migration 0003) yararlanarak aynı ödemenin iki kez
	// işlenmesini engeller. `credited == true` ise bu çağrı sonucunda
	// GERÇEKTEN yeni bir kayıt oluşturuldu (kredi yüklenmeli); `false`
	// ise bu ödeme zaten daha önce işlenmiş (kredi TEKRAR yüklenmemeli).
	CreditIfNotAlreadyProcessed(ctx context.Context, provider, providerPaymentID, companyID, planID string, creditAmount int, amountTRY float64, rawPayload json.RawMessage) (credited bool, err error)
}

// ---------------------------------------------------------------------
// Handler
// ---------------------------------------------------------------------

type Handler struct {
	Provider      PaymentProvider
	Repository    Repository
	CreditService CreditService
	Logger        *slog.Logger
}

func NewHandler(provider PaymentProvider, repo Repository, creditService CreditService, logger *slog.Logger) *Handler {
	if logger == nil {
		logger = slog.Default()
	}
	return &Handler{Provider: provider, Repository: repo, CreditService: creditService, Logger: logger}
}

// IyzicoWebhookPayload, iyzico'nun POST /payments/webhook'a gönderdiği
// ham body'dir. Bu struct SADECE token'ı okumak için kullanılır —
// `status` alanına bile güvenilmez, tekrar doğrulanır (bkz. dosya başı notu).
type IyzicoWebhookPayload struct {
	Token         string `json:"token"`
	IyziEventType string `json:"iyziEventType"`
	IyziPaymentID string `json:"iyziPaymentId"`
	Status        string `json:"status"`
}

// HandleIyzicoWebhook, `POST /payments/webhook` route'una bağlanır.
func (h *Handler) HandleIyzicoWebhook(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	var payload IyzicoWebhookPayload
	if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
		h.Logger.Warn("iyzico webhook payload parse edilemedi", "error", err)
		http.Error(w, "invalid payload", http.StatusBadRequest)
		return
	}

	// 1) Webhook'a KÖRÜ KÖRÜNE güvenme — token ile provider'ın kendi
	//    endpoint'ine sorup gerçek durumu al.
	verified, err := h.Provider.RetrieveCheckoutForm(ctx, payload.Token)
	if err != nil {
		h.Logger.Error("iyzico checkout form doğrulanamadı", "error", err, "token", payload.Token)
		// İyzico'ya 200 DÖNMEK burada bilinçli bir tercih: eğer gerçek bir
		// hata değilse (örn. ödeme henüz sonuçlanmadı) 200 dönmek,
		// provider'ın anlamsız retry fırtınası yaratmasını önler. Gerçek
		// bir altyapı hatasıysa loglar üzerinden fark edilir.
		w.WriteHeader(http.StatusOK)
		return
	}

	if verified.Status != "success" {
		h.Logger.Info("iyzico ödemesi başarısız/iptal, kredi yüklenmiyor",
			"payment_id", verified.PaymentID, "status", verified.Status,
		)
		w.WriteHeader(http.StatusOK)
		return
	}

	// 2) İDEMPOTENCY: aynı webhook birden fazla kez gelebilir. Repository,
	//    `provider_payment_id` UNIQUE kısıtından yararlanarak bunu
	//    veritabanı seviyesinde garanti eder.
	credited, err := h.Repository.CreditIfNotAlreadyProcessed(
		ctx, h.Provider.Name(), verified.PaymentID, verified.CompanyID,
		verified.PlanID, verified.PlanCreditAmount, verified.AmountTRY, verified.RawPayload,
	)
	if err != nil {
		h.Logger.Error("payment kaydı oluşturulamadı", "error", err, "payment_id", verified.PaymentID)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	if !credited {
		h.Logger.Info("ödeme zaten işlenmiş, kredi tekrar yüklenmedi",
			"payment_id", verified.PaymentID,
		)
		w.WriteHeader(http.StatusOK)
		return
	}

	// 3) Yeni ödeme — krediyi yükle. Bu, Reserve/Commit/Refund üçlüsünden
	//    farklı bir işlemdir (bkz. credits.Service.AddBalance); bir
	//    generation'a bağlı değildir, doğrudan satın almadır.
	reason := fmt.Sprintf("%s payment_id=%s plan=%s", h.Provider.Name(), verified.PaymentID, verified.PlanID)
	if err := h.CreditService.AddBalance(ctx, verified.CompanyID, verified.PlanCreditAmount, reason); err != nil {
		// Bu noktada `payments` tablosuna kayıt zaten düştü ama bakiye
		// eklenemedi — bu durum ALARM gerektirir (para alındı, kredi
		// yüklenmedi). Gerçek sistemde burada bir retry job'u veya
		// Sentry/PagerDuty bildirimi tetiklenmelidir.
		h.Logger.Error("KRİTİK: ödeme kaydedildi ama bakiye eklenemedi",
			"error", err, "payment_id", verified.PaymentID, "company_id", verified.CompanyID,
		)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	h.Logger.Info("kredi paketi başarıyla yüklendi",
		"company_id", verified.CompanyID, "credit_amount", verified.PlanCreditAmount, "plan", verified.PlanID,
	)
	w.WriteHeader(http.StatusOK)
}