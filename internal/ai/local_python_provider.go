package ai

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"time"
)

// LocalPythonSegmentationProvider executes the background removal python script locally
type LocalPythonSegmentationProvider struct {
	pythonPath string
	scriptPath string
	provider   string // "rembg" or "removebg"
	model      string // e.g. "birefnet-general", "u2net"
	apiKey     string // removebg API key
	config     *ProviderConfig
}

// NewLocalPythonSegmentationProvider creates a new LocalPythonSegmentationProvider
func NewLocalPythonSegmentationProvider(config *ProviderConfig) *LocalPythonSegmentationProvider {
	pythonPath := os.Getenv("PYTHON_PATH")
	if pythonPath == "" {
		pythonPath = "python"
	}

	scriptPath := os.Getenv("BACKGROUND_REMOVER_SCRIPT_PATH")
	if scriptPath == "" {
		scriptPath = filepath.Join("internal", "ai", "scripts", "remove_background.py")
		if _, err := os.Stat(scriptPath); os.IsNotExist(err) {
			altPath := filepath.Join("scripts", "remove_background.py")
			if _, errAlt := os.Stat(altPath); errAlt == nil {
				scriptPath = altPath
			}
		}
	}

	provider := os.Getenv("BACKGROUND_REMOVER_PROVIDER")
	if provider == "" {
		provider = "rembg"
	}

	model := os.Getenv("BACKGROUND_REMOVER_MODEL")
	if model == "" {
		model = "birefnet-general"
	}

	apiKey := os.Getenv("REMOVE_BG_API_KEY")

	return &LocalPythonSegmentationProvider{
		pythonPath: pythonPath,
		scriptPath: scriptPath,
		provider:   provider,
		model:      model,
		apiKey:     apiKey,
		config:     config,
	}
}

// Name returns the provider name
func (p *LocalPythonSegmentationProvider) Name() string {
	return "local_python"
}

// Ping checks if Python is executable
func (p *LocalPythonSegmentationProvider) Ping(ctx context.Context) error {
	cmd := exec.CommandContext(ctx, p.pythonPath, "--version")
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("python check failed: %w", err)
	}
	return nil
}

// GetCreditCost returns the credit cost for this provider
func (p *LocalPythonSegmentationProvider) GetCreditCost(operationType string) int {
	if p.provider == "removebg" {
		if p.config != nil && p.config.ThrottleConfig != nil {
			return p.config.ThrottleConfig.CreditCost
		}
		return 100 // removebg is paid
	}
	return 0 // local processing is free
}

// Close closes the provider
func (p *LocalPythonSegmentationProvider) Close() error {
	return nil
}

// SegmentImage segments an image
func (p *LocalPythonSegmentationProvider) SegmentImage(ctx context.Context, imageURL string) (*SegmentationResult, error) {
	return p.SegmentJewelry(ctx, imageURL, nil)
}

// SegmentJewelry performs background removal on a jewelry image
func (p *LocalPythonSegmentationProvider) SegmentJewelry(
	ctx context.Context,
	imageURL string,
	params map[string]interface{},
) (*SegmentationResult, error) {
	// Create outputs under uploads directory
	err := os.MkdirAll("uploads", 0755)
	if err != nil {
		return nil, fmt.Errorf("failed to create uploads dir: %w", err)
	}

	timestamp := time.Now().UnixNano()
	cleanPath := filepath.Join("uploads", fmt.Sprintf("clean_%d.png", timestamp))
	maskPath := filepath.Join("uploads", fmt.Sprintf("mask_%d.png", timestamp))
	inpaintingMaskPath := filepath.Join("uploads", fmt.Sprintf("inpainting_mask_%d.png", timestamp))

	// Allow overrides from params or fallback to env variables, then defaults
	provider := p.provider
	if pVal, ok := params["provider"].(string); ok {
		provider = pVal
	}

	model := p.model
	if mVal, ok := params["model"].(string); ok {
		model = mVal
	}

	alphaMatting := true
	if amEnv := os.Getenv("BACKGROUND_REMOVER_ALPHA_MATTING"); amEnv == "false" {
		alphaMatting = false
	}
	if pVal, ok := params["alpha_matting"].(bool); ok {
		alphaMatting = pVal
	}

	featherRadius := 2.0
	if frEnv := os.Getenv("BACKGROUND_REMOVER_FEATHER_RADIUS"); frEnv != "" {
		if val, err := strconv.ParseFloat(frEnv, 64); err == nil {
			featherRadius = val
		}
	}
	if pVal, ok := params["feather_radius"].(float64); ok {
		featherRadius = pVal
	} else if pVal, ok := params["feather_radius"].(int); ok {
		featherRadius = float64(pVal)
	}

	args := []string{
		p.scriptPath,
		"--input", imageURL,
		"--output-clean", cleanPath,
		"--output-mask", maskPath,
		"--output-inpainting-mask", inpaintingMaskPath,
		"--provider", provider,
	}

	if provider == "rembg" {
		args = append(args, "--model", model)
		if alphaMatting {
			args = append(args, "--alpha-matting")
		}
		args = append(args, "--feather-radius", strconv.FormatFloat(featherRadius, 'f', -1, 64))
	} else if provider == "removebg" {
		apiKey := p.apiKey
		if kVal, ok := params["api_key"].(string); ok {
			apiKey = kVal
		}
		if apiKey == "" {
			return nil, fmt.Errorf("remove.bg API key is required")
		}
		args = append(args, "--api-key", apiKey)
	}

	cmd := exec.CommandContext(ctx, p.pythonPath, args...)
	
	// Use separate stdout and stderr buffers to avoid download logs polluting stdout
	var stdoutBuf bytes.Buffer
	var stderrBuf bytes.Buffer
	cmd.Stdout = &stdoutBuf
	cmd.Stderr = &stderrBuf

	if err := cmd.Run(); err != nil {
		return nil, fmt.Errorf("background removal script failed: %w (stderr: %s)", err, stderrBuf.String())
	}

	stdoutBytes := stdoutBuf.Bytes()

	// Parse JSON output from stdout
	var scriptResult struct {
		Success           bool    `json:"success"`
		Error             string  `json:"error"`
		CleanJewelryURL   string  `json:"clean_jewelry_url"`
		MaskImageURL      string  `json:"mask_image_url"`
		InpaintingMaskURL string  `json:"inpainting_mask_url"`
		SegmentationScore float32 `json:"segmentation_score"`
		BoundingBox       [4]int  `json:"bounding_box"`
		MaskPixelArea     int     `json:"mask_pixel_area"`
		ModelUsed         string  `json:"model_used"`
	}

	if err := json.Unmarshal(stdoutBytes, &scriptResult); err != nil {
		return nil, fmt.Errorf("failed to parse script output: %s (stderr: %s): %w", string(stdoutBytes), stderrBuf.String(), err)
	}

	if !scriptResult.Success {
		return nil, fmt.Errorf("background removal failed: %s (stderr: %s)", scriptResult.Error, stderrBuf.String())
	}

	// Convert paths to absolute file:// URLs
	cleanAbs, _ := filepath.Abs(scriptResult.CleanJewelryURL)
	maskAbs, _ := filepath.Abs(scriptResult.MaskImageURL)
	inpaintingMaskAbs := ""
	if scriptResult.InpaintingMaskURL != "" {
		abs, _ := filepath.Abs(scriptResult.InpaintingMaskURL)
		inpaintingMaskAbs = "file:///" + filepath.ToSlash(abs)
	}

	return &SegmentationResult{
		MaskImageURL:      "file:///" + filepath.ToSlash(maskAbs),
		CleanJewelryURL:   "file:///" + filepath.ToSlash(cleanAbs),
		InpaintingMaskURL:  inpaintingMaskAbs,
		SegmentationScore: scriptResult.SegmentationScore,
		BoundingBox:       scriptResult.BoundingBox,
		MaskPixelArea:     scriptResult.MaskPixelArea,
		ProcessedAt:       time.Now(),
		ModelVersion:      scriptResult.ModelUsed,
	}, nil
}
