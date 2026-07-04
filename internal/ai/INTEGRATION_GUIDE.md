# AI Module Integration Guide

Bu rehber, AI modülünün backend'e entegre edilmesi için adım adım talimatları içerir.

---

## Adım 1: Provider API Keys Alınması

### 1.1 Fal.ai (Vision + Generation)

1. https://www.fal.ai adresine git
2. "Sign Up" → "Free Tier" seç
3. Dashboard → API Key section'dan key al
4. Maksimum Fal.ai limit: 10 concurrent requests

**Faal.ai İyi Noktaları:**
- Claude Vision integration
- Flux Pro (en iyi kalite)
- SAM 2 segmentasyonu
- WebSocket streaming support

### 1.2 Replicate (Alternative Generation)

1. https://replicate.com adresine git
2. Account oluştur
3. Settings → API tokens
4. Token oluştur ve kopyala

**Replicate İyi Noktaları:**
- Stable Diffusion 3 (hızlı)
- Cost-effective
- REST + WebSocket API
- Model versioning

### 1.3 S3/R2 (Image Storage)

**AWS S3 için:**
```
1. AWS Console → IAM
2. User oluştur ve S3 permissions ver
3. Access Key + Secret Key al
```

**Cloudflare R2 için (önerilir - daha ucuz):**
```
1. Cloudflare Dashboard → R2
2. Bucket oluştur (kuyumcu-assets)
3. API Token oluştur
4. Endpoint: https://<account-id>.r2.cloudflarestorage.com
```

---

## Adım 2: Environment Configuration

### .env dosyası oluştur

```bash
# =====================
# FAL.AI CONFIG
# =====================
FAL_AI_API_KEY=<your-fal-ai-key>
FAL_AI_BASE_URL=https://api.fal.ai/v1
FAL_AI_VISION_MODEL=claude-vision
FAL_AI_GENERATION_MODEL=flux-pro

# =====================
# REPLICATE CONFIG
# =====================
REPLICATE_API_KEY=<your-replicate-key>
REPLICATE_BASE_URL=https://api.replicate.com/v1
REPLICATE_GENERATION_MODEL=stability-ai/stable-diffusion-3

# =====================
# S3/R2 CONFIG
# =====================
S3_BUCKET=kuyumcu-assets
S3_REGION=us-east-1

# AWS S3 (if using)
AWS_ACCESS_KEY_ID=<key>
AWS_SECRET_ACCESS_KEY=<secret>

# Cloudflare R2 (if using)
R2_ENDPOINT=https://<account-id>.r2.cloudflarestorage.com
R2_ACCESS_KEY_ID=<key>
R2_SECRET_ACCESS_KEY=<secret>

# =====================
# CREDIT SYSTEM
# =====================
CREDIT_COST_VISION_ANALYSIS=50
CREDIT_COST_REFERENCE_ANALYSIS=75
CREDIT_COST_JEWELRY_EXTRACTION=40
CREDIT_COST_GENERATION=200
CREDIT_COST_SEGMENTATION=100
CREDIT_COST_COMPOSITING=150

# =====================
# WORKER CONFIG
# =====================
WORKER_MAX_CONCURRENT_JOBS=5
WORKER_JOB_TIMEOUT=300s
WORKER_RETRY_ATTEMPTS=3
WORKER_ENABLE_NOTIFICATIONS=true

# =====================
# LOGGING
# =====================
LOG_LEVEL=info
AI_DETAILED_LOGGING=false
```

---

## Adım 3: Go Module Entegrasyonu

### go.mod'e dependencies ekle

```bash
go get github.com/your-org/kuyumcu@latest
```

### main.go'da initialize et

```go
package main

import (
    "os"
    "context"
    "github.com/your-org/kuyumcu/internal/ai"
)

func main() {
    // Load config from env
    config := &ai.Config{
        // Vision
        VisionProvider: ai.ProviderTypeFalAI,
        VisionConfig: &ai.ProviderConfig{
            APIKey: os.Getenv("FAL_AI_API_KEY"),
            BaseURL: os.Getenv("FAL_AI_BASE_URL"),
            Timeout: 30 * time.Second,
        },
        VisionModelID: os.Getenv("FAL_AI_VISION_MODEL"),

        // Generation
        GenerationProvider: ai.ProviderTypeFalAI,
        GenerationConfig: &ai.ProviderConfig{
            APIKey: os.Getenv("FAL_AI_API_KEY"),
            BaseURL: os.Getenv("FAL_AI_BASE_URL"),
            Timeout: 120 * time.Second,
        },
        GenerationModelID: os.Getenv("FAL_AI_GENERATION_MODEL"),

        // Segmentation
        SegmentationProvider: ai.ProviderTypeFalAI,
        SegmentationConfig: &ai.ProviderConfig{
            APIKey: os.Getenv("FAL_AI_API_KEY"),
        },
        SegmentationModelID: "sam2",

        // Storage
        S3Bucket: os.Getenv("S3_BUCKET"),
        S3Region: os.Getenv("S3_REGION"),
        S3Endpoint: os.Getenv("R2_ENDPOINT"),

        // Credits
        AnalysisCreditCost:    50,
        GenerationCreditCost:  200,
        SegmentationCreditCost: 100,
        CompositingCreditCost: 150,
    }

    // Create providers
    visionProvider := ai.NewFalAIProvider(
        os.Getenv("FAL_AI_API_KEY"),
        config.VisionModelID,
        config.VisionConfig,
    )

    genProvider := ai.NewFluxProGenerationProvider(
        os.Getenv("FAL_AI_API_KEY"),
        config.GenerationConfig,
    )

    segProvider := ai.NewSAM2SegmentationProvider(
        os.Getenv("FAL_AI_API_KEY"),
        config.SegmentationConfig,
    )

    // Create AI service
    aiService, err := ai.NewAIService(
        config,
        visionProvider,
        genProvider,
        segProvider,
        creditService, // implement this interface
        logger,        // implement or use NoOpLogger
    )
    if err != nil {
        panic(err)
    }

    // Start worker if needed
    workerConfig := &ai.WorkerConfig{
        MaxConcurrentJobs: 5,
        JobTimeout: 5 * time.Minute,
        RetryAttempts: 3,
    }
    
    executor := ai.NewWorkerJobExecutor(aiService, workerConfig)
    executor.Start(context.Background())
}
```

---

## Adım 4: HTTP Handler Yazma

### Örnek: Full Pipeline Handler

```go
package handlers

import (
    "encoding/json"
    "net/http"
    "github.com/your-org/kuyumcu/internal/ai"
)

type GenerateImageRequest struct {
    ProductImageURL string  `json:"product_image_url"`
    ReferenceImageURL string `json:"reference_image_url,omitempty"`
    ProductType string      `json:"product_type"` // ring, necklace, etc
    MetalColor string       `json:"metal_color"` // yellow_gold, white_gold, etc
    StoneCount int          `json:"stone_count"`
    DesiredStyle string     `json:"desired_style"` // luxury, minimalist, etc
    OutputCount int         `json:"output_count"`
    Quality string          `json:"quality"` // standard, high, ultra
}

func GenerateImageHandler(aiService *ai.AIService) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        var req GenerateImageRequest
        if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
            http.Error(w, "Invalid request", http.StatusBadRequest)
            return
        }

        // Extract company ID from auth context
        companyID := r.Context().Value("company_id").(string)

        // Create characteristics
        characteristics := &ai.JewelryCharacteristics{
            ProductType: req.ProductType,
            MetalColor: req.MetalColor,
            StoneCount: req.StoneCount,
            MainFocusArea: "center_stone",
        }

        // Create pipeline request
        pipelineReq := &ai.FullPipelineRequest{
            ProductImageURL: req.ProductImageURL,
            ReferenceImageURL: req.ReferenceImageURL,
            ProductCharacteristics: characteristics,
            CompanyID: companyID,
            DesiredStyle: req.DesiredStyle,
            OutputCount: req.OutputCount,
            Quality: req.Quality,
        }

        // Execute
        result := aiService.ExecuteFullPipeline(r.Context(), pipelineReq)

        // Return result
        w.Header().Set("Content-Type", "application/json")
        json.NewEncoder(w).Encode(result)
    }
}
```

### Router'a ekle

```go
package routes

import (
    "github.com/gorilla/mux"
    "github.com/your-org/kuyumcu/internal/ai"
    "github.com/your-org/kuyumcu/handlers"
)

func RegisterAIRoutes(router *mux.Router, aiService *ai.AIService) {
    // Image generation
    router.HandleFunc("/api/v1/generate-image", 
        handlers.GenerateImageHandler(aiService)).
        Methods("POST")

    // Reference analysis
    router.HandleFunc("/api/v1/analyze-reference",
        handlers.AnalyzeReferenceHandler(aiService)).
        Methods("POST")

    // Segmentation
    router.HandleFunc("/api/v1/segment-product",
        handlers.SegmentProductHandler(aiService)).
        Methods("POST")

    // Job status
    router.HandleFunc("/api/v1/generation-status/{jobId}",
        handlers.GetGenerationStatusHandler()).
        Methods("GET")
}
```

---

## Adım 5: Database Schema Updates

### Migration: Add AI metadata columns

```sql
-- reference_analyses tablosu zaten var, extracted_metadata JSONB kolonu olmalı
ALTER TABLE reference_analyses 
ADD COLUMN extracted_metadata JSONB DEFAULT '{}'::jsonb;

CREATE INDEX idx_reference_analyses_company_extracted 
ON reference_analyses USING GIN (extracted_metadata);

-- products tablosu AI metadata için
ALTER TABLE products
ADD COLUMN ai_metadata JSONB DEFAULT '{}'::jsonb,
ADD COLUMN clean_image_url TEXT,
ADD COLUMN mask_image_url TEXT;

-- Generation jobs için yeni tablo
CREATE TABLE IF NOT EXISTS generation_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES companies(id),
    user_id UUID REFERENCES users(id),
    product_id UUID REFERENCES products(id),
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    input_params JSONB,
    output_images TEXT[],
    total_credits_used INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT now(),
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    error_message TEXT
);

CREATE INDEX idx_generation_jobs_company ON generation_jobs(company_id);
CREATE INDEX idx_generation_jobs_status ON generation_jobs(status);
```

---

## Adım 6: Credit Service Implementation

### Örnek: Database-based credit service

```go
package services

import (
    "context"
    "fmt"
)

type DatabaseCreditService struct {
    db *sql.DB
}

func (cs *DatabaseCreditService) GetBalance(ctx context.Context, companyID string) (int, error) {
    var balance int
    err := cs.db.QueryRowContext(
        ctx,
        "SELECT credit_balance FROM companies WHERE id = $1",
        companyID,
    ).Scan(&balance)
    return balance, err
}

func (cs *DatabaseCreditService) Deduct(ctx context.Context, companyID string, amount int, operationType string) error {
    tx, err := cs.db.BeginTx(ctx, nil)
    if err != nil {
        return err
    }
    defer tx.Rollback()

    // Check balance
    var balance int
    err = tx.QueryRowContext(
        ctx,
        "SELECT credit_balance FROM companies WHERE id = $1 FOR UPDATE",
        companyID,
    ).Scan(&balance)
    if err != nil {
        return err
    }

    if balance < amount {
        return fmt.Errorf("insufficient credits: have %d, need %d", balance, amount)
    }

    // Deduct
    _, err = tx.ExecContext(
        ctx,
        "UPDATE companies SET credit_balance = credit_balance - $1 WHERE id = $2",
        amount,
        companyID,
    )
    if err != nil {
        return err
    }

    // Record operation
    _, err = tx.ExecContext(
        ctx,
        `INSERT INTO credit_operations (company_id, operation_type, credits_used, balance_before, balance_after)
         VALUES ($1, $2, $3, $4, $5)`,
        companyID,
        operationType,
        amount,
        balance,
        balance-amount,
    )
    if err != nil {
        return err
    }

    return tx.Commit().Err
}

func (cs *DatabaseCreditService) CanDeduct(ctx context.Context, companyID string, amount int) (bool, error) {
    var balance int
    err := cs.db.QueryRowContext(
        ctx,
        "SELECT credit_balance FROM companies WHERE id = $1",
        companyID,
    ).Scan(&balance)
    if err != nil {
        return false, err
    }
    return balance >= amount, nil
}

func (cs *DatabaseCreditService) Refund(ctx context.Context, companyID string, amount int, reason string) error {
    _, err := cs.db.ExecContext(
        ctx,
        `UPDATE companies SET credit_balance = credit_balance + $1 WHERE id = $2`,
        amount,
        companyID,
    )
    return err
}
```

---

## Adım 7: Testing

### Unit Test Örneği

```go
package ai_test

import (
    "context"
    "testing"
    "github.com/your-org/kuyumcu/internal/ai"
)

func TestPromptBuilder(t *testing.T) {
    builder := ai.NewPromptBuilder().
        WithCharacteristics(&ai.JewelryCharacteristics{
            ProductType: "ring",
            MetalColor: "rose_gold",
            StoneCount: 1,
            StoneType: "diamond",
            DesignType: "solitaire",
        })

    template, err := builder.Build()
    if err != nil {
        t.Fatalf("Expected no error, got %v", err)
    }

    if template == nil {
        t.Fatal("Expected template, got nil")
    }

    if template.BasePrompt == "" {
        t.Fatal("Expected non-empty base prompt")
    }

    if len(template.NegativePrompt) == 0 {
        t.Fatal("Expected non-empty negative prompt")
    }

    // Check preservation rules
    if !contains(template.NegativePrompt, "no missing stones") {
        t.Fatal("Expected stone preservation rule in negative prompt")
    }
}

func TestCreditCalculator(t *testing.T) {
    calc := ai.NewDefaultCreditCalculator()

    // Test generation cost
    cost := calc.CalculateGenerationCost("flux-pro", 4, "1024x1024")
    if cost <= 0 {
        t.Fatalf("Expected positive cost, got %d", cost)
    }

    // Test batch discount
    baseCost := calc.GetBaseCost("image_generation")
    batchCost := calc.CalculateGenerationCost("flux-pro", 8, "1024x1024")
    
    if batchCost <= baseCost {
        t.Fatal("Expected batch cost to be greater than base cost")
    }
}

func TestMockProviders(t *testing.T) {
    ctx := context.Background()
    
    mockGen := &ai.MockGenerationProvider{}
    result, err := mockGen.CompositeImage(ctx, &ai.CompositingRequest{})
    
    if err != nil {
        t.Fatalf("Expected no error, got %v", err)
    }
    
    if result == nil {
        t.Fatal("Expected result, got nil")
    }
}

func contains(str, substr string) bool {
    return strings.Contains(str, substr)
}
```

---

## Adım 8: Deployment Checklist

- [ ] Environment variables konfigüre edildi
- [ ] Database migrations çalıştırıldı
- [ ] API credentials test edildi (ping)
- [ ] Credit service implementasyonu tamamlandı
- [ ] HTTP handlers yazıldı ve tested
- [ ] Logging konfigüre edildi
- [ ] Error handling kontrol edildi
- [ ] Load testing yapıldı
- [ ] Security audit tamamlandı
- [ ] Monitoring alertler kuruldu

---

## Adım 9: Monitoring & Observability

### Prometheus Metrics (optional)

```go
var (
    generationDuration = prometheus.NewHistogramVec(
        prometheus.HistogramOpts{
            Name: "ai_generation_duration_seconds",
            Help: "Time taken for image generation",
        },
        []string{"quality", "status"},
    )

    segmentationConfidence = prometheus.NewHistogramVec(
        prometheus.HistogramOpts{
            Name: "ai_segmentation_confidence",
            Help: "Segmentation confidence score",
        },
        []string{"product_type"},
    )

    creditsCost = prometheus.NewCounterVec(
        prometheus.CounterOpts{
            Name: "ai_credits_cost_total",
            Help: "Total credits spent",
        },
        []string{"operation_type", "company_id"},
    )
)
```

### Structured Logging

```go
logger.Info("generation_completed",
    "company_id", companyID,
    "duration_ms", duration.Milliseconds(),
    "images_count", len(result.GeneratedImages),
    "credits_used", result.TotalCreditsUsed,
    "quality_score", result.QualityScore,
)
```

---

## Adım 10: Production Best Practices

### Rate Limiting

```go
limiter := rate.NewLimiter(60, 10) // 60 req/min, burst 10

if !limiter.Allow() {
    http.Error(w, "Rate limit exceeded", http.StatusTooManyRequests)
    return
}
```

### Request Validation

```go
if len(req.ProductImageURL) == 0 {
    http.Error(w, "product_image_url required", http.StatusBadRequest)
    return
}

if req.OutputCount > 10 {
    http.Error(w, "max output_count is 10", http.StatusBadRequest)
    return
}
```

### Timeout Management

```go
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
defer cancel()

result := aiService.ExecuteFullPipeline(ctx, req)
```

---

## Troubleshooting

### "API Key invalid"
```
→ FAL_AI_API_KEY ve REPLICATE_API_KEY kontrol et
→ Keys'in rotation olmadığını verify et
```

### "Insufficient credits"
```
→ CREDIT_COST_* env variables kontrol et
→ Company hesabı credit balance'ı kontrol et
→ Credit refund logic test et
```

### "Segmentation quality low"
```
→ Input image resolution kontrol et (minimum 512px)
→ Product position'ını verify et (centered better)
→ Quality tier arttır
```

### "Rate limit errors"
```
→ Batch size azalt (3-5 max)
→ Concurrent jobs limit düşür
→ Provider side rate limits kontrol et
```

---

## Support

- **Documentation**: `/internal/ai/README.md`
- **Issues**: GitHub Issues
- **Email**: support@kuyumcu.dev
- **Slack**: #ai-integration channel
