package ai

import (
	"fmt"
	"strings"
)

// =============================================================================
// PROMPT ENGINEERING & TEMPLATES
// =============================================================================

// PromptBuilder, dinamik prompt oluşturmayı handle eder
type PromptBuilder struct {
	baseTemplate string
	characteristics *JewelryCharacteristics
	referenceAnalysis *ReferenceImageAnalysisResult
}

// NewPromptBuilder, yeni prompt builder oluşturur
func NewPromptBuilder() *PromptBuilder {
	return &PromptBuilder{}
}

// WithCharacteristics, takı özelliklerini ekler
func (pb *PromptBuilder) WithCharacteristics(chars *JewelryCharacteristics) *PromptBuilder {
	pb.characteristics = chars
	return pb
}

// WithReferenceAnalysis, referans görsel analizini ekler
func (pb *PromptBuilder) WithReferenceAnalysis(analysis *ReferenceImageAnalysisResult) *PromptBuilder {
	pb.referenceAnalysis = analysis
	return pb
}

// Build, final prompt'u oluşturur
func (pb *PromptBuilder) Build() (*PromptTemplate, error) {
	if pb.characteristics == nil {
		return nil, fmt.Errorf("takı özelikleri gerekli")
	}

	pt := &PromptTemplate{
		TemplateVersion: "1.0",
		StyleModifiers:  []string{},
		Complexity:      5,
	}

	// Base prompt oluştur
	pt.BasePrompt = pb.buildBasePrompt()

	// Negatif prompt (neler yapılmasın)
	pt.NegativePrompt = pb.buildNegativePrompt()

	// Style modifierleri ekle
	pt.StyleModifiers = pb.buildStyleModifiers()

	// Contextual notes
	pt.ContextualNotes = pb.buildContextualNotes()

	// Jewelry details
	pt.JewelryDetails = pb.characteristics

	return pt, nil
}

// buildBasePrompt, temel prompt stringini oluşturur
func (pb *PromptBuilder) buildBasePrompt() string {
	c := pb.characteristics

	// Kuyumcu terminolojisine uygun prompt şablonu
	prompt := fmt.Sprintf(
		"Luxury jewelry photography: %s %s in %s. ",
		pb.getArticleForProductType(c.ProductType),
		c.ProductType,
		pb.formatMetalColor(c.MetalColor),
	)

	// Taş bilgisi ekle (varsa)
	if c.StoneType != "none" && c.StoneType != "" {
		if c.StoneCount > 0 {
			prompt += fmt.Sprintf(
				"Features %d %s %s stones. ",
				c.StoneCount,
				pb.formatStoneType(c.StoneType),
				strings.Join(c.StoneColors, " and "),
			)
		}
	}

	// Metal bright/finish bilgisi
	if c.MetalBrightness != "" {
		prompt += fmt.Sprintf("Metal finish: %s. ", c.MetalBrightness)
	}

	// Design tipi (baguette, halo, pave vb.)
	if c.DesignType != "" {
		prompt += fmt.Sprintf("Design style: %s. ", c.DesignType)
	}

	// Kamera açısı ve makro çekim
	prompt += pb.buildCameraInstructions()

	// Referans görsel analizine göre stil ekle
	if pb.referenceAnalysis != nil {
		prompt += pb.buildStyleFromReference()
	}

	return prompt
}

// buildStyleFromReference, referans görselden stil ekle
func (pb *PromptBuilder) buildStyleFromReference() string {
	if pb.referenceAnalysis == nil {
		return ""
	}

	style := ""

	if pb.referenceAnalysis.Lighting != nil {
		l := pb.referenceAnalysis.Lighting
		style += fmt.Sprintf("Lighting: %s %s with %s intensity. ", 
			l.Direction, l.Type, l.Intensity)
		
		if l.ColorTemp != "" {
			style += fmt.Sprintf("Color temperature: %s. ", l.ColorTemp)
		}
	}

	if pb.referenceAnalysis.Background != nil {
		b := pb.referenceAnalysis.Background
		style += fmt.Sprintf("Background: %s %s surface with %s blur. ",
			b.Texture, b.Type, b.Blur)
		if b.Color != "" {
			style += fmt.Sprintf("Background color: %s. ", b.Color)
		}
	}

	if pb.referenceAnalysis.ColorPalette != nil {
		cp := pb.referenceAnalysis.ColorPalette
		style += fmt.Sprintf("Mood: %s. Color palette: %s. Saturation: %s. ",
			cp.Mood, cp.DominantColor, cp.Saturation)
	}

	return style
}

// buildCameraInstructions, kamera talimatlarını oluşturur
func (pb *PromptBuilder) buildCameraInstructions() string {
	c := pb.characteristics

	// Default: makro çekim, 45 derece açı
	instructions := "Photography style: Professional macro shot at 45-degree angle. "

	switch c.MainFocusArea {
	case "center_stone":
		instructions = "Macro photography with focus on center stone, 45-degree angle. "
	case "band":
		instructions = "Detailed macro shot of band design, frontal view. "
	case "overall":
		instructions = "Full jewelry showcase, three-quarter view, macro photography. "
	}

	// Boyut bilgisine göre framing
	switch c.SizeEstimate {
	case "small":
		instructions += "Extreme close-up macro, very tight framing. "
	case "large", "statement":
		instructions += "Wide macro framing to capture entire piece. "
	default:
		instructions += "Standard macro framing. "
	}

	instructions += "Studio lighting with professional soft box. Professional camera setup. "

	return instructions
}

// buildNegativePrompt, yapılmaması gereken şeyleri listeler
func (pb *PromptBuilder) buildNegativePrompt() string {
	return strings.TrimSpace(fmt.Sprintf(
		`NEVER modify the jewelry itself: no missing stones, no altered metal color, no design changes. 
		 Preserve: %d %s stones, %s metal, %s design. 
		 Avoid: blurry focus, distorted jewelry, incorrect reflections, 
		 mismatched lighting, overexposed highlights, shadow artifacts, 
		 stretched metals, broken stones, artificial looking, poor quality, 
		 saturated colors, watermarks, text, low resolution`,
		pb.characteristics.StoneCount,
		pb.characteristics.StoneType,
		pb.characteristics.MetalColor,
		pb.characteristics.DesignType,
	))
}

// buildStyleModifiers, stil modifierleri listeler
func (pb *PromptBuilder) buildStyleModifiers() []string {
	modifiers := []string{
		"ultra high quality",
		"professional jewelry photography",
		"studio lighting",
		"sharp focus",
		"pristine condition",
		"commercial product photo",
		"RAW image quality",
		"detailed texture",
		"realistic reflections",
		"professional color grading",
	}

	// Metal brightness'e göre modifier ekle
	if pb.characteristics.MetalBrightness == "glossy" {
		modifiers = append(modifiers, "glossy finish", "polished metal")
	} else if pb.characteristics.MetalBrightness == "matte" {
		modifiers = append(modifiers, "matte finish", "brushed metal")
	}

	// Taş türüne göre modifier
	switch pb.characteristics.StoneType {
	case "diamond":
		modifiers = append(modifiers, "sparkling diamonds", "brilliant cut", "diamond scintillation")
	case "pearl":
		modifiers = append(modifiers, "lustrous pearls", "pearl sheen", "mother of pearl glow")
	}

	return modifiers
}

// buildContextualNotes, ek açıklama notları
func (pb *PromptBuilder) buildContextualNotes() string {
	notes := "PRODUCT PRESERVATION RULES:\n"
	notes += fmt.Sprintf("1. Metal Color: Keep %s exactly as is\n", pb.characteristics.MetalColor)
	notes += fmt.Sprintf("2. Stone Count: Preserve exactly %d stones\n", pb.characteristics.StoneCount)
	notes += fmt.Sprintf("3. Design: No alterations to %s design\n", pb.characteristics.DesignType)
	notes += "4. Compositing: Only modify background and lighting\n"
	notes += "5. Product: Must remain centered and properly framed\n"
	notes += "6. Quality: Seamless integration with background\n"

	return notes
}

// =============================================================================
// HELPER METHODS
// =============================================================================

// getArticleForProductType, ürün türü için doğru makale döndürür
func (pb *PromptBuilder) getArticleForProductType(productType string) string {
	switch productType {
	case "ring":
		return "a"
	case "earring":
		return "an"
	case "necklace":
		return "a"
	case "bracelet":
		return "a"
	case "set":
		return "a"
	default:
		return "a"
	}
}

// formatMetalColor, metal rengini kuyumcu terimine çevirir
func (pb *PromptBuilder) formatMetalColor(color string) string {
	switch color {
	case "yellow_gold":
		return "yellow gold (18K)"
	case "white_gold":
		return "white gold (18K)"
	case "rose_gold":
		return "rose gold (18K)"
	case "silver":
		return "sterling silver"
	default:
		return color
	}
}

// formatStoneType, taş türünü kuyumcu terimine çevirir
func (pb *PromptBuilder) formatStoneType(stoneType string) string {
	switch stoneType {
	case "diamond":
		return "brilliant cut diamond"
	case "zircon":
		return "cubic zirconia"
	case "pearl":
		return "lustrous pearl"
	case "colored_stone":
		return "colored gemstone"
	default:
		return stoneType
	}
}

// =============================================================================
// TEMPLATE VARIATIONS
// =============================================================================

// TemplateVariationBuilder, çeşitli görsel stilleri için template varyasyonları oluşturur
type TemplateVariationBuilder struct {
	baseTemplate *PromptTemplate
}

// NewTemplateVariationBuilder, varyasyon builder oluşturur
func NewTemplateVariationBuilder(baseTemplate *PromptTemplate) *TemplateVariationBuilder {
	return &TemplateVariationBuilder{baseTemplate: baseTemplate}
}

// BuildMinimalist, minimalist stil varyasyonunu oluşturur
func (tvb *TemplateVariationBuilder) BuildMinimalist() *PromptTemplate {
	t := *tvb.baseTemplate // copy
	t.BasePrompt = strings.ReplaceAll(t.BasePrompt, "studio lighting", "soft diffused lighting")
	t.StyleModifiers = append(t.StyleModifiers, "minimalist", "clean background", "white space")
	return &t
}

// BuildLuxury, lüks stil varyasyonunu oluşturur
func (tvb *TemplateVariationBuilder) BuildLuxury() *PromptTemplate {
	t := *tvb.baseTemplate // copy
	t.BasePrompt += "Ultra-premium luxury presentation. "
	t.StyleModifiers = append(t.StyleModifiers, "luxury magazine photography", "premium lighting", "high-end aesthetic")
	t.Complexity = 8
	return &t
}

// BuildElegant, zarif stil varyasyonunu oluşturur
func (tvb *TemplateVariationBuilder) BuildElegant() *PromptTemplate {
	t := *tvb.baseTemplate // copy
	t.BasePrompt += "Elegant and sophisticated presentation. "
	t.StyleModifiers = append(t.StyleModifiers, "elegant", "refined", "soft lighting", "romantic mood")
	t.Complexity = 6
	return &t
}

// BuildContemporary, çağdaş stil varyasyonunu oluşturur
func (tvb *TemplateVariationBuilder) BuildContemporary() *PromptTemplate {
	t := *tvb.baseTemplate // copy
	t.BasePrompt += "Contemporary modern aesthetic. "
	t.StyleModifiers = append(t.StyleModifiers, "contemporary", "bold", "artistic", "editorial photography")
	t.Complexity = 7
	return &t
}

// BuildVintage, vintage stil varyasyonunu oluşturur
func (tvb *TemplateVariationBuilder) BuildVintage() *PromptTemplate {
	t := *tvb.baseTemplate // copy
	t.BasePrompt += "Vintage inspired aesthetic with timeless appeal. "
	t.StyleModifiers = append(t.StyleModifiers, "vintage", "warm tones", "nostalgic", "antique feel")
	t.Complexity = 7
	return &t
}

// BuildRomantic, romantik stil varyasyonunu oluşturur
func (tvb *TemplateVariationBuilder) BuildRomantic() *PromptTemplate {
	t := *tvb.baseTemplate // copy
	t.BasePrompt += "Romantic and dreamy presentation. "
	t.StyleModifiers = append(t.StyleModifiers, "romantic", "soft focus", "warm lighting", "dreamy", "gentle")
	t.Complexity = 6
	return &t
}
