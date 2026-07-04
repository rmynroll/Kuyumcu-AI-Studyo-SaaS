package ai

import (
	"context"
	"fmt"
	"time"
)

// =============================================================================
// SEGMENTATION SERVICE
// =============================================================================

// SegmentationService, görsel segmentasyon işlemlerini yönetir
type SegmentationService struct {
	provider    SegmentationProvider
	config      *ProviderConfig
	creditSvc   CreditService
	requestMeta *RequestMetadata
}

// NewSegmentationService, segmentasyon servisi oluşturur
func NewSegmentationService(
	provider SegmentationProvider,
	config *ProviderConfig,
	creditSvc CreditService,
) *SegmentationService {
	return &SegmentationService{
		provider:  provider,
		config:    config,
		creditSvc: creditSvc,
	}
}

// =============================================================================
// JEWELRY SEGMENTATION (SAM 2)
// =============================================================================

// SegmentJewelry, takı segmentasyonu yapar (SAM 2 optimized)
// Bu fonksiyon, takıyı arka plandan ayırarak temiz PNG maskesi döndürür
func (ss *SegmentationService) SegmentJewelry(
	ctx context.Context,
	imageURL string,
	companyID string,
	params map[string]interface{},
) (*SegmentationResult, error) {
	
	if imageURL == "" {
		return nil, ErrInvalidImageURL
	}

	// Request metadata setup
	ss.requestMeta = &RequestMetadata{
		RequestID: generateRequestID(),
		CompanyID: companyID,
		CreatedAt: time.Now(),
		ProviderUsed: ss.config.Type,
	}

	// Credit check
	creditCost := ss.provider.GetCreditCost("segmentation")
	canDeduct, err := ss.creditSvc.CanDeduct(ctx, companyID, creditCost)
	if err != nil {
		return nil, fmt.Errorf("kredi kontrol hatası: %w", err)
	}
	if !canDeduct {
		return nil, NewInsufficientCreditsError(creditCost, 0)
	}

	// Deduct credits
	if err := ss.creditSvc.Deduct(ctx, companyID, creditCost, "segmentation"); err != nil {
		return nil, fmt.Errorf("kredi düşme hatası: %w", err)
	}

	ss.requestMeta.CreditsUsed = creditCost
	ss.requestMeta.StartedAt = time.Now()

	// Call segmentation provider
	result, err := ss.provider.SegmentJewelry(ctx, imageURL, params)
	if err != nil {
		// Refund credits on failure
		_ = ss.creditSvc.Refund(ctx, companyID, creditCost, fmt.Sprintf("segmentation failed: %v", err))
		ss.requestMeta.Status = "failed"
		ss.requestMeta.ErrorMessage = err.Error()
		return nil, fmt.Errorf("takı segmentasyonu başarısız: %w", err)
	}

	ss.requestMeta.Status = "completed"
	ss.requestMeta.CompletedAt = time.Now()
	ss.requestMeta.Duration = ss.requestMeta.CompletedAt.Sub(ss.requestMeta.StartedAt)

	return result, nil
}

// =============================================================================
// GENERIC IMAGE SEGMENTATION
// =============================================================================

// SegmentImage, genel görsel segmentasyonu yapar
func (ss *SegmentationService) SegmentImage(
	ctx context.Context,
	imageURL string,
	companyID string,
) (*SegmentationResult, error) {
	
	if imageURL == "" {
		return nil, ErrInvalidImageURL
	}

	ss.requestMeta = &RequestMetadata{
		RequestID: generateRequestID(),
		CompanyID: companyID,
		CreatedAt: time.Now(),
		ProviderUsed: ss.config.Type,
	}

	creditCost := ss.provider.GetCreditCost("segmentation")
	canDeduct, err := ss.creditSvc.CanDeduct(ctx, companyID, creditCost)
	if err != nil {
		return nil, fmt.Errorf("kredi kontrol hatası: %w", err)
	}
	if !canDeduct {
		return nil, NewInsufficientCreditsError(creditCost, 0)
	}

	if err := ss.creditSvc.Deduct(ctx, companyID, creditCost, "segmentation"); err != nil {
		return nil, fmt.Errorf("kredi düşme hatası: %w", err)
	}

	ss.requestMeta.CreditsUsed = creditCost
	ss.requestMeta.StartedAt = time.Now()

	result, err := ss.provider.SegmentImage(ctx, imageURL)
	if err != nil {
		_ = ss.creditSvc.Refund(ctx, companyID, creditCost, fmt.Sprintf("segmentation failed: %v", err))
		ss.requestMeta.Status = "failed"
		ss.requestMeta.ErrorMessage = err.Error()
		return nil, fmt.Errorf("segmentasyon başarısız: %w", err)
	}

	ss.requestMeta.Status = "completed"
	ss.requestMeta.CompletedAt = time.Now()
	ss.requestMeta.Duration = ss.requestMeta.CompletedAt.Sub(ss.requestMeta.StartedAt)

	return result, nil
}

// =============================================================================
// BATCH SEGMENTATION
// =============================================================================

// BatchSegmentationRequest, batch segmentasyon isteğini tutar
type BatchSegmentationRequest struct {
	ImageURLs []string
	CompanyID string
	Params    map[string]interface{}
}

// BatchSegmentationResult, batch segmentasyon sonuçlarını tutar
type BatchSegmentationResult struct {
	TotalRequests      int
	SuccessfulRequests int
	FailedRequests     int
	Results            []SegmentationResultItem
	TotalCreditsUsed   int
	TotalDuration      time.Duration
}

// SegmentationResultItem, tek bir segmentasyon sonuçunu tutar
type SegmentationResultItem struct {
	ImageURL     string
	Result       *SegmentationResult
	Error        error
	Duration     time.Duration
	CreditsUsed  int
}

// SegmentBatch, çoklu görsel segmentasyonu yapar
func (ss *SegmentationService) SegmentBatch(
	ctx context.Context,
	req *BatchSegmentationRequest,
) *BatchSegmentationResult {
	
	startTime := time.Now()
	result := &BatchSegmentationResult{
		TotalRequests: len(req.ImageURLs),
		Results:       make([]SegmentationResultItem, 0, len(req.ImageURLs)),
	}

	for _, imageURL := range req.ImageURLs {
		itemStart := time.Now()
		
		segResult, err := ss.SegmentJewelry(ctx, imageURL, req.CompanyID, req.Params)
		
		item := SegmentationResultItem{
			ImageURL:    imageURL,
			Result:      segResult,
			Error:       err,
			Duration:    time.Since(itemStart),
			CreditsUsed: 0,
		}

		if ss.requestMeta != nil {
			item.CreditsUsed = ss.requestMeta.CreditsUsed
			result.TotalCreditsUsed += ss.requestMeta.CreditsUsed
		}

		if err != nil {
			result.FailedRequests++
		} else {
			result.SuccessfulRequests++
		}

		result.Results = append(result.Results, item)

		// Rate limiting simulation
		select {
		case <-ctx.Done():
			return result
		case <-time.After(200 * time.Millisecond):
		}
	}

	result.TotalDuration = time.Since(startTime)
	return result
}

// =============================================================================
// SEGMENTATION QUALITY CONTROL
// =============================================================================

// QualityValidator, segmentasyon kalitesini kontrol eder
type QualityValidator struct {
	minConfidenceScore float32
	maxEdgeArtifacts   float32
	minMaskArea        int
}

// NewQualityValidator, kalite validator oluşturur
func NewQualityValidator() *QualityValidator {
	return &QualityValidator{
		minConfidenceScore: 0.85,
		maxEdgeArtifacts:   0.15,
		minMaskArea:        5000, // pixel
	}
}

// ValidateSegmentationResult, segmentasyon sonucunun kalitesini kontrol eder
func (qv *QualityValidator) ValidateSegmentationResult(result *SegmentationResult) (bool, []string) {
	issues := []string{}

	if result.SegmentationScore < qv.minConfidenceScore {
		issues = append(issues, fmt.Sprintf(
			"Segmentasyon skoru düşük: %f (minimum: %f)",
			result.SegmentationScore,
			qv.minConfidenceScore,
		))
	}

	if result.MaskPixelArea < qv.minMaskArea {
		issues = append(issues, fmt.Sprintf(
			"Mask alanı çok küçük: %d piksel (minimum: %d)",
			result.MaskPixelArea,
			qv.minMaskArea,
		))
	}

	return len(issues) == 0, issues
}

// =============================================================================
// MASK POST-PROCESSING
// =============================================================================

// MaskPostProcessor, segmentasyon maskesini post-process eder
type MaskPostProcessor struct {
	enableSmoothing bool
	enableDilation  bool
	enableErosion   bool
}

// NewMaskPostProcessor, mask post-processor oluşturur
func NewMaskPostProcessor() *MaskPostProcessor {
	return &MaskPostProcessor{
		enableSmoothing: true,
		enableDilation:  true,
		enableErosion:   false,
	}
}

// ProcessMask, maske üzerinde post-processing yapar
func (mpp *MaskPostProcessor) ProcessMask(
	ctx context.Context,
	maskImageURL string,
) (string, error) {
	
	// TODO: Implement actual mask post-processing:
	// 1. Morphological operations (dilation, erosion)
	// 2. Smoothing edges (Gaussian blur, bilateral filter)
	// 3. Feathering (yumuşak geçişler için)
	// 4. Quality assurance
	
	return maskImageURL, nil
}

// GetLastRequestMetadata, son istek metadata'sını döndürür
func (ss *SegmentationService) GetLastRequestMetadata() *RequestMetadata {
	return ss.requestMeta
}
