package ai

import (
	"context"
	"encoding/json"
	"fmt"
	"time"
)

// =============================================================================
// VISION ANALYZER SERVICE
// =============================================================================

// ImageAnalyzerService, görsel analizi işlemlerini yönetir
type ImageAnalyzerService struct {
	provider     VisionProvider
	config       *ProviderConfig
	creditSvc    CreditService
	requestMeta  *RequestMetadata
}

// NewImageAnalyzerService, görsel analyzer servisi oluşturur
func NewImageAnalyzerService(provider VisionProvider, config *ProviderConfig, creditSvc CreditService) *ImageAnalyzerService {
	return &ImageAnalyzerService{
		provider:  provider,
		config:    config,
		creditSvc: creditSvc,
	}
}

// =============================================================================
// REFERENCE IMAGE ANALYSIS
// =============================================================================

// AnalyzeReferenceImage, referans görsel analizi yapar
// Sistem, ışık açısı, arka plan türü, renk atmosferi vb. çıkarır
func (ias *ImageAnalyzerService) AnalyzeReferenceImage(
	ctx context.Context,
	imageURL string,
	companyID string,
) (*ReferenceImageAnalysisResult, error) {
	
	// Input validation
	if imageURL == "" {
		return nil, ErrInvalidImageURL
	}

	// Request metadata setup
	ias.requestMeta = &RequestMetadata{
		RequestID: generateRequestID(),
		CompanyID: companyID,
		CreatedAt: time.Now(),
		ProviderUsed: ias.config.Type,
	}

	// Credit check
	creditCost := ias.provider.GetCreditCost("reference_analysis")
	canDeduct, err := ias.creditSvc.CanDeduct(ctx, companyID, creditCost)
	if err != nil {
		return nil, fmt.Errorf("kredi kontrol başarısız: %w", err)
	}
	if !canDeduct {
		return nil, NewInsufficientCreditsError(creditCost, 0)
	}

	// Deduct credits
	if err := ias.creditSvc.Deduct(ctx, companyID, creditCost, "reference_analysis"); err != nil {
		return nil, fmt.Errorf("kredi düşme hatası: %w", err)
	}

	ias.requestMeta.CreditsUsed = creditCost
	ias.requestMeta.StartedAt = time.Now()

	// Call vision provider
	result, err := ias.provider.AnalyzeReferenceImage(ctx, imageURL)
	if err != nil {
		// Refund credits on failure
		_ = ias.creditSvc.Refund(ctx, companyID, creditCost, fmt.Sprintf("reference_analysis failed: %v", err))
		ias.requestMeta.Status = "failed"
		ias.requestMeta.ErrorMessage = err.Error()
		return nil, fmt.Errorf("referans görsel analizi başarısız: %w", err)
	}

	ias.requestMeta.Status = "completed"
	ias.requestMeta.CompletedAt = time.Now()
	ias.requestMeta.Duration = ias.requestMeta.CompletedAt.Sub(ias.requestMeta.StartedAt)

	return result, nil
}

// =============================================================================
// JEWELRY CHARACTERISTICS EXTRACTION
// =============================================================================

// ExtractJewelryCharacteristics, takının özelliklerini çıkarır
// Sistem, taş sayısı, metal rengi, tasarım türü vb. belirler
func (ias *ImageAnalyzerService) ExtractJewelryCharacteristics(
	ctx context.Context,
	imageURL string,
	companyID string,
) (*JewelryCharacteristics, error) {
	
	if imageURL == "" {
		return nil, ErrInvalidImageURL
	}

	ias.requestMeta = &RequestMetadata{
		RequestID: generateRequestID(),
		CompanyID: companyID,
		CreatedAt: time.Now(),
		ProviderUsed: ias.config.Type,
	}

	// Credit check
	creditCost := ias.provider.GetCreditCost("jewelry_extraction")
	canDeduct, err := ias.creditSvc.CanDeduct(ctx, companyID, creditCost)
	if err != nil {
		return nil, fmt.Errorf("kredi kontrol başarısız: %w", err)
	}
	if !canDeduct {
		return nil, NewInsufficientCreditsError(creditCost, 0)
	}

	if err := ias.creditSvc.Deduct(ctx, companyID, creditCost, "jewelry_extraction"); err != nil {
		return nil, fmt.Errorf("kredi düşme hatası: %w", err)
	}

	ias.requestMeta.CreditsUsed = creditCost
	ias.requestMeta.StartedAt = time.Now()

	// Call provider
	chars, err := ias.provider.ExtractJewelryCharacteristics(ctx, imageURL)
	if err != nil {
		_ = ias.creditSvc.Refund(ctx, companyID, creditCost, fmt.Sprintf("jewelry_extraction failed: %v", err))
		ias.requestMeta.Status = "failed"
		ias.requestMeta.ErrorMessage = err.Error()
		return nil, fmt.Errorf("takı özelliği çıkarma başarısız: %w", err)
	}

	ias.requestMeta.Status = "completed"
	ias.requestMeta.CompletedAt = time.Now()
	ias.requestMeta.Duration = ias.requestMeta.CompletedAt.Sub(ias.requestMeta.StartedAt)

	return chars, nil
}

// =============================================================================
// GENERIC IMAGE ANALYSIS
// =============================================================================

// AnalyzeImage, genel görsel analizi yapar
func (ias *ImageAnalyzerService) AnalyzeImage(
	ctx context.Context,
	imageURL string,
	analysisType string,
	companyID string,
) (json.RawMessage, error) {
	
	if imageURL == "" {
		return nil, ErrInvalidImageURL
	}

	ias.requestMeta = &RequestMetadata{
		RequestID: generateRequestID(),
		CompanyID: companyID,
		CreatedAt: time.Now(),
		ProviderUsed: ias.config.Type,
	}

	creditCost := ias.provider.GetCreditCost("vision_analysis")
	canDeduct, err := ias.creditSvc.CanDeduct(ctx, companyID, creditCost)
	if err != nil {
		return nil, fmt.Errorf("kredi kontrol başarısız: %w", err)
	}
	if !canDeduct {
		return nil, NewInsufficientCreditsError(creditCost, 0)
	}

	if err := ias.creditSvc.Deduct(ctx, companyID, creditCost, "vision_analysis"); err != nil {
		return nil, fmt.Errorf("kredi düşme hatası: %w", err)
	}

	ias.requestMeta.CreditsUsed = creditCost
	ias.requestMeta.StartedAt = time.Now()

	result, err := ias.provider.AnalyzeImage(ctx, imageURL, analysisType)
	if err != nil {
		_ = ias.creditSvc.Refund(ctx, companyID, creditCost, fmt.Sprintf("vision_analysis failed: %v", err))
		ias.requestMeta.Status = "failed"
		ias.requestMeta.ErrorMessage = err.Error()
		return nil, fmt.Errorf("görsel analizi başarısız: %w", err)
	}

	ias.requestMeta.Status = "completed"
	ias.requestMeta.CompletedAt = time.Now()
	ias.requestMeta.Duration = ias.requestMeta.CompletedAt.Sub(ias.requestMeta.StartedAt)

	return result, nil
}

// GetLastRequestMetadata, son istek metadata'sını döndürür
func (ias *ImageAnalyzerService) GetLastRequestMetadata() *RequestMetadata {
	return ias.requestMeta
}

// =============================================================================
// BATCH ANALYSIS
// =============================================================================

// BatchAnalysisRequest, batch analiz isteğini tutar
type BatchAnalysisRequest struct {
	ImageURLs    []string
	AnalysisType string
	CompanyID    string
}

// BatchAnalysisResult, batch analiz sonuçlarını tutar
type BatchAnalysisResult struct {
	TotalRequests    int
	SuccessfulRequests int
	FailedRequests   int
	Results          []AnalysisResultItem
	TotalCreditsUsed int
	TotalDuration    time.Duration
}

// AnalysisResultItem, tek bir analiz sonuçunu tutar
type AnalysisResultItem struct {
	ImageURL  string
	Result    json.RawMessage
	Error     error
	Duration  time.Duration
	CreditsUsed int
}

// AnalyzeBatch, çoklu görsel analizi yapar
func (ias *ImageAnalyzerService) AnalyzeBatch(
	ctx context.Context,
	req *BatchAnalysisRequest,
) *BatchAnalysisResult {
	
	startTime := time.Now()
	result := &BatchAnalysisResult{
		TotalRequests: len(req.ImageURLs),
		Results:       make([]AnalysisResultItem, 0, len(req.ImageURLs)),
	}

	for _, imageURL := range req.ImageURLs {
		itemStart := time.Now()
		
		analysis, err := ias.AnalyzeImage(ctx, imageURL, req.AnalysisType, req.CompanyID)
		
		item := AnalysisResultItem{
			ImageURL:    imageURL,
			Result:      analysis,
			Error:       err,
			Duration:    time.Since(itemStart),
			CreditsUsed: 0,
		}

		if ias.requestMeta != nil {
			item.CreditsUsed = ias.requestMeta.CreditsUsed
			result.TotalCreditsUsed += ias.requestMeta.CreditsUsed
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
		case <-time.After(100 * time.Millisecond):
		}
	}

	result.TotalDuration = time.Since(startTime)
	return result
}

// =============================================================================
// UTILITY FUNCTIONS
// =============================================================================

// generateRequestID, unique request ID oluşturur
func generateRequestID() string {
	// Bu gerçek implementasyonda UUID olacak
	return fmt.Sprintf("req_%d", time.Now().UnixNano())
}
