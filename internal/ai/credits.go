package ai

import (
	"context"
	"fmt"
	"time"
)

// =============================================================================
// CREDIT SERVICE INTERFACE
// =============================================================================

// CreditService, kredi yönetimini handle eder
type CreditService interface {
	// GetBalance, firma için kredi bakiyesini döndürür
	GetBalance(ctx context.Context, companyID string) (int, error)

	// Deduct, firma hesabından kredi düşer
	Deduct(ctx context.Context, companyID string, amount int, operationType string) error

	// CanDeduct, yeterli kredi var mı kontrolü yapar
	CanDeduct(ctx context.Context, companyID string, amount int) (bool, error)

	// Refund, işlem başarısız olursa kredi geri yükler
	Refund(ctx context.Context, companyID string, amount int, reason string) error

	// RecordOperation, işlem detaylarını kaydeder
	RecordOperation(ctx context.Context, record *OperationRecord) error

	// GetUsageStats, firma kullanım istatistiklerini döndürür
	GetUsageStats(ctx context.Context, companyID string, period string) (*UsageStats, error)
}

// OperationRecord, kredi işlemi kaydını tutar
type OperationRecord struct {
	ID            string
	CompanyID     string
	OperationType string // "analysis", "generation", "segmentation", "compositing"
	CreditsUsed   int
	BalanceBefore int
	BalanceAfter  int
	Status        string // "pending", "completed", "failed", "refunded"
	RequestID     string
	Metadata      map[string]interface{}
	CreatedAt     time.Time
	CompletedAt   *time.Time
}

// UsageStats, kredi kullanım istatistiklerini tutar
type UsageStats struct {
	CompanyID         string
	TotalCredits      int
	CreditsUsed       int
	CreditsRemaining  int
	Period            string
	OperationBreakdown map[string]int // operationType -> creditUsed
	AnalysisCount     int
	GenerationCount   int
	SegmentationCount int
	CompositingCount  int
	TotalOperations   int
	PeriodStart       time.Time
	PeriodEnd         time.Time
}

// =============================================================================
// CREDIT CALCULATOR
// =============================================================================

// CreditCalculator, kredi maliyetini hesaplar
type CreditCalculator interface {
	// CalculateAnalysisCost, vision analizi maliyetini hesaplar
	CalculateAnalysisCost(imageSize int, analysisType string) int

	// CalculateGenerationCost, görsel üretimi maliyetini hesaplar
	CalculateGenerationCost(modelID string, imageCount int, resolution string) int

	// CalculateSegmentationCost, segmentasyon maliyetini hesaplar
	CalculateSegmentationCost(imageSize int, modelID string) int

	// CalculateCompositingCost, tamamlama maliyetini hesaplar
	CalculateCompositingCost(quality string, imageCount int) int

	// CalculateBatchCost, batch işlem maliyetini hesaplar
	CalculateBatchCost(operations []string) int

	// GetBaseCost, temel maliyet tablosunu döndürür
	GetBaseCost(operationType string) int
}

// DefaultCreditCalculator, varsayılan kredi hesaplayıcı
type DefaultCreditCalculator struct {
	baseCosts map[string]int
}

// NewDefaultCreditCalculator, varsayılan hesaplayıcı oluşturur
func NewDefaultCreditCalculator() *DefaultCreditCalculator {
	return &DefaultCreditCalculator{
		baseCosts: map[string]int{
			"vision_analysis":           50,    // Vision model analizi
			"reference_analysis":        75,    // Referans görsel analizi
			"jewelry_extraction":        40,    // Takı özelliği çıkarma
			"image_generation":          200,   // Tek görsel üretimi
			"image_generation_batch":    350,   // 4-8 görsel üretimi
			"segmentation":              100,   // SAM 2 segmentasyon
			"compositing":               150,   // Tamamlama işlemi
			"relighting":                120,   // Işık değiştirme
			"full_pipeline":             500,   // Tam pipeline (analiz + üretim + compositing)
		},
	}
}

// CalculateAnalysisCost, vision analizi maliyetini hesaplar
func (c *DefaultCreditCalculator) CalculateAnalysisCost(imageSize int, analysisType string) int {
	baseCost := c.baseCosts["vision_analysis"]
	
	// İmaj boyutuna göre ayarlama
	if imageSize > 10*1024*1024 { // > 10MB
		baseCost = int(float32(baseCost) * 1.5)
	} else if imageSize > 5*1024*1024 { // > 5MB
		baseCost = int(float32(baseCost) * 1.25)
	}

	// Analiz türüne göre ayarlama
	if analysisType == "reference_analysis" {
		baseCost = c.baseCosts["reference_analysis"]
	} else if analysisType == "detailed" {
		baseCost = int(float32(baseCost) * 1.3)
	}

	return baseCost
}

// CalculateGenerationCost, görsel üretimi maliyetini hesaplar
func (c *DefaultCreditCalculator) CalculateGenerationCost(modelID string, imageCount int, resolution string) int {
	baseCost := c.baseCosts["image_generation"]

	// Çoklu görsel üretimi için indirim
	if imageCount > 3 {
		baseCost = c.baseCosts["image_generation_batch"]
	}

	// Çözünürlüğe göre ayarlama
	switch resolution {
	case "512x512":
		baseCost = int(float32(baseCost) * 0.8)
	case "1024x1024":
		baseCost = baseCost // default
	case "1536x1536":
		baseCost = int(float32(baseCost) * 1.5)
	case "2048x2048":
		baseCost = int(float32(baseCost) * 2.0)
	}

	// Model'e göre ayarlama
	if modelID == "flux-pro" {
		baseCost = int(float32(baseCost) * 1.3)
	} else if modelID == "stable-diffusion-3" {
		baseCost = int(float32(baseCost) * 0.9)
	}

	return baseCost * imageCount
}

// CalculateSegmentationCost, segmentasyon maliyetini hesaplar
func (c *DefaultCreditCalculator) CalculateSegmentationCost(imageSize int, modelID string) int {
	baseCost := c.baseCosts["segmentation"]

	// İmaj boyutuna göre ayarlama
	if imageSize > 5*1024*1024 {
		baseCost = int(float32(baseCost) * 1.2)
	}

	// Model'e göre ayarlama (SAM 2 vs diğerleri)
	if modelID == "sam2" {
		baseCost = int(float32(baseCost) * 1.0) // baseline
	} else if modelID == "mobile-sam" {
		baseCost = int(float32(baseCost) * 0.7)
	}

	return baseCost
}

// CalculateCompositingCost, tamamlama maliyetini hesaplar
func (c *DefaultCreditCalculator) CalculateCompositingCost(quality string, imageCount int) int {
	baseCost := c.baseCosts["compositing"]

	switch quality {
	case "standard":
		baseCost = int(float32(baseCost) * 0.8)
	case "high":
		baseCost = baseCost
	case "ultra":
		baseCost = int(float32(baseCost) * 1.5)
	}

	return baseCost * imageCount
}

// CalculateBatchCost, batch işlem maliyetini hesaplar
func (c *DefaultCreditCalculator) CalculateBatchCost(operations []string) int {
	totalCost := 0
	for _, op := range operations {
		if cost, ok := c.baseCosts[op]; ok {
			totalCost += cost
		}
	}
	// Batch işlem indirimi: %15
	return int(float32(totalCost) * 0.85)
}

// GetBaseCost, temel maliyet tablosunu döndürür
func (c *DefaultCreditCalculator) GetBaseCost(operationType string) int {
	if cost, ok := c.baseCosts[operationType]; ok {
		return cost
	}
	return 0
}

// =============================================================================
// CREDIT LIMITER
// =============================================================================

// CreditLimiter, kredi tabanlı hız sınırlaması yapar
type CreditLimiter struct {
	calculator CreditCalculator
	service    CreditService
}

// NewCreditLimiter, kredi limiter oluşturur
func NewCreditLimiter(calculator CreditCalculator, service CreditService) *CreditLimiter {
	return &CreditLimiter{
		calculator: calculator,
		service:    service,
	}
}

// CheckAndDeduct, kredi kontrolü ve düşme yapıldığında true döner
func (cl *CreditLimiter) CheckAndDeduct(ctx context.Context, companyID string, operationType string, amount int) (bool, error) {
	// Yeterli kredi var mı kontrol et
	canDeduct, err := cl.service.CanDeduct(ctx, companyID, amount)
	if err != nil {
		return false, fmt.Errorf("kredi kontrol hatası: %w", err)
	}

	if !canDeduct {
		return false, NewInsufficientCreditsError(amount, 0) // balance unknown
	}

	// Kredi düş
	if err := cl.service.Deduct(ctx, companyID, amount, operationType); err != nil {
		return false, fmt.Errorf("kredi düşme hatası: %w", err)
	}

	return true, nil
}

// EstimateOperationCost, işlem maliyetini tahmin eder
func (cl *CreditLimiter) EstimateOperationCost(operationType string) int {
	return cl.calculator.GetBaseCost(operationType)
}

// CanAfford, firma işlemi karşılayabilir mi kontrol eder
func (cl *CreditLimiter) CanAfford(ctx context.Context, companyID string, cost int) (bool, error) {
	balance, err := cl.service.GetBalance(ctx, companyID)
	if err != nil {
		return false, err
	}
	return balance >= cost, nil
}
