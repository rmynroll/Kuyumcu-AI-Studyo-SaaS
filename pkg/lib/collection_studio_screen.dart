import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'app_colors.dart';
import 'credits_provider.dart';

class CollectionStudioScreen extends ConsumerStatefulWidget {
  const CollectionStudioScreen({super.key});

  @override
  ConsumerState<CollectionStudioScreen> createState() => _CollectionStudioScreenState();
}

class _CollectionStudioScreenState extends ConsumerState<CollectionStudioScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Nişan Koleksiyonu - Kadife Kutu Serisi');
  final TextEditingController _extraDetailsController = TextEditingController();
  final Set<String> _selectedProductIds = {'1', '2', '3'}; // Default selected items
  String? _selectedTemplateId = '1';
  final ImagePicker _picker = ImagePicker();

  // Mock raw products list
  final List<_MockRawProduct> _products = [
    _MockRawProduct(id: '1', name: 'Zümrüt Yüzük', imageUrl: 'https://images.unsplash.com/photo-1598560917505-59a3ad559071?q=80&w=150&auto=format&fit=crop'),
    _MockRawProduct(id: '2', name: 'Altın Künye', imageUrl: 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?q=80&w=150&auto=format&fit=crop'),
    _MockRawProduct(id: '3', name: 'Elmas Kolye', imageUrl: 'https://images.unsplash.com/photo-1617038260897-41a1f14a8ca0?q=80&w=150&auto=format&fit=crop'),
    _MockRawProduct(id: '4', name: 'Yakut Küpe', imageUrl: 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=150&auto=format&fit=crop'),
    _MockRawProduct(id: '5', name: 'Safir Yüzük', imageUrl: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?q=80&w=150&auto=format&fit=crop'),
    _MockRawProduct(id: '6', name: 'Gümüş Halhal', imageUrl: 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?q=80&w=150&auto=format&fit=crop'),
  ];

  // Mock template options
  final List<_MockTemplate> _templates = [
    _MockTemplate(
      id: '1', 
      name: 'Kırmızı Kadife', 
      desc: 'Lüks kadife mücevher kutusu ve spot ışık',
      imageUrl: 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=300&auto=format&fit=crop'
    ),
    _MockTemplate(
      id: '2', 
      name: 'Siyah Mermer', 
      desc: 'Yansımalı cilalı mermer zemin',
      imageUrl: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?q=80&w=300&auto=format&fit=crop'
    ),
    _MockTemplate(
      id: '3', 
      name: 'Gün Işığı Yaprak', 
      desc: 'Yanal doğal ışık ve palmiye gölgesi',
      imageUrl: 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?q=80&w=300&auto=format&fit=crop'
    ),
    _MockTemplate(
      id: '4', 
      name: 'Klasik Fildişi', 
      desc: 'Sade bej zemin ve yumuşak stüdyo tonu',
      imageUrl: 'https://images.unsplash.com/photo-1617038260897-41a1f14a8ca0?q=80&w=300&auto=format&fit=crop'
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _extraDetailsController.dispose();
    super.dispose();
  }

  void _toggleProductSelection(String id) {
    setState(() {
      if (_selectedProductIds.contains(id)) {
        if (_selectedProductIds.length > 1) {
          _selectedProductIds.remove(id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Toplu üretim için en az 1 ürün seçmelisiniz.')),
          );
        }
      } else {
        _selectedProductIds.add(id);
      }
    });
  }

  Future<void> _pickNewProduct(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        // Prompt for product name
        if (mounted) {
          final TextEditingController tempNameController = TextEditingController(
            text: 'Yeni Koleksiyon Ürünü ${_products.length + 1}'
          );
          
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: AppColors.surface,
                title: const Text('Ürün Bilgisi', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                content: TextField(
                  controller: tempNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Ürün Adı',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.gold)),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.textOnGold),
                    onPressed: () {
                      final name = tempNameController.text.trim();
                      if (name.isNotEmpty) {
                        final newId = (_products.length + 1).toString();
                        setState(() {
                          _products.add(_MockRawProduct(
                            id: newId,
                            name: name,
                            imageUrl: image.path,
                          ));
                          _selectedProductIds.add(newId);
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('"$name" koleksiyona eklendi ve seçildi.')),
                        );
                      }
                    },
                    child: const Text('Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fotoğraf eklenemedi: $e')),
      );
    }
  }

  void _showNewProductOptions() {
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
                title: const Text('Galeriden Fotoğraf Seç', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  _pickNewProduct(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.gold),
                title: const Text('Kameradan Fotoğraf Çek', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  _pickNewProduct(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _startBatchGeneration() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen koleksiyonunuza bir isim verin.')),
      );
      return;
    }

    final creditCost = _selectedProductIds.length;
    
    // Validate credits
    final hasCredits = ref.read(creditsProvider.notifier).spendCredits(
          creditCost,
          'Koleksiyon Toplu Üretim: $name',
        );

    if (!hasCredits) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.surfaceElevated,
            title: const Row(
              children: [
                Icon(Icons.diamond_outlined, color: AppColors.gold),
                SizedBox(width: 8),
                Text('Yetersiz Kredi'),
              ],
            ),
            content: Text(
              'Bu koleksiyonu ($creditCost adet ürün) toplu üretmek için yeterli krediniz bulunmamaktadır. '
              'Lütfen kredi paketi satın alın.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.textOnGold),
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/'); // Redirect to main
                },
                child: const Text('Kredi Al'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Show loading batch progress modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 3.5),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Koleksiyon İşleniyor...',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '$creditCost ürün tek bir marka kimliği altında toplanıp arka plan transferi sırasına alınıyor.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Simulate backend job scheduling for batch
    await Future.delayed(const Duration(seconds: 1800 ~/ 1000));

    if (context.mounted) {
      Navigator.pop(context); // Close loading dialog
      
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.surfaceElevated,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text('Toplu Üretim Başladı'),
              ],
            ),
            content: Text(
              'Koleksiyonunuz başarıyla kuyruğa eklenmiştir. '
              'Tüm ürünler aynı arka plan, ışık açısı ve zemin yansıması ile üretilip kataloğunuzda toplanacaktır. '
              'Üretim durumunu "Sonuçlarım" sekmesinden takip edebilirsiniz.',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.textOnGold),
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/'); // Back to dashboard
                },
                child: const Text('Anlaşıldı', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildProductImage(String path) {
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
    final creditsState = ref.watch(creditsProvider);
    final selectedCount = _selectedProductIds.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Koleksiyon Stüdyosu'),
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
                  Text(
                    'Marka Dilinizi Tekleştirin',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Koleksiyonunuzdaki ürünleri tek seferde seçin, hepsine aynı ışık ve arka plan şablonunu uygulayarak pürüzsüz görsel tutarlılığı yakalayın.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 28),

                  // 1. KOLEKSİYON ADI
                  _buildSectionHeader('Koleksiyon Adı'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surface,
                      hintText: 'Örn: Nişan Koleksiyonu 2026',
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  const SizedBox(height: 28),

                  // 2. ÜRÜN ÇOKLU SEÇİMİ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader('Koleksiyona Dahil Edilecek Ürünler ($selectedCount Seçili)'),
                      TextButton.icon(
                        onPressed: _showNewProductOptions,
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.gold, size: 16),
                        label: const Text('Ürün Ekle', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final p = _products[index];
                      final isSelected = _selectedProductIds.contains(p.id);

                      return InkWell(
                        onTap: () => _toggleProductSelection(p.id),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.gold : AppColors.divider,
                              width: isSelected ? 1.8 : 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              _buildProductImage(p.imageUrl),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.gold : Colors.black45,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    isSelected ? Icons.check : Icons.add,
                                    color: isSelected ? AppColors.textOnGold : Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  color: Colors.black54,
                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                                  child: Text(
                                    p.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // 3. ŞABLON SEÇİMİ (Yenilenmiş Görsel Kart Yapısı)
                  _buildSectionHeader('Ortak Tasarım Şablonu Seçin'),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _templates.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final t = _templates[index];
                      final isSelected = _selectedTemplateId == t.id;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedTemplateId = t.id;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppColors.gold : AppColors.divider,
                              width: isSelected ? 1.8 : 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Row(
                            children: [
                              // Şablon Önizleme Görseli
                              Container(
                                width: 90,
                                height: 90,
                                clipBehavior: Clip.antiAlias,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.horizontal(left: Radius.circular(15)),
                                ),
                                child: Image.network(t.imageUrl, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      t.name,
                                      style: TextStyle(
                                        color: isSelected ? AppColors.gold : AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      t.desc,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Radio<String>(
                                value: t.id,
                                groupValue: _selectedTemplateId,
                                activeColor: AppColors.gold,
                                onChanged: (val) {
                                  setState(() {
                                    _selectedTemplateId = val;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // 4. ORTAK KOMPOZİSYON DETAYLARI
                  _buildSectionHeader('Ortak Kompozisyon Detayları (İsteğe Bağlı)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _extraDetailsController,
                    maxLines: 2,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surface,
                      hintText: 'Tüm görsellere uygulanacak ekstra stil detayları yazın...\nÖrn: Bölgesel ışıklar, gölge yumuşatması, 8k mücevher çekimi',
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  const SizedBox(height: 28),

                  // 5. KREDİ ÖZET PANELİ
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gold.withOpacity(0.25)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Seçilen Ürün Sayısı:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            Text('$selectedCount Adet', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Gerekli Toplam Kredi:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            Row(
                              children: [
                                Text('$selectedCount', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800, fontSize: 16)),
                                const SizedBox(width: 4),
                                const Icon(Icons.diamond_rounded, color: AppColors.gold, size: 16),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Mevcut Cüzdan Bakiyesi:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            Row(
                              children: [
                                Text('${creditsState.balance}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(width: 4),
                                const Icon(Icons.diamond_rounded, color: AppColors.gold, size: 14),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // TOPLU ÜRET BUTONU
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.textOnGold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _startBatchGeneration,
                    icon: const Icon(Icons.auto_awesome_motion_rounded, size: 18),
                    label: Text(
                      'Toplu Üretimi Başlat ($selectedCount Kredi 💎)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.gold,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }
}

class _MockRawProduct {
  final String id;
  final String name;
  final String imageUrl;

  _MockRawProduct({required this.id, required this.name, required this.imageUrl});
}

class _MockTemplate {
  final String id;
  final String name;
  final String desc;
  final String imageUrl;

  _MockTemplate({required this.id, required this.name, required this.desc, required this.imageUrl});
}
