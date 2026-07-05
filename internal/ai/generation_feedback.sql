-- =====================================================================
-- Migration 0005: generation_feedback
--
-- Amaç: Kullanıcının üretim sonrası verdiği geri bildirimleri saklamak
-- ve ürün kimliği ihlali (taş sayısı, metal rengi vb.) içerenleri admin
-- kuyruğuna otomatik flag'lemek (bkz. internal/feedback/service.go
-- criticalCodes haritası).
-- =====================================================================

CREATE TABLE IF NOT EXISTS generation_feedback (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    generation_id  UUID NOT NULL REFERENCES generations(id) ON DELETE CASCADE,
    company_id     UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,

    feedback_code  VARCHAR(50) NOT NULL,
    -- 'product_broken', 'stone_count_changed', 'metal_color_wrong',
    -- 'background_bad', 'unnatural_placement', 'looks_good_but_not_similar'

    note           TEXT,                            -- kullanıcının serbest metin notu (opsiyonel)
    is_flagged     BOOLEAN NOT NULL DEFAULT TRUE,     -- admin kuyruğuna düşsün mü
    reviewed_at    TIMESTAMP,
    reviewer_note  TEXT,

    created_at     TIMESTAMP NOT NULL DEFAULT now(),

    CONSTRAINT chk_generation_feedback_code CHECK (feedback_code IN (
        'product_broken', 'stone_count_changed', 'metal_color_wrong',
        'background_bad', 'unnatural_placement', 'looks_good_but_not_similar'
    ))
);

-- Admin panelinin "incelenmemiş + kritik" kuyruğu bu index üzerinden
-- hızlıca sorgulanır (bkz. internal/feedback/repository.go ListFlagged).
CREATE INDEX IF NOT EXISTS idx_generation_feedback_unreviewed
    ON generation_feedback (created_at) WHERE reviewed_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_generation_feedback_generation_id
    ON generation_feedback (generation_id);