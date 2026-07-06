import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_colors.dart';
import 'credits_provider.dart';

class InspirationBoardScreen extends ConsumerStatefulWidget {
  const InspirationBoardScreen({super.key});

  @override
  ConsumerState<InspirationBoardScreen> createState() => _InspirationBoardScreenState();
}

class _InspirationBoardScreenState extends ConsumerState<InspirationBoardScreen> {
  // Selection states
  String? _selectedProductUrl;
  String? _selectedStyleUrl;
  String? _selectedStyleName;

  // Fine-tuning slider parameters
  double _lightIntensity = 0.85;
  double _backgroundMatch = 0.75;
  double _colorHarmony = 0.90;

  // Mock product option
  final String _mockProductUrl = 'https://images.unsplash.com/photo-1598560917505-59a3ad559071?q=80&w=400&auto=format&fit=crop';

  // Presets definition
  final List<_StylePreset> _presets = [
    _StylePreset(
      name: 'Lüks İtalyan',
      imageUrl: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?q=80&w=400&auto=format&fit=crop',
      light: 'Yumuşak Çapraz Işık, Yüksek Dinamik Aralık (HDR)',
      background: 'Cilalı Beyaz Mermer ve Altın Vurgular',
      mood: 'Sıcak & Lüks Akdeniz Esintisi (%94 Kararlılık)',
    ),
    _StylePreset(
      name: 'Doğal Gün Işığı',
      imageUrl: 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?q=80&w=400&auto=format&fit=crop',
      light: 'Yanal Gün Işığı, Yaprak Gölgeleri Efekti',
      background: 'Rustik Meşe Ağacı Zemin',
      mood: 'Minimalist & Doğal Atmosfer (%91 Kararlılık)',
    ),
    _StylePreset(
      name: 'Siyah Kadife',
      imageUrl: 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=400&auto=format&fit=crop',
      light: 'Spot Tepe Işığı, Yüksek Kontrastlı Yansıma',
      background: 'Koyu Kadife Zemin',
      mood: 'Gizemli & Dramatik Lüks (%96 Kararlılık)',
    ),
  ];

  void _selectProduct() {
    setState(() {
      _selectedProductUrl = _mockProductUrl; // Simulated pick
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ürün görseli başarıyla seçildi.')),
    );
  }

  void _selectPreset(_StylePreset preset) {
    setState(() {
      _selectedStyleUrl = preset.imageUrl;
      _selectedStyleName = preset.name;
    });
  }

  void _selectCustomStyle() {
    setState(() {
      _selectedStyleUrl = 'https://images.unsplash.com/photo-1617038260897-41a1f14a8ca0?q=80&w=400&auto=format&fit=crop';
      _selectedStyleName = 'Galeriden Özel Stil';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stil referans görseli başarıyla yüklendi.')),
    );
  }

  void _generateWithStyle() async {
    if (_selectedProductUrl == null || _selectedStyleUrl == null) return;

    // Check credits first
    final hasCredits = ref.read(creditsProvider.notifier).spendCredits(1, 'İlham Panosu: $_selectedStyleName');

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
            content: const Text('İlham panosu ile üretim yapmak için 1 krediniz olması gerekmektedir.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kapat', style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.textOnGold),
                onPressed: () {
                  Navigator.pop(context);
                  // Since we are inside Bottom Navigation tab-indexed wrapper or router
                  // We can navigate to '/' or direct to tab 1 (Kredi Mağazası).
                  // In router setup, '/' opens MainNavigationScreen. 
                  // For now, redirect to '/' (Home).
                  context.go('/');
                },
                child: const Text('Kredi Al'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      ),
    );

    // Simulate backend job scheduling
    await Future.delayed(const Duration(seconds: 1200 ~/ 1000));
    
    if (context.mounted) {
      Navigator.pop(context); // Close loading
      final genId = DateTime.now().millisecondsSinceEpoch.toString();
      context.go('/generation/progress/$genId'); // Navigate to progress tracking screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final activePreset = _selectedStyleUrl != null
        ? _presets.firstWhere((p) => p.imageUrl == _selectedStyleUrl, orElse: () => _presets[0])
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('İlham Panosu (Stil Aktarımı)'),
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
                    'Görsel Ruhunu Yakala',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Beğendiğiniz bir mücevher fotoğrafının ışık, arka plan ve kompozisyon stilini kopyalayıp kendi takınıza uygulayın.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 32),

                  // ADIM 1: ÜRÜN SEÇİMİ
                  _buildSectionHeader('1. Kendi Ürününüzü Ekleyin'),
                  const SizedBox(height: 12),
                  _buildUploadSlot(
                    imageUrl: _selectedProductUrl,
                    label: 'Ham Ürün Fotoğrafı Yükle',
                    subtitle: 'Örn: Telefonla çekilmiş beyaz zeminli yüzük',
                    onTap: _selectProduct,
                    icon: Icons.add_a_photo_outlined,
                  ),
                  const SizedBox(height: 32),

                  // ADIM 2: STİL SEÇİMİ
                  _buildSectionHeader('2. İlham Alınacak Görseli Seçin'),
                  const SizedBox(height: 12),
                  _buildUploadSlot(
                    imageUrl: _selectedStyleName == 'Galeriden Özel Stil' ? _selectedStyleUrl : null,
                    label: 'Instagram/Pinterest Görseli Yükle',
                    subtitle: 'Örn: Beğendiğiniz lüks stüdyo kompozisyonu',
                    onTap: _selectCustomStyle,
                    icon: Icons.palette_outlined,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'veya Hazır Lüks Stillerden Seçin:',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  
                  // HORIZONTAL PRESET SLIDER
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _presets.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final preset = _presets[index];
                        final isSelected = _selectedStyleUrl == preset.imageUrl;

                        return InkWell(
                          onTap: () => _selectPreset(preset),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 130,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.gold : AppColors.divider,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Image.network(preset.imageUrl, fit: BoxFit.cover),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                                  child: Text(
                                    preset.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isSelected ? AppColors.gold : AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ADIM 3: AI ANALİZ RAPORU
                  if (_selectedStyleUrl != null && activePreset != null) ...[
                    _buildSectionHeader('3. AI Tarz Analiz Raporu'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.psychology_outlined, color: AppColors.gold, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                '${_selectedStyleName} Stili Çözümlendi',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildAnalysisRow('Işık Düzeni', activePreset.light),
                          const SizedBox(height: 12),
                          _buildAnalysisRow('Zemin & Sahne', activePreset.background),
                          const SizedBox(height: 12),
                          _buildAnalysisRow('Renk & Atmosfer', activePreset.mood),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('4. Stil Aktarım Hassasiyeti (İnce Ayar)'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSliderRow(
                            title: 'Işık ve Gölge Aktarımı',
                            value: _lightIntensity,
                            onChanged: (val) {
                              setState(() {
                                _lightIntensity = val;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildSliderRow(
                            title: 'Arka Plan ve Sahne Uyumu',
                            value: _backgroundMatch,
                            onChanged: (val) {
                              setState(() {
                                _backgroundMatch = val;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildSliderRow(
                            title: 'Renk ve Doygunluk Geçişi',
                            value: _colorHarmony,
                            onChanged: (val) {
                              setState(() {
                                _colorHarmony = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],

                  // ÜRET BUTONU
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.textOnGold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      minimumSize: const Size.fromHeight(56),
                    ),
                    onPressed: (_selectedProductUrl == null || _selectedStyleUrl == null) ? null : _generateWithStyle,
                    icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: const Text(
                      'Stili Aktar ve Üret (1 Kredi 💎)',
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

  Widget _buildUploadSlot({
    required String? imageUrl,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider, style: BorderStyle.solid),
        ),
        clipBehavior: Clip.antiAlias,
        child: imageUrl != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(imageUrl, fit: BoxFit.cover),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.edit, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: AppColors.gold, size: 36),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderRow({
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.gold,
            inactiveTrackColor: AppColors.divider,
            thumbColor: AppColors.gold,
            overlayColor: AppColors.gold.withOpacity(0.12),
            valueIndicatorColor: AppColors.surfaceElevated,
            valueIndicatorTextStyle: const TextStyle(color: AppColors.textPrimary),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: 0.0,
            max: 1.0,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _StylePreset {
  final String name;
  final String imageUrl;
  final String light;
  final String background;
  final String mood;

  _StylePreset({
    required this.name,
    required this.imageUrl,
    required this.light,
    required this.background,
    required this.mood,
  });
}
