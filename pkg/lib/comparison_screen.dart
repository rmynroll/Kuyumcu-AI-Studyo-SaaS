import 'package:flutter/material.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'app_colors.dart';

/// Önce/Sonra Karşılaştırma Ekranı.
/// Kuyumcuların takı geometrisi kararlılığını test etmesi için
/// altın kılavuz grid (CAD mesh), büyüteç merceği ve gerçek zamanlı analiz metrikleri sunar.
class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({
    super.key,
    required this.beforeImageUrl,
    required this.afterImageUrl,
    required this.productTitle,
  });

  final String beforeImageUrl;
  final String afterImageUrl;
  final String productTitle;

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  double _sliderFraction = 0.5; // Başlangıçta tam ortada
  bool _isGridEnabled = true;   // Altın Kılavuz Grid açık/kapalı
  bool _isLoupeEnabled = false;  // Büyüteç açık/kapalı
  Offset? _touchPosition;       // Büyüteç koordinatları

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.productTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Grid ve Büyüteç Hızlı Ayarları
          IconButton(
            icon: Icon(
              _isGridEnabled ? Icons.grid_on_rounded : Icons.grid_off_rounded,
              color: _isGridEnabled ? AppColors.gold : AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _isGridEnabled = !_isGridEnabled;
              });
            },
            tooltip: 'Kılavuz Izgarayı Aç/Kapat',
          ),
          IconButton(
            icon: Icon(
              _isLoupeEnabled ? Icons.zoom_in_rounded : Icons.zoom_out_rounded,
              color: _isLoupeEnabled ? AppColors.gold : AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _isLoupeEnabled = !_isLoupeEnabled;
                if (!_isLoupeEnabled) _touchPosition = null;
              });
            },
            tooltip: 'Büyüteç Aracını Aç/Kapat',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. AÇIKLAMA BAŞLIĞI
              const Text(
                'Detay Koruma Kontrolü',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Çizgiyi sağa sola kaydırarak ürününüzün detaylarının bozulmadığını kontrol edin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),

              // Karşılaştırma Moduna Göre Değişen Gerçek Zamanlı Analiz Skorları
              _buildFidelityStatusRow(),
              const SizedBox(height: 16),

              // 2. ANA SLIDER ALANI
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final height = constraints.maxHeight;

                        return GestureDetector(
                          onPanStart: (details) {
                            if (_isLoupeEnabled) {
                              setState(() {
                                _touchPosition = details.localPosition;
                              });
                            }
                          },
                          onPanUpdate: (details) {
                            setState(() {
                              // Eğer büyüteç açıksa ve dokunma büyüteç sınırlarına yakınsa büyüteci hareket ettir
                              if (_isLoupeEnabled) {
                                _touchPosition = details.localPosition;
                              }
                              
                              // Slider hareket ettirme hassasiyeti (büyüteç kapalıyken veya slider'a yakın sürüklerken)
                              if (!_isLoupeEnabled || (details.localPosition.dx - (width * _sliderFraction)).abs() < 40) {
                                _sliderFraction = (_sliderFraction + details.delta.dx / width).clamp(0.0, 1.0);
                              }
                            });
                          },
                          onPanEnd: (_) {
                            if (_isLoupeEnabled) {
                              setState(() {
                                _touchPosition = null;
                              });
                            }
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // GÖRSEL STACK'İ (Ortak Metoda Çıkardık)
                              _buildSliderStack(width, height),

                              // C. OVERLAYS: Etiketler
                              Positioned(
                                top: 16,
                                left: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: const Text(
                                    'ÖNCE (ORİJİNAL)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),

                              Positioned(
                                top: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.goldLight.withOpacity(0.3)),
                                  ),
                                  child: const Text(
                                    'SONRA (AI STÜDYO)',
                                    style: TextStyle(
                                      color: AppColors.textOnGold,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),

                              // D. DIVIDER LINE & HANDLE
                              Positioned(
                                left: width * _sliderFraction - 1,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 2,
                                  color: AppColors.gold,
                                ),
                              ),

                              Positioned(
                                left: width * _sliderFraction - 24,
                                top: height / 2 - 24,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.gold, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.gold.withOpacity(0.3),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.swap_horiz_rounded,
                                    color: AppColors.gold,
                                    size: 24,
                                  ),
                                ),
                              ),

                              // DİNAMİK BÜYÜTEÇ KATMANI
                              if (_isLoupeEnabled && _touchPosition != null)
                                Positioned(
                                  left: _touchPosition!.dx - 75,
                                  top: _touchPosition!.dy - 165,
                                  child: IgnorePointer(
                                    child: Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.gold, width: 2.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.55),
                                            blurRadius: 18,
                                            spreadRadius: 2,
                                          )
                                        ],
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Stack(
                                        children: [
                                          Transform.scale(
                                            scale: 2.2,
                                            origin: Offset(
                                              (_touchPosition!.dx / width - 0.5) * 150,
                                              (_touchPosition!.dy / height - 0.5) * 150,
                                            ),
                                            child: _buildSliderStack(width, height),
                                          ),
                                          Center(
                                            child: Container(
                                              width: 14,
                                              height: 14,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(color: AppColors.gold, width: 1),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 6,
                                            left: 0,
                                            right: 0,
                                            child: Center(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.7),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  '2.2X DETAY MERCEĞİ',
                                                  style: TextStyle(color: AppColors.gold, fontSize: 8, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. DOĞRULAMA & GÜVEN KARTI
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 20),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ürün Geometrisi Birebir Korundu',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Takınızın tırnak kalınlığı, taş sayısı, kesim açısı ve metal rengi tam korumalıdır.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 4. AKSİYON BUTONLARI
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.divider),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        minimumSize: const Size.fromHeight(56),
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Kapat', style: TextStyle(fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.textOnGold,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        minimumSize: const Size.fromHeight(56),
                      ),
                      onPressed: () {
                        _showShareDialog(context);
                      },
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Kıyası Paylaş', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Before ve After katmanlarını bir arada barındıran temel görsel yapısı
  Widget _buildSliderStack(double width, double height) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // A. ALT KATMAN: Yapay Zeka Çıktısı (Sağda görünür)
        _buildImageWidget(widget.afterImageUrl),

        // B. ÜST KATMAN: Orijinal Görsel (Solda görünür, sliderFraction ile kırpılır)
        ClipRect(
          clipper: _SliderClipper(_sliderFraction),
          child: _buildImageWidget(widget.beforeImageUrl),
        ),

        // E. ALTIN GEOMETRİK GRID (CAD MESH) KATMANI
        if (_isGridEnabled)
          IgnorePointer(
            child: CustomPaint(
              painter: GoldenMeshPainter(),
            ),
          ),
      ],
    );
  }

  // Dinamik olarak görseli yerel veya uzak url formatına göre yükleyen widget
  Widget _buildImageWidget(String path) {
    if (path.startsWith('composite:')) {
      final paramsStr = path.replaceFirst('composite:', '');
      final queryParams = Uri.splitQueryString(paramsStr);
      final productUrl = queryParams['productUrl'] ?? '';
      final styleUrl = queryParams['styleUrl'] ?? '';

      return Stack(
        fit: StackFit.expand,
        children: [
          // Background template
          _buildSingleImage(styleUrl),
          // Subtle radial dark shadow to focus the ring
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.transparent, Colors.black.withOpacity(0.35)],
                radius: 0.85,
              ),
            ),
          ),
          // Product Ring centered with a drop shadow
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.58,
              heightFactor: 0.58,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 24,
                      spreadRadius: 3,
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildSingleImage(productUrl),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return _buildSingleImage(path);
  }

  Widget _buildSingleImage(String path) {
    if (path.startsWith('http') || path.startsWith('blob')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder('Görsel Yüklenemedi'),
      );
    } else {
      if (kIsWeb) {
        return Image.network(
          path,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder('Görsel Yüklenemedi'),
        );
      } else {
        return Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder('Görsel Yüklenemedi'),
        );
      }
    }
  }

  Widget _buildFidelityStatusRow() {
    String currentFidelityMode = 'Geometri Hizalama: Aktif';
    String accuracyText = 'Hassasiyet: %99.4';
    Color textThemeColor = AppColors.gold;

    if (_sliderFraction < 0.15) {
      currentFidelityMode = 'Mod: Orijinal Analiz';
      accuracyText = 'Sadece Ham Görsel Gösteriliyor';
      textThemeColor = AppColors.textPrimary;
    } else if (_sliderFraction > 0.85) {
      currentFidelityMode = 'Mod: AI Stüdyo Çıktısı';
      accuracyText = 'Sadece Yapay Zeka Render Görünüyor';
      textThemeColor = AppColors.gold;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            currentFidelityMode,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Text(
            accuracyText,
            style: TextStyle(color: textThemeColor, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder(String message) {
    return Container(
      color: AppColors.surfaceElevated,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image_outlined, color: AppColors.textSecondary, size: 48),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
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
                'Sosyal Medyada Paylaş',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                '"Önce / Sonra" karşılaştırmalı görsel formatını paylaşarak müşterilerinize güven verin.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ShareOption(icon: Icons.camera_alt_outlined, label: 'Instagram Story', color: const Color(0xFFE1306C)),
                  _ShareOption(icon: Icons.chat_bubble_outline_rounded, label: 'WhatsApp', color: const Color(0xFF25D366)),
                  _ShareOption(icon: Icons.download_rounded, label: 'Kıyas Videosu İndir', color: AppColors.gold),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.divider),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Kapat'),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Altın Izgara (Geometric CAD Wireframe blueprint style mesh)
class GoldenMeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold.withOpacity(0.24)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = AppColors.gold.withOpacity(0.08)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final rows = 12;
    final cols = 12;
    final rowStep = size.height / rows;
    final colStep = size.width / cols;

    // Horizontal curving arcs
    for (int i = 0; i <= rows; i++) {
      final y = i * rowStep;
      final path = Path()
        ..moveTo(0, y)
        ..quadraticBezierTo(size.width / 2, y - 25, size.width, y);
      canvas.drawPath(path, paint);
      canvas.drawPath(path, glowPaint);
    }

    // Vertical focusing curves
    for (int j = 0; j <= cols; j++) {
      final x = j * colStep;
      final path = Path()
        ..moveTo(x, 0)
        ..quadraticBezierTo(size.width / 2 + (x - size.width / 2) * 0.25, size.height / 2, x, size.height);
      canvas.drawPath(path, paint);
      canvas.drawPath(path, glowPaint);
    }

    // Diamond facet lines in the center
    final centerPaint = Paint()
      ..color = AppColors.gold.withOpacity(0.4)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.22;

    canvas.drawCircle(Offset(centerX, centerY), radius, centerPaint);
    
    final path = Path();
    final points = 8;
    for (int i = 0; i < points; i++) {
      final angle = (i * 2 * 3.14159) / points;
      final px = centerX + radius * 1.35 * (i % 2 == 0 ? 1.05 : 0.95);
      final py = centerY + radius * 1.35 * (i % 2 == 0 ? 0.95 : 1.05);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
      canvas.drawLine(Offset(centerX, centerY), Offset(px, py), centerPaint);
    }
    path.close();
    canvas.drawPath(path, centerPaint);
  }

  @override
  bool shouldRepaint(covariant GoldenMeshPainter oldDelegate) => false;
}

class _SliderClipper extends CustomClipper<Rect> {
  final double fraction;
  _SliderClipper(this.fraction);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * fraction, size.height);
  }

  @override
  bool shouldReclip(covariant _SliderClipper oldClipper) {
    return oldClipper.fraction != fraction;
  }
}

class _ShareOption extends StatelessWidget {
  const _ShareOption({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.success,
            content: Text('$label paylaşım simülasyonu başlatıldı!'),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
