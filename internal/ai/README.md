# AI Module Documentation

## Overview

Bu modul, kuyumcu ürünlerinin AI ile görsel üretimi, referans analizi, segmentasyonu ve tamamlama (compositing) işlemlerini yönetir. **Compositing-first yaklaşımı** kullanarak, orijinal takıyı korurken sadece arka plan ve ışığı değiştirir.

### Temel Özellikler

- ✅ **Vision Model Entegrasyonu** (Claude Vision, GPT-4o)
- ✅ **Image Generation** (Flux Pro, Stable Diffusion 3)
- ✅ **SAM 2 Segmentasyonu** (Takıyı arka plandan ayırma)
- ✅ **Ürün Koruma** (Taş sayısı, metal rengi, form korunması)
- ✅ **Kredi Sistemi** (İşlem başı kredi tüketimi)
- ✅ **Retry Mekanizması** (Otomatik yeniden deneme)
- ✅ **Prompt Engineering** (Kuyumcu terminolojisine uygun)

---

## Dosya Yapısı

```
internal/ai/
├── types.go                 # Tüm veri tiplerini tanımlar
├── config.go               # Konfigürasyon ve provider arayüzleri
├── errors.go               # Hata yönetimi
├── credits.go              # Kredi sistemi
├── prompt.go               # Prompt engineering ve template'ler
├── analyzer.go             # Vision model analizi
├── segmentation.go         # SAM 2 segmentasyonu
├── service.go              # Ana orchestration servisi
├── providers.go            # Fal.ai ve Replicate entegrasyonu
├── generation.go           # Flux Pro ve SD3 generation
└── README.md              # Bu dosya
```

---

## 1. Türler (types.go)

### Vision Analysis

```go
// Işık analizi
type LightingAnalysis struct {
    Type           string  // "directional", "soft", "rim", etc
    Direction      string  // "top", "left", "right", etc
    Intensity      string  // "soft", "medium", "hard"
    ColorTemp      string  // "warm", "neutral", "cool"
}

// Arka plan analizi
type BackgroundAnalysis struct {
    Type          string  // "plain", "marble", "velvet", etc
    Texture       string  // "smooth", "matte", "glossy"
    Blur          string  // "none", "soft", "heavy"
}

// Referans görsel analiz sonucu
type ReferenceImageAnalysisResult struct {
    Lighting        *LightingAnalysis
    Background      *BackgroundAnalysis
    Camera          *CameraAnalysis
    ColorPalette    *ColorPaletteAnalysis
    ConfidenceScore float32
}
```

### Takı Özelikleri

```go
type JewelryCharacteristics struct {
    ProductType     string  // "ring", "necklace", "bracelet", etc
    MetalColor      string  // "yellow_gold", "white_gold", "rose_gold"
    StoneCount      int     // Taş sayısı (KORUNMALI)
    StoneType       string  // "diamond", "zircon", "pearl"
    MetalBrightness string  // "glossy", "matte", "satin"
    DesignType      string  // "solitaire", "baguette", "halo"
}
```

### Segmentasyon

```go
type SegmentationResult struct {
    MaskImageURL       string  // PNG mask
    CleanJewelryURL    string  // Arka plan temizlenmiş
    SegmentationScore  float32 // 0-1 confidence
    BoundingBox        [4]int  // [x, y, width, height]
    ModelVersion       string  // "SAM 2.0", "SAM 2.1"
}
```

### Tamamlama (Compositing)

```go
type CompositingRequest struct {
    ProductMaskURL      string  // SAM 2 maskesi
    OriginalProductURL  string  // Orijinal takı
    GeneratedSceneURL   string  // AI üreteç sahne
    RelightingStyle     string  // "soft", "dramatic", "studio"
    Quality             string  // "standard", "high", "ultra"
}

type CompositingResult struct {
    CompositeImageURL   string
    BlendQualityScore   float32 // 0-1
    EdgeArtifactScore   float32 // 0-1 (düşük iyi)
}
```

---

## 2. Konfigürasyon (config.go)

### Ayar Yapısı

```go
type Config struct {
    // Vision Model
    VisionProvider  ProviderType      // ProviderTypeFalAI
    VisionConfig    *ProviderConfig
    VisionModelID   string            // "claude-vision"

    // Generation
    GenerationProvider  ProviderType
    GenerationConfig    *ProviderConfig
    GenerationModelID   string        // "flux-pro"

    // Segmentation
    SegmentationProvider ProviderType
    SegmentationConfig   *ProviderConfig
    SegmentationModelID  string       // "sam2"

    // Storage
    S3Bucket    string
    S3Region    string
    S3Endpoint  string  // R2 için custom

    // Credits
    AnalysisCreditCost      int
    GenerationCreditCost    int
    SegmentationCreditCost  int
    CompositingCreditCost   int
}
```

### Provider Arayüzleri

```go
type VisionProvider interface {
    AnalyzeImage(ctx context.Context, imageURL string) (json.RawMessage, error)
    AnalyzeReferenceImage(ctx context.Context, imageURL string) (*ReferenceImageAnalysisResult, error)
    ExtractJewelryCharacteristics(ctx context.Context, imageURL string) (*JewelryCharacteristics, error)
}

type GenerationProvider interface {
    GenerateImage(ctx context.Context, prompt string, params map[string]interface{}) (json.RawMessage, error)
    CompositeImage(ctx context.Context, req *CompositingRequest) (*CompositingResult, error)
    GenerateWithCompositing(ctx context.Context, productMask, productURL, prompt string) (*CompositingResult, error)
}

type SegmentationProvider interface {
    SegmentImage(ctx context.Context, imageURL string) (*SegmentationResult, error)
    SegmentJewelry(ctx context.Context, imageURL string, params map[string]interface{}) (*SegmentationResult, error)
}
```

---

## 3. Hata Yönetimi (errors.go)

### Predefined Errors

```go
var ErrInsufficientCredits   // 402 - Kredi yetersiz
var ErrProviderRateLimit      // 429 - Hız sınırı
var ErrProcessingTimeout      // 408 - Zaman aşımı
var ErrImageProcessingFailed  // 500 - İşlem başarısız

// Kontrol metodları
func IsRetryable(err error) bool
func IsFatal(err error) bool
func GetAIError(err error) *AIError
```

---

## 4. Kredi Sistemi (credits.go)

### Kredi Maliyetleri

| İşlem | Kredi |
|-------|------|
| Vision analiz | 50 |
| Referans analiz | 75 |
| Takı özelliği | 40 |
| Görsel üretimi | 200-350 |
| Segmentasyon | 100 |
| Tamamlama (Compositing) | 150 |

### Kullanım

```go
calculator := NewDefaultCreditCalculator()

// Maliyet hesapla
cost := calculator.CalculateGenerationCost("flux-pro", 4, "1024x1024")

// Kredi kontrolü
limiter := NewCreditLimiter(calculator, creditService)
canAfford, err := limiter.CanAfford(ctx, companyID, cost)
```

---

## 5. Prompt Engineering (prompt.go)

### Prompt Builder

```go
builder := NewPromptBuilder().
    WithCharacteristics(jewelry).
    WithReferenceAnalysis(refAnalysis)

template, err := builder.Build()
```

### Template Varyasyonları

```go
tvb := NewTemplateVariationBuilder(baseTemplate)

luxury := tvb.BuildLuxury()        // Premium presentation
minimalist := tvb.BuildMinimalist()  // Clean & simple
elegant := tvb.BuildElegant()      // Refined aesthetic
contemporary := tvb.BuildContemporary() // Modern style
romantic := tvb.BuildRomantic()    // Dreamy feel
```

### Ürün Koruma Kuralları

```
NEVER modify the jewelry itself:
- Preserve: Stone count, Metal color, Design
- Only modify: Background, Lighting, Composition

Negative Prompt:
- "no missing stones, no altered metal color, no design changes"
- "distorted jewelry, incorrect reflections"
```

---

## 6. Vision Model Analizi (analyzer.go)

### Referans Görsel Analizi

```go
analyzer := NewImageAnalyzerService(provider, config, creditService)

result, err := analyzer.AnalyzeReferenceImage(ctx, imageURL, companyID)
// Result: Lighting, Background, Camera, ColorPalette análizi
```

### Takı Özelliği Çıkarma

```go
chars, err := analyzer.ExtractJewelryCharacteristics(ctx, imageURL, companyID)
// Result: Stone count, Metal color, Design type, etc
```

### Batch Analiz

```go
batchReq := &BatchAnalysisRequest{
    ImageURLs: []string{...},
    AnalysisType: "reference_analysis",
    CompanyID: "company_123",
}

result := analyzer.AnalyzeBatch(ctx, batchReq)
// Result: Success count, Failed count, Total credits used
```

---

## 7. Segmentasyon (segmentation.go)

### SAM 2 Segmentasyonu

```go
segSvc := NewSegmentationService(provider, config, creditService)

result, err := segSvc.SegmentJewelry(ctx, imageURL, companyID, params)
// Result: PNG mask, Clean jewelry URL, Confidence score
```

### Kalite Kontrol

```go
validator := NewQualityValidator()
isValid, issues := validator.ValidateSegmentationResult(result)

if !isValid {
    for _, issue := range issues {
        log.Warn(issue) // e.g., "Confidence score too low"
    }
}
```

---

## 8. Ana Servis (service.go)

### Full Pipeline

```go
aiService := NewAIService(config, visionProvider, genProvider, segProvider, creditSvc, logger)

req := &FullPipelineRequest{
    ProductImageURL: "s3://bucket/product.jpg",
    ReferenceImageURL: "s3://bucket/reference.jpg",
    ProductCharacteristics: &JewelryCharacteristics{...},
    CompanyID: "company_123",
    DesiredStyle: "luxury",
    OutputCount: 4,
    Quality: "high",
}

result := aiService.ExecuteFullPipeline(ctx, req)
```

### Pipeline Adımları

```
1. Referans görsel analizi → Styling insights
2. Ürün segmentasyonu → PNG mask + clean image
3. Prompt engineering → Product-preservation prompt
4. AI görsel üretimi → Background + lighting generated
5. Compositing → Product merged with scene
```

---

## 9. Provider Entegrasyonları (providers.go & generation.go)

### Fal.ai (Vision + Generation)

```go
// Vision Provider
visionProvider := NewFalAIProvider(apiKey, "claude-vision", config)
result, err := visionProvider.AnalyzeReferenceImage(ctx, imageURL)

// Generation Provider
genProvider := NewFluxProGenerationProvider(apiKey, config)
images, err := genProvider.GenerateImage(ctx, prompt, params)
```

### Replicate (Alternative Generation)

```go
replicateProvider := NewReplicateProvider(apiKey, "stable-diffusion-3", config)
images, err := replicateProvider.GenerateImage(ctx, prompt, params)
```

### SAM 2 (Segmentation)

```go
segProvider := NewSAM2SegmentationProvider(apiKey, config)
result, err := segProvider.SegmentJewelry(ctx, imageURL, params)
```

---

## 10. Compositing-First Yaklaşımı

### Felsefe

**Orijinal takı hiçbir zaman değiştirilmez.** Sadece:
1. **Arka Plan**: Yeni sahne oluştur
2. **Işık**: Yeni aydınlatma uygula
3. **Yansımalar**: Otomatik ayarlama

### Implementasyon

```go
result, err := genProvider.GenerateWithCompositing(ctx,
    productMask,     // SAM 2'den
    productURL,      // Orijinal takı
    prompt,          // Ürün koruması kurallarıyla
)

// Result:
// - Takı: Orijinal olarak kalır ✅
// - Arka plan: Tamamen yeni oluşturulur ✅
// - Işık: Otomatik tutarlı hale getirilir ✅
```

---

## 11. Hata Yönetimi & Retry

### Automatic Retry

```go
policy := &RetryPolicy{
    MaxRetries: 3,
    InitialBackoff: 1 * time.Second,
    MaxBackoff: 1 * time.Minute,
    BackoffExponent: 2.0,
}

// Exponential backoff:
// Attempt 1: Fail
// Attempt 2: Wait 1s, Retry
// Attempt 3: Wait 2s, Retry
// Attempt 4: Wait 4s, Retry
// Failed after 7 seconds
```

### Retry Koşulları

```go
// Yeniden denenebilir hatalar:
- PROVIDER_RATE_LIMIT
- PROVIDER_UNREACHABLE
- REQUEST_TIMEOUT

// Ölümcül hatalar (yeniden denenmez):
- INVALID_API_KEY
- INSUFFICIENT_CREDITS
- INVALID_IMAGE_URL
```

---

## 12. Örnek Kullanım

### Minimal Setup

```go
package main

import (
    "context"
    "github.com/your-org/kuyumcu/internal/ai"
)

func main() {
    config := &ai.Config{
        VisionProvider: ai.ProviderTypeFalAI,
        VisionConfig: &ai.ProviderConfig{
            APIKey: os.Getenv("FAL_AI_KEY"),
        },
        GenerationProvider: ai.ProviderTypeFalAI,
        GenerationModelID: "flux-pro",
        SegmentationProvider: ai.ProviderTypeFalAI,
        SegmentationModelID: "sam2",
    }

    visionProvider := ai.NewFalAIProvider(
        os.Getenv("FAL_AI_KEY"),
        "claude-vision",
        config.VisionConfig,
    )

    genProvider := ai.NewFluxProGenerationProvider(
        os.Getenv("FAL_AI_KEY"),
        config.GenerationConfig,
    )

    segProvider := ai.NewSAM2SegmentationProvider(
        os.Getenv("FAL_AI_KEY"),
        config.SegmentationConfig,
    )

    aiService, _ := ai.NewAIService(
        config,
        visionProvider,
        genProvider,
        segProvider,
        creditService, // implementation required
        nil, // logger
    )

    // Full pipeline
    result := aiService.ExecuteFullPipeline(context.Background(), &ai.FullPipelineRequest{
        ProductImageURL: "https://s3.example.com/ring.jpg",
        ReferenceImageURL: "https://s3.example.com/style-ref.jpg",
        ProductCharacteristics: &ai.JewelryCharacteristics{
            ProductType: "ring",
            MetalColor: "rose_gold",
            StoneCount: 1,
            StoneType: "diamond",
        },
        CompanyID: "company_123",
        DesiredStyle: "luxury",
        OutputCount: 4,
        Quality: "high",
    })

    fmt.Printf("Status: %s, Images: %d, Credits Used: %d\n",
        result.Status,
        len(result.GeneratedImages),
        result.TotalCreditsUsed,
    )
}
```

---

## 13. Veritabanı İntegrasyonu

### reference_analyses Tablosu

```sql
extracted_metadata JSONB:
{
    "scene": "professional_studio",
    "lighting": {
        "type": "three_point",
        "direction": "top_left",
        "color_temp": "warm"
    },
    "background": {
        "type": "marble",
        "blur": "soft"
    },
    "color_palette": {
        "mood": "luxury",
        "saturation": "vibrant"
    }
}
```

### products Tablosu

```sql
ai_metadata JSONB:
{
    "stone_count": 1,
    "metal_brightness": "glossy",
    "design_confidence": 0.95,
    "extracted_at": "2025-01-15T10:30:00Z"
}
```

---

## 14. Environment Variables

```bash
# Fal.ai
FAL_AI_API_KEY=<your-api-key>

# Replicate
REPLICATE_API_KEY=<your-api-key>

# S3/R2
AWS_ACCESS_KEY_ID=<key>
AWS_SECRET_ACCESS_KEY=<secret>
S3_BUCKET=kuyumcu-assets
S3_REGION=us-east-1

# Optional: R2
R2_ENDPOINT=https://<account-id>.r2.cloudflarestorage.com

# Credits
CREDIT_COST_ANALYSIS=50
CREDIT_COST_GENERATION=200
CREDIT_COST_SEGMENTATION=100
CREDIT_COST_COMPOSITING=150
```

---

## 15. Performance Optimizasyonları

### Caching

```go
aiService.EnableCache(24 * time.Hour)
// Analysis results cached for 24 hours
```

### Batch Processing

```go
// 4-8 görseli batch'te işle (indirimli)
batch := &ai.BatchRequest{
    Operations: []string{"analyze_reference", "segment_product"},
    ImageURLs: imageURLs,
    CompanyID: "company_123",
}

results := aiService.ExecuteBatch(ctx, batch)
```

### Throttling

```go
config.VisionConfig.ThrottleConfig = &ai.ThrottleConfig{
    RequestsPerMinute: 60,
    BurstSize: 5,
}
```

---

## 16. Monitoring & Logging

### Request Metadata

```go
meta := analyzer.GetLastRequestMetadata()

fmt.Printf("Request: %s\n", meta.RequestID)
fmt.Printf("Duration: %v\n", meta.Duration)
fmt.Printf("Credits Used: %d\n", meta.CreditsUsed)
fmt.Printf("Status: %s\n", meta.Status)
```

### Batch Statistics

```go
result := analyzer.AnalyzeBatch(ctx, batchReq)

fmt.Printf("Success: %d/%d\n", result.SuccessfulRequests, result.TotalRequests)
fmt.Printf("Total Credits: %d\n", result.TotalCreditsUsed)
fmt.Printf("Total Time: %v\n", result.TotalDuration)
```

---

## 17. Testing

```go
// Mock Provider
mockGen := &ai.MockGenerationProvider{}
mockVision := &ai.MockVisionProvider{}

aiService, _ := ai.NewAIService(config, mockVision, mockGen, nil, nil, logger)

result := aiService.ExecuteFullPipeline(ctx, req)
// Test without real API calls
```

---

## 18. Gelecek Geliştirmeler

- [ ] Redis caching layer
- [ ] Webhook notifications
- [ ] WebSocket live progress
- [ ] Advanced quality scoring
- [ ] A/B testing framework
- [ ] User preference learning
- [ ] Multi-image campaigns
- [ ] Video generation support

---

## 19. Troubleshooting

| Problem | Solution |
|---------|----------|
| 429 Rate Limit | Reduce batch size, wait before retry |
| 402 Insufficient Credits | Purchase more credits or reduce quality |
| Segmentation quality low | Check image clarity, increase budget |
| Compositing artifacts | Use "high" quality, check mask precision |
| Timeout errors | Increase `config.Timeout`, use smaller images |

---

## Lisans & Support

Tüm kodlar **Kuyumcu SaaS Platformu** için geliştirilmiştir.

Destek için: support@kuyumcu.dev
