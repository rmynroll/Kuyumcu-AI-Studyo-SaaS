import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_colors.dart';
import 'credits_provider.dart';

class CollectionStudioScreen extends ConsumerStatefulWidget {
  const CollectionStudioScreen({super.key});

  @override
  ConsumerState<CollectionStudioScreen> createState() => _CollectionStudioScreenState();
}

class _CollectionStudioScreenState extends ConsumerState<CollectionStudioScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Nişan Koleksiyonu - Kadife Kutu Serisi');
  final Set<String> _selectedProductIds = {'1', '2', '3'}; // Default selected items
  String? _selectedTemplateId = '1';

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
    _MockTemplate(id: '1', name: 'Kırmızı Kadife', desc: 'Lüks kadife mücevher kutusu ve spot ışık'),
    _MockTemplate(id: '2', name: 'Siyah Mermer', desc: 'Yansımalı cilalı mermer zemin'),
    _MockTemplate(id: '3', name: 'Gün Işığı Yaprak', desc: 'Yanal doğal ışık ve palmiye gölgesi'),
    _MockTemplate(id: '4', name: 'Klasik Fildişi', desc: 'Sade bej zemin ve yumuşak stüdyo tonu'),
  ];

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
                Text(
                  'Koleksiyon İşleniyor...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                  _buildSectionHeader('Koleksiyona Dahil Edilecek Ürünler ($selectedCount Seçili)'),
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
                              Image.network(p.imageUrl, fit: BoxFit.cover),
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

                  // 3. ŞABLON SEÇİMİ
                  _buildSectionHeader('Ortak Tasarım Şablonu Seçin'),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _templates.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final t = _templates[index];
                      final isSelected = _selectedTemplateId == t.id;

                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.gold : AppColors.divider,
                            width: isSelected ? 1.6 : 1,
                          ),
                        ),
                        child: RadioListTile<String>(
                          value: t.id,
                          groupValue: _selectedTemplateId,
                          activeColor: AppColors.gold,
                          onChanged: (val) {
                            setState(() {
                              _selectedTemplateId = val;
                            });
                          },
                          title: Text(
                            t.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                          ),
                          subtitle: Text(
                            t.desc,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // 4. KREDİ ÖZET PANELİ
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

  _MockTemplate({required this.id, required this.name, required this.desc});
}
