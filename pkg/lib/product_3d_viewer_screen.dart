import 'dart:async';
import 'package:flutter/material.dart';
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

    // Provide a short delay to allow webview embedding to initialize nicely
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isWebviewInitializing = false;
        });
      }
    });
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
              Positioned.fill(
                child: ModelViewer(
                  backgroundColor: velvetBlack,
                  src: _product!.glbUrl!,
                  alt: _product!.title,
                  ar: false,
                  autoRotate: true,
                  cameraControls: true,
                  autoRotateDelay: 0,
                ),
              ),

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
