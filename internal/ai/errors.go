package ai

import (
	"errors"
	"fmt"
)

// =============================================================================
// ERROR TYPES
// =============================================================================

// AIError, AI modülünün temel hata tipidir
type AIError struct {
	Code       string
	Message    string
	StatusCode int
	Err        error
	RequestID  string
	Timestamp  string
}

// Error, AIError'un string temsilini döndürür
func (e *AIError) Error() string {
	if e.Err != nil {
		return fmt.Sprintf("[%s] %s: %v (req_id: %s)", e.Code, e.Message, e.Err, e.RequestID)
	}
	return fmt.Sprintf("[%s] %s (req_id: %s)", e.Code, e.Message, e.RequestID)
}

// Unwrap, kapsanan hatayı döndürür
func (e *AIError) Unwrap() error {
	return e.Err
}

// =============================================================================
// PREDEFINED ERRORS
// =============================================================================

// Credit-related errors
var (
	ErrInsufficientCredits = &AIError{
		Code:       "INSUFFICIENT_CREDITS",
		Message:    "Yeterli kredi yok",
		StatusCode: 402,
	}

	ErrCreditSystemFailure = &AIError{
		Code:       "CREDIT_SYSTEM_FAILURE",
		Message:    "Kredi sistemi hatası",
		StatusCode: 500,
	}

	ErrCreditDeductionFailed = &AIError{
		Code:       "CREDIT_DEDUCTION_FAILED",
		Message:    "Kredi düşme başarısız",
		StatusCode: 500,
	}
)

// Provider-related errors
var (
	ErrProviderNotFound = &AIError{
		Code:       "PROVIDER_NOT_FOUND",
		Message:    "Provider bulunamadı",
		StatusCode: 404,
	}

	ErrProviderUnreachable = &AIError{
		Code:       "PROVIDER_UNREACHABLE",
		Message:    "Provider ulaşılamıyor",
		StatusCode: 503,
	}

	ErrProviderRateLimit = &AIError{
		Code:       "PROVIDER_RATE_LIMIT",
		Message:    "Provider hız sınırına ulaşıldı",
		StatusCode: 429,
	}

	ErrProviderQuotaExceeded = &AIError{
		Code:       "PROVIDER_QUOTA_EXCEEDED",
		Message:    "Provider kota aşıldı",
		StatusCode: 429,
	}

	ErrInvalidAPIKey = &AIError{
		Code:       "INVALID_API_KEY",
		Message:    "Geçersiz API anahtarı",
		StatusCode: 401,
	}
)

// Processing errors
var (
	ErrImageProcessingFailed = &AIError{
		Code:       "IMAGE_PROCESSING_FAILED",
		Message:    "Görsel işleme başarısız",
		StatusCode: 500,
	}

	ErrSegmentationFailed = &AIError{
		Code:       "SEGMENTATION_FAILED",
		Message:    "Segmentasyon başarısız",
		StatusCode: 500,
	}

	ErrGenerationFailed = &AIError{
		Code:       "GENERATION_FAILED",
		Message:    "Üretim başarısız",
		StatusCode: 500,
	}

	ErrAnalysisFailed = &AIError{
		Code:       "ANALYSIS_FAILED",
		Message:    "Analiz başarısız",
		StatusCode: 500,
	}

	ErrCompositingFailed = &AIError{
		Code:       "COMPOSITING_FAILED",
		Message:    "Tamamlama başarısız",
		StatusCode: 500,
	}
)

// Input validation errors
var (
	ErrInvalidImageURL = &AIError{
		Code:       "INVALID_IMAGE_URL",
		Message:    "Geçersiz görsel URL",
		StatusCode: 400,
	}

	ErrInvalidPrompt = &AIError{
		Code:       "INVALID_PROMPT",
		Message:    "Geçersiz prompt",
		StatusCode: 400,
	}

	ErrMissingRequiredParameter = &AIError{
		Code:       "MISSING_REQUIRED_PARAMETER",
		Message:    "Zorunlu parametre eksik",
		StatusCode: 400,
	}
)

// Timeout errors
var (
	ErrProcessingTimeout = &AIError{
		Code:       "PROCESSING_TIMEOUT",
		Message:    "İşlem zaman aşımı",
		StatusCode: 408,
	}

	ErrRequestTimeout = &AIError{
		Code:       "REQUEST_TIMEOUT",
		Message:    "İstek zaman aşımı",
		StatusCode: 408,
	}
)

// =============================================================================
// ERROR CONSTRUCTORS
// =============================================================================

// NewAIError, yeni bir AI hatası oluşturur
func NewAIError(code, message string, statusCode int, err error) *AIError {
	return &AIError{
		Code:       code,
		Message:    message,
		StatusCode: statusCode,
		Err:        err,
	}
}

// NewInsufficientCreditsError, kredi yetersizlik hatası oluşturur
func NewInsufficientCreditsError(required, available int) *AIError {
	return &AIError{
		Code:       "INSUFFICIENT_CREDITS",
		Message:    fmt.Sprintf("Gerekli %d kredi, mevcut %d kredi", required, available),
		StatusCode: 402,
	}
}

// NewProviderError, provider hatası oluşturur
func NewProviderError(provider string, statusCode int, err error) *AIError {
	return &AIError{
		Code:       "PROVIDER_ERROR",
		Message:    fmt.Sprintf("%s provider hatası", provider),
		StatusCode: statusCode,
		Err:        err,
	}
}

// NewTimeoutError, zaman aşımı hatası oluşturur
func NewTimeoutError(operation string) *AIError {
	return &AIError{
		Code:       "OPERATION_TIMEOUT",
		Message:    fmt.Sprintf("%s işlemi zaman aşımına uğradı", operation),
		StatusCode: 408,
	}
}

// =============================================================================
// ERROR CHECKING
// =============================================================================

// IsAIError, verilen hatanın AIError olup olmadığını kontrol eder
func IsAIError(err error) bool {
	var aiErr *AIError
	return errors.As(err, &aiErr)
}

// GetAIError, AIError'u extract eder
func GetAIError(err error) *AIError {
	var aiErr *AIError
	if errors.As(err, &aiErr) {
		return aiErr
	}
	return nil
}

// IsRetryable, hatanın yeniden deneyebilir olup olmadığını kontrol eder
func IsRetryable(err error) bool {
	if aiErr := GetAIError(err); aiErr != nil {
		switch aiErr.Code {
		case "PROVIDER_RATE_LIMIT",
			"PROVIDER_UNREACHABLE",
			"REQUEST_TIMEOUT",
			"PROCESSING_TIMEOUT":
			return true
		}
	}
	return false
}

// IsFatal, hatanın ölümcül (yeniden denenemez) olup olmadığını kontrol eder
func IsFatal(err error) bool {
	if aiErr := GetAIError(err); aiErr != nil {
		switch aiErr.Code {
		case "INVALID_API_KEY",
			"INSUFFICIENT_CREDITS",
			"INVALID_IMAGE_URL",
			"INVALID_PROMPT":
			return true
		}
	}
	return false
}
