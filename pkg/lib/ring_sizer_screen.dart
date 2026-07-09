import 'package:flutter/material.dart';
import 'app_colors.dart';

class RingSizerScreen extends StatefulWidget {
  const RingSizerScreen({super.key, this.isClientMode = false});

  final bool isClientMode;

  @override
  State<RingSizerScreen> createState() => _RingSizerScreenState();
}

class _RingSizerScreenState extends State<RingSizerScreen> {
  // Modes: 0 = Existing Ring, 1 = Card Calibration
  int _activeMode = 0;

  // Mode 0: Ring Calibration Variables
  double _ringDiameterMm = 17.3;

  // Mode 1: Card Calibration Variables
  double _cardWidthPixels = 220.0;
  double _calibratedDiameterMm = 17.3;

  // Calculate TR standard size based on diameter
  int _getCalculatedTrSize(double diameter) {
    // 17.3mm is roughly size 14
    final size = ((diameter - 15.0) * 3.125 + 7.0).round();
    return size.clamp(7, 30);
  }

  double get _pixelsPerMm {
    // Standard credit card width is 85.6 mm
    return _cardWidthPixels / 85.6;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Yüzük Ölçer Pro'),
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
              // MODE SWITCHER TOGGLE
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeMode = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _activeMode == 0 ? AppColors.gold : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Yüzük ile Ölç',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _activeMode == 0 ? AppColors.textOnGold : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeMode = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _activeMode == 1 ? AppColors.gold : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Kart ile Kalibre Et',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _activeMode == 1 ? AppColors.textOnGold : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_activeMode == 0) _buildRingCalibrationView() else _buildCardCalibrationView(),

              const SizedBox(height: 32),

              // DYNAMIC RESULTS VIEW
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
                          '${(_activeMode == 0 ? _ringDiameterMm : _calibratedDiameterMm).toStringAsFixed(1)} mm',
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
                          '${_getCalculatedTrSize(_activeMode == 0 ? _ringDiameterMm : _calibratedDiameterMm)} No',
                          style: const TextStyle(color: AppColors.gold, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // ACTION BUTTONS
              if (widget.isClientMode)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.textOnGold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    minimumSize: const Size.fromHeight(56),
                  ),
                  onPressed: () {
                    final size = _getCalculatedTrSize(_activeMode == 0 ? _ringDiameterMm : _calibratedDiameterMm);
                    Navigator.pop(context, size);
                  },
                  icon: const Icon(Icons.check, size: 20),
                  label: const Text('Ölçümü Onayla ve Gönder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                )
              else ...[
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRingCalibrationView() {
    return Column(
      children: [
        const Text(
          'Fiziksel Kalibrasyon',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.gold, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Mevcut bir yüzüğünüzü ekrandaki halkanın üzerine koyun. Sürükleyiciyi kullanarak halkanın sınırlarını yüzüğün iç kısmına eşitleyin.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 32),

        // RING AREA
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
              child: Container(
                width: _ringDiameterMm * 10,
                height: _ringDiameterMm * 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: Border.all(color: AppColors.gold, width: 4),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.goldLight.withOpacity(0.4), width: 1),
                  ),
                ),
              ),
            ),
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
            value: _ringDiameterMm,
            min: 14.0,
            max: 22.0,
            onChanged: (val) {
              setState(() {
                _ringDiameterMm = val;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCardCalibrationView() {
    return Column(
      children: [
        const Text(
          'Ekran Kalibrasyonu (Kredi Kartı ile)',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.gold, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Herhangi bir plastik kartı (kredi kartı, kimlik kartı) ekrandaki sarı çerçeve ile birebir boyuta getirin. Ardından alttaki halkayı parmağınızla hizalayın.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 24),

        // CARD AND DYNAMIC RING SPLIT VIEW
        Column(
          children: [
            // Credit card silhouette
            Container(
              width: _cardWidthPixels,
              height: _cardWidthPixels * 0.63,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.gold, width: 2.5),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payment, color: AppColors.gold, size: 24),
                    SizedBox(height: 4),
                    Text(
                      'FİZİKSEL KARTI HİZALAYIN',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Slider(
              value: _cardWidthPixels,
              min: 160.0,
              max: 280.0,
              activeColor: AppColors.gold,
              inactiveColor: AppColors.divider,
              onChanged: (val) {
                setState(() {
                  _cardWidthPixels = val;
                });
              },
            ),
            const SizedBox(height: 24),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 24),

            // Accurate calibrated ring
            const Text(
              'Parmağınızı / Yüzüğünüzü Eşleştirin',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              width: _calibratedDiameterMm * _pixelsPerMm,
              height: _calibratedDiameterMm * _pixelsPerMm,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(color: AppColors.gold, width: 3.5),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.goldLight.withOpacity(0.3), width: 1),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Slider(
              value: _calibratedDiameterMm,
              min: 14.0,
              max: 22.0,
              activeColor: AppColors.gold,
              inactiveColor: AppColors.divider,
              onChanged: (val) {
                setState(() {
                  _calibratedDiameterMm = val;
                });
              },
            ),
          ],
        ),
      ],
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
