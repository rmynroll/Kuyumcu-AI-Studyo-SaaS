package ai

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
)

// AIServiceRequest Stable Diffusion / ComfyUI API'sine gidecek parametreler
type AIServiceRequest struct {
	UserImageURL   string                 `json:"user_image_url"` // Kullanıcının yüklediği orijinal takı
	TemplateID     string                 `json:"template_id"`    // "model_hand" veya "model_neck"
	Prompt         string                 `json:"prompt"`
	NegativePrompt string                 `json:"negative_prompt"`
	ControlWeights map[string]interface{} `json:"control_weights"` // IP-Adapter ve ControlNet ayarları
}

// ProcessModelPlacement takıyı manken üzerine hatasız yerleştiren fonksiyon
func ProcessModelPlacement(userImageURL string, templateID string) ([]byte, error) {
	apiURL := "https://api.buildkor.ai/v1/generation/comfyui" // Bizim ComfyUI API endpointimiz

	// Şablona göre prompt özelleştirme
	var specificPrompt string
	switch templateID {
	case "model_hand":
		specificPrompt = "a close-up elegant shot of a woman's hand wearing the jewelry ring, highly detailed skin texture, professional manicure, luxury jewelry photography"
	case "model_neck":
		specificPrompt = "a professional studio lookbook shot of a woman's neck and collarbone wearing the jewelry necklace, soft studio lighting"
	default:
		specificPrompt = "professional jewelry studio shot"
	}

	// Ürün kalitesini kilitleyen katı kurallar
	requestBody := AIServiceRequest{
		UserImageURL:   userImageURL,
		TemplateID:     templateID,
		Prompt:         fmt.Sprintf("%s, hyper-realistic, maintaining exact design of the jewelry, high resolution, 8k", specificPrompt),
		NegativePrompt: "deformed jewelry, changed gemstone shape, altered metal details, low quality, blurred jewelry, extra stones",
		ControlWeights: map[string]interface{}{
			"ip_adapter_scale":     0.85, // Ürün kimliğine sadakat oranı (Yüksek tutulmalı)
			"controlnet_structure": "canny_edge",
		},
	}

	jsonData, err := json.Marshal(requestBody)
	if err != nil {
		return nil, err
	}

	// API İsteği
	resp, err := http.Post(apiURL, "application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("AI servisi hata kodu döndürdü: %d", resp.StatusCode)
	}

	// Üretilen görsel verisi (byte dizisi veya URL olarak dönebilir)
	// Biz burada byte dizisi olarak simüle ediyoruz
	return []byte("generated_image_data"), nil
}
