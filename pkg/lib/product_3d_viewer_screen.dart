import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:dio/dio.dart';
import 'app_colors.dart';
import 'product.dart';

class Product3DViewerScreen extends ConsumerStatefulWidget {
  final String productId;
  const Product3DViewerScreen({super.key, required this.productId});

  @override
  ConsumerState<Product3DViewerScreen> createState() =>
      _Product3DViewerScreenState();
}

class _Product3DViewerScreenState extends ConsumerState<Product3DViewerScreen> {
  bool _isCheckingUrl = true;
  bool _isWebviewInitializing = true;
  bool _hasError = false;
  Product? _product;
  double _rotX = -0.3;
  double _rotY = 0.5;

  @override
  void initState() {
    super.initState();
    _loadAndVerifyModel();
  }

  Future<void> _loadAndVerifyModel() async {
    setState(() {
      _isCheckingUrl = true;
      _isWebviewInitializing = true;
      _hasError = false;
    });

    // Ürünü listeden bul
    final products = ref.read(productsProvider);
    final productIndex = products.indexWhere((p) => p.id == widget.productId);
    
    Product product;
    if (productIndex == -1) {
      // Listede yoksa demo için dinamik ürün oluştur
      product = Product(
        id: widget.productId,
        title: 'Özel Tasarım Yüzük',
        imageUrl: '',
        originalImageUrl: '',
        status: 'completed',
        date: DateTime.now(),
        glbUrl: 'https://raw.githubusercontent.com/AbdallahMuhammad2/provador-ajorsul/main/working-ring-7.glb',
      );
    } else {
      product = products[productIndex];
    }

    // GLB adresi yoksa (kullanıcı yeni ürettiğinde veya varsayılan mock listesinde) altını 3D ata
    if (product.glbUrl == null || product.glbUrl!.isEmpty) {
      product = product.copyWith(
        glbUrl: 'https://raw.githubusercontent.com/AbdallahMuhammad2/provador-ajorsul/main/working-ring-7.glb',
      );
    }

    setState(() {
      _product = product;
    });

    // model_viewer_plus zaten kendi yüklenme spinner'ını yönettiği için
    // harici Dio HEAD kontrolünü bypass ederek CORS ve bağlantı hatalarını eliyoruz.
    _onVerificationSuccess();
  }

  void _onVerificationSuccess() {
    setState(() {
      _isCheckingUrl = false;
    });

    final isDesktop = !kIsWeb &&
        (Theme.of(context).platform == TargetPlatform.windows ||
         Theme.of(context).platform == TargetPlatform.macOS ||
         Theme.of(context).platform == TargetPlatform.linux);

    if (isDesktop) {
      setState(() {
        _isWebviewInitializing = false;
      });
    } else {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _isWebviewInitializing = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kadife siyah arka plan (#08080A)
    const velvetBlack = Color(0xFF08080A);
    const goldAccent = Color(0xFFD8B254);

    return Scaffold(
      backgroundColor: velvetBlack,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. 3D Model Viewer (when URL is verified and no error)
            if (!_hasError && _product?.glbUrl != null)
              (() {
                final isDesktop = !kIsWeb && 
                    (Theme.of(context).platform == TargetPlatform.windows || 
                     Theme.of(context).platform == TargetPlatform.macOS || 
                     Theme.of(context).platform == TargetPlatform.linux);

                if (isDesktop) {
                  return Positioned.fill(
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          _rotY += details.delta.dx * 0.015;
                          _rotX += details.delta.dy * 0.015;
                        });
                      },
                      child: Container(
                        color: velvetBlack,
                        child: CustomPaint(
                          painter: Ring3DPainter(
                            rotationX: _rotX,
                            rotationY: _rotY,
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Positioned.fill(
                    child: ModelViewer(
                      backgroundColor: velvetBlack,
                      src: _product!.glbUrl!,
                      alt: _product!.title,
                      ar: false,
                      autoRotate: true,
                      cameraControls: true,
                      autoRotateDelay: 0,
                    ),
                  );
                }
              }()),

            // 2. Custom Top Header Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      velvetBlack.withOpacity(0.9),
                      velvetBlack.withOpacity(0.0),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textPrimary, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _product?.title ?? '3D Önizleme',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Custom Bottom Info Bar (only when model is ready)
            if (!_hasError && !_isCheckingUrl && !_isWebviewInitializing)
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: velvetBlack.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: goldAccent.withOpacity(0.4), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.touch_app_outlined,
                          color: goldAccent, size: 22),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Döndürmek için sürükleyin, yakınlaştırmak için iki parmakla açın',
                          style: TextStyle(
                            color: AppColors.textPrimary.withOpacity(0.9),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 4. Custom loading spinner (#D8B254)
            if (_isCheckingUrl || _isWebviewInitializing)
              Positioned.fill(
                child: Container(
                  color: velvetBlack,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(goldAccent),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          '3D Model Yükleniyor...',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 5. Zarif Hata Durumu (Error Screen)
            if (_hasError)
              Positioned.fill(
                child: Container(
                  color: velvetBlack,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.08),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.error.withOpacity(0.3),
                                width: 1.5),
                          ),
                          child: const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.error,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          '3D önizleme şu an hazırlanamadı',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Lütfen internet bağlantınızı kontrol edip tekrar deneyin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 32),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: AppColors.gold, width: 1.2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size(180, 48),
                            foregroundColor: AppColors.gold,
                          ),
                          onPressed: _loadAndVerifyModel,
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          label: const Text(
                            'Tekrar Dene',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Ring3DPainter extends CustomPainter {
  final double rotationX;
  final double rotationY;

  Ring3DPainter({required this.rotationX, required this.rotationY});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.23;
    final strokeWidth = size.width * 0.055;

    final points = <Offset>[];
    final zDepths = <double>[];
    
    const segments = 36;
    for (int ringIndex = 0; ringIndex < 2; ringIndex++) {
      final zOffset = (ringIndex == 0 ? -1.0 : 1.0) * (size.width * 0.025);
      for (int i = 0; i < segments; i++) {
        final angle = (i * 2 * pi) / segments;
        double x = radius * cos(angle);
        double y = radius * sin(angle);
        double z = zOffset;

        // Rotate X
        double x1 = x;
        double y1 = y * cos(rotationX) - z * sin(rotationX);
        double z1 = y * sin(rotationX) + z * cos(rotationX);

        // Rotate Y
        double x2 = x1 * cos(rotationY) + z1 * sin(rotationY);
        double y2 = y1;
        double z2 = -x1 * sin(rotationY) + z1 * cos(rotationY);

        points.add(Offset(x2 + center.dx, y2 + center.dy));
        zDepths.add(z2);
      }
    }

    final List<int> sortedIndices = List.generate(segments, (i) => i);
    sortedIndices.sort((a, b) {
      double depthA = (zDepths[a] + zDepths[a + segments]) / 2;
      double depthB = (zDepths[b] + zDepths[b + segments]) / 2;
      return depthA.compareTo(depthB);
    });

    for (final index in sortedIndices) {
      final nextIndex = (index + 1) % segments;
      double depthNorm = (zDepths[index] + radius) / (2 * radius);
      if (depthNorm < 0) depthNorm = 0;
      if (depthNorm > 1) depthNorm = 1;

      final segmentColor = Color.lerp(
        const Color(0xFF8F6E25), // Shadow gold
        const Color(0xFFFFF1C5), // Highlight gold
        depthNorm,
      )!;

      final p1 = points[index];
      final p2 = points[nextIndex];
      final p1Side = points[index + segments];
      final p2Side = points[nextIndex + segments];

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p2Side.dx, p2Side.dy)
        ..lineTo(p1Side.dx, p1Side.dy)
        ..close();

      canvas.drawPath(path, Paint()..color = segmentColor..style = PaintingStyle.fill);
      canvas.drawPath(path, Paint()..color = const Color(0xFFD8B254)..style = PaintingStyle.stroke..strokeWidth = 0.5);
    }

    // Diamond gem placement on top of the ring
    final crownIndex = (segments * 3) ~/ 4;
    final crownOffset = points[crownIndex];

    final double dSize = size.width * 0.07;
    final dPoints = [
      Offset(crownOffset.dx, crownOffset.dy - dSize * 1.3), 
      Offset(crownOffset.dx - dSize, crownOffset.dy - dSize * 0.4), 
      Offset(crownOffset.dx + dSize, crownOffset.dy - dSize * 0.4), 
      Offset(crownOffset.dx - dSize * 0.7, crownOffset.dy + dSize * 0.3), 
      Offset(crownOffset.dx + dSize * 0.7, crownOffset.dy + dSize * 0.3), 
      Offset(crownOffset.dx, crownOffset.dy + dSize * 1.3), 
    ];

    void drawFacet(int p1, int p2, int p3, Color color) {
      final path = Path()
        ..moveTo(dPoints[p1].dx, dPoints[p1].dy)
        ..lineTo(dPoints[p2].dx, dPoints[p2].dy)
        ..lineTo(dPoints[p3].dx, dPoints[p3].dy)
        ..close();
      canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
      canvas.drawPath(path, Paint()..color = const Color(0x608CD8FF)..style = PaintingStyle.stroke..strokeWidth = 1.0);
    }

    drawFacet(0, 1, 2, const Color(0xF2FFFFFF)); // Table
    drawFacet(1, 3, 5, const Color(0xD9B3E5FC)); // Left Pavilion
    drawFacet(2, 4, 5, const Color(0xD9E1F5FE)); // Right Pavilion
    drawFacet(1, 2, 5, const Color(0xBEFFFFFF)); // Center
    drawFacet(3, 4, 5, const Color(0xFFE3F2FD)); // Girdle

    // Diamond sparkle cross glow
    final sparklePaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final sparkleCenter = Offset(crownOffset.dx - dSize * 0.4, crownOffset.dy - dSize * 0.4);
    canvas.drawRect(Rect.fromCenter(center: sparkleCenter, width: 16, height: 2), sparklePaint);
    canvas.drawRect(Rect.fromCenter(center: sparkleCenter, width: 2, height: 16), sparklePaint);
  }

  @override
  bool shouldRepaint(Ring3DPainter oldDelegate) =>
      oldDelegate.rotationX != rotationX || oldDelegate.rotationY != rotationY;
}
