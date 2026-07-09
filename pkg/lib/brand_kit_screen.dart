import 'package:flutter/material.dart';
import 'app_colors.dart';

class BrandKitScreen extends StatefulWidget {
  const BrandKitScreen({super.key});

  @override
  State<BrandKitScreen> createState() => _BrandKitScreenState();
}

class _BrandKitScreenState extends State<BrandKitScreen> {
  bool _watermarkEnabled = true;
  String _selectedPosition = 'Alt-Sağ'; // Default position
  double _opacity = 0.4; // 40% transparency
  String? _logoUrl; // Default to fallback asset logo

  final List<String> _positions = ['Üst-Sol', 'Üst-Sağ', 'Merkez', 'Alt-Sol', 'Alt-Sağ'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Marka Kiti'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
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
                    'Kurumsal Kimlik Yönetimi',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Logonuzu ve marka filigranınızı bir kez yükleyin. Üretilen tüm görsellere otomatik olarak basılsın.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 32),

                  // 1. LOGO YÜKLEME ALANI
                  _buildSectionHeader('1. Firma Logosu (Crest/Arma)'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.divider),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _logoUrl != null
                              ? Image.network(_logoUrl!, fit: BoxFit.cover)
                              : Image.asset('assets/icon/app_icon.png', fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.surfaceElevated,
                                  foregroundColor: AppColors.gold,
                                  minimumSize: const Size(120, 36),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(color: AppColors.gold, width: 1),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _logoUrl = 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?q=80&w=150&auto=format&fit=crop';
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Yeni logo başarıyla yüklendi!')),
                                  );
                                },
                                child: const Text('Logoyu Değiştir', style: TextStyle(fontSize: 12)),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Şeffaf arka planlı PNG formatı önerilir.',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 2. FİLİGRAN (WATERMARK) AYARLARI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader('2. Otomatik Filigran Basımı'),
                      Switch.adaptive(
                        value: _watermarkEnabled,
                        activeColor: AppColors.gold,
                        onChanged: (val) {
                          setState(() {
                            _watermarkEnabled = val;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_watermarkEnabled) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Filigran Konumu',
                            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          
                          // Konum butonları grid
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _positions.map((pos) {
                              final isSelected = _selectedPosition == pos;
                              return ChoiceChip(
                                label: Text(pos),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedPosition = pos;
                                    });
                                  }
                                },
                                selectedColor: AppColors.gold.withOpacity(0.12),
                                labelStyle: TextStyle(
                                  color: isSelected ? AppColors.gold : AppColors.textSecondary,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                backgroundColor: AppColors.surfaceElevated,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: isSelected ? AppColors.gold : AppColors.divider),
                                ),
                              );
                            }).toList(),
                          ),
                          const Divider(height: 32),

                          // Şeffaflık Slider
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Şeffaflık Oranı',
                                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                '${(_opacity * 100).toInt()}%',
                                style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.gold,
                              inactiveTrackColor: AppColors.divider,
                              thumbColor: AppColors.gold,
                              trackHeight: 4,
                            ),
                            child: Slider(
                              value: _opacity,
                              min: 0.1,
                              max: 1.0,
                              onChanged: (val) {
                                setState(() {
                                  _opacity = val;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],

                  // KAYDET BUTONU
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.textOnGold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      minimumSize: const Size.fromHeight(56),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.success,
                          content: Text('Marka kiti değişiklikleri başarıyla kaydedildi!'),
                        ),
                      );
                    },
                    child: const Text('Marka Kitini Kaydet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
