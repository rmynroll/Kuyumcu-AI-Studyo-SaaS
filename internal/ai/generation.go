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
// FLUX PRO GENERATION PROVIDER (via Fal.ai)
// =============================================================================

// FluxProGenerationProvider, Flux Pro modeli ile görsel üretimi yapar
type FluxProGenerationProvider struct {
	apiKey      string
	baseURL     string
	httpClient  *http.Client
	config      *ProviderConfig
	retryPolicy *RetryPolicy
}

// NewFluxProGenerationProvider, Flux Pro generation provider oluşturur
func NewFluxProGenerationProvider(apiKey string, config *ProviderConfig) *FluxProGenerationProvider {
	if config == nil {
		config = &ProviderConfig{
			Type:        ProviderTypeFalAI,
			BaseURL:     "https://api.fal.ai/v1",
			Timeout:     120 * time.Second,
			RetryPolicy: DefaultRetryPolicy(),
		}
	}

	return &FluxProGenerationProvider{
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
func (f *FluxProGenerationProvider) Name() string {
	return "flux_pro_generation"
}

// Ping, provider'ın erişilebilir olup olmadığını kontrol eder
func (f *FluxProGenerationProvider) Ping(ctx context.Context) error {
	req, err := http.NewRequestWithContext(ctx, "GET", f.baseURL+"/health", nil)
	if err != nil {
		return err
	}

	req.Header.Set("Authorization", fmt.Sprintf("Key %s", f.apiKey))

	resp, err := f.httpClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("health check failed: %d", resp.StatusCode)
	}

	return nil
}

// GetCreditCost, işlem kredisi maliyetini döndürür
func (f *FluxProGenerationProvider) GetCreditCost(operationType string) int {
	return 300 // Flux Pro yüksek kalite için daha pahalı
}

// GenerateImage, prompt'a göre görsel oluşturur
func (f *FluxProGenerationProvider) GenerateImage(
	ctx context.Context,
	prompt string,
	params map[string]interface{},
) (json.RawMessage, error) {

	payload := map[string]interface{}{
		"prompt":              prompt,
		"num_outputs":         getIntParam(params, "num_outputs", 1),
		"image_size":          "landscape_4_3", // 1024x768
		"num_inference_steps": getIntParam(params, "num_inference_steps", 50),
		"guidance_scale":      getFloatParam(params, "guidance_scale", 3.5),
		"seed":                getIntParam(params, "seed", -1),
	}

	// Negatif prompt ekle (varsa)
	if negPrompt, ok := params["negative_prompt"].(string); ok {
		payload["negative_prompt"] = negPrompt
	}

	return f.callGenerationAPI(ctx, "/generate", payload)
}

// CompositeImage, tamamlama işlemini yapar
func (f *FluxProGenerationProvider) CompositeImage(
	ctx context.Context,
	req *CompositingRequest,
) (*CompositingResult, error) {

	payload := map[string]interface{}{
		"product_mask_url":     req.ProductMaskURL,
		"original_product_url": req.OriginalProductURL,
		"generated_scene_url":  req.GeneratedSceneURL,
		"relighting_style":     req.RelightingStyle,
		"quality":              req.Quality,
		"output_format":        req.OutputFormat,
	}

	resp, err := f.callGenerationAPI(ctx, "/composite", payload)
	if err != nil {
		return nil, err
	}

	var result CompositingResult
	if err := json.Unmarshal(resp, &result); err != nil {
		return nil, fmt.Errorf("response parsing hatası: %w", err)
	}

	return &result, nil
}

// GenerateWithCompositing, compositing-first yaklaşımıyla görsel oluşturur
// Bu method:
// 1. Arka plan ve sahne oluşturur (takı haricinde)
// 2. Maskeyi kullanarak takıyı ön plana getir
// 3. Işığı ve yansımaları ayarla
func (f *FluxProGenerationProvider) GenerateWithCompositing(
	ctx context.Context,
	productMask string,
	productURL string,
	prompt string,
) (*CompositingResult, error) {

	// Compositing-first payload
	payload := map[string]interface{}{
		"method":            "compositing_first",
		"product_mask":      productMask,
		"product_image":     productURL,
		"generation_prompt": prompt,
		"preserve_product":  true,
		"auto_relighting":   true,
		"blend_mode":        "seamless",
		"edge_enhancement":  true,
	}

	resp, err := f.callGenerationAPI(ctx, "/generate-with-compositing", payload)
	if err != nil {
		return nil, err
	}

	var result CompositingResult
	if err := json.Unmarshal(resp, &result); err != nil {
		return nil, err
	}

	return &result, nil
}

// Close, provider bağlantısını kapatır
func (f *FluxProGenerationProvider) Close() error {
	if f.httpClient != nil {
		f.httpClient.CloseIdleConnections()
	}
	return nil
}

// callGenerationAPI, Fal.ai generation API'sine çağrı yapar
func (f *FluxProGenerationProvider) callGenerationAPI(
	ctx context.Context,
	endpoint string,
	payload interface{},
) (json.RawMessage, error) {

	_, err := json.Marshal(payload)
	if err != nil {
		return nil, fmt.Errorf("payload encoding hatası: %w", err)
	}

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
			continue
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

		if resp.StatusCode == http.StatusTooManyRequests {
			lastErr = ErrProviderRateLimit
			continue
		}

		lastErr = fmt.Errorf("API error: %d", resp.StatusCode)
	}

	return nil, lastErr
}

// =============================================================================
// STABLE DIFFUSION 3 PROVIDER (via Replicate)
// =============================================================================

// StableDiffusion3GenerationProvider, Stable Diffusion 3 ile görsel üretimi yapar
type StableDiffusion3GenerationProvider struct {
	apiKey      string
	baseURL     string
	httpClient  *http.Client
	config      *ProviderConfig
	retryPolicy *RetryPolicy
}

// NewStableDiffusion3GenerationProvider, SD3 provider oluşturur
func NewStableDiffusion3GenerationProvider(apiKey string, config *ProviderConfig) *StableDiffusion3GenerationProvider {
	if config == nil {
		config = &ProviderConfig{
			Type:        ProviderTypeReplicate,
			BaseURL:     "https://api.replicate.com/v1",
			Timeout:     120 * time.Second,
			RetryPolicy: DefaultRetryPolicy(),
		}
	}

	return &StableDiffusion3GenerationProvider{
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
func (s *StableDiffusion3GenerationProvider) Name() string {
	return "stable_diffusion_3"
}

// Ping, provider'ın erişilebilir olup olmadığını kontrol eder
func (s *StableDiffusion3GenerationProvider) Ping(ctx context.Context) error {
	return nil
}

// GetCreditCost, işlem kredisi maliyetini döndürür
func (s *StableDiffusion3GenerationProvider) GetCreditCost(operationType string) int {
	return 250 // SD3 Flux Pro'dan daha ucuz
}

// GenerateImage, prompt'a göre görsel oluşturur
func (s *StableDiffusion3GenerationProvider) GenerateImage(
	ctx context.Context,
	prompt string,
	params map[string]interface{},
) (json.RawMessage, error) {

	payload := map[string]interface{}{
		"prompt":          prompt,
		"output_count":    getIntParam(params, "num_outputs", 1),
		"output_format":   "png",
		"guidance_scale":  getFloatParam(params, "guidance_scale", 7.5),
		"negative_prompt": getStringParam(params, "negative_prompt", ""),
	}

	return s.callGenerationAPI(ctx, "/predictions", payload)
}

// CompositeImage, tamamlama işlemini yapar
func (s *StableDiffusion3GenerationProvider) CompositeImage(
	ctx context.Context,
	req *CompositingRequest,
) (*CompositingResult, error) {

	return nil, fmt.Errorf("compositing currently not supported for SD3")
}

// GenerateWithCompositing, compositing-first yaklaşımıyla görsel oluşturur
func (s *StableDiffusion3GenerationProvider) GenerateWithCompositing(
	ctx context.Context,
	productMask string,
	productURL string,
	prompt string,
) (*CompositingResult, error) {

	return nil, fmt.Errorf("compositing currently not supported for SD3")
}

// Close, provider bağlantısını kapatır
func (s *StableDiffusion3GenerationProvider) Close() error {
	if s.httpClient != nil {
		s.httpClient.CloseIdleConnections()
	}
	return nil
}

// callGenerationAPI, Replicate API'sine çağrı yapar
func (s *StableDiffusion3GenerationProvider) callGenerationAPI(
	ctx context.Context,
	endpoint string,
	payload interface{},
) (json.RawMessage, error) {

	_, err := json.Marshal(payload)
	if err != nil {
		return nil, err
	}

	for attempt := 0; attempt <= s.retryPolicy.MaxRetries; attempt++ {
		if attempt > 0 {
			time.Sleep(time.Duration(attempt) * time.Second)
		}

		req, err := http.NewRequestWithContext(
			ctx,
			"POST",
			s.baseURL+endpoint,
			io.Reader(nil),
		)
		if err != nil {
			continue
		}

		req.Header.Set("Content-Type", "application/json")
		req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", s.apiKey))

		resp, err := s.httpClient.Do(req)
		if err != nil {
			continue
		}
		defer resp.Body.Close()

		body, _ := io.ReadAll(resp.Body)

		if resp.StatusCode == http.StatusCreated || resp.StatusCode == http.StatusOK {
			return json.RawMessage(body), nil
		}
	}

	return nil, fmt.Errorf("generation failed after retries")
}

// =============================================================================
// UTILITY HELPER FUNCTIONS
// =============================================================================

// getIntParam, params haritasından int değer alır
func getIntParam(params map[string]interface{}, key string, defaultVal int) int {
	if params == nil {
		return defaultVal
	}

	if val, ok := params[key].(int); ok {
		return val
	}

	if val, ok := params[key].(float64); ok {
		return int(val)
	}

	return defaultVal
}

// getFloatParam, params haritasından float değer alır
func getFloatParam(params map[string]interface{}, key string, defaultVal float64) float64 {
	if params == nil {
		return defaultVal
	}

	if val, ok := params[key].(float64); ok {
		return val
	}

	if val, ok := params[key].(int); ok {
		return float64(val)
	}

	return defaultVal
}

// getStringParam, params haritasından string değer alır
func getStringParam(params map[string]interface{}, key string, defaultVal string) string {
	if params == nil {
		return defaultVal
	}

	if val, ok := params[key].(string); ok {
		return val
	}

	return defaultVal
}

// =============================================================================
// MOCK GENERATION PROVIDER (TESTING)
// =============================================================================

// MockGenerationProvider, testing için mock generation provider
type MockGenerationProvider struct{}

// Name, provider adını döndürür
func (m *MockGenerationProvider) Name() string {
	return "mock_generation"
}

// Ping, provider'ın erişilebilir olup olmadığını kontrol eder
func (m *MockGenerationProvider) Ping(ctx context.Context) error {
	return nil
}

// GetCreditCost, işlem kredisi maliyetini döndürür
func (m *MockGenerationProvider) GetCreditCost(operationType string) int {
	return 100
}

// GenerateImage, prompt'a göre görsel oluşturur
func (m *MockGenerationProvider) GenerateImage(
	ctx context.Context,
	prompt string,
	params map[string]interface{},
) (json.RawMessage, error) {

	result := map[string]interface{}{
		"images": []string{
			"https://example.com/generated_1.png",
			"https://example.com/generated_2.png",
		},
	}

	return json.Marshal(result)
}

// CompositeImage, tamamlama işlemini yapar
func (m *MockGenerationProvider) CompositeImage(
	ctx context.Context,
	req *CompositingRequest,
) (*CompositingResult, error) {

	return &CompositingResult{
		CompositeImageURL:   "https://example.com/composited.png",
		CompositeThumbURL:   "https://example.com/composited_thumb.png",
		BlendQualityScore:   0.95,
		EdgeArtifactScore:   0.05,
		LightingConsistency: 0.92,
		ProcessedAt:         time.Now(),
	}, nil
}

// GenerateWithCompositing, compositing-first yaklaşımıyla görsel oluşturur
func (m *MockGenerationProvider) GenerateWithCompositing(
	ctx context.Context,
	productMask string,
	productURL string,
	prompt string,
) (*CompositingResult, error) {

	return m.CompositeImage(ctx, &CompositingRequest{})
}

// Close, provider bağlantısını kapatır
func (m *MockGenerationProvider) Close() error {
	return nil
}

type GenerationFeedback struct {
	ID           string    `json:"id" db:"id"`
	GenerationID string    `json:"generation_id" db:"generation_id"`
	UserID       string    `json:"user_id" db:"user_id"`
	Rating       int       `json:"rating" db:"rating"` // 1-5 arası
	IssueType    string    `json:"issue_type" db:"issue_type"` // "stone_distorted", "color_wrong", "blur"
	Comment      string    `json:"comment" db:"comment"`
	NeedsReview  bool      `json:"needs_review" db:"needs_review"` // Admin paneline düşmesi için flag
	CreatedAt    time.Time `json:"created_at" db:"created_at"`
}