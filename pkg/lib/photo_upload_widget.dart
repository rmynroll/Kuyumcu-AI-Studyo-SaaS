import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:kuyumcu_flutter/generation_repository.dart';

class PhotoUploadWidget extends ConsumerStatefulWidget {
  const PhotoUploadWidget({super.key});

  @override
  ConsumerState<PhotoUploadWidget> createState() => _PhotoUploadWidgetState();
}

class _PhotoUploadWidgetState extends ConsumerState<PhotoUploadWidget> {
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

    // 2. Prompt kelimelerine göre gerçekçi arka plan şablonunu belirle
    final prompt = customPrompt.toLowerCase();
    String styleUrl = 'https://images.unsplash.com/photo-1533090161767-e6ffed986c88?q=80&w=400&auto=format&fit=crop'; // Varsayılan: Lüks İtalyan Mermer
    if (prompt.contains('kadife') || prompt.contains('kutusu') || prompt.contains('box') || prompt.contains('velvet') || prompt.contains('siyah') || prompt.contains('black')) {
      styleUrl = 'https://images.unsplash.com/photo-1502239608882-93b729c6af43?q=80&w=400&auto=format&fit=crop'; // Siyah Kadife/Doku
    } else if (prompt.contains('el') || prompt.contains('parmak') || prompt.contains('hand') || prompt.contains('finger') || prompt.contains('manken') || prompt.contains('model')) {
      styleUrl = 'https://images.unsplash.com/photo-1602751584552-8ba73aad10e1?q=80&w=400&auto=format&fit=crop'; // Manken Eli (Yüzük)
    } else if (prompt.contains('ışık') || prompt.contains('güneş') || prompt.contains('sun') || prompt.contains('light') || prompt.contains('gün')) {
      styleUrl = 'https://images.unsplash.com/photo-1541123437800-1bb1317badc2?q=80&w=400&auto=format&fit=crop'; // Doğal Gün Işığı Taş
    }

    // 3. Görsel üretim işini repoda oluştur
    final repo = ref.read(generationRepositoryProvider);
    final gen = await repo.createFromTemplate(
      productId: _selectedImage!.path,
      templateId: styleUrl,
    );

    // 4. İşlem bitince yükleniyor animasyonunu kapat
    if (mounted) Navigator.pop(context);

    // 5. Üretim izleme ekranına yönlendir
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Görsel başarıyla yapay zekaya iletildi!')),
      );
      context.go('/generation/progress/${gen.id}');
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
            border: Border.all(color: const Color(0xFFFFD4AF37), width: 1), // Altın çerçeve
          ),
          child: _selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb 
                      ? Image.network(_selectedImage!.path, fit: BoxFit.cover) 
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