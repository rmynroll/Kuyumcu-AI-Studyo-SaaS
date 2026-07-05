-- =====================================================================
-- Migration 0004: template_categories, templates
--
-- Amaç: Hazır şablon setini kod değişikliği gerektirmeden genişletebilmek.
-- `scene_prompt_vars` JSONB, `internal/ai.PromptVariables`'a doğrudan map
-- edilir (bkz. internal/ai/prompts.go BuildScenePrompt); yeni bir şablon
-- eklemek artık bir INSERT'tir, bir deploy değil.
-- =====================================================================

CREATE TABLE IF NOT EXISTS template_categories (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key        VARCHAR(50) UNIQUE NOT NULL,   -- 'basic' | 'model_presentation' | 'social_media'
    label      VARCHAR(100) NOT NULL,          -- "Temel Çekimler"
    sort_order INT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS templates (
    id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id                 UUID NOT NULL REFERENCES template_categories(id) ON DELETE CASCADE,
    key                         VARCHAR(50) UNIQUE NOT NULL,  -- 'white_background', 'velvet_box'
    label                       VARCHAR(100) NOT NULL,         -- "Beyaz Fon"
    preview_image_url           TEXT NOT NULL,
    aspect_ratio                VARCHAR(10) NOT NULL DEFAULT '1:1',

    -- internal/ai.PromptVariables alt kümesi: scene, lighting, camera_angle,
    -- composition, style, mood (bkz. internal/ai/prompts.go)
    scene_prompt_vars           JSONB NOT NULL,

    -- true ise bu şablon "el/boyun/kulak üzerinde kullanım" kategorisinde
    -- sayılır ve internal/credits.CreditCostTable.ModelPresentation
    -- maliyetiyle ücretlendirilir (bkz. pricing.go).
    requires_model_presentation BOOLEAN NOT NULL DEFAULT FALSE,

    is_active                   BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order                  INT NOT NULL DEFAULT 0,
    created_at                  TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_templates_category_id ON templates(category_id);

-- ---------------------------------------------------------------------
-- Seed: 3 kategori
-- ---------------------------------------------------------------------
INSERT INTO template_categories (key, label, sort_order) VALUES
    ('basic',              'Temel Çekimler',      1),
    ('model_presentation', 'Mankenli Sunumlar',    2),
    ('social_media',       'Sosyal Medya',         3)
ON CONFLICT (key) DO NOTHING;

-- ---------------------------------------------------------------------
-- Seed: Temel Çekimler (beyaz fon, kadife kutu, siyah mermer)
-- ---------------------------------------------------------------------
INSERT INTO templates (category_id, key, label, preview_image_url, aspect_ratio, scene_prompt_vars, requires_model_presentation, sort_order)
SELECT id, 'white_background', 'Beyaz Fon',
       'https://cdn.kuyumcuaistudio.com/templates/white_background.jpg', '1:1',
       '{"scene": "clean white studio background", "lighting": "soft even studio lighting", "camera_angle": "top-down macro", "style": "minimal e-commerce", "mood": "clean, professional"}',
       FALSE, 1
FROM template_categories WHERE key = 'basic'
ON CONFLICT (key) DO NOTHING;

INSERT INTO templates (category_id, key, label, preview_image_url, aspect_ratio, scene_prompt_vars, requires_model_presentation, sort_order)
SELECT id, 'velvet_box', 'Kadife Kutu',
       'https://cdn.kuyumcuaistudio.com/templates/velvet_box.jpg', '1:1',
       '{"scene": "open luxury velvet jewelry box", "lighting": "soft warm studio lighting", "camera_angle": "45 degree close-up macro", "style": "luxury jewelry advertising", "mood": "premium, elegant"}',
       FALSE, 2
FROM template_categories WHERE key = 'basic'
ON CONFLICT (key) DO NOTHING;

INSERT INTO templates (category_id, key, label, preview_image_url, aspect_ratio, scene_prompt_vars, requires_model_presentation, sort_order)
SELECT id, 'black_marble', 'Siyah Mermer',
       'https://cdn.kuyumcuaistudio.com/templates/black_marble.jpg', '1:1',
       '{"scene": "black marble surface with subtle reflection", "lighting": "soft warm studio lighting", "camera_angle": "45 degree close-up macro", "style": "luxury jewelry advertising", "mood": "premium, elegant, minimal"}',
       FALSE, 3
FROM template_categories WHERE key = 'basic'
ON CONFLICT (key) DO NOTHING;

-- ---------------------------------------------------------------------
-- Seed: Mankenli Sunumlar (el, boyun, kulak) — kredi maliyeti daha yüksek
-- ---------------------------------------------------------------------
INSERT INTO templates (category_id, key, label, preview_image_url, aspect_ratio, scene_prompt_vars, requires_model_presentation, sort_order)
SELECT id, 'hand_model', 'El Üzerinde',
       'https://cdn.kuyumcuaistudio.com/templates/hand_model.jpg', '4:5',
       '{"scene": "elegant female hand resting on soft fabric", "lighting": "soft natural window light", "camera_angle": "close-up macro", "style": "lifestyle jewelry photography", "mood": "natural, elegant"}',
       TRUE, 1
FROM template_categories WHERE key = 'model_presentation'
ON CONFLICT (key) DO NOTHING;

INSERT INTO templates (category_id, key, label, preview_image_url, aspect_ratio, scene_prompt_vars, requires_model_presentation, sort_order)
SELECT id, 'neck_model', 'Boyunda',
       'https://cdn.kuyumcuaistudio.com/templates/neck_model.jpg', '4:5',
       '{"scene": "elegant neckline, soft studio backdrop", "lighting": "soft warm studio lighting", "camera_angle": "close-up, slightly above", "style": "lifestyle jewelry photography", "mood": "natural, elegant"}',
       TRUE, 2
FROM template_categories WHERE key = 'model_presentation'
ON CONFLICT (key) DO NOTHING;

INSERT INTO templates (category_id, key, label, preview_image_url, aspect_ratio, scene_prompt_vars, requires_model_presentation, sort_order)
SELECT id, 'ear_model', 'Kulakta',
       'https://cdn.kuyumcuaistudio.com/templates/ear_model.jpg', '4:5',
       '{"scene": "elegant ear and jawline profile, soft studio backdrop", "lighting": "soft warm studio lighting", "camera_angle": "profile close-up macro", "style": "lifestyle jewelry photography", "mood": "natural, elegant"}',
       TRUE, 3
FROM template_categories WHERE key = 'model_presentation'
ON CONFLICT (key) DO NOTHING;

-- ---------------------------------------------------------------------
-- Seed: Sosyal Medya (1:1, 4:5, 9:16)
-- ---------------------------------------------------------------------
INSERT INTO templates (category_id, key, label, preview_image_url, aspect_ratio, scene_prompt_vars, requires_model_presentation, sort_order)
SELECT id, 'instagram_post_1_1', 'Instagram Post',
       'https://cdn.kuyumcuaistudio.com/templates/instagram_post.jpg', '1:1',
       '{"scene": "clean minimal backdrop with brand accent color", "lighting": "soft studio lighting", "camera_angle": "45 degree close-up macro", "style": "social media campaign", "mood": "vibrant, eye-catching"}',
       FALSE, 1
FROM template_categories WHERE key = 'social_media'
ON CONFLICT (key) DO NOTHING;

INSERT INTO templates (category_id, key, label, preview_image_url, aspect_ratio, scene_prompt_vars, requires_model_presentation, sort_order)
SELECT id, 'catalog_4_5', 'Katalog Görseli',
       'https://cdn.kuyumcuaistudio.com/templates/catalog_4_5.jpg', '4:5',
       '{"scene": "clean e-commerce backdrop", "lighting": "soft even studio lighting", "camera_angle": "front-facing macro", "style": "minimal e-commerce catalog", "mood": "clean, professional"}',
       FALSE, 2
FROM template_categories WHERE key = 'social_media'
ON CONFLICT (key) DO NOTHING;

INSERT INTO templates (category_id, key, label, preview_image_url, aspect_ratio, scene_prompt_vars, requires_model_presentation, sort_order)
SELECT id, 'instagram_story_9_16', 'Instagram Story',
       'https://cdn.kuyumcuaistudio.com/templates/instagram_story.jpg', '9:16',
       '{"scene": "vertical clean backdrop with negative space for text overlay", "lighting": "soft studio lighting", "camera_angle": "close-up macro", "style": "social media campaign", "mood": "vibrant, modern"}',
       FALSE, 3
FROM template_categories WHERE key = 'social_media'
ON CONFLICT (key) DO NOTHING;