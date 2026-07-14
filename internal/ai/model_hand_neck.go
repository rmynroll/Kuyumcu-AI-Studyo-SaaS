package ai

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"time"
)

// AIServiceRequest Stable Diffusion / ComfyUI API'sine gidecek parametreler
type AIServiceRequest struct {
	UserImageURL   string                 `json:"user_image_url"` // Kullanıcının yüklediği orijinal takı
	TemplateID     string                 `json:"template_id"`    // "model_hand" veya "model_neck"
	Prompt         string                 `json:"prompt"`
	NegativePrompt string                 `json:"negative_prompt"`
	ControlWeights map[string]interface{} `json:"control_weights"` // IP-Adapter ve ControlNet ayarları
}

// TemplateAnchor şablon üzerine yerleşim çapa (anchor) metadata parametreleri
type TemplateAnchor struct {
	X               int     `json:"x"`
	Y               int     `json:"y"`
	Rotation        float64 `json:"rotation"`
	Scale           float64 `json:"scale"`
	PerspectiveSkew float64 `json:"perspective_skew"`
	BackgroundURL   string  `json:"background_url"`
}

// PredefinedTemplates el ve boyun şablonlarının önceden tanımlanmış çapa (anchor) noktaları
var PredefinedTemplates = map[string]TemplateAnchor{
	"model_hand": {
		X:               512,
		Y:               640,
		Rotation:        -12,
		Scale:           0.25,
		PerspectiveSkew: 0.15,
		BackgroundURL:   "https://images.unsplash.com/photo-1602751584552-8ba73aad10e1?q=80&w=1024&auto=format&fit=crop",
	},
	"model_neck": {
		X:               512,
		Y:               580,
		Rotation:        0,
		Scale:           0.35,
		PerspectiveSkew: 0.0,
		BackgroundURL:   "https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=1024&auto=format&fit=crop",
	},
}

// ProcessModelPlacement takıyı manken üzerine hatasız yerleştiren fonksiyon
func ProcessModelPlacement(userImageURL string, templateID string) ([]byte, error) {
	// 1. Şablon önceden tanımlı çapa (anchor) noktalarına sahip mi kontrol et
	if anchor, ok := PredefinedTemplates[templateID]; ok {
		// Python konumlandırma script'i yolunu çöz
		pythonPath := os.Getenv("PYTHON_PATH")
		if pythonPath == "" {
			pythonPath = "python"
		}

		scriptPath := os.Getenv("POSITION_JEWELRY_SCRIPT_PATH")
		if scriptPath == "" {
			scriptPath = filepath.Join("internal", "ai", "scripts", "position_jewelry.py")
			if _, err := os.Stat(scriptPath); os.IsNotExist(err) {
				altPath := filepath.Join("scripts", "position_jewelry.py")
				if _, errAlt := os.Stat(altPath); errAlt == nil {
					scriptPath = altPath
				}
			}
		}

		// Çıktı dosyasını uploads dizinine oluştur
		if err := os.MkdirAll("uploads", 0755); err != nil {
			return nil, fmt.Errorf("failed to create uploads directory: %w", err)
		}

		timestamp := time.Now().UnixNano()
		outputPath := filepath.Join("uploads", fmt.Sprintf("placement_%d.png", timestamp))

		colorMatch := true
		if cmEnv := os.Getenv("BACKGROUND_REMOVER_COLOR_MATCH"); cmEnv == "false" {
			colorMatch = false
		}

		shadow := true
		if sEnv := os.Getenv("BACKGROUND_REMOVER_SHADOW"); sEnv == "false" {
			shadow = false
		}

		shadowOpacity := 0.3
		if soEnv := os.Getenv("BACKGROUND_REMOVER_SHADOW_OPACITY"); soEnv != "" {
			if val, err := strconv.ParseFloat(soEnv, 64); err == nil {
				shadowOpacity = val
			}
		}

		shadowBlur := 8.0
		if sbEnv := os.Getenv("BACKGROUND_REMOVER_SHADOW_BLUR"); sbEnv != "" {
			if val, err := strconv.ParseFloat(sbEnv, 64); err == nil {
				shadowBlur = val
			}
		}

		brightnessBalance := true
		if bbEnv := os.Getenv("BACKGROUND_REMOVER_BRIGHTNESS_BALANCE"); bbEnv == "false" {
			brightnessBalance = false
		}

		args := []string{
			scriptPath,
			"--background", anchor.BackgroundURL,
			"--jewelry", userImageURL,
			"--output", outputPath,
			"--x", strconv.Itoa(anchor.X),
			"--y", strconv.Itoa(anchor.Y),
			"--scale", strconv.FormatFloat(anchor.Scale, 'f', -1, 64),
			"--rotation", strconv.FormatFloat(anchor.Rotation, 'f', -1, 64),
			"--skew", strconv.FormatFloat(anchor.PerspectiveSkew, 'f', -1, 64),
		}

		if !colorMatch {
			args = append(args, "--no-color-match")
		}
		if !shadow {
			args = append(args, "--no-shadow")
		} else {
			args = append(args, "--shadow-opacity", strconv.FormatFloat(shadowOpacity, 'f', -1, 64))
			args = append(args, "--shadow-blur", strconv.FormatFloat(shadowBlur, 'f', -1, 64))
		}
		if !brightnessBalance {
			args = append(args, "--no-brightness-balance")
		}

		// Scripti çalıştır
		cmd := exec.Command(pythonPath, args...)
		var stderrBuf bytes.Buffer
		cmd.Stderr = &stderrBuf

		if err := cmd.Run(); err != nil {
			return nil, fmt.Errorf("positioning script failed: %w (stderr: %s)", err, stderrBuf.String())
		}

		// Üretilen görsel verisini oku
		data, err := os.ReadFile(outputPath)
		if err != nil {
			return nil, fmt.Errorf("failed to read positioned image output: %w", err)
		}

		return data, nil
	}

	// 2. Tanımlı şablon yoksa eski API servisine fallback yap
	apiURL := "https://api.buildkor.ai/v1/generation/comfyui"

	var specificPrompt string
	switch templateID {
	case "model_hand":
		specificPrompt = "a close-up elegant shot of a woman's hand wearing the jewelry ring, highly detailed skin texture, professional manicure, luxury jewelry photography"
	case "model_neck":
		specificPrompt = "a professional studio lookbook shot of a woman's neck and collarbone wearing the jewelry necklace, soft studio lighting"
	default:
		specificPrompt = "professional jewelry studio shot"
	}

	requestBody := AIServiceRequest{
		UserImageURL:   userImageURL,
		TemplateID:     templateID,
		Prompt:         fmt.Sprintf("%s, hyper-realistic, maintaining exact design of the jewelry, high resolution, 8k", specificPrompt),
		NegativePrompt: "deformed jewelry, changed gemstone shape, altered metal details, low quality, blurred jewelry, extra stones",
		ControlWeights: map[string]interface{}{
			"ip_adapter_scale":     0.85,
			"controlnet_structure": "canny_edge",
		},
	}

	jsonData, err := json.Marshal(requestBody)
	if err != nil {
		return nil, err
	}

	resp, err := http.Post(apiURL, "application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("AI servisi hata kodu döndürdü: %d", resp.StatusCode)
	}

	return []byte("generated_image_data"), nil
}
