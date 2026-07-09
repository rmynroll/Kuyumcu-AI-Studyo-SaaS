import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_colors.dart';
import 'gold_price_service.dart';

class CampaignCardsScreen extends ConsumerStatefulWidget {
  const CampaignCardsScreen({
    super.key,
    required this.productImageUrl,
  });

  final String productImageUrl;

  @override
  ConsumerState<CampaignCardsScreen> createState() => _CampaignCardsScreenState();
}

class _CampaignCardsScreenState extends ConsumerState<CampaignCardsScreen> {
  final TextEditingController _priceController = TextEditingController(text: '14.990 TL');
  final TextEditingController _gramController = TextEditingController(text: '4.20 gr');
  String _selectedCampaign = 'Anneler Günü'; // Default preset

  // Live gold price state
  bool _useLiveGoldPrice = false;
  String _selectedGoldType = 'gram-altin';
  double _workmanshipPercent = 10.0;
  double _fixedWorkmanship = 0.0;
  bool _isRefreshingGoldPrice = false;

  final List<String> _campaignPresets = [
    'Anneler Günü',
    'Sevgililer Günü',
    'Ramazan Bayramı',
    'Özel İndirim',
    'Düğün Sezonu',
  ];

  @override
  void initState() {
    super.initState();
    _gramController.addListener(_onInputsChanged);
  }

  void _onInputsChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _gramController.removeListener(_onInputsChanged);
    _priceController.dispose();
    _gramController.dispose();
    super.dispose();
  }

  String _formatMoney(int amount) {
    final str = amount.toString();
    if (str.length <= 3) return '$str TL';
    
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return '${buffer.toString().split('').reversed.join('')} TL';
  }

  String _formatDateTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  void _updateLivePrice(GoldPriceData prices) {
    if (!_useLiveGoldPrice) return;
    
    final cleanGramStr = _gramController.text
        .replaceAll(' gr', '')
        .replaceAll('gr', '')
        .trim()
        .replaceAll(',', '.');
    final double weight = double.tryParse(cleanGramStr) ?? 0.0;

    final double rawGoldRate = prices.getRateByType(_selectedGoldType);
    final double finalPricePerGram = rawGoldRate + _fixedWorkmanship;
    final double totalPrice = finalPricePerGram * weight * (1 + _workmanshipPercent / 100);

    final int roundedPrice = totalPrice.round();
    final formattedPrice = _formatMoney(roundedPrice);
    
    if (_priceController.text != formattedPrice) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _priceController.text = formattedPrice;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final goldPricesAsync = ref.watch(goldPriceProvider);

    // Dynamic price calculation if live gold price is enabled
    goldPricesAsync.whenData((prices) {
      if (_useLiveGoldPrice) {
        _updateLivePrice(prices);
      }
    });
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kampanya Kartı Oluşturucu'),
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
                  // BİLGİ
                  const Text(
                    'Yerelleştirilmiş Sosyal Medya Hazırlayıcı',
                    style: TextStyle(color: AppColors.gold, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Görselinizin üzerine fiyat, gramaj ve kampanya şablonları ekleyerek satışa hazır postlar oluşturun.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 28),

                  // LÜKS KAMPANYA KARTI ÖNİZLEMESİ
                  _buildPreviewCard(context),
                  const SizedBox(height: 32),

                  // KAMPANYA BAŞLIĞI DÜZENLEME
                  _buildSectionHeader('Kampanya Şablonu Seçin'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _campaignPresets.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final campaign = _campaignPresets[index];
                        final isSelected = _selectedCampaign == campaign;
                        return ChoiceChip(
                          label: Text(campaign),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCampaign = campaign;
                              });
                            }
                          },
                          selectedColor: AppColors.gold.withOpacity(0.12),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.gold : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          backgroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: isSelected ? AppColors.gold : AppColors.divider),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // CANLI ALTIN ENTEGRASYONU PANELİ
                  goldPricesAsync.when(
                    data: (prices) => Column(
                      children: [
                        _buildLiveGoldPriceCard(context, prices),
                        const SizedBox(height: 24),
                      ],
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
                    ),
                    error: (err, stack) => const SizedBox(),
                  ),

                  // BİLGİ GİRİŞİ: FİYAT VE GRAM
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Gram Bilgisi'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _gramController,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                              onChanged: (val) => setState(() {}),
                              decoration: _buildInputDecoration('Örn: 4.20 gr'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _buildSectionHeader('Fiyat Bilgisi'),
                                if (_useLiveGoldPrice) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: AppColors.gold, width: 0.8),
                                    ),
                                    child: const Text(
                                      'CANLI',
                                      style: TextStyle(
                                        color: AppColors.gold,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _priceController,
                              enabled: !_useLiveGoldPrice,
                              style: TextStyle(
                                color: _useLiveGoldPrice ? AppColors.gold : AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: _useLiveGoldPrice ? FontWeight.bold : FontWeight.normal,
                              ),
                              onChanged: (val) => setState(() {}),
                              decoration: _buildInputDecoration(
                                _useLiveGoldPrice ? 'Otomatik Canlı Fiyat' : 'Örn: 14.990 TL',
                              ).copyWith(
                                suffixIcon: _useLiveGoldPrice
                                    ? const Icon(Icons.lock_outline_rounded, color: AppColors.gold, size: 16)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // AKSİYON BUTONLARI
                  ElevatedButton.icon(
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
                          content: Text('Kampanya görseli galeriye kaydedildi!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_rounded, size: 20),
                    label: const Text('Kampanya Görselini Kaydet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
        fontSize: 13,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.surface,
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gold),
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // A. ARKA PLAN MÜCEVHER GÖRSELİ
          Image.network(widget.productImageUrl, fit: BoxFit.cover),

          // B. SÜS ÇERÇEVESİ (GRADIENT OVERLAY)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),

          // C. KAMPANYA ROZETİ (ÜSTTE ORTALANMIŞ)
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.goldLight, AppColors.gold, AppColors.goldDark],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
                  ],
                ),
                child: Text(
                  _selectedCampaign.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textOnGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // D. FİYAT VE GRAMAJ BİLGİSİ (ALTA SABİTLENMİŞ CAPSULE)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gold.withOpacity(0.4), width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'ÖZEL İŞÇİLİK',
                        style: TextStyle(color: AppColors.gold, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _gramController.text.isNotEmpty ? _gramController.text : '0.00 gr',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Text(
                    _priceController.text.isNotEmpty ? _priceController.text : '0.00 TL',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveGoldPriceCard(BuildContext context, GoldPriceData prices) {
    final currentRate = prices.getRateByType(_selectedGoldType);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _useLiveGoldPrice ? AppColors.gold.withOpacity(0.5) : AppColors.divider,
          width: 1.5,
        ),
        boxShadow: [
          if (_useLiveGoldPrice)
            BoxShadow(
              color: AppColors.gold.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
            )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    color: _useLiveGoldPrice ? AppColors.gold : AppColors.textSecondary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Canlı Altın Fiyat Entegrasyonu',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Switch.adaptive(
                value: _useLiveGoldPrice,
                activeColor: AppColors.gold,
                onChanged: (val) {
                  setState(() {
                    _useLiveGoldPrice = val;
                  });
                },
              ),
            ],
          ),
          
          if (_useLiveGoldPrice) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 16),

            // GOLD TYPE DROPDOWN
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Altın Ayarı / Türü',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedGoldType,
                      dropdownColor: AppColors.surface,
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.gold),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                      items: const [
                        DropdownMenuItem(value: 'gram-altin', child: Text('Gram Altın (24 Ayar)')),
                        DropdownMenuItem(value: 'gram-has-altin', child: Text('Has Altın (24 Ayar)')),
                        DropdownMenuItem(value: '22-ayar-bilezik', child: Text('22 Ayar Bilezik')),
                        DropdownMenuItem(value: '18-ayar-altin', child: Text('18 Ayar Altın')),
                        DropdownMenuItem(value: '14-ayar-altin', child: Text('14 Ayar Altın')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedGoldType = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // SLIDER FOR WORKMANSHIP PERCENTAGE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kâr / İşçilik Oranı',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                Text(
                  '%${_workmanshipPercent.round()}',
                  style: const TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.gold,
                inactiveTrackColor: AppColors.divider,
                thumbColor: AppColors.gold,
                overlayColor: AppColors.gold.withOpacity(0.12),
              ),
              child: Slider(
                value: _workmanshipPercent,
                min: 0,
                max: 50,
                divisions: 50,
                onChanged: (val) {
                  setState(() {
                    _workmanshipPercent = val;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),

            // EXTRA FIXED WORKMANSHIP INPUT
            Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sabit İşçilik (TL/gr)',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ham fiyata gram başına eklenir',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.background,
                        hintText: '0 TL',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.divider),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.gold),
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _fixedWorkmanship = double.tryParse(val) ?? 0.0;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // LIVE PRICE STATS CARD
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.flash_on, color: AppColors.gold, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Canlı Fiyat: 1 gr = ${_formatMoney(currentRate.round())}',
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Son Güncelleme: ${_formatDateTime(prices.updateDate)}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: _isRefreshingGoldPrice
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                          )
                        : const Icon(Icons.refresh, color: AppColors.gold, size: 20),
                    onPressed: _isRefreshingGoldPrice
                        ? null
                        : () async {
                            setState(() {
                              _isRefreshingGoldPrice = true;
                            });
                            await ref.refresh(goldPriceProvider.future);
                            if (mounted) {
                              setState(() {
                                _isRefreshingGoldPrice = false;
                              });
                            }
                          },
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            const Text(
              'Aktif ederek gram altın, has altın veya ayar bazlı canlı fiyat hesaplaması kullanabilirsiniz.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ]
        ],
      ),
    );
  }
}
