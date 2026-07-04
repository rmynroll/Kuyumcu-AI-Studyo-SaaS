package ai

import (
	"context"
	"encoding/json"
	"time"
)

// =============================================================================
// PROVIDER CONFIG TYPES
// =============================================================================

// ProviderConfig, bir AI provider için ayar sınıfını tutar
type ProviderConfig struct {
	Type              ProviderType
	APIKey            string
	BaseURL           string
	Timeout           time.Duration
	RateLimit         int // requests per minute
	MaxConcurrency    int
	EnableCaching     bool
	CacheTTL          time.Duration
	RetryPolicy       *RetryPolicy
	ThrottleConfig    *ThrottleConfig
}

// Config, tüm AI modülü ayarlarını tutar
type Config struct {
	// Vision Model
	VisionProvider   ProviderType
	VisionConfig     *ProviderConfig
	VisionModelID    string // "claude-vision", "gpt-4-vision", etc

	// Image Generation (Compositing)
	GenerationProvider ProviderType
	GenerationConfig   *ProviderConfig
	GenerationModelID  string // "flux-pro", "stable-diffusion-3", etc

	// Segmentation
	SegmentationProvider ProviderType
	SegmentationConfig   *ProviderConfig
	SegmentationModelID  string // "sam2", "mobile-sam", etc

	// Storage
	S3Bucket          string
	S3Region          string
	S3AccessKey       string
	S3SecretKey       string
	S3Endpoint        string // R2 için custom endpoint

	// Credit System
	AnalysisCreditCost      int // Vision analizi için kredi
	GenerationCreditCost    int // Image generation için kredi
	SegmentationCreditCost  int // Segmentasyon için kredi
	CompositingCreditCost   int // Compositing için kredi

	// Logging
	LogLevel          string
	EnableDetailedLogging bool
}

// DefaultRetryPolicy, varsayılan yeniden deneme politikasını döndürür
func DefaultRetryPolicy() *RetryPolicy {
	return &RetryPolicy{
		MaxRetries:      3,
		InitialBackoff:  time.Second,
		MaxBackoff:      time.Minute,
		BackoffExponent: 2.0,
	}
}

// =============================================================================
// PROVIDER INTERFACE
// =============================================================================

// Provider, bir AI modeli sağlayıcı için arayüzü tanımlar
type Provider interface {
	// Name, provider'ın adını döndürür
	Name() string

	// Ping, provider'ın erişilebilir olup olmadığını kontrol eder
	Ping(ctx context.Context) error

	// GetCreditCost, belirli bir işlem için kredi maliyetini döndürür
	GetCreditCost(operationType string) int

	// Close, provider bağlantısını kapatır
	Close() error
}

// VisionProvider, Vision model işlemlerini yapar
type VisionProvider interface {
	Provider

	// AnalyzeImage, bir görsel için vision analizi yapar
	AnalyzeImage(ctx context.Context, imageURL string, analysisType string) (json.RawMessage, error)

	// AnalyzeReferenceImage, referans görsel analizi yapar
	AnalyzeReferenceImage(ctx context.Context, imageURL string) (*ReferenceImageAnalysisResult, error)

	// ExtractJewelryCharacteristics, takının özelliklerini çıkarır
	ExtractJewelryCharacteristics(ctx context.Context, imageURL string) (*JewelryCharacteristics, error)
}

// GenerationProvider, Image generation işlemlerini yapar
type GenerationProvider interface {
	Provider

	// GenerateImage, prompt'a göre görsel oluşturur
	GenerateImage(ctx context.Context, prompt string, params map[string]interface{}) (json.RawMessage, error)

	// CompositeImage, tamamlama (compositing) işlemini yapar
	CompositeImage(ctx context.Context, req *CompositingRequest) (*CompositingResult, error)

	// GenerateWithCompositing, compositing-first yaklaşımıyla görsel oluşturur
	GenerateWithCompositing(ctx context.Context, productMask, productURL, prompt string) (*CompositingResult, error)
}

// SegmentationProvider, görsel segmentasyon işlemlerini yapar
type SegmentationProvider interface {
	Provider

	// SegmentImage, görsel için segmentasyon maskesi oluşturur
	SegmentImage(ctx context.Context, imageURL string) (*SegmentationResult, error)

	// SegmentJewelry, takı segmentasyonu (SAM 2 optimized)
	SegmentJewelry(ctx context.Context, imageURL string, params map[string]interface{}) (*SegmentationResult, error)
}

// =============================================================================
// PROVIDER FACTORY
// =============================================================================

// ProviderFactory, provider oluşturmak için fabrika arayüzü
type ProviderFactory interface {
	// CreateVisionProvider, vision provider oluşturur
	CreateVisionProvider(config *ProviderConfig) (VisionProvider, error)

	// CreateGenerationProvider, generation provider oluşturur
	CreateGenerationProvider(config *ProviderConfig) (GenerationProvider, error)

	// CreateSegmentationProvider, segmentasyon provider oluşturur
	CreateSegmentationProvider(config *ProviderConfig) (SegmentationProvider, error)
}
