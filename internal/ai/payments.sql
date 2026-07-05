-- =====================================================================
-- Migration 0003: payments
--
-- Amaç: iyzico/PayTR webhook'larının İDEMPOTENT işlenmesi. Aynı ödeme
-- bildirimi ağ tekrarı veya provider'ın kendi retry'ı yüzünden birden
-- fazla kez gelebilir; `provider_payment_id` üzerindeki UNIQUE kısıt,
-- krediyi yanlışlıkla iki kez yüklememizi veritabanı seviyesinde engeller
-- (bkz. internal/payments/webhook_handler.go CreditIfNotAlreadyProcessed).
-- =====================================================================

CREATE TABLE IF NOT EXISTS payments (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id          UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,

    provider            VARCHAR(20) NOT NULL,   -- 'iyzico' | 'paytr' | 'stripe'
    provider_payment_id VARCHAR(255) NOT NULL,   -- iyzico paymentId / PayTR merchant_oid

    plan_id             VARCHAR(50),              -- satın alınan paket (örn. 'starter', 'pro')
    credit_amount       INT NOT NULL,             -- yüklenen kredi miktarı
    amount_try          NUMERIC(10, 2),           -- ödenen tutar (TL), raporlama için

    status              VARCHAR(20) NOT NULL DEFAULT 'success',

    raw_provider_payload JSONB,   -- webhook body'sinin ham hali (debug/denetim)

    created_at          TIMESTAMP NOT NULL DEFAULT now(),

    CONSTRAINT uq_payments_provider_payment_id UNIQUE (provider, provider_payment_id)
);

CREATE INDEX IF NOT EXISTS idx_payments_company_id ON payments(company_id);

-- Paketler: Türkiye pazarı için sabit tanımlı planlar. Fiyat TL, kredi
-- miktarı sabit — admin panelinden yönetilebilir hale getirmek isterseniz
-- bu tablo ileride `plans` adında ayrı bir tabloya taşınabilir; MVP'de
-- sabit kod (internal/payments/plans.go) yeterlidir, burada sadece
-- referans için bırakıldı.
COMMENT ON COLUMN payments.plan_id IS
    'internal/payments/plans.go içindeki sabit plan tanımlarına referans (örn. starter=100 kredi, pro=500 kredi)';