import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_colors.dart';

class SharedProductViewScreen extends StatefulWidget {
  const SharedProductViewScreen({
    super.key,
    required this.imageUrl,
    required this.productTitle,
    this.price = '14.990 TL',
    this.includeSizer = true,
    this.include3D = true,
  });

  final String imageUrl;
  final String productTitle;
  final String price;
  final bool includeSizer;
  final bool include3D;

  @override
  State<SharedProductViewScreen> createState() => _SharedProductViewScreenState();
}

class _SharedProductViewScreenState extends State<SharedProductViewScreen> {
  double _rotationAngle = 0.0;
  int? _selectedRingSize;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Müşteri Önizleme Sayfası'),
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
              // B2C INTRO BADGE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.person_pin_outlined, color: AppColors.gold, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bu ekran son müşterinizin WhatsApp bağlantısına tıkladığında göreceği mobil katalog arayüzüdür.',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 11, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // INTERACTIVE 3D/AR ROTATING VIEW
              if (widget.include3D) ...[
                const Text(
                  '3D INTERAKTİF GÖRÜNÜM',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Görseli döndürmek için sağa sola sürükleyin',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _rotationAngle += details.delta.dx * 0.01;
                    });
                  },
                  child: Center(
                    child: Container(
                      width: 280,
                      height: 280,
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
                        alignment: Alignment.center,
                        children: [
                          // Perspective rotate transform mock 3D
                          Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001) // perspective
                              ..rotateY(_rotationAngle),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Image.network(widget.imageUrl, fit: BoxFit.contain),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.rotate_right, color: AppColors.gold, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Flat image view
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(widget.imageUrl, width: 280, height: 280, fit: BoxFit.cover),
                  ),
                ),
              ],
              const SizedBox(height: 28),

              // TITLE AND PRICE
              Text(
                widget.productTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                widget.price,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.gold),
              ),
              const SizedBox(height: 32),

              // RING SIZER OPTION
              if (widget.includeSizer) ...[
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
                      const Row(
                        children: [
                          Icon(Icons.straighten, color: AppColors.gold, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Yüzük Ölçünüzü Belirleyin',
                            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ölçünüzü bilmiyorsanız endişelenmeyin. Telefonunuz üzerinden kredi kartı veya mevcut bir yüzüğünüzle anında ölçü alabilirsiniz.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.3),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedRingSize != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.success.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Belirlenen Ölçü:', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                              Text(
                                '$_selectedRingSize No',
                                style: const TextStyle(color: AppColors.success, fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.gold, width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          // Navigate to RingSizerScreen and get results
                          final result = await context.push<int>('/premium/ring-sizer?client=1');
                          if (result != null) {
                            setState(() {
                              _selectedRingSize = result;
                            });
                          }
                        },
                        icon: const Icon(Icons.crop_free, color: AppColors.gold, size: 16),
                        label: Text(
                          _selectedRingSize != null ? 'Ölçüyü Yeniden Hesapla' : 'Ekran Ölçer Modülünü Aç',
                          style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // WhatsApp Order Action
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  minimumSize: const Size.fromHeight(56),
                ),
                onPressed: () {
                  final sizeText = _selectedRingSize != null ? ' ($_selectedRingSize No)' : '';
                  final message = 'Merhaba, ${widget.productTitle} ürününüzü$sizeText sipariş etmek istiyorum.';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF25D366),
                      content: Text('WhatsApp Mesajı Simüle Edildi:\n"$message"'),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
                label: const Text('WhatsApp İle Sipariş Ver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
