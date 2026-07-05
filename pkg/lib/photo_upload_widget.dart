import 'dart:io';
import 'ai_generation_service.dart'; // Dosya yoluna göre düzenleyebilirsin
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PhotoUploadWidget extends StatefulWidget {
  const PhotoUploadWidget({super.key});

  @override
  State<PhotoUploadWidget> createState() => _PhotoUploadWidgetState();
}

class _PhotoUploadWidgetState extends State<PhotoUploadWidget> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _promptController = TextEditingController();

  // Kamera veya Galeriden görsel seçme fonksiyonu
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

 void _startGeneration() async {
    if (_selectedImage == null) return;
    
    String customPrompt = _promptController.text;

    // 1. Ekrana yükleniyor animasyonu çıkar
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFD4AF37)), 
      ),
    );

    // 2. Ayrı dosyada yazdığımız servisi çağır
    final service = AiGenerationService();
    final isSuccess = await service.generateImage(_selectedImage!, customPrompt);

    // 3. İşlem bitince yükleniyor animasyonunu kapat
    if (context.mounted) Navigator.pop(context);

    // 4. Go sunucusundan gelen sonuca göre kullanıcıya mesaj göster
    if (isSuccess && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Görsel başarıyla yapay zekaya iletildi!')),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Üretim sırasında sunucu hatası oluştu.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. GÖRSEL ALANI
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFD4AF37), width: 1), // Altın rengi çerçeve
          ),
          child: _selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb 
                      ? Image.network(_selectedImage!.path, fit: BoxFit.cover) // Web'de test ederken çökmemesi için
                      : Image.file(_selectedImage!, fit: BoxFit.cover),
                )
              : const Center(
                  child: Text(
                    'Henüz bir takı görseli seçilmedi',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
        ),
        const SizedBox(height: 16),

        // 2. BUTONLAR (Kamera ve Galeri)
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Kamera'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Galeri'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 3. PROMPT GİRİŞ ALANI (Yapay Zeka İçin)
        TextField(
          controller: _promptController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Yapay zekaya eklemek istediğiniz detayları yazın...\nÖrn: Siyah mermer zemin üzerinde, loş ışıklı stüdyo çekimi',
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 4. ÜRETİMİ BAŞLAT BUTONU
        ElevatedButton(
          onPressed: _selectedImage == null ? null : _startGeneration,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD4AF37),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Yapay Zeka ile Üret',
            style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}