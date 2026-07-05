package ai

import (
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// =============================================================================
// MAIN AI SERVICE ORCHESTRATION
// =============================================================================

// AIService, tüm AI işlemlerini orchestrate eden ana servis
type AIService struct {
	visionAnalyzer     *ImageAnalyzerService
	generationProvider GenerationProvider
	segmentationSvc    *SegmentationService

	promptBuilder      *PromptBuilder
	creditCalculator   CreditCalculator
	creditLimiter      *CreditLimiter

	config             *Config
	requestCache       map[string]*CachedRequest
	cacheLock          sync.RWMutex

	logger             Logger
}

// CachedRequest, cache edilen istek sonuçlarını tutar
type CachedRequest struct {
	Data      interface{}
	ExpiresAt time.Time
}

// Logger, logging arayüzü
type Logger interface {
	Debug(msg string, args ...interface{})
	Info(msg string, args ...interface{})
	Warn(msg string, args ...interface{})
	Error(msg string, args ...interface{})
}

// NoOpLogger, işlem yapmayan logger
type NoOpLogger struct{}

func (n *NoOpLogger) Debug(msg string, args ...interface{}) {}
func (n *NoOpLogger) Info(msg string, args ...interface{})  {}
func (n *NoOpLogger) Warn(msg string, args ...interface{})  {}
func (n *NoOpLogger) Error(msg string, args ...interface{}) {}

// NewAIService, AI servisi oluşturur
func NewAIService(
	config *Config,
	visionProvider VisionProvider,
	generationProvider GenerationProvider,
	segmentationProvider SegmentationProvider,
	creditSvc CreditService,
	logger Logger,
) (*AIService, error) {
	
	if logger == nil {
		logger = &NoOpLogger{}
	}

	// Analyzerand Segmentation services oluştur
	visionAnalyzer := NewImageAnalyzerService(
		visionProvider,
		config.VisionConfig,
		creditSvc,
	)

	segmentationSvc := NewSegmentationService(
		segmentationProvider,
		config.SegmentationConfig,
		creditSvc,
	)

	// Credit systems
	creditCalculator := NewDefaultCreditCalculator()
	creditLimiter := NewCreditLimiter(creditCalculator, creditSvc)

	return &AIService{
		visionAnalyzer:     visionAnalyzer,
		generationProvider: generationProvider,
		segmentationSvc:    segmentationSvc,
		promptBuilder:      NewPromptBuilder(),
		creditCalculator:   creditCalculator,
		creditLimiter:      creditLimiter,
		config:             config,
		requestCache:       make(map[string]*CachedRequest),
		logger:             logger,
	}, nil
}

// =============================================================================
// FULL PIPELINE OPERATIONS
// =============================================================================

// FullPipelineRequest, tam pipeline isteğini tutar
type FullPipelineRequest struct {
	ProductImageURL     string
	ReferenceImageURL   string // opsiyonel
	ProductCharacteristics *JewelryCharacteristics
	CompanyID           string
	UserID              string
	DesiredStyle        string // "minimalist", "luxury", "elegant", etc.
	OutputCount         int
	Quality             string // "standard", "high", "ultra"
}

// FullPipelineResult, tam pipeline sonucunu tutar
type FullPipelineResult struct {
	RequestID           string
	Status              string // "pending", "processing", "completed", "failed"
	SegmentationResult  *SegmentationResult
	GeneratedImages     []string // URLs
	AnalysisMetadata    *ReferenceImageAnalysisResult
	CompositedResults   []*CompositingResult
	TotalCreditsUsed    int
	TotalDuration       time.Duration
	Error               error
	StartedAt           time.Time
	CompletedAt         time.Time
}

// ExecuteFullPipeline, tam üretim pipeline'ını çalıştırır
// Adımlar:
// 1. Referans görsel analizi (varsa)
// 2. Ürün segmentasyonu (takıyı arka plandan ayırma)
// 3. Prompt engineering (ürün koruma kurallarıyla)
// 4. AI görsel üretimi (arka plan ve ışık değişikliği)
// 5. Tamamlama (compositing - takıyı yeni sahneyle birleştirme)
func (as *AIService) ExecuteFullPipeline(
	ctx context.Context,
	req *FullPipelineRequest,
) *FullPipelineResult {
	
	result := &FullPipelineResult{
		RequestID:   generateRequestID(),
		StartedAt:   time.Now(),
		Status:      "processing",
		CompositedResults: make([]*CompositingResult, 0, req.OutputCount),
	}

	as.logger.Info(fmt.Sprintf("Starting full pipeline for company %s, request %s", req.CompanyID, result.RequestID))

	defer func() {
		result.CompletedAt = time.Now()
		result.TotalDuration = result.CompletedAt.Sub(result.StartedAt)
	}()

	// Step 1: Referans görsel analizi (varsa)
	if req.ReferenceImageURL != "" {
		as.logger.Info("Step 1: Analyzing reference image...")
		
		analysisResult, err := as.visionAnalyzer.AnalyzeReferenceImage(
			ctx,
			req.ReferenceImageURL,
			req.CompanyID,
		)

		if err != nil {
			result.Status = "failed"
			result.Error = fmt.Errorf("referans görsel analizi başarısız: %w", err)
			as.logger.Error(fmt.Sprintf("Reference analysis failed: %v", err))
			return result
		}

		result.AnalysisMetadata = analysisResult
		if meta := as.visionAnalyzer.GetLastRequestMetadata(); meta != nil {
			result.TotalCreditsUsed += meta.CreditsUsed
		}
	}

	// Step 2: Ürün segmentasyonu (SAM 2)
	as.logger.Info("Step 2: Segmenting product from background...")
	
	segParams := map[string]interface{}{
		"product_type": req.ProductCharacteristics.ProductType,
		"target_focus": req.ProductCharacteristics.MainFocusArea,
	}

	segResult, err := as.segmentationSvc.SegmentJewelry(
		ctx,
		req.ProductImageURL,
		req.CompanyID,
		segParams,
	)

	if err != nil {
		result.Status = "failed"
		result.Error = fmt.Errorf("segmentasyon başarısız: %w", err)
		as.logger.Error(fmt.Sprintf("Segmentation failed: %v", err))
		return result
	}

	result.SegmentationResult = segResult
	if meta := as.segmentationSvc.GetLastRequestMetadata(); meta != nil {
		result.TotalCreditsUsed += meta.CreditsUsed
	}

	// Step 3: Prompt engineering
	as.logger.Info("Step 3: Building optimized prompt...")
	
	promptTemplate, err := as.promptBuilder.
		WithCharacteristics(req.ProductCharacteristics).
		WithReferenceAnalysis(result.AnalysisMetadata).
		Build()

	if err != nil {
		result.Status = "failed"
		result.Error = fmt.Errorf("prompt oluşturma başarısız: %w", err)
		as.logger.Error(fmt.Sprintf("Prompt building failed: %v", err))
		return result
	}

	// Stil varyasyonu (opsiyonel)
	if req.DesiredStyle != "" {
		tvb := NewTemplateVariationBuilder(promptTemplate)
		switch req.DesiredStyle {
		case "luxury":
			promptTemplate = tvb.BuildLuxury()
		case "minimalist":
			promptTemplate = tvb.BuildMinimalist()
		case "elegant":
			promptTemplate = tvb.BuildElegant()
		case "contemporary":
			promptTemplate = tvb.BuildContemporary()
		case "vintage":
			promptTemplate = tvb.BuildVintage()
		case "romantic":
			promptTemplate = tvb.BuildRomantic()
		}
	}

	// Step 4: Generate images with AI model
	as.logger.Info("Step 4: Generating scene with AI...")

	// Credit check for generation
	genCreditCost := as.creditCalculator.CalculateGenerationCost(
		as.config.GenerationModelID,
		req.OutputCount,
		"1024x1024",
	)

	canGenerate, err := as.creditLimiter.CanAfford(ctx, req.CompanyID, genCreditCost)
	if err != nil || !canGenerate {
		result.Status = "failed"
		result.Error = NewInsufficientCreditsError(genCreditCost, 0)
		as.logger.Error("Insufficient credits for generation")
		return result
	}

	// TODO: Call generation provider to create images
	// generatedImages, err := as.generationProvider.GenerateImage(ctx, promptTemplate.BasePrompt, genParams)

	// Step 5: Compositing - Combine product mask with generated scene
	as.logger.Info("Step 5: Compositing product with generated scene...")
	
	for i := 0; i < req.OutputCount; i++ {
		compReq := &CompositingRequest{
			ProductMaskURL:     segResult.MaskImageURL,
			OriginalProductURL: req.ProductImageURL,
			GeneratedSceneURL:  fmt.Sprintf("generated_scene_%d_url", i), // From Step 4
			RelightingStyle:    "studio",
			OutputFormat:       "png",
			Quality:            req.Quality,
		}

		compResult, err := as.generationProvider.CompositeImage(ctx, compReq)
		if err != nil {
			as.logger.Warn(fmt.Sprintf("Compositing failed for image %d: %v", i, err))
			continue
		}

		result.CompositedResults = append(result.CompositedResults, compResult)
		result.GeneratedImages = append(result.GeneratedImages, compResult.CompositeImageURL)
	}

	result.Status = "completed"
	result.TotalCreditsUsed += genCreditCost

	as.logger.Info(fmt.Sprintf("Pipeline completed successfully. Total credits used: %d", result.TotalCreditsUsed))

	return result
}

// =============================================================================
// INDIVIDUAL OPERATIONS
// =============================================================================

// AnalyzeProduct, ürün görselini analiz eder
func (as *AIService) AnalyzeProduct(
	ctx context.Context,
	imageURL string,
	companyID string,
) (*JewelryCharacteristics, error) {
	
	return as.visionAnalyzer.ExtractJewelryCharacteristics(ctx, imageURL, companyID)
}

// AnalyzeReference, referans görsel analizi yapar
func (as *AIService) AnalyzeReference(
	ctx context.Context,
	imageURL string,
	companyID string,
) (*ReferenceImageAnalysisResult, error) {
	
	return as.visionAnalyzer.AnalyzeReferenceImage(ctx, imageURL, companyID)
}

// SegmentProduct, takıyı arka plandan ayırır
func (as *AIService) SegmentProduct(
	ctx context.Context,
	imageURL string,
	companyID string,
) (*SegmentationResult, error) {
	
	return as.segmentationSvc.SegmentJewelry(ctx, imageURL, companyID, map[string]interface{}{})
}

// GenerateWithCompositing, compositing-first yaklaşımıyla görsel oluşturur
func (as *AIService) GenerateWithCompositing(
	ctx context.Context,
	productMask string,
	productURL string,
	prompt string,
	companyID string,
) (*CompositingResult, error) {
	
	// Credit check
	creditCost := as.creditCalculator.GetBaseCost("compositing")
	canAfford, err := as.creditLimiter.CanAfford(ctx, companyID, creditCost)
	if err != nil || !canAfford {
		return nil, NewInsufficientCreditsError(creditCost, 0)
	}

	return as.generationProvider.GenerateWithCompositing(ctx, productMask, productURL, prompt)
}

// =============================================================================
// UTILITY METHODS
// =============================================================================

// GetServiceStatus, servis durumunu döndürür
func (as *AIService) GetServiceStatus(ctx context.Context) map[string]interface{} {
	status := map[string]interface{}{
		"timestamp": time.Now(),
		"services": map[string]interface{}{
			"vision_provider":        "configured",
			"generation_provider":    "configured",
			"segmentation_provider":  "configured",
			"credit_system":          "active",
		},
	}

	return status
}

// ClearCache, istek cache'ini temizler
func (as *AIService) ClearCache() {
	as.cacheLock.Lock()
	defer as.cacheLock.Unlock()
	as.requestCache = make(map[string]*CachedRequest)
}

// Close, servisi kapatır ve kaynakları serbest bırakır
func (as *AIService) Close() error {
	as.logger.Info("Shutting down AI service")
	// Cleanup resources
	return nil
}

// =============================================================================
// BATCH PROCESSING
// =============================================================================

// BatchRequest, batch işlem isteğini tutar
type BatchRequest struct {
	Operations []string // ["analyze_reference", "segment_product", "generate"]
	ImageURLs  []string
	CompanyID  string
}

// ExecuteBatch, batch işlemleri sırayla çalıştırır
func (as *AIService) ExecuteBatch(
	ctx context.Context,
	req *BatchRequest,
) map[string]interface{} {
	
	results := map[string]interface{}{
		"request_id": generateRequestID(),
		"operations": make(map[string]interface{}),
	}

	for _, op := range req.Operations {
		switch op {
		case "analyze_reference":
			for _, url := range req.ImageURLs {
				analysis, err := as.AnalyzeReference(ctx, url, req.CompanyID)
				results[fmt.Sprintf("analyze_reference_%s", url)] = map[string]interface{}{
					"result": analysis,
					"error":  err,
				}
			}

		case "segment_product":
			for _, url := range req.ImageURLs {
				segmentation, err := as.SegmentProduct(ctx, url, req.CompanyID)
				results[fmt.Sprintf("segment_product_%s", url)] = map[string]interface{}{
					"result": segmentation,
					"error":  err,
				}
			}

		case "generate":
			// Image generation implementation
			as.logger.Info("Generating images for batch...")
		}
	}

	return results
}

// =============================================================================
// PROVIDER IMPLEMENTATIONS (Stub)
// =============================================================================

// MockVisionProvider, testing için mock vision provider
type MockVisionProvider struct{}

func (m *MockVisionProvider) Name() string                          { return "mock_vision" }
func (m *MockVisionProvider) Ping(ctx context.Context) error       { return nil }
func (m *MockVisionProvider) GetCreditCost(op string) int           { return 50 }
func (m *MockVisionProvider) Close() error                         { return nil }
func (m *MockVisionProvider) AnalyzeImage(ctx context.Context, img string, typ string) (interface{}, error) {
	return nil, nil
}
func (m *MockVisionProvider) AnalyzeReferenceImage(ctx context.Context, img string) (*ReferenceImageAnalysisResult, error) {
	return nil, nil
}
func (m *MockVisionProvider) ExtractJewelryCharacteristics(ctx context.Context, img string) (*JewelryCharacteristics, error) {
	return nil, nil
}

// =============================================================================
// FEEDBACK SERVICE
// =============================================================================

// Package feedback, kullanıcının üretim sonrası verdiği geri
// bildirimleri (`generation_feedback` tablosu) yönetir. Amaç sadece veri
// toplamak değil; ÜRÜN KİMLİĞİ ihlali (taş sayısı, metal rengi değişimi
// gibi) içeren geri bildirimleri estetik şikayetlerden (arka plan kötü
// gibi) ayırıp admin'in ilk göreceği kuyruğa otomatik düşürmektir.


// FeedbackCode, Flutter tarafındaki `ChoiceChip` seçenekleriyle birebir
// eşleşir (bkz. feedback_bottom_sheet.dart).
type FeedbackCode string

const (
	CodeProductBroken           FeedbackCode = "product_broken"
	CodeStoneCountChanged       FeedbackCode = "stone_count_changed"
	CodeMetalColorWrong         FeedbackCode = "metal_color_wrong"
	CodeBackgroundBad           FeedbackCode = "background_bad"
	CodeUnnaturalPlacement      FeedbackCode = "unnatural_placement"
	CodeLooksGoodButNotSimilar  FeedbackCode = "looks_good_but_not_similar"
)

// criticalCodes, ÜRÜN KİMLİĞİ ihlali sayılan ve otomatik olarak
// `is_flagged = true` ile admin kuyruğuna düşen kodlardır. Bunlar aynı
// zamanda dokümandaki "ayıplı mal / yanıltıcı reklam" hukuki riskiyle
// doğrudan ilişkilidir — estetik şikayetler (arka plan kötü vb.) admin'i
// boğmasın diye bu ayrım yapılır.
var criticalCodes = map[FeedbackCode]bool{
	CodeProductBroken:     true,
	CodeStoneCountChanged: true,
	CodeMetalColorWrong:   true,
}

// allowedCodes, veritabanındaki CHECK constraint ile birebir eşleşir
// (bkz. migration 0005); API handler'ı burada olmayan bir kod gelirse
// isteği reddeder.
var allowedCodes = map[FeedbackCode]bool{
	CodeProductBroken:          true,
	CodeStoneCountChanged:      true,
	CodeMetalColorWrong:        true,
	CodeBackgroundBad:          true,
	CodeUnnaturalPlacement:     true,
	CodeLooksGoodButNotSimilar: true,
}

// FeedbackService, feedback gönderme ve admin tarafında listeleme işlemlerini yürütür.
type FeedbackService struct {
	db *pgxpool.Pool
}

func NewFeedbackService(db *pgxpool.Pool) *FeedbackService {
	return &FeedbackService{db: db}
}

// Submit, `POST /generations/{id}/feedback` handler'ının çağıracağı ana
// metottur. `isFlagged` kararı burada, kod bazında otomatik verilir —
// kullanıcı veya API çağıran bunu manipüle edemez.
func (s *FeedbackService) Submit(ctx context.Context, generationID, companyID string, code FeedbackCode, note string) error {
	if !allowedCodes[code] {
		return fmt.Errorf("geçersiz feedback kodu: %s", code)
	}

	isFlagged := criticalCodes[code]

	const query = `
		INSERT INTO generation_feedback (generation_id, company_id, feedback_code, note, is_flagged)
		VALUES ($1, $2, $3, $4, $5)
	`
	_, err := s.db.Exec(ctx, query, generationID, companyID, string(code), note, isFlagged)
	if err != nil {
		return fmt.Errorf("feedback kaydedilemedi: %w", err)
	}
	return nil
}

// FlaggedFeedback, admin panelinin incelemesi için dönen özet satırdır.
type FlaggedFeedback struct {
	ID           string
	GenerationID string
	CompanyID    string
	FeedbackCode string
	Note         *string
	OutputURL    *string // generations.output_urls[0].file_url, admin görsel görsün
	CreatedAt    string
}

// ListUnreviewedFlagged, admin panelinin "incelenmemiş + kritik" kuyruğunu
// döner (bkz. migration 0005 idx_generation_feedback_unreviewed index'i).
func (s *FeedbackService) ListUnreviewedFlagged(ctx context.Context, limit int) ([]FlaggedFeedback, error) {
	if limit <= 0 {
		limit = 50
	}

	const query = `
		SELECT
			f.id, f.generation_id, f.company_id, f.feedback_code, f.note,
			g.output_urls->0->>'file_url' AS output_url,
			f.created_at::text
		FROM generation_feedback f
		JOIN generations g ON g.id = f.generation_id
		WHERE f.reviewed_at IS NULL AND f.is_flagged = TRUE
		ORDER BY f.created_at ASC
		LIMIT $1
	`

	rows, err := s.db.Query(ctx, query, limit)
	if err != nil {
		return nil, fmt.Errorf("flagged feedback listesi okunamadı: %w", err)
	}
	defer rows.Close()

	var results []FlaggedFeedback
	for rows.Next() {
		var f FlaggedFeedback
		if err := rows.Scan(&f.ID, &f.GenerationID, &f.CompanyID, &f.FeedbackCode, &f.Note, &f.OutputURL, &f.CreatedAt); err != nil {
			return nil, fmt.Errorf("flagged feedback satırı okunamadı: %w", err)
		}
		results = append(results, f)
	}
	return results, rows.Err()
}

// MarkReviewed, admin bir feedback'i inceledikten sonra çağrılır.
func (s *Service) MarkReviewed(ctx context.Context, feedbackID, reviewerNote string) error {
	const query = `
		UPDATE generation_feedback
		SET reviewed_at = now(), reviewer_note = $1
		WHERE id = $2
	`
	tag, err := s.db.Exec(ctx, query, reviewerNote, feedbackID)
	if err != nil {
		return fmt.Errorf("feedback incelendi olarak işaretlenemedi: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return fmt.Errorf("feedback bulunamadı (id=%s)", feedbackID)
	}
	return nil
}