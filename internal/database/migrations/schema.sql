-- =====================================================================
-- Kuyumcu AI Stüdyo SaaS - PostgreSQL Şema
-- Kapsam: users, companies, products, generations, reference_analyses
-- Not: Basitlik ilkesi gereği ürün metadata'sı (ürün türü, metal rengi,
-- taş türü) düz kolonlarda; esnek/AI kaynaklı ek bilgiler JSONB'de tutulur.
-- =====================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto"; -- gen_random_uuid() için

-- ---------------------------------------------------------------------
-- users: Kuyumcu hesabına bağlı kullanıcı kimlik bilgileri
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email           VARCHAR(255) UNIQUE,
    phone           VARCHAR(30) UNIQUE,
    password_hash   TEXT NOT NULL,
    full_name       VARCHAR(255),
    role            VARCHAR(50) NOT NULL DEFAULT 'owner', -- owner, member, admin
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP NOT NULL DEFAULT now(),
    updated_at      TIMESTAMP NOT NULL DEFAULT now(),
    CONSTRAINT chk_users_contact CHECK (email IS NOT NULL OR phone IS NOT NULL)
);

-- ---------------------------------------------------------------------
-- companies: Kuyumcu firma / mağaza hesabı
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS companies (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name                VARCHAR(255) NOT NULL,
    phone               VARCHAR(30),
    city                VARCHAR(100),
    instagram_handle    VARCHAR(150),
    website_url         TEXT,
    logo_url            TEXT,          -- S3/R2 uyumlu URL
    brand_colors        JSONB,         -- {"primary": "#...", "secondary": "#..."}
    credit_balance      INT NOT NULL DEFAULT 0,
    plan                VARCHAR(50) NOT NULL DEFAULT 'trial', -- trial, starter, pro, enterprise
    created_at          TIMESTAMP NOT NULL DEFAULT now(),
    updated_at          TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_companies_owner_user_id ON companies(owner_user_id);

-- ---------------------------------------------------------------------
-- products: Kuyumcunun yüklediği takı ürünleri
-- Basitlik ilkesi: ürün türü / metal rengi / taş türü sabit, kısa
-- seçenek listeleriyle sınırlı düz kolonlar olarak tutulur.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS products (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id          UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    name                VARCHAR(255) NOT NULL,
    description         TEXT,

    -- Basitleştirilmiş, kuyumcu dostu sınıflandırma alanları
    product_type        VARCHAR(50) NOT NULL,   -- ring, necklace, bracelet, earring, set
    metal_color         VARCHAR(50),             -- yellow_gold, white_gold, rose_gold, silver
    stone_type          VARCHAR(50),             -- diamond, zircon, pearl, colored_stone, none

    collection_name     VARCHAR(255),
    sku                 VARCHAR(100),

    -- S3/R2 uyumlu görsel URL'leri
    original_image_url  TEXT NOT NULL,
    clean_image_url     TEXT,   -- arka planı temizlenmiş görsel
    mask_image_url      TEXT,   -- segmentasyon maskesi
    thumbnail_url       TEXT,

    status              VARCHAR(50) NOT NULL DEFAULT 'active', -- active, archived
    ai_metadata         JSONB,  -- AI'nin otomatik tahmin ettiği ek bilgiler

    created_at          TIMESTAMP NOT NULL DEFAULT now(),
    updated_at          TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_products_company_id ON products(company_id);
CREATE INDEX IF NOT EXISTS idx_products_product_type ON products(product_type);

-- ---------------------------------------------------------------------
-- reference_analyses: Kullanıcının yüklediği referans görselden
-- çıkarılan stil/ışık/kompozisyon bilgisi (JSONB)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS reference_analyses (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id              UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    user_id                 UUID REFERENCES users(id) ON DELETE SET NULL,

    reference_image_url     TEXT NOT NULL, -- S3/R2 uyumlu URL

    extracted_prompt        TEXT,
    extracted_metadata      JSONB, -- scene, lighting, camera_angle, composition, style, color_palette, mood

    status                  VARCHAR(50) NOT NULL DEFAULT 'pending', -- pending, completed, failed
    error_message           TEXT,

    created_at              TIMESTAMP NOT NULL DEFAULT now(),
    updated_at              TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_reference_analyses_company_id ON reference_analyses(company_id);

-- ---------------------------------------------------------------------
-- generations: AI üretim işleri (hazır şablon veya referans görsel modu)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS generations (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id              UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    user_id                 UUID REFERENCES users(id) ON DELETE SET NULL,
    product_id              UUID REFERENCES products(id) ON DELETE SET NULL,
    reference_analysis_id   UUID REFERENCES reference_analyses(id) ON DELETE SET NULL,

    generation_mode         VARCHAR(50) NOT NULL DEFAULT 'template', -- template, reference
    generation_type         VARCHAR(50) NOT NULL DEFAULT 'image',    -- image, video
    template_id             UUID,           -- ileride templates tablosuna FK olabilir

    status                  VARCHAR(50) NOT NULL DEFAULT 'pending',
    -- pending, queued, processing, analyzing_product, removing_background,
    -- generating_scene, compositing_product, quality_checking, completed,
    -- failed, cancelled

    prompt                  TEXT,
    negative_prompt         TEXT,
    input_params             JSONB, -- scene, lighting, aspect_ratio, output_count, use_logo vb.

    -- S3/R2 uyumlu çıktı görselleri (birden fazla çıktı desteklenir)
    output_urls              JSONB, -- [{"file_url": "...", "thumbnail_url": "...", "width":..., "height":...}]

    credit_cost              INT NOT NULL DEFAULT 1,
    error_message             TEXT,

    started_at                TIMESTAMP,
    completed_at              TIMESTAMP,
    created_at                 TIMESTAMP NOT NULL DEFAULT now(),
    updated_at                 TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_generations_company_id ON generations(company_id);
CREATE INDEX IF NOT EXISTS idx_generations_product_id ON generations(product_id);
CREATE INDEX IF NOT EXISTS idx_generations_status ON generations(status);
