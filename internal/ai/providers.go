package ai

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

// =============================================================================
// FAL.AI PROVIDER IMPLEMENTATION
// =============================================================================

// FalAIProvider, Fal.ai ile integration yapar
type FalAIProvider struct {
	apiKey      string
	baseURL     string
	httpClient  *http.Client
	config      *ProviderConfig
	modelID     string
	retryPolicy *RetryPolicy
}

// NewFalAIProvider, Fal.ai provider oluşturur
func NewFalAIProvider(apiKey string, modelID string, config *ProviderConfig) *FalAIProvider {
	if config == nil {
		config = &ProviderConfig{
			Type:           ProviderTypeFalAI,
			Timeout:        30 * time.Second,
			RateLimit:      60,
			MaxConcurrency: 10,
			RetryPolicy:    DefaultRetryPolicy(),
		}
	}

	return &FalAIProvider{
		apiKey:      apiKey,
		modelID:     modelID,
		baseURL:     config.BaseURL,
		config:      config,
		retryPolicy: config.RetryPolicy,
		httpClient: &http.Client{
			Timeout: config.Timeout,
		},
	}
}

// Name, provider adını döndürür
func (f *FalAIProvider) Name() string {
	return "fal.ai"
}

// Ping, provider'ın erişilebilir olup olmadığını kontrol eder
func (f *FalAIProvider) Ping(ctx context.Context) error {
	req, err := http.NewRequestWithContext(ctx, "GET", f.baseURL+"/health", nil)
	if err != nil {
		return err
	}

	req.Header.Set("Authorization", fmt.Sprintf("Key %s", f.apiKey))

	resp, err := f.httpClient.Do(req)
	if err != nil {
		return NewProviderError("fal.ai", http.StatusServiceUnavailable, err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return NewProviderError("fal.ai", resp.StatusCode, fmt.Errorf("health check failed"))
	}

	return nil
}

// GetCreditCost, işlem kredisi maliyetini döndürür
func (f *FalAIProvider) GetCreditCost(operationType string) int {
	costMap := map[string]int{
		"vision_analysis":    100,
		"reference_analysis": 150,
		"jewelry_extraction": 80,
		"image_generation":   300,
		"segmentation":       120,
		"compositing":        200,
	}

	if cost, ok := costMap[operationType]; ok {
		return cost
	}
	return 100 // default
}

// AnalyzeImage, görsel analizi yapar (Vision model)
func (f *FalAIProvider) AnalyzeImage(
	ctx context.Context,
	imageURL string,
	analysisType string,
) (json.RawMessage, error) {

	payload := map[string]interface{}{
		"image_url":     imageURL,
		"analysis_type": analysisType,
	}

	return f.callAPI(ctx, "/analyze", payload)
}

// AnalyzeReferenceImage, referans görsel analizi yapar
func (f *FalAIProvider) AnalyzeReferenceImage(
	ctx context.Context,
	imageURL string,
) (*ReferenceImageAnalysisResult, error) {

	payload := map[string]interface{}{
		"image_url": imageURL,
		"detailed":  true,
	}

	resp, err := f.callAPI(ctx, "/analyze-reference", payload)
	if err != nil {
		return nil, err
	}

	var result ReferenceImageAnalysisResult
	if err := json.Unmarshal(resp, &result); err != nil {
		return nil, fmt.Errorf("response parsing hatası: %w", err)
	}

	return &result, nil
}

// ExtractJewelryCharacteristics, takı özelliklerini çıkarır
func (f *FalAIProvider) ExtractJewelryCharacteristics(
	ctx context.Context,
	imageURL string,
) (*JewelryCharacteristics, error) {

	payload := map[string]interface{}{
		"image_url":   imageURL,
		"extract_all": true,
	}

	resp, err := f.callAPI(ctx, "/extract-jewelry", payload)
	if err != nil {
		return nil, err
	}

	var result JewelryCharacteristics
	if err := json.Unmarshal(resp, &result); err != nil {
		return nil, fmt.Errorf("response parsing hatası: %w", err)
	}

	return &result, nil
}

// Close, provider bağlantısını kapatır
func (f *FalAIProvider) Close() error {
	if f.httpClient != nil {
		f.httpClient.CloseIdleConnections()
	}
	return nil
}

// callAPI, Fal.ai API'sine çağrı yapar
func (f *FalAIProvider) callAPI(ctx context.Context, endpoint string, payload interface{}) (json.RawMessage, error) {
	_, err := json.Marshal(payload)
	if err != nil {
		return nil, fmt.Errorf("payload encoding hatası: %w", err)
	}

	// Retry mekanizması
	var lastErr error
	for attempt := 0; attempt <= f.retryPolicy.MaxRetries; attempt++ {
		if attempt > 0 {
			backoff := time.Duration(float64(f.retryPolicy.InitialBackoff) *
				(f.retryPolicy.BackoffExponent * float64(attempt)))
			if backoff > f.retryPolicy.MaxBackoff {
				backoff = f.retryPolicy.MaxBackoff
			}
			time.Sleep(backoff)
		}

		req, err := http.NewRequestWithContext(
			ctx,
			"POST",
			f.baseURL+endpoint,
			io.Reader(nil),
		)
		if err != nil {
			lastErr = err
			continue
		}

		req.Header.Set("Content-Type", "application/json")
		req.Header.Set("Authorization", fmt.Sprintf("Key %s", f.apiKey))

		resp, err := f.httpClient.Do(req)
		if err != nil {
			lastErr = err
			if IsRetryable(NewProviderError("fal.ai", 0, err)) {
				continue
			}
			return nil, err
		}
		defer resp.Body.Close()

		body, err := io.ReadAll(resp.Body)
		if err != nil {
			lastErr = err
			continue
		}

		if resp.StatusCode == http.StatusOK {
			return json.RawMessage(body), nil
		}

		// Rate limit check
		if resp.StatusCode == http.StatusTooManyRequests {
			lastErr = ErrProviderRateLimit
			continue
		}

		if resp.StatusCode >= 500 {
			lastErr = fmt.Errorf("server error: %d", resp.StatusCode)
			continue
		}

		return nil, fmt.Errorf("API error: %d", resp.StatusCode)
	}

	return nil, fmt.Errorf("max retries exceeded: %w", lastErr)
}

// =============================================================================
// REPLICATE PROVIDER IMPLEMENTATION
// =============================================================================

// ReplicateProvider, Replicate ile integration yapar
type ReplicateProvider struct {
	apiKey      string
	baseURL     string
	httpClient  *http.Client
	config      *ProviderConfig
	modelID     string
	retryPolicy *RetryPolicy
}

// NewReplicateProvider, Replicate provider oluşturur
func NewReplicateProvider(apiKey string, modelID string, config *ProviderConfig) *ReplicateProvider {
	if config == nil {
		config = &ProviderConfig{
			Type:           ProviderTypeReplicate,
			BaseURL:        "https://api.replicate.com/v1",
			Timeout:        60 * time.Second,
			RateLimit:      60,
			MaxConcurrency: 5,
			RetryPolicy:    DefaultRetryPolicy(),
		}
	}

	return &ReplicateProvider{
		apiKey:      apiKey,
		modelID:     modelID,
		baseURL:     config.BaseURL,
		config:      config,
		retryPolicy: config.RetryPolicy,
		httpClient: &http.Client{
			Timeout: config.Timeout,
		},
	}
}

// Name, provider adını döndürür
func (r *ReplicateProvider) Name() string {
	return "replicate"
}

// Ping, provider'ın erişilebilir olup olmadığını kontrol eder
func (r *ReplicateProvider) Ping(ctx context.Context) error {
	req, err := http.NewRequestWithContext(ctx, "GET", r.baseURL+"/models", nil)
	if err != nil {
		return err
	}

	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", r.apiKey))

	resp, err := r.httpClient.Do(req)
	if err != nil {
		return NewProviderError("replicate", http.StatusServiceUnavailable, err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return NewProviderError("replicate", resp.StatusCode, fmt.Errorf("ping failed"))
	}

	return nil
}

// GetCreditCost, işlem kredisi maliyetini döndürür
func (r *ReplicateProvider) GetCreditCost(operationType string) int {
	costMap := map[string]int{
		"vision_analysis":    80,
		"reference_analysis": 120,
		"jewelry_extraction": 60,
		"image_generation":   250,
		"segmentation":       100,
		"compositing":        180,
	}

	if cost, ok := costMap[operationType]; ok {
		return cost
	}
	return 100
}

// AnalyzeImage, görsel analizi yapar
func (r *ReplicateProvider) AnalyzeImage(
	ctx context.Context,
	imageURL string,
	analysisType string,
) (json.RawMessage, error) {

	payload := map[string]interface{}{
		"image":         imageURL,
		"analysis_type": analysisType,
	}

	return r.callAPI(ctx, "/predictions", payload)
}

// AnalyzeReferenceImage, referans görsel analizi yapar
func (r *ReplicateProvider) AnalyzeReferenceImage(
	ctx context.Context,
	imageURL string,
) (*ReferenceImageAnalysisResult, error) {

	payload := map[string]interface{}{
		"image": imageURL,
	}

	resp, err := r.callAPI(ctx, "/predictions", payload)
	if err != nil {
		return nil, err
	}

	var result ReferenceImageAnalysisResult
	if err := json.Unmarshal(resp, &result); err != nil {
		return nil, fmt.Errorf("response parsing hatası: %w", err)
	}

	return &result, nil
}

// ExtractJewelryCharacteristics, takı özelliklerini çıkarır
func (r *ReplicateProvider) ExtractJewelryCharacteristics(
	ctx context.Context,
	imageURL string,
) (*JewelryCharacteristics, error) {

	payload := map[string]interface{}{
		"image": imageURL,
	}

	resp, err := r.callAPI(ctx, "/predictions", payload)
	if err != nil {
		return nil, err
	}

	var result JewelryCharacteristics
	if err := json.Unmarshal(resp, &result); err != nil {
		return nil, fmt.Errorf("response parsing hatası: %w", err)
	}

	return &result, nil
}

// Close, provider bağlantısını kapatır
func (r *ReplicateProvider) Close() error {
	if r.httpClient != nil {
		r.httpClient.CloseIdleConnections()
	}
	return nil
}

// callAPI, Replicate API'sine çağrı yapar
func (r *ReplicateProvider) callAPI(ctx context.Context, endpoint string, payload interface{}) (json.RawMessage, error) {
	_, err := json.Marshal(payload)
	if err != nil {
		return nil, fmt.Errorf("payload encoding hatası: %w", err)
	}

	for attempt := 0; attempt <= r.retryPolicy.MaxRetries; attempt++ {
		if attempt > 0 {
			backoff := time.Duration(float64(r.retryPolicy.InitialBackoff) *
				(r.retryPolicy.BackoffExponent * float64(attempt)))
			if backoff > r.retryPolicy.MaxBackoff {
				backoff = r.retryPolicy.MaxBackoff
			}
			time.Sleep(backoff)
		}

		req, err := http.NewRequestWithContext(
			ctx,
			"POST",
			r.baseURL+endpoint,
			io.Reader(nil),
		)
		if err != nil {
			continue
		}

		req.Header.Set("Content-Type", "application/json")
		req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", r.apiKey))

		resp, err := r.httpClient.Do(req)
		if err != nil {
			if IsRetryable(NewProviderError("replicate", 0, err)) {
				continue
			}
			return nil, err
		}
		defer resp.Body.Close()

		body, err := io.ReadAll(resp.Body)
		if err != nil {
			continue
		}

		if resp.StatusCode == http.StatusCreated || resp.StatusCode == http.StatusOK {
			return json.RawMessage(body), nil
		}

		if resp.StatusCode == http.StatusTooManyRequests {
			continue
		}

		if resp.StatusCode >= 500 {
			continue
		}

		return nil, fmt.Errorf("API error: %d", resp.StatusCode)
	}

	return nil, fmt.Errorf("max retries exceeded")
}

// =============================================================================
// GENERATION PROVIDER - SAM 2 SEGMENTATION
// =============================================================================

// SAM2SegmentationProvider, SAM 2 segmentasyonu yapar
type SAM2SegmentationProvider struct {
	apiKey      string
	baseURL     string
	httpClient  *http.Client
	config      *ProviderConfig
	retryPolicy *RetryPolicy
}

// NewSAM2SegmentationProvider, SAM 2 provider oluşturur
func NewSAM2SegmentationProvider(apiKey string, config *ProviderConfig) *SAM2SegmentationProvider {
	if config == nil {
		config = &ProviderConfig{
			Type:        ProviderTypeFalAI, // Fal.ai hosts SAM 2
			Timeout:     30 * time.Second,
			RetryPolicy: DefaultRetryPolicy(),
		}
	}

	return &SAM2SegmentationProvider{
		apiKey:      apiKey,
		baseURL:     config.BaseURL,
		config:      config,
		retryPolicy: config.RetryPolicy,
		httpClient: &http.Client{
			Timeout: config.Timeout,
		},
	}
}

// Name, provider adını döndürür
func (s *SAM2SegmentationProvider) Name() string {
	return "sam2_segmentation"
}

// Ping, provider'ın erişilebilir olup olmadığını kontrol eder
func (s *SAM2SegmentationProvider) Ping(ctx context.Context) error {
	return nil
}

// GetCreditCost, işlem kredisi maliyetini döndürür
func (s *SAM2SegmentationProvider) GetCreditCost(operationType string) int {
	return 100
}

// SegmentImage, görsel segmentasyonu yapar
func (s *SAM2SegmentationProvider) SegmentImage(
	ctx context.Context,
	imageURL string,
) (*SegmentationResult, error) {

	return s.SegmentJewelry(ctx, imageURL, map[string]interface{}{})
}

// SegmentJewelry, takı segmentasyonu yapar (SAM 2 optimized)
func (s *SAM2SegmentationProvider) SegmentJewelry(
	ctx context.Context,
	imageURL string,
	params map[string]interface{},
) (*SegmentationResult, error) {

	payload := map[string]interface{}{
		"image_url":  imageURL,
		"model":      "sam2",
		"auto_masks": true,
		"params":     params,
	}

	_, err := json.Marshal(payload)
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequestWithContext(ctx, "POST", s.baseURL+"/segment", nil)
	if err != nil {
		return nil, err
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", fmt.Sprintf("Key %s", s.apiKey))

	resp, err := s.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)

	var result SegmentationResult
	if err := json.Unmarshal(body, &result); err != nil {
		return nil, err
	}

	return &result, nil
}

// Close, provider bağlantısını kapatır
func (s *SAM2SegmentationProvider) Close() error {
	if s.httpClient != nil {
		s.httpClient.CloseIdleConnections()
	}
	return nil
}
