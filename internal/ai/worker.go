package ai

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"time"
)

// =============================================================================
// WORKER PIPELINE EXECUTOR (FOR BACKGROUND JOBS)
// =============================================================================

// WorkerConfig, worker pipeline konfigürasyonunu tutar
type WorkerConfig struct {
	MaxConcurrentJobs int
	JobTimeout        time.Duration
	RetryAttempts     int
	EnableNotifications bool
}

// GenerationJob, background işlemini temsil eder
type GenerationJob struct {
	ID                  string
	CompanyID           string
	UserID              string
	ProductID           string
	ProductImageURL     string
	ReferenceImageURL   string
	ProductCharacteristics *JewelryCharacteristics
	DesiredStyle        string
	OutputCount         int
	Quality             string
	Status              string // pending, processing, completed, failed
	CreatedAt           time.Time
	StartedAt           *time.Time
	CompletedAt         *time.Time
	Result              *FullPipelineResult
	ErrorMessage        string
}

// WorkerJobExecutor, background job'ları çalıştıran executor
type WorkerJobExecutor struct {
	aiService   *AIService
	workerConfig *WorkerConfig
	jobQueue    chan *GenerationJob
	resultChan  chan *GenerationJob
}

// NewWorkerJobExecutor, job executor oluşturur
func NewWorkerJobExecutor(
	aiService *AIService,
	config *WorkerConfig,
) *WorkerJobExecutor {
	
	if config == nil {
		config = &WorkerConfig{
			MaxConcurrentJobs: 5,
			JobTimeout:        5 * time.Minute,
			RetryAttempts:     3,
			EnableNotifications: true,
		}
	}

	return &WorkerJobExecutor{
		aiService:    aiService,
		workerConfig: config,
		jobQueue:     make(chan *GenerationJob, config.MaxConcurrentJobs*2),
		resultChan:   make(chan *GenerationJob, config.MaxConcurrentJobs),
	}
}

// Start, worker'ı başlatır
func (wje *WorkerJobExecutor) Start(ctx context.Context) {
	for i := 0; i < wje.workerConfig.MaxConcurrentJobs; i++ {
		go wje.workerLoop(ctx, i)
	}
}

// SubmitJob, job'ı queue'ye ekler
func (wje *WorkerJobExecutor) SubmitJob(job *GenerationJob) error {
	if job.ID == "" {
		job.ID = generateRequestID()
	}
	if job.CreatedAt.IsZero() {
		job.CreatedAt = time.Now()
	}

	select {
	case wje.jobQueue <- job:
		return nil
	case <-time.After(time.Second):
		return fmt.Errorf("job queue dolu")
	}
}

// GetResult, tamamlanan job sonucunu alır
func (wje *WorkerJobExecutor) GetResult() *GenerationJob {
	select {
	case result := <-wje.resultChan:
		return result
	case <-time.After(100 * time.Millisecond):
		return nil
	}
}

// workerLoop, worker döngüsü
func (wje *WorkerJobExecutor) workerLoop(ctx context.Context, workerID int) {
	for {
		select {
		case <-ctx.Done():
			log.Printf("Worker %d shutting down", workerID)
			return

		case job := <-wje.jobQueue:
			log.Printf("Worker %d processing job %s", workerID, job.ID)
			wje.executeJob(ctx, job)
			wje.resultChan <- job
		}
	}
}

// executeJob, job'ı çalıştırır
func (wje *WorkerJobExecutor) executeJob(ctx context.Context, job *GenerationJob) {
	job.Status = "processing"
	now := time.Now()
	job.StartedAt = &now

	// Context with timeout
	jobCtx, cancel := context.WithTimeout(ctx, wje.workerConfig.JobTimeout)
	defer cancel()

	// Pipeline request oluştur
	req := &FullPipelineRequest{
		ProductImageURL:     job.ProductImageURL,
		ReferenceImageURL:   job.ReferenceImageURL,
		ProductCharacteristics: job.ProductCharacteristics,
		CompanyID:           job.CompanyID,
		DesiredStyle:        job.DesiredStyle,
		OutputCount:         job.OutputCount,
		Quality:             job.Quality,
	}

	// Pipeline'ı çalıştır
	result := wje.aiService.ExecuteFullPipeline(jobCtx, req)

	// Job sonucunu güncelle
	job.Result = result
	completed := time.Now()
	job.CompletedAt = &completed

	if result.Status == "completed" {
		job.Status = "completed"
	} else {
		job.Status = "failed"
		if result.Error != nil {
			job.ErrorMessage = result.Error.Error()
		}
	}

	// Notification gönder (varsa)
	if wje.workerConfig.EnableNotifications {
		wje.sendNotification(job)
	}
}

// sendNotification, job tamamlandığında notification gönder
func (wje *WorkerJobExecutor) sendNotification(job *GenerationJob) {
	// TODO: Webhook, email, push notification gönderimi
	log.Printf("Job %s completed: %s", job.ID, job.Status)
}

// =============================================================================
// BATCH GENERATION PIPELINE
// =============================================================================

// BatchGenerationRequest, batch üretim isteğini tutar
type BatchGenerationRequest struct {
	BatchID             string
	CompanyID           string
	UserID              string
	Products            []*GenerationJob
	MaxParallel         int
	OnProgressCallback  func(progress int, total int)
}

// BatchGenerationResult, batch üretim sonucunu tutar
type BatchGenerationResult struct {
	BatchID         string
	TotalJobs       int
	CompletedJobs   int
	FailedJobs      int
	TotalCreditsUsed int
	TotalDuration   time.Duration
	Results         []*GenerationJob
	StartedAt       time.Time
	CompletedAt     time.Time
}

// ExecuteBatchGeneration, multiple ürün için batch üretimi yapar
func (wje *WorkerJobExecutor) ExecuteBatchGeneration(
	ctx context.Context,
	req *BatchGenerationRequest,
) *BatchGenerationResult {
	
	result := &BatchGenerationResult{
		BatchID:   req.BatchID,
		TotalJobs: len(req.Products),
		Results:   make([]*GenerationJob, 0, len(req.Products)),
		StartedAt: time.Now(),
	}

	// Semaphore pattern for limiting parallelism
	semaphore := make(chan struct{}, req.MaxParallel)
	defer close(semaphore)

	doneChan := make(chan *GenerationJob, len(req.Products))

	for _, product := range req.Products {
		go func(job *GenerationJob) {
			semaphore <- struct{}{}        // Acquire
			defer func() { <-semaphore }() // Release

			wje.executeJob(ctx, job)
			doneChan <- job
		}(product)
	}

	// Collect results
	for i := 0; i < len(req.Products); i++ {
		job := <-doneChan
		result.Results = append(result.Results, job)

		if job.Status == "completed" {
			result.CompletedJobs++
			if job.Result != nil {
				result.TotalCreditsUsed += job.Result.TotalCreditsUsed
			}
		} else {
			result.FailedJobs++
		}

		// Progress callback
		if req.OnProgressCallback != nil {
			req.OnProgressCallback(result.CompletedJobs+result.FailedJobs, result.TotalJobs)
		}
	}

	result.CompletedAt = time.Now()
	result.TotalDuration = result.CompletedAt.Sub(result.StartedAt)

	return result
}

// =============================================================================
// JOB PERSISTENCE (Database Integration)
// =============================================================================

// JobRepository, job'ları veritabanında saklamak için arayüz
type JobRepository interface {
	// SaveJob, job'ı veritabanına kaydeder
	SaveJob(ctx context.Context, job *GenerationJob) error

	// GetJob, ID'ye göre job'ı getirir
	GetJob(ctx context.Context, jobID string) (*GenerationJob, error)

	// GetJobsByCompany, firma'nın tüm job'larını getirir
	GetJobsByCompany(ctx context.Context, companyID string, limit int, offset int) ([]*GenerationJob, error)

	// UpdateJobStatus, job statusunu günceller
	UpdateJobStatus(ctx context.Context, jobID string, status string) error

	// DeleteJob, job'ı siler
	DeleteJob(ctx context.Context, jobID string) error

	// GetPendingJobs, pending job'ları getirir
	GetPendingJobs(ctx context.Context, limit int) ([]*GenerationJob, error)
}

// =============================================================================
// SEGMENT ANALYZER PIPELINE (Detailed workflow)
// =============================================================================

// SegmentationPipeline, detaylı segmentasyon pipeline'ı
type SegmentationPipeline struct {
	inputImage          string
	segmentationResult  *SegmentationResult
	qualityValidator    *QualityValidator
	maskPostProcessor   *MaskPostProcessor
	retryCount          int
	maxRetries          int
}

// NewSegmentationPipeline, pipeline oluşturur
func NewSegmentationPipeline(inputImage string) *SegmentationPipeline {
	return &SegmentationPipeline{
		inputImage:        inputImage,
		qualityValidator:  NewQualityValidator(),
		maskPostProcessor: NewMaskPostProcessor(),
		maxRetries:        3,
	}
}

// Execute, pipeline'ı çalıştırır
func (sp *SegmentationPipeline) Execute(
	ctx context.Context,
	segSvc *SegmentationService,
	companyID string,
) (*SegmentationResult, error) {
	
	// Step 1: Segmentasyon
	result, err := segSvc.SegmentJewelry(ctx, sp.inputImage, companyID, map[string]interface{}{})
	if err != nil {
		return nil, fmt.Errorf("segmentasyon başarısız: %w", err)
	}

	sp.segmentationResult = result

	// Step 2: Kalite kontrolü
	isValid, issues := sp.qualityValidator.ValidateSegmentationResult(result)
	if !isValid {
		log.Printf("Kalite kontrol başarısız: %v", issues)

		// Retry logic
		if sp.retryCount < sp.maxRetries {
			sp.retryCount++
			log.Printf("Yeniden deneme %d/%d", sp.retryCount, sp.maxRetries)
			return sp.Execute(ctx, segSvc, companyID)
		}

		return nil, fmt.Errorf("segmentasyon kalitesi yetersiz: %v", issues)
	}

	// Step 3: Mask post-processing
	processedMask, err := sp.maskPostProcessor.ProcessMask(ctx, result.MaskImageURL)
	if err != nil {
		log.Printf("Mask post-processing başarısız: %v", err)
	} else {
		result.MaskImageURL = processedMask
	}

	return result, nil
}

// =============================================================================
// FULL PIPELINE WITH DETAILED LOGGING
// =============================================================================

// DetailedPipelineExecutor, verbose logging ile pipeline çalıştırır
type DetailedPipelineExecutor struct {
	aiService *AIService
	logger    Logger
}

// NewDetailedPipelineExecutor, executor oluşturur
func NewDetailedPipelineExecutor(aiService *AIService, logger Logger) *DetailedPipelineExecutor {
	return &DetailedPipelineExecutor{
		aiService: aiService,
		logger:    logger,
	}
}

// ExecuteWithLogging, detaylı logging ile pipeline çalıştırır
func (dpe *DetailedPipelineExecutor) ExecuteWithLogging(
	ctx context.Context,
	req *FullPipelineRequest,
) *FullPipelineResult {
	
	dpe.logger.Info(fmt.Sprintf("🚀 Starting pipeline for company: %s", req.CompanyID))
	dpe.logger.Info(fmt.Sprintf("📦 Product: %s (%s in %s)",
		req.ProductCharacteristics.ProductType,
		req.ProductCharacteristics.DesignType,
		req.ProductCharacteristics.MetalColor,
	))

	startTime := time.Now()

	// Execute
	result := dpe.aiService.ExecuteFullPipeline(ctx, req)

	duration := time.Since(startTime)

	// Log results
	if result.Status == "completed" {
		dpe.logger.Info(fmt.Sprintf("✅ Pipeline completed successfully"))
		dpe.logger.Info(fmt.Sprintf("📊 Generated %d images in %v", len(result.GeneratedImages), duration))
		dpe.logger.Info(fmt.Sprintf("💳 Total credits used: %d", result.TotalCreditsUsed))

		if result.SegmentationResult != nil {
			dpe.logger.Info(fmt.Sprintf("🎯 Segmentation confidence: %.2f%%",
				result.SegmentationResult.SegmentationScore*100,
			))
		}

		for i, composite := range result.CompositedResults {
			dpe.logger.Info(fmt.Sprintf("  [%d] Blend quality: %.2f%%, Edge artifacts: %.2f%%",
				i+1,
				composite.BlendQualityScore*100,
				composite.EdgeArtifactScore*100,
			))
		}
	} else {
		dpe.logger.Error(fmt.Sprintf("❌ Pipeline failed: %v", result.Error))
		dpe.logger.Error(fmt.Sprintf("⏱️ Duration: %v", duration))
	}

	return result
}

// =============================================================================
// EXAMPLE USAGE
// =============================================================================

// ExampleWorkerUsage, worker kullanım örneği
func ExampleWorkerUsage() {
	// Setup
	config := &WorkerConfig{
		MaxConcurrentJobs: 5,
		JobTimeout:        5 * time.Minute,
		RetryAttempts:     3,
	}

	executor := NewWorkerJobExecutor(nil, config) // aiService would be passed here
	ctx := context.Background()
	executor.Start(ctx)

	// Submit jobs
	job1 := &GenerationJob{
		CompanyID: "company_1",
		ProductImageURL: "https://s3.example.com/ring1.jpg",
		ProductCharacteristics: &JewelryCharacteristics{
			ProductType: "ring",
			MetalColor: "yellow_gold",
			StoneCount: 1,
			StoneType: "diamond",
		},
		OutputCount: 4,
		Quality: "high",
	}

	executor.SubmitJob(job1)

	// Check results (in real scenario, this would be in a separate polling goroutine)
	time.Sleep(2 * time.Second)
	result := executor.GetResult()
	if result != nil {
		fmt.Printf("Job %s: %s\n", result.ID, result.Status)
	}
}

// =============================================================================
// BATCH EXAMPLE
// =============================================================================

// ExampleBatchUsage, batch kullanım örneği
func ExampleBatchUsage() {
	// Setup
	batchReq := &BatchGenerationRequest{
		BatchID:   "batch_2025_01_15",
		CompanyID: "company_kuyumcu",
		MaxParallel: 3,
		OnProgressCallback: func(progress, total int) {
			fmt.Printf("Progress: %d/%d\n", progress, total)
		},
	}

	// Add products
	for i := 0; i < 10; i++ {
		job := &GenerationJob{
			ProductID: fmt.Sprintf("product_%d", i),
			OutputCount: 4,
			Quality: "high",
		}
		batchReq.Products = append(batchReq.Products, job)
	}

	// Execute
	executor := NewWorkerJobExecutor(nil, &WorkerConfig{MaxConcurrentJobs: 3})
	result := executor.ExecuteBatchGeneration(context.Background(), batchReq)

	fmt.Printf("Batch Result:\n")
	fmt.Printf("Total: %d, Completed: %d, Failed: %d\n",
		result.TotalJobs, result.CompletedJobs, result.FailedJobs,
	)
	fmt.Printf("Total Credits: %d\n", result.TotalCreditsUsed)
	fmt.Printf("Duration: %v\n", result.TotalDuration)
}
