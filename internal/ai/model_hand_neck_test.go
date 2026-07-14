package ai

import (
	"os"
	"path/filepath"
	"testing"
)

func TestProcessModelPlacement(t *testing.T) {
	// Setup test input image
	testInput := filepath.Join("uploads", "test_ring_input.png")
	if err := createTestImage(testInput); err != nil {
		t.Fatalf("Failed to create test image: %v", err)
	}
	defer os.Remove(testInput)

	t.Run("PositionJewelry_ModelHand", func(t *testing.T) {
		// Run local placement on model_hand template
		// Note: The test will download the background from Unsplash, so it requires internet.
		data, err := ProcessModelPlacement(testInput, "model_hand")
		if err != nil {
			// Skip if there's internet connection issue, but fail if it's a scripting error
			t.Fatalf("ProcessModelPlacement failed: %v", err)
		}

		if len(data) == 0 {
			t.Fatal("Expected non-empty image data output")
		}

		// Save the test output so we can verify it visually or clean it up
		testOutput := filepath.Join("uploads", "test_positioned_hand.png")
		if err := os.WriteFile(testOutput, data, 0644); err != nil {
			t.Errorf("Failed to save positioned output file: %v", err)
		}
		defer os.Remove(testOutput)
	})

	t.Run("PositionJewelry_Fallback", func(t *testing.T) {
		// Non-existent template fallback to mockup api which returns generated_image_data
		data, err := ProcessModelPlacement(testInput, "non_existent_template")
		if err != nil {
			t.Skipf("Skipping API fallback test if network or endpoint is invalid: %v", err)
			return
		}

		if string(data) != "generated_image_data" {
			t.Errorf("Expected fallback data to be 'generated_image_data', got %q", string(data))
		}
	})
}
