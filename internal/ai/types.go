package ai

import (
	"encoding/json"
	"time"
)

// ProviderType, AI modellerini sağlayan hizmetin türünü tanımlar
type ProviderType string

const (
	ProviderTypeFalAI       ProviderType = "fal_ai"
	ProviderTypeReplicate   ProviderType = "replicate"
	ProviderTypeClaude      ProviderType = "claude"
	ProviderTypeOpenAI      ProviderType = "openai"
	ProviderTypeLocalPython ProviderType = "local_python"
)

// GenerationMode, görsel üretim modunu tanımlar
type GenerationMode string

const (
	GenerationModeTemplate  GenerationMode = "template"
	GenerationModeReference GenerationMode = "reference"
)

// =============================================================================
// VISION ANALYZER TYPES
// =============================================================================

// LightingAnalysis, referans görselden çıkarılan ışık bilgisini tutar
type LightingAnalysis struct {
	Type       string    `json:"type"`        // "directional", "soft", "rim", "three_point", "studio"
	Direction  string    `json:"direction"`   // "top", "left", "right", "bottom", "frontal"
	Intensity  string    `json:"intensity"`   // "soft", "medium", "hard"
	ColorTemp  string    `json:"color_temp"` // "warm", "neutral", "cool"
	Ratio      string    `json:"ratio"`      // "1:1", "2:1", "3:1", etc
	HighlightColor string `json:"highlight_color"` // hex color
	ShadowColor    string `json:"shadow_color"`    // hex color
}

// BackgroundAnalysis, arka plan karakteristiğini tutar
type BackgroundAnalysis struct {
	Type            string   `json:"type"`              // "plain", "marble", "velvet", "bokeh", "gradient", "textured"
	Color           string   `json:"color"`            // dominant hex color
	Texture         string   `json:"texture"`          // "smooth", "matte", "glossy", "rough"
	Blur            string   `json:"blur"`             // "none", "soft", "heavy"
	Colors          []string `json:"colors,omitempty"` // dominant colors
	MaterialGuess   string   `json:"material_guess"`   // velvet, marble, fabric, etc
}

// CameraAnalysis, kamera açısı ve çerçevelemeyi tutar
type CameraAnalysis struct {
	Angle          string `json:"angle"`           // "frontal", "45_degree", "macro", "profile", "3_4_view"
	MacroDistance  string `json:"macro_distance"`  // "very_close", "close", "medium", "far"
	Aperture       string `json:"aperture"`        // "shallow", "medium", "deep"
	FocusArea      string `json:"focus_area"`      // "center", "jewelry", "detail"
	Zoom           string `json:"zoom"`            // "wide", "normal", "telephoto"
	PerspectiveDistortion string `json:"perspective_distortion"` // "minimal", "moderate", "high"
}

// ColorPaletteAnalysis, renk paletini tutar
type ColorPaletteAnalysis struct {
	DominantColor   string   `json:"dominant_color"`
	SecondaryColors []string `json:"secondary_colors"`
	Mood            string   `json:"mood"` // "luxury", "romantic", "professional", "artistic", "minimalist"
	Saturation      string   `json:"saturation"` // "desaturated", "natural", "vibrant"
	Contrast        string   `json:"contrast"`   // "low", "medium", "high"
	WarmthLevel     string   `json:"warmth_level"` // "cool", "neutral", "warm"
}

// ReferenceImageAnalysisResult, referans görsel analizinin tam sonucu
type ReferenceImageAnalysisResult struct {
	ImageURL        string                  `json:"image_url"`
	Lighting        *LightingAnalysis       `json:"lighting,omitempty"`
	Background      *BackgroundAnalysis     `json:"background,omitempty"`
	Camera          *CameraAnalysis         `json:"camera,omitempty"`
	ColorPalette    *ColorPaletteAnalysis   `json:"color_palette,omitempty"`
	AnalysisPrompt  string                  `json:"analysis_prompt"` // Extracted prompt
	ConfidenceScore float32                 `json:"confidence_score"`
	AnalyzedAt      time.Time               `json:"analyzed_at"`
}

// =============================================================================
// PRODUCT PRESERVATION TYPES
// =============================================================================

// JewelryCharacteristics, takının korunması gereken özelliklerini tutar
type JewelryCharacteristics struct {
	ProductType      string   `json:"product_type"`       // ring, necklace, bracelet, earring, set
	MetalColor       string   `json:"metal_color"`        // yellow_gold, white_gold, rose_gold, silver
	StoneCount       int      `json:"stone_count"`        // taş sayısı
	StoneType        string   `json:"stone_type"`         // diamond, zircon, pearl, colored_stone, none
	StoneColors      []string `json:"stone_colors"`       // taş renkleri
	MetalBrightness  string   `json:"metal_brightness"`   // glossy, matte, satin
	DesignType       string   `json:"design_type"`        // solitaire, baguette, halo, pave, etc
	SizeEstimate     string   `json:"size_estimate"`      // small, medium, large, statement
	MainFocusArea    string   `json:"main_focus_area"`    // center_stone, band, overall
}

// PromptTemplate, dinamik prompt şablonunu tutar
type PromptTemplate struct {
	BasePrompt        string                 `json:"base_prompt"`
	JewelryDetails    *JewelryCharacteristics `json:"jewelry_details,omitempty"`
	StyleModifiers    []string               `json:"style_modifiers"`
	NegativePrompt    string                 `json:"negative_prompt"`
	ContextualNotes   string                 `json:"contextual_notes"`
	Complexity        int                    `json:"complexity"` // 1-10
	TemplateVersion   string                 `json:"template_version"`
}

// =============================================================================
// SEGMENTATION TYPES
// =============================================================================

// SegmentationResult, SAM 2 segmentasyonunun sonucunu tutar
type SegmentationResult struct {
	MaskImageURL       string    `json:"mask_image_url"`         // PNG mask
	CleanJewelryURL    string    `json:"clean_jewelry_url"`      // Arka plan temizlenmiş takı
	InpaintingMaskURL  string    `json:"inpainting_mask_url"`    // Dar bantlı inpainting maskesi (opsiyonel)
	SegmentationScore  float32   `json:"segmentation_score"`    // 0-1 confidence
	BoundingBox        [4]int    `json:"bounding_box"`          // [x, y, width, height]
	MaskPixelArea      int       `json:"mask_pixel_area"`       // Mask'ın pixel alanı
	ProcessedAt        time.Time `json:"processed_at"`
	ModelVersion       string    `json:"model_version"`         // SAM 2.0, SAM 2.1, etc
}

// =============================================================================
// GENERATION & COMPOSITING TYPES
// =============================================================================

// CompositingRequest, tamamlama isteğini tutar
type CompositingRequest struct {
	ProductMaskURL      string                 `json:"product_mask_url"`      // SAM 2 maskesi
	OriginalProductURL  string                 `json:"original_product_url"`  // Orijinal takı
	GeneratedSceneURL   string                 `json:"generated_scene_url"`   // AI üreteç tarafından oluşturulan sahne
	RelightingStyle     string                 `json:"relighting_style"`      // "soft", "dramatic", "studio", "natural"
	OutputFormat        string                 `json:"output_format"`         // "png", "jpg"
	Quality             string                 `json:"quality"`               // "standard", "high", "ultra"
}

// CompositingResult, tamamlama sonucunu tutar
type CompositingResult struct {
	CompositeImageURL   string    `json:"composite_image_url"`
	CompositeThumbURL   string    `json:"composite_thumb_url"`
	BlendQualityScore   float32   `json:"blend_quality_score"` // 0-1
	EdgeArtifactScore   float32   `json:"edge_artifact_score"` // 0-1 (lower is better)
	LightingConsistency float32   `json:"lighting_consistency"` // 0-1
	ProcessedAt         time.Time `json:"processed_at"`
}

// =============================================================================
// API RESPONSE TYPES
// =============================================================================

// APIResponse, API sağlayıcılarından dönen yanıtı tutarız
type APIResponse struct {
	RequestID      string          `json:"request_id,omitempty"`
	Status         string          `json:"status"`
	Output         json.RawMessage `json:"output,omitempty"`
	Error          string          `json:"error,omitempty"`
	ErrorCode      string          `json:"error_code,omitempty"`
	EstimatedTime  int             `json:"estimated_time,omitempty"` // seconds
	CompletionTime time.Time       `json:"completion_time,omitempty"`
}

// =============================================================================
// RETRY & THROTTLE TYPES
// =============================================================================

// RetryPolicy, yeniden deneme politikasını tanımlar
type RetryPolicy struct {
	MaxRetries      int
	InitialBackoff  time.Duration
	MaxBackoff      time.Duration
	BackoffExponent float64
}

// ThrottleConfig, hız sınırlaması konfigürasyonunu tutar
type ThrottleConfig struct {
	RequestsPerMinute int
	BurstSize        int
	CreditCost       int
}

// RequestMetadata, her istek için meta veri toplar
type RequestMetadata struct {
	RequestID      string
	CompanyID      string
	UserID         string
	CreatedAt      time.Time
	StartedAt      time.Time
	CompletedAt    time.Time
	CreditsUsed    int
	ProviderUsed   ProviderType
	Status         string
	ErrorMessage   string
	RetryCount     int
	Duration       time.Duration
}
