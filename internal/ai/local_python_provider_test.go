package ai

import (
	"context"
	"image"
	"image/color"
	"image/png"
	"os"
	"path/filepath"
	"testing"
)

// createTestImage creates a simple image with a distinct foreground and background
func createTestImage(path string) error {
	// Create a 200x200 image
	img := image.NewRGBA(image.Rect(0, 0, 200, 200))

	// Fill background with blue
	for x := 0; x < 200; x++ {
		for y := 0; y < 200; y++ {
			img.Set(x, y, color.RGBA{0, 0, 255, 255})
		}
	}

	// Create a red square in the middle (foreground)
	for x := 50; x < 150; x++ {
		for y := 50; y < 150; y++ {
			img.Set(x, y, color.RGBA{255, 0, 0, 255})
		}
	}

	err := os.MkdirAll(filepath.Dir(path), 0755)
	if err != nil {
		return err
	}

	f, err := os.Create(path)
	if err != nil {
		return err
	}
	defer f.Close()

	return png.Encode(f, img)
}

func TestLocalPythonSegmentationProvider(t *testing.T) {
	// Setup test image
	testInput := filepath.Join("uploads", "test_input.png")
	if err := createTestImage(testInput); err != nil {
		t.Fatalf("Failed to create test image: %v", err)
	}
	defer os.Remove(testInput)

	// Setup provider config
	config := &ProviderConfig{
		Type: ProviderTypeLocalPython,
	}

	provider := NewLocalPythonSegmentationProvider(config)

	// Test Ping
	ctx := context.Background()
	if err := provider.Ping(ctx); err != nil {
		t.Skipf("Skipping integration test since Python is not available or configuration failed: %v", err)
	}

	// Test SegmentJewelry (using rembg default model u2net to speed up download/run)
	t.Run("SegmentJewelry_Rembg", func(t *testing.T) {
		params := map[string]interface{}{
			"provider": "rembg",
			"model":    "u2net", // u2net is fast and default
		}

		result, err := provider.SegmentJewelry(ctx, testInput, params)
		if err != nil {
			t.Fatalf("SegmentJewelry failed: %v", err)
		}

		if result == nil {
			t.Fatal("Expected non-nil result")
		}

		if result.MaskImageURL == "" {
			t.Error("Expected MaskImageURL to be set")
		}

		if result.CleanJewelryURL == "" {
			t.Error("Expected CleanJewelryURL to be set")
		}

		if result.InpaintingMaskURL == "" {
			t.Error("Expected InpaintingMaskURL to be set")
		}

		if result.MaskPixelArea <= 0 {
			t.Errorf("Expected positive MaskPixelArea, got %d", result.MaskPixelArea)
		}

		// Clean up output files
		// Extract local paths from file:/// URLs
		cleanPath := filepath.FromSlash(result.CleanJewelryURL[8:])
		maskPath := filepath.FromSlash(result.MaskImageURL[8:])
		inpaintingPath := filepath.FromSlash(result.InpaintingMaskURL[8:])
		os.Remove(cleanPath)
		os.Remove(maskPath)
		os.Remove(inpaintingPath)
	})
}
