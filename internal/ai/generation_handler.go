package ai

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
)

// UploadProductImage kullanıcıdan gelen takı fotoğrafını alır
func UploadProductImage(w http.ResponseWriter, r *http.Request) {
	// Yüklenen dosyanın maksimum boyutu (örnek: 10 MB)
	r.ParseMultipartForm(10 << 20)

	file, handler, err := r.FormFile("product_image")
	if err != nil {
		http.Error(w, "Görsel alınamadı", http.StatusBadRequest)
		return
	}
	defer file.Close()

	// Dosyayı sunucuda geçici bir klasöre kaydet
	// Gerçek senaryoda burası AWS S3 veya Google Cloud Storage olmalıdır.
	tempPath := filepath.Join("uploads", handler.Filename)
	dst, err := os.Create(tempPath)
	if err != nil {
		http.Error(w, "Sunucu hatası, dosya kaydedilemedi", http.StatusInternalServerError)
		return
	}
	defer dst.Close()
	io.Copy(dst, file)

	// TODO: İş akışı (Workflow) burada başlar.
	// 1. Görselin arka planı silinir.
	// 2. ControlNet (Canny) ve Inpainting parametreleri ile AI API'sine yollanır.

	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, `{"status": "success", "message": "Görsel %s başarıyla yüklendi ve işleme alındı."}`, handler.Filename)
}
