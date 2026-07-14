import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:kuyumcu_flutter/app_colors.dart';
import 'package:kuyumcu_flutter/ai_generation_service.dart';
import 'package:kuyumcu_flutter/generation_repository.dart';

class ProductUploadScreen extends ConsumerStatefulWidget {
  const ProductUploadScreen({super.key});

  @override
  ConsumerState<ProductUploadScreen> createState() => _ProductUploadScreenState();
}

class _ProductUploadScreenState extends ConsumerState<ProductUploadScreen> {
  String? _selectedImagePath;
  final ImagePicker _picker = ImagePicker();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();

  String _selectedType = 'Yüzük';
  String _selectedMetal = 'Sarı Altın';
  String _selectedStone = 'Pırlanta';

  @override
  void dispose() {
    _nameController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
          // Pre-fill name if empty
          if (_nameController.text.isEmpty) {
            _nameController.text = 'Yeni $_selectedMetal $_selectedStone $_selectedType';
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Görsel seçilemedi: $e')),
      );
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.gold),
                title: const Text('Galeriden Seç', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.gold),
                title: const Text('Kamera ile Çek', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitProduct() async {
    if (_selectedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir ürün görseli seçin.')),
      );
      return;
    }

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen ürün adı/kodu girin.')),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      ),
    );

    final finalPrompt = 'Ürün: $name, Tür: $_selectedType, Metal: $_selectedMetal, Taş: $_selectedStone. ${_promptController.text.trim()}';

    // Görsel üretim işini yerel repoda oluştur
    final repo = ref.read(generationRepositoryProvider);
    final gen = await repo.createFromTemplate(
      productId: _selectedImagePath!,
      templateId: 'white_background', // Varsayılan arka plan şablonu
    );

    if (mounted) Navigator.pop(context); // Close loading dialog

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ürün başarıyla kaydedildi ve stüdyoya gönderildi!')),
      );
      context.go('/generation/progress/${gen.id}');
    }
  }

  Widget _buildChoiceChip(String label, String groupValue, ValueChanged<String> onSelected) {
    final isSelected = label == groupValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(label),
      selectedColor: AppColors.gold.withOpacity(0.12),
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.gold : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: isSelected ? AppColors.gold : AppColors.divider),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildImageWidget(String path) {
    if (path.startsWith('http') || path.startsWith('blob')) {
      return Image.network(path, fit: BoxFit.cover);
    } else {
      if (kIsWeb) {
        return Image.network(path, fit: BoxFit.cover);
      } else {
        return Image.file(File(path), fit: BoxFit.cover);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ürün Yükle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. GÖRSEL SEÇİM ALANI
                  InkWell(
                    onTap: _showImagePickerOptions,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.divider),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _selectedImagePath != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                _buildImageWidget(_selectedImagePath!),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                    child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add_a_photo_outlined, color: AppColors.gold, size: 40),
                                SizedBox(height: 12),
                                Text(
                                  'Ürün Fotoğrafı Çek veya Yükle',
                                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Telefon kamerası ya da galeriden seçin',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. ÜRÜN BİLGİLERİ (Ad / Kod)
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Ürün Adı veya Stok Kodu',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      hintText: 'Örn: 22K Baget Yüzük',
                      hintStyle: const TextStyle(color: Colors.white24),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.gold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. FİLTRE SEÇENEKLERİ (Kategori / Tür)
                  const Text('ÜRÜN KATEGORİSİ', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildChoiceChip('Yüzük', _selectedType, (val) => setState(() => _selectedType = val)),
                      _buildChoiceChip('Kolye', _selectedType, (val) => setState(() => _selectedType = val)),
                      _buildChoiceChip('Bileklik', _selectedType, (val) => setState(() => _selectedType = val)),
                      _buildChoiceChip('Küpe', _selectedType, (val) => setState(() => _selectedType = val)),
                      _buildChoiceChip('Diğer', _selectedType, (val) => setState(() => _selectedType = val)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 4. METAL TÜRÜ
                  const Text('METAL TÜRÜ', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildChoiceChip('Sarı Altın', _selectedMetal, (val) => setState(() => _selectedMetal = val)),
                      _buildChoiceChip('Beyaz Altın', _selectedMetal, (val) => setState(() => _selectedMetal = val)),
                      _buildChoiceChip('Rose Altın', _selectedMetal, (val) => setState(() => _selectedMetal = val)),
                      _buildChoiceChip('Platin', _selectedMetal, (val) => setState(() => _selectedMetal = val)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 5. TAŞ TÜRÜ
                  const Text('TAŞ TÜRÜ', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildChoiceChip('Pırlanta', _selectedStone, (val) => setState(() => _selectedStone = val)),
                      _buildChoiceChip('Yakut', _selectedStone, (val) => setState(() => _selectedStone = val)),
                      _buildChoiceChip('Safir', _selectedStone, (val) => setState(() => _selectedStone = val)),
                      _buildChoiceChip('Zümrüt', _selectedStone, (val) => setState(() => _selectedStone = val)),
                      _buildChoiceChip('Taşsız', _selectedStone, (val) => setState(() => _selectedStone = val)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 6. DETAYLAR / NOTLAR
                  TextField(
                    controller: _promptController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Ekstra Yapay Zeka Detayları (İsteğe Bağlı)',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      hintText: 'Sahneye eklenmesini istediğiniz detaylar (Örn: Işıltılı arka plan, ahşap sahne...)',
                      hintStyle: const TextStyle(color: Colors.white24),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.gold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 7. GÖNDER BUTONU
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.textOnGold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _submitProduct,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text(
                      'Yapay Zeka Stüdyosuna Gönder',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
