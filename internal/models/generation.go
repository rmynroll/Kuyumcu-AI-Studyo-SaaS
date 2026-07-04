package models

import (
	"encoding/json"
	"time"
)

// Üretim modu: hazır şablon mı, referans görsel mi
const (
	GenerationModeTemplate  = "template"
	GenerationModeReference = "reference"
)

// Üretim tipi
const (
	GenerationTypeImage = "image"
	GenerationTypeVideo = "video"
)

// Üretim durumları (worker pipeline aşamalarıyla birebir eşleşir)
const (
	GenerationStatusPending             = "pending"
	GenerationStatusQueued              = "queued"
	GenerationStatusProcessing          = "processing"
	GenerationStatusAnalyzingProduct    = "analyzing_product"
	GenerationStatusRemovingBackground  = "removing_background"
	GenerationStatusGeneratingScene     = "generating_scene"
	GenerationStatusCompositingProduct  = "compositing_product"
	GenerationStatusQualityChecking     = "quality_checking"
	GenerationStatusCompleted           = "completed"
	GenerationStatusFailed              = "failed"
	GenerationStatusCancelled           = "cancelled"
)

// GenerationOutput, üretilen tek bir görsel/video çıktısını temsil eder.
type GenerationOutput struct {
	FileURL      string `json:"file_url"`      // S3/R2 uyumlu URL
	ThumbnailURL string `json:"thumbnail_url"` // S3/R2 uyumlu URL
	Width        int    `json:"width,omitempty"`
	Height       int    `json:"height,omitempty"`
}

// GenerationInputParams, üretim isteğinin serbest biçimli parametrelerini tutar.
type GenerationInputParams struct {
	Scene       string `json:"scene,omitempty"`
	Lighting    string `json:"lighting,omitempty"`
	AspectRatio string `json:"aspect_ratio,omitempty"`
	OutputCount int    `json:"output_count,omitempty"`
	UseLogo     bool   `json:"use_logo,omitempty"`
}

// Generation, bir AI üretim işini (hazır şablon veya referans görsel modunda) temsil eder.
type Generation struct {
	ID                   string  `json:"id" db:"id"`
	CompanyID            string  `json:"company_id" db:"company_id"`
	UserID               *string `json:"user_id,omitempty" db:"user_id"`
	ProductID            *string `json:"product_id,omitempty" db:"product_id"`
	ReferenceAnalysisID  *string `json:"reference_analysis_id,omitempty" db:"reference_analysis_id"`

	GenerationMode string  `json:"generation_mode" db:"generation_mode"` // template, reference
	GenerationType string  `json:"generation_type" db:"generation_type"` // image, video
	TemplateID     *string `json:"template_id,omitempty" db:"template_id"`

	Status string `json:"status" db:"status"`

	Prompt         *string                `json:"prompt,omitempty" db:"prompt"`
	NegativePrompt *string                `json:"negative_prompt,omitempty" db:"negative_prompt"`
	InputParams    *GenerationInputParams `json:"input_params,omitempty" db:"input_params"`

	OutputURLs []GenerationOutput `json:"output_urls,omitempty" db:"output_urls"`

	CreditCost   int             `json:"credit_cost" db:"credit_cost"`
	ErrorMessage *string         `json:"error_message,omitempty" db:"error_message"`
	RawMetadata  json.RawMessage `json:"-" db:"-"` // gerektiğinde ham JSONB erişimi için

	StartedAt   *time.Time `json:"started_at,omitempty" db:"started_at"`
	CompletedAt *time.Time `json:"completed_at,omitempty" db:"completed_at"`
	CreatedAt   time.Time  `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time  `json:"updated_at" db:"updated_at"`
}
