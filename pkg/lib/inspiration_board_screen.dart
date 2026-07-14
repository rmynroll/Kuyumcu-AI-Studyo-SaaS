import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'app_colors.dart';
import 'credits_provider.dart';
import 'generation_repository.dart';

class InspirationBoardScreen extends ConsumerStatefulWidget {
  final int? initialTab;
  final String? initialPrompt;

  const InspirationBoardScreen({
    super.key,
    this.initialTab,
    this.initialPrompt,
  });

  @override
  ConsumerState<InspirationBoardScreen> createState() => _InspirationBoardScreenState();
}

class _InspirationBoardScreenState extends ConsumerState<InspirationBoardScreen> {
  // Selection states
  String? _selectedProductUrl;
  String? _selectedStyleUrl;
  String? _selectedStyleName;

  int _selectedStyleTab = 0; // 0: Hazır, 1: Referans Yükle, 2: Kutu Seçimi, 3: Yapay Zeka Manken, 4: Serbest Tarif
  final TextEditingController _styleUrlController = TextEditingController();
  final TextEditingController _stylePromptController = TextEditingController();
  final TextEditingController _boxPromptController = TextEditingController();
  final TextEditingController _modelPromptController = TextEditingController();
  int _selectedBoxIndex = 0;
  int _selectedModelIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialTab != null) {
      _selectedStyleTab = widget.initialTab!;
    }
    if (widget.initialPrompt != null) {
      _stylePromptController.text = widget.initialPrompt!;
      _selectedStyleTab = 4; // Swaps to free prompt mode (tab index 4)
      _selectedStyleUrl = 'prompt_mode';
      _selectedStyleName = 'Metin Tarifi: ${widget.initialPrompt}';
    }
  }

  @override
  void dispose() {
    _styleUrlController.dispose();
    _stylePromptController.dispose();
    _boxPromptController.dispose();
    _modelPromptController.dispose();
    super.dispose();
  }

  // Fine-tuning slider parameters
  double _lightIntensity = 0.85;
  double _backgroundMatch = 0.75;
  double _colorHarmony = 0.90;
  String _selectedRatio = '1:1 Kare';
  String _selectedRes = '4K Ultra HD';

  // Mock product option
  final String _mockProductUrl = 'https://images.unsplash.com/photo-1598560917505-59a3ad559071?q=80&w=400&auto=format&fit=crop';

  // Presets definition
  final List<_StylePreset> _presets = [
    _StylePreset(
      name: 'Lüks İtalyan',
      imageUrl: 'https://images.unsplash.com/photo-1533090161767-e6ffed986c88?q=80&w=400&auto=format&fit=crop',
      light: 'Yumuşak Çapraz Işık, Yüksek Dinamik Aralık (HDR)',
      background: 'Cilalı Beyaz Mermer ve Altın Vurgular',
      mood: 'Sıcak & Lüks Akdeniz Esintisi (%94 Kararlılık)',
    ),
    _StylePreset(
      name: 'Doğal Gün Işığı',
      imageUrl: 'https://images.unsplash.com/photo-1541123437800-1bb1317badc2?q=80&w=400&auto=format&fit=crop',
      light: 'Yanal Gün Işığı, Yaprak Gölgeleri Efekti',
      background: 'Rustik Meşe Ağacı Zemin',
      mood: 'Minimalist & Doğal Atmosfer (%91 Kararlılık)',
    ),
    _StylePreset(
      name: 'Siyah Kadife',
      imageUrl: 'https://images.unsplash.com/photo-1502239608882-93b729c6af43?q=80&w=400&auto=format&fit=crop',
      light: 'Spot Tepe Işığı, Yüksek Kontrastlı Yansıma',
      background: 'Koyu Kadife Zemin',
      mood: 'Gizemli & Dramatik Lüks (%96 Kararlılık)',
    ),
  ];

  // Kutu çeşitleri listesi
  final List<_BoxPreset> _boxes = [
    _BoxPreset(
      name: 'Kırmızı Kadife Kutu',
      imageUrl: 'https://images.unsplash.com/photo-1601121141461-9d6647bca1ed?q=80&w=400&auto=format&fit=crop',
      description: 'Lüks ve romantik kırmızı kadife doku, yumuşak kadife yüzük yatağı.',
    ),
    _BoxPreset(
      name: 'Lüks Ahşap Kutu',
      imageUrl: 'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?q=80&w=400&auto=format&fit=crop',
      description: 'Ceviz ağacından el yapımı, mat cilalı doğal ahşap kutu.',
    ),
    _BoxPreset(
      name: 'Kraliyet Mavisi Kutu',
      imageUrl: 'https://images.unsplash.com/photo-1512909006721-3d6018887383?q=80&w=400&auto=format&fit=crop',
      description: 'Koyu lacivert saten kaplama, asil ve göz alıcı kontrast sunumu.',
    ),
    _BoxPreset(
      name: 'Modern Siyah Kutu',
      imageUrl: 'https://images.unsplash.com/photo-1502239608882-93b729c6af43?q=80&w=400&auto=format&fit=crop',
      description: 'Mat siyah minimalist kutu, dramatik stüdyo spot ışığı yansıması.',
    ),
  ];

  // Yapay Zeka Manken listesi
  final List<_ModelPreset> _models = [
    _ModelPreset(
      name: 'El Mankeni',
      imageUrl: 'https://images.unsplash.com/photo-1602751584552-8ba73aad10e1?q=80&w=400&auto=format&fit=crop',
      description: 'Zarif el mankeni duruşu. Yüzük, alyan ve bileklikler için idealdir.',
    ),
    _ModelPreset(
      name: 'Yüz & Boyun Mankeni',
      imageUrl: 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400&auto=format&fit=crop',
      description: 'Lüks portre ve dekolte planı. Kolye, gerdanlık ve küpeler için idealdir.',
    ),
  ];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source, bool isProduct) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          if (isProduct) {
            _selectedProductUrl = image.path;
          } else {
            _selectedStyleUrl = image.path;
            _selectedStyleName = 'Galeriden Özel Stil';
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isProduct ? 'Ürün görseli başarıyla eklendi.' : 'Stil referans görseli başarıyla yüklendi.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Görsel seçilemedi: $e')),
      );
    }
  }

  void _selectProduct() {
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
                  _pickImage(ImageSource.gallery, true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.gold),
                title: const Text('Kamera ile Çek', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dashboard_outlined, color: AppColors.gold),
                title: const Text('Örnek Görsel Kullan (Demo)', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedProductUrl = _mockProductUrl;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Örnek ürün görseli seçildi.')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectPreset(_StylePreset preset) {
    setState(() {
      _selectedStyleUrl = preset.imageUrl;
      _selectedStyleName = preset.name;
    });
  }

  void _selectCustomStyle() {
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
                  _pickImage(ImageSource.gallery, false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.gold),
                title: const Text('Kamera ile Çek', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dashboard_outlined, color: AppColors.gold),
                title: const Text('Örnek Görsel Kullan (Demo)', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedStyleUrl = 'https://images.unsplash.com/photo-1617038260897-41a1f14a8ca0?q=80&w=400&auto=format&fit=crop';
                    _selectedStyleName = 'Örnek Referans Görsel';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Örnek referans görseli seçildi.')),
                  );
                },
              ),
            ],
          ),
        );
      },
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

    // Görsel üretim işini yerel repoda oluştur
    final repo = ref.read(generationRepositoryProvider);
    String styleId = _selectedStyleUrl!;
    if (styleId == 'prompt_mode') {
      final prompt = _stylePromptController.text.toLowerCase();
      styleId = 'https://images.unsplash.com/photo-1533090161767-e6ffed986c88?q=80&w=400&auto=format&fit=crop'; // Default: marble
      
      if (prompt.contains('kırmızı') || prompt.contains('red') || prompt.contains('yakut kutu')) {
        styleId = 'https://images.unsplash.com/photo-1601121141461-9d6647bca1ed?q=80&w=400&auto=format&fit=crop';
      } else if (prompt.contains('ahşap') || prompt.contains('wood') || prompt.contains('kahve') || prompt.contains('meşe')) {
        styleId = 'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?q=80&w=400&auto=format&fit=crop';
      } else if (prompt.contains('mavi') || prompt.contains('blue') || prompt.contains('lacivert') || prompt.contains('kraliyet')) {
        styleId = 'https://images.unsplash.com/photo-1512909006721-3d6018887383?q=80&w=400&auto=format&fit=crop';
      } else if (prompt.contains('siyah') || prompt.contains('black') || prompt.contains('kadife') || prompt.contains('velvet')) {
        styleId = 'https://images.unsplash.com/photo-1502239608882-93b729c6af43?q=80&w=400&auto=format&fit=crop';
      } else if (prompt.contains('boyun') || prompt.contains('neck') || prompt.contains('kolye') || prompt.contains('gerdan') || prompt.contains('yüz') || prompt.contains('face') || prompt.contains('model portre')) {
        styleId = 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400&auto=format&fit=crop';
      } else if (prompt.contains('el') || prompt.contains('parmak') || prompt.contains('hand') || prompt.contains('finger') || prompt.contains('manken') || prompt.contains('model')) {
        styleId = 'https://images.unsplash.com/photo-1602751584552-8ba73aad10e1?q=80&w=400&auto=format&fit=crop';
      } else if (prompt.contains('ışık') || prompt.contains('güneş') || prompt.contains('sun') || prompt.contains('light') || prompt.contains('gün')) {
        styleId = 'https://images.unsplash.com/photo-1541123437800-1bb1317badc2?q=80&w=400&auto=format&fit=crop';
      }
    }

    final gen = await repo.createFromTemplate(
      productId: _selectedProductUrl!,
      templateId: styleId,
      aspectRatio: _selectedRatio,
    );
    
    if (context.mounted) {
      Navigator.pop(context); // Close loading
      context.go('/generation/progress/${gen.id}'); // Navigate to progress tracking screen
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
                  _buildSectionHeader('2. İlham Alınacak Görseli/Tarifi Belirleyin'),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildTabButton(0, 'Hazır Stiller', Icons.auto_awesome_mosaic_outlined),
                        _buildTabButton(1, 'Referans Yükle', Icons.photo_library_outlined),
                        _buildTabButton(2, 'Kutu Seçimi', Icons.inventory_2_outlined),
                        _buildTabButton(3, 'Manken Seçimi', Icons.face_retouching_natural_outlined),
                        _buildTabButton(4, 'Serbest Tarif', Icons.edit_note_rounded),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTabContent(),
                  const SizedBox(height: 32),

                  // ADIM 3: AI ANALİZ RAPORU
                  if (_selectedStyleUrl != null) ...[
                    _buildStyleAnalysisSection(
                      _selectedStyleUrl != null && _presets.any((p) => p.imageUrl == _selectedStyleUrl),
                      activePreset,
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
                          const Divider(height: 32),
                          const Text('GÖRSEL BOYUT (ASPECT RATIO)', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildSettingsChoiceChip('1:1 Kare', _selectedRatio, (val) => setState(() => _selectedRatio = val)),
                              _buildSettingsChoiceChip('9:16 Hikaye', _selectedRatio, (val) => setState(() => _selectedRatio = val)),
                              _buildSettingsChoiceChip('4:3 Klasik Web', _selectedRatio, (val) => setState(() => _selectedRatio = val)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text('ÇÖZÜNÜRLÜK KALİTESİ', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildSettingsChoiceChip('Standart (1K)', _selectedRes, (val) => setState(() => _selectedRes = val)),
                              _buildSettingsChoiceChip('4K Ultra HD', _selectedRes, (val) => setState(() => _selectedRes = val)),
                              _buildSettingsChoiceChip('Stüdyo Kalitesi', _selectedRes, (val) => setState(() => _selectedRes = val)),
                            ],
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
                  _buildImageWidget(imageUrl),
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

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _selectedStyleTab == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedStyleTab = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 105,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gold.withOpacity(0.12) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.gold : AppColors.divider,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? AppColors.gold : AppColors.textSecondary, size: 18),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.gold : AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedStyleTab) {
      case 0: // Hazır Stiller
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aşağıdaki lüks stillerden birini seçin:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
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
          ],
        );
      case 1: // Referans Yükle / Link Gir
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Bir stil referans fotoğrafı yükleyin:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 10),
              _buildUploadSlot(
                imageUrl: _selectedStyleName == 'Galeriden Özel Stil' ? _selectedStyleUrl : null,
                label: 'Görsel Yükle (Galeri / Kamera)',
                subtitle: 'Referans görselinizi seçin',
                onTap: _selectCustomStyle,
                icon: Icons.photo_library_outlined,
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(child: Divider(color: AppColors.divider)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('VEYA', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(child: Divider(color: AppColors.divider)),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _styleUrlController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Web Görsel veya Paylaşım Linki',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  hintText: 'Instagram, Pinterest veya web görsel linki...',
                  hintStyle: const TextStyle(color: Colors.white24),
                  prefixIcon: const Icon(Icons.link, color: AppColors.gold),
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
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.textOnGold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  final text = _styleUrlController.text.trim();
                  if (text.isEmpty) return;
                  setState(() {
                    _selectedStyleUrl = text;
                    _selectedStyleName = 'Web Linkinden Stil';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Görsel linki başarıyla uygulandı!')),
                  );
                },
                child: const Text('Linki Uygula', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              if (_selectedStyleName == 'Web Linkinden Stil' && _selectedStyleUrl != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Uygulanan Link Önizlemesi:',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _selectedStyleUrl!.startsWith('http')
                      ? Image.network(
                          _selectedStyleUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.black38,
                            child: const Center(
                              child: Text(
                                'Önizleme yüklenemedi (Doğrudan resim linki olmayabilir)',
                                style: TextStyle(color: Colors.redAccent, fontSize: 11),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.black38,
                          child: Center(
                            child: Text(
                              _selectedStyleUrl!,
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                ),
              ]
            ],
          ),
        );
      case 2: // Kutu Seçimi
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Mücevherin yerleştirileceği kutu çeşidini seçin:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _boxes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final box = _boxes[index];
                    final isSelected = _selectedBoxIndex == index;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedBoxIndex = index;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 110,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
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
                              child: Image.network(box.imageUrl, fit: BoxFit.cover),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4),
                              child: Text(
                                box.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected ? AppColors.gold : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _boxes[_selectedBoxIndex].description,
                style: const TextStyle(color: AppColors.gold, fontSize: 11, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _boxPromptController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Kutu İçi Detaylar (Prompt)',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  hintText: 'Örn: Işık kutunun iç kadifesine yansısın, kutu kapağı hafif aralık dursun...',
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
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.textOnGold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  final box = _boxes[_selectedBoxIndex];
                  final promptText = _boxPromptController.text.trim();
                  setState(() {
                    _selectedStyleUrl = box.imageUrl;
                    _selectedStyleName = promptText.isNotEmpty
                        ? 'Kutuda Sunum: ${box.name} (${promptText})'
                        : 'Kutuda Sunum: ${box.name}';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kutulu sunum tarzı ve detayları uygulandı!')),
                  );
                },
                child: const Text('Kutuyu ve Tarifi Uygula', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      case 3: // Manken Seçimi
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Mücevherin sergileneceği yapay zeka manken modelini seçin:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _models.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final model = _models[index];
                    final isSelected = _selectedModelIndex == index;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedModelIndex = index;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 110,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
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
                              child: Image.network(model.imageUrl, fit: BoxFit.cover),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4),
                              child: Text(
                                model.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected ? AppColors.gold : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _models[_selectedModelIndex].description,
                style: const TextStyle(color: AppColors.gold, fontSize: 11, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _modelPromptController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Manken ve Kadraj Detayları (Prompt)',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  hintText: 'Örn: 20\'li yaşlarda İtalyan kadın manken, bej gömlekli, doğal güneş gölgeli...',
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
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.textOnGold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  final model = _models[_selectedModelIndex];
                  final promptText = _modelPromptController.text.trim();
                  setState(() {
                    _selectedStyleUrl = model.imageUrl;
                    _selectedStyleName = promptText.isNotEmpty
                        ? 'Yapay Zeka Manken: ${model.name} (${promptText})'
                        : 'Yapay Zeka Manken: ${model.name}';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Manken tarzı ve detayları uygulandı!')),
                  );
                },
                child: const Text('Mankeni ve Tarifi Uygula', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      case 4: // Tarif Yaz
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _stylePromptController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Stil / Sahne Tarifi',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  hintText: 'Yapay zekanın oluşturacağı arka plan ve ışık düzenini tarif edin...\nÖrn: Siyah parlak zemin üzerinde, tepeden vuran odak spot ışığı...',
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
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.textOnGold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  final text = _stylePromptController.text.trim();
                  if (text.isEmpty) return;
                  setState(() {
                    _selectedStyleUrl = 'prompt_mode';
                    _selectedStyleName = 'Metin Tarifi: $text';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Stil tarifi başarıyla uygulandı!')),
                  );
                },
                child: const Text('Tarifi Uygula', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              if (_selectedStyleUrl == 'prompt_mode' && _selectedStyleName != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Aktif Stil Tarifi:',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_note_rounded, color: AppColors.gold, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedStyleName!.replaceAll('Metin Tarifi: ', ''),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStyleAnalysisSection(bool isPreset, dynamic activePreset) {
    if (isPreset && activePreset != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
        ],
      );
    } else {
      final isPrompt = _selectedStyleUrl == 'prompt_mode';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      isPrompt ? 'Yazılı Tarif Analiz Edildi' : 'Özel Görsel Analiz Edildi',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildAnalysisRow(
                  isPrompt ? 'Stil Motoru' : 'Stil Analizör',
                  isPrompt 
                      ? 'Yazdığınız tarif doğrudan yapay zeka görsel motoruna yönlendirilecek.'
                      : 'Referans görseldeki sahne kompozisyonu, ışık açıları ve renk tonları çıkarıldı.',
                ),
                const SizedBox(height: 12),
                _buildAnalysisRow(
                  'Kararlılık',
                  isPrompt ? 'Yüksek (Metinsel Odak)' : 'Dinamik (%92 Uyum Oranı)',
                ),
              ],
            ),
          ),
        ],
      );
    }
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

  Widget _buildSettingsChoiceChip(String label, String groupValue, ValueChanged<String> onSelected) {
    final isSelected = label == groupValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(label),
      selectedColor: AppColors.gold.withOpacity(0.12),
      backgroundColor: Colors.transparent,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.gold : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 11,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isSelected ? AppColors.gold : AppColors.divider),
      ),
      showCheckmark: false,
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

class _BoxPreset {
  final String name;
  final String imageUrl;
  final String description;

  _BoxPreset({
    required this.name,
    required this.imageUrl,
    required this.description,
  });
}

class _ModelPreset {
  final String name;
  final String imageUrl;
  final String description;

  _ModelPreset({
    required this.name,
    required this.imageUrl,
    required this.description,
  });
}
