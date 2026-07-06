import 'package:flutter/material.dart';
import 'app_colors.dart';

class CampaignCardsScreen extends StatefulWidget {
  const CampaignCardsScreen({
    super.key,
    required this.productImageUrl,
  });

  final String productImageUrl;

  @override
  State<CampaignCardsScreen> createState() => _CampaignCardsScreenState();
}

class _CampaignCardsScreenState extends State<CampaignCardsScreen> {
  final TextEditingController _priceController = TextEditingController(text: '14.990 TL');
  final TextEditingController _gramController = TextEditingController(text: '4.20 gr');
  String _selectedCampaign = 'Anneler Günü'; // Default preset

  final List<String> _campaignPresets = [
    'Anneler Günü',
    'Sevgililer Günü',
    'Ramazan Bayramı',
    'Özel İndirim',
    'Düğün Sezonu',
  ];

  @override
  void dispose() {
    _priceController.dispose();
    _gramController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                            _buildSectionHeader('Fiyat Bilgisi'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _priceController,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                              onChanged: (val) => setState(() {}),
                              decoration: _buildInputDecoration('Örn: 14.990 TL'),
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
                    fontWeight: FontWeight.extrabold,
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
                      fontWeight: FontWeight.extrabold,
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
}
