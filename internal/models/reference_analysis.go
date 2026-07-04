package models

import "time"

const (
	ReferenceAnalysisStatusPending   = "pending"
	ReferenceAnalysisStatusCompleted = "completed"
	ReferenceAnalysisStatusFailed    = "failed"
)

// ReferenceAnalysisMetadata, referans görselden çıkarılan görsel dil bilgisini tutar.
type ReferenceAnalysisMetadata struct {
	Scene             string   `json:"scene,omitempty"`
	Lighting          string   `json:"lighting,omitempty"`
	CameraAngle       string   `json:"camera_angle,omitempty"`
	Composition       string   `json:"composition,omitempty"`
	Style             string   `json:"style,omitempty"`
	ColorPalette      []string `json:"color_palette,omitempty"`
	Mood              string   `json:"mood,omitempty"`
	PreservationRules []string `json:"preservation_rules,omitempty"`
}

// ReferenceAnalysis, kullanıcının "şunun gibi olsun" dediği referans
// görselden çıkarılan stil analizini temsil eder.
type ReferenceAnalysis struct {
	ID        string  `json:"id" db:"id"`
	CompanyID string  `json:"company_id" db:"company_id"`
	UserID    *string `json:"user_id,omitempty" db:"user_id"`

	ReferenceImageURL string `json:"reference_image_url" db:"reference_image_url"` // S3/R2 uyumlu URL

	ExtractedPrompt   *string                    `json:"extracted_prompt,omitempty" db:"extracted_prompt"`
	ExtractedMetadata *ReferenceAnalysisMetadata `json:"extracted_metadata,omitempty" db:"extracted_metadata"`

	Status       string  `json:"status" db:"status"` // pending, completed, failed
	ErrorMessage *string `json:"error_message,omitempty" db:"error_message"`

	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}
