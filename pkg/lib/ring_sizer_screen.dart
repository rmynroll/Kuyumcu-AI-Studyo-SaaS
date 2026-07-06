import 'package:flutter/material.dart';
import 'app_colors.dart';

class RingSizerScreen extends StatefulWidget {
  const RingSizerScreen({super.key});

  @override
  State<RingSizerScreen> createState() => _RingSizerScreenState();
}

class _RingSizerScreenState extends State<RingSizerScreen> {
  double _diameterMm = 17.3; // Default size (Standard size 14-15 in TR)

  // Map diameter to TR standard ring sizes
  int get _calculatedTrSize {
    // Basic linear map: TR sizes usually range from 8 (15.3mm) to 28 (21.6mm)
    // 17.3mm is roughly size 14
    final size = ((_diameterMm - 15.0) * 3.125 + 7.0).round();
    return size.clamp(7, 30);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Yüzük Ölçer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // BİLGİLENDİRME
              const Text(
                'Fiziksel Kalibrasyon',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.gold, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Mevcut bir yüzüğünüzü ekrandaki halkanın üzerine koyun. Sürükleyiciyi kullanarak halkanın sınırlarını yüzüğün iç metal kısmına eşitleyin.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 40),

              // HALKA ÖLÇÜM ALANI
              Center(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.divider, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Center(
                    // Dynamically sized ring circle
                    child: Container(
                      width: _diameterMm * 10, // scaling multiplier
                      height: _diameterMm * 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                          color: AppColors.gold,
                          width: 4,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.goldLight.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // DEĞER PANALİ
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('İç Çap', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          '${_diameterMm.toStringAsFixed(1)} mm',
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 40, color: AppColors.divider),
                    Column(
                      children: [
                        const Text('TR Yüzük Ölçüsü', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          '$_calculatedTrSize No',
                          style: const TextStyle(color: AppColors.gold, fontSize: 22, fontWeight: FontWeight.extrabold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // SLIDER
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.gold,
                  inactiveTrackColor: AppColors.divider,
                  thumbColor: AppColors.gold,
                  overlayColor: AppColors.gold.withOpacity(0.12),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _diameterMm,
                  min: 14.0,
                  max: 22.0,
                  onChanged: (val) {
                    setState(() {
                      _diameterMm = val;
                    });
                  },
                ),
              ),
              const SizedBox(height: 40),

              // B2B2C PAYLAŞIM ALANI
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.textOnGold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  minimumSize: const Size.fromHeight(56),
                ),
                onPressed: () => _showShareSizerSheet(context),
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                label: const Text('WhatsApp ile Müşterine Ölçtür', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showShareSizerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Müşterine QR / Link Gönder',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bu QR kodu veya linki müşterinize gönderin. Müşteriniz herhangi bir uygulama indirmeden kendi telefonundan yüzük ölçüsünü kolayca belirleyebilir.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 24),
              
              // MOCK QR CODE CONTAINER
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.network(
                    'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=https://kuyumcuaistudio.com/sizer/sarraf-1',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'kuyumcuaistudio.com/sizer/sarraf-1',
                  style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  minimumSize: const Size.fromHeight(56),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yüzük ölçer bağlantısı WhatsApp üzerinden paylaşıldı!')),
                  );
                },
                icon: const Icon(Icons.share, color: Colors.white),
                label: const Text('Bağlantıyı WhatsApp\'ta Paylaş', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }
}
