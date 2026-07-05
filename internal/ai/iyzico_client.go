package ai

import (
	"bytes"
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

// ---------------------------------------------------------------------
// IyzicoClient — `PaymentProvider` arayüzünün iyzico implementasyonu.
//
// İki sorumluluğu var:
//  1. InitializeCheckoutForm: Flutter'ın WebView'da açacağı ödeme formu
//     URL'ini üretir (bkz. `POST /payments/checkout` handler'ı, bu
//     teslimatın kapsamı dışında ama bu client'ı çağırır).
//  2. RetrieveCheckoutForm: webhook'taki token ile GERÇEK ödeme durumunu
//     iyzico'nun kendi API'sinden sorar (webhook_handler.go bunu çağırır).
// ---------------------------------------------------------------------

type IyzicoConfig struct {
	APIKey     string
	SecretKey  string
	BaseURL    string // varsayılan: https://api.iyzipay.com
	HTTPClient *http.Client
}

type IyzicoClient struct {
	cfg IyzicoConfig
}

func NewIyzicoClient(cfg IyzicoConfig) *IyzicoClient {
	if cfg.BaseURL == "" {
		cfg.BaseURL = "https://api.iyzipay.com"
	}
	if cfg.HTTPClient == nil {
		cfg.HTTPClient = &http.Client{Timeout: 20 * time.Second}
	}
	return &IyzicoClient{cfg: cfg}
}

func (c *IyzicoClient) Name() string { return "iyzico" }

// InitializeCheckoutFormRequest, `POST /payments/checkout` handler'ının
// dolduracağı minimum bilgidir.
type InitializeCheckoutFormRequest struct {
	CompanyID   string
	PlanID      string
	CallbackURL string // ödeme sonrası kullanıcının döneceği URL
	BuyerEmail  string
	BuyerName   string
}

type InitializeCheckoutFormResult struct {
	CheckoutFormContentURL string // Flutter WebView'da açılacak URL
	Token                  string
}

// InitializeCheckoutForm, iyzico'nun "Checkout Form Initialize" isteğini
// yapar. Plan bilgisi `conversationId` alanına gömülür ki webhook geri
// geldiğinde hangi plan/firma olduğunu tekrar sorgulayabilelim.
func (c *IyzicoClient) InitializeCheckoutForm(ctx context.Context, req InitializeCheckoutFormRequest) (*InitializeCheckoutFormResult, error) {
	plan, ok := GetPlan(req.PlanID)
	if !ok {
		return nil, fmt.Errorf("bilinmeyen plan: %s", req.PlanID)
	}

	// conversationId, companyID+planID'yi taşır; webhook'ta bu bilgiyi
	// tekrar üretmek için kullanılır (iyzico bunu bize geri döner).
	conversationID := fmt.Sprintf("%s:%s", req.CompanyID, req.PlanID)

	payload := map[string]any{
		"locale":         "tr",
		"conversationId": conversationID,
		"price":          fmt.Sprintf("%.2f", plan.PriceTRY),
		"paidPrice":      fmt.Sprintf("%.2f", plan.PriceTRY),
		"currency":       "TRY",
		"basketId":       conversationID,
		"paymentGroup":   "PRODUCT",
		"callbackUrl":    req.CallbackURL,
		"buyer": map[string]any{
			"id":    req.CompanyID,
			"email": req.BuyerEmail,
			"name":  req.BuyerName,
		},
		"basketItems": []map[string]any{
			{
				"id": plan.ID, "name": plan.Label, "category1": "credits",
				"itemType": "VIRTUAL", "price": fmt.Sprintf("%.2f", plan.PriceTRY),
			},
		},
	}

	var out struct {
		Status                 string `json:"status"`
		Token                  string `json:"token"`
		CheckoutFormContentURL string `json:"checkoutFormContent"`
		ErrorMessage           string `json:"errorMessage"`
	}
	if err := c.call(ctx, "/payment/iyzipos/checkoutform/initialize/auth/ecom", payload, &out); err != nil {
		return nil, err
	}
	if out.Status != "success" {
		return nil, fmt.Errorf("iyzico checkout form initialize başarısız: %s", out.ErrorMessage)
	}

	return &InitializeCheckoutFormResult{
		CheckoutFormContentURL: out.CheckoutFormContentURL,
		Token:                  out.Token,
	}, nil
}

// RetrieveCheckoutForm, `PaymentProvider` arayüzünü implemente eder.
// Webhook'taki token'ı alır, iyzico'ya SORAR ve gerçek sonucu döner.
func (c *IyzicoClient) RetrieveCheckoutForm(ctx context.Context, token string) (*VerifiedPayment, error) {
	payload := map[string]any{
		"locale": "tr",
		"token":  token,
	}

	var out struct {
		Status         string `json:"status"`
		PaymentStatus  string `json:"paymentStatus"`
		PaymentID      string `json:"paymentId"`
		ConversationID string `json:"conversationId"` // companyID:planID
		PaidPrice      string `json:"paidPrice"`
		ErrorMessage   string `json:"errorMessage"`
	}
	rawBody, err := c.callRaw(ctx, "/payment/iyzipos/checkoutform/auth/ecom/detail", payload, &out)
	if err != nil {
		return nil, err
	}

	if out.Status != "success" || out.PaymentStatus != "SUCCESS" {
		return &VerifiedPayment{
			PaymentID: out.PaymentID,
			Status:    "failure",
		}, nil
	}

	companyID, planID := splitConversationID(out.ConversationID)
	plan, ok := GetPlan(planID)
	if !ok {
		return nil, fmt.Errorf("doğrulanan ödemede bilinmeyen plan: %s (conversationId=%s)", planID, out.ConversationID)
	}

	amount := parseFloatSafe(out.PaidPrice)

	return &VerifiedPayment{
		PaymentID:        out.PaymentID,
		CompanyID:        companyID,
		Status:           "success",
		PlanID:           planID,
		PlanCreditAmount: plan.CreditAmount,
		AmountTRY:        amount,
		RawPayload:       rawBody,
	}, nil
}

// ---------------------------------------------------------------------
// HTTP + imza yardımcıları
//
// İyzico, HMAC-SHA256 tabanlı bir "Authorization" header imzası bekler.
// Gerçek imza algoritması iyzico'nun resmi SDK'sındaki (iyzipay-go)
// mantıkla birebir aynı olmalıdır; burada o algoritmanın iskeleti
// verilmiştir — prodüksiyona geçmeden önce resmi SDK ile çapraz
// doğrulama yapılması önerilir.
// ---------------------------------------------------------------------

func (c *IyzicoClient) call(ctx context.Context, path string, payload map[string]any, out any) error {
	_, err := c.callRaw(ctx, path, payload, out)
	return err
}

func (c *IyzicoClient) callRaw(ctx context.Context, path string, payload map[string]any, out any) (json.RawMessage, error) {
	body, err := json.Marshal(payload)
	if err != nil {
		return nil, fmt.Errorf("iyzico isteği marshal edilemedi: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.cfg.BaseURL+path, bytes.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("iyzico isteği kurulamadı: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", c.buildAuthHeader(body))

	resp, err := c.cfg.HTTPClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("iyzico isteği başarısız: %w", err)
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("iyzico yanıtı okunamadı: %w", err)
	}

	if err := json.Unmarshal(respBody, out); err != nil {
		return nil, fmt.Errorf("iyzico yanıtı parse edilemedi: %w", err)
	}

	return respBody, nil
}

// buildAuthHeader, iyzico'nun IYZWSv2 imza şemasını uygular.
// NOT: Bu, resmi iyzipay-go SDK'sındaki `HmacAuthorizationProvider`
// mantığının basitleştirilmiş bir taslağıdır; rastgele üretilen `x-iyzi-rnd`
// değeri gerçek implementasyonda her istekte benzersiz olmalıdır.
func (c *IyzicoClient) buildAuthHeader(body []byte) string {
	randomKey := fmt.Sprintf("%d", time.Now().UnixNano())
	dataToSign := randomKey + c.cfg.APIKey + string(body)

	mac := hmac.New(sha256.New, []byte(c.cfg.SecretKey))
	mac.Write([]byte(dataToSign))
	signature := base64.StdEncoding.EncodeToString(mac.Sum(nil))

	return fmt.Sprintf("IYZWSv2 %s:%s", c.cfg.APIKey, signature)
}

func splitConversationID(conversationID string) (companyID, planID string) {
	for i := len(conversationID) - 1; i >= 0; i-- {
		if conversationID[i] == ':' {
			return conversationID[:i], conversationID[i+1:]
		}
	}
	return conversationID, ""
}

func parseFloatSafe(s string) float64 {
	var f float64
	_, _ = fmt.Sscanf(s, "%f", &f)
	return f
}
