import 'package:flutter/material.dart';
import 'app_colors.dart';

class CustomerMirrorScreen extends StatefulWidget {
  const CustomerMirrorScreen({
    super.key,
    required this.productTitle,
    required this.productImageUrl,
  });

  final String productTitle;
  final String productImageUrl;

  @override
  State<CustomerMirrorScreen> createState() => _CustomerMirrorScreenState();
}

class _CustomerMirrorScreenState extends State<CustomerMirrorScreen> {
  late final TextEditingController _messageController;
  final String _mockTryOnLink = 'https://kuyumcuaistudio.com/tryon/sarraf-ring-102';

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(
      text: 'Merhaba, beğendiğiniz ${widget.productTitle} modelini aşağıdaki linke tıklayarak parmağınızda/boynunuzda canlı olarak deneyebilirsiniz!\n\n👉 $_mockTryOnLink',
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Müşteri Aynası (Try-On)'),
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
              // BİLGİ KUTUSU
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.camera_front_rounded, color: AppColors.gold, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'B2B2C WhatsApp Satış Aracı',
                          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Müşteriniz herhangi bir uygulama indirmeden kendi telefon kamerasından AR (3D) olarak ürünü deneyebilir.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 32),

              // ÜRÜN KARTI
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(widget.productImageUrl, width: 72, height: 72, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.productTitle,
                            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Paylaşılabilir AR Modeli Hazır',
                            style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // QR KODU PANELİ
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Mağaza İçi Deneme QR Kodu',
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Kuyumcu tezgahına koyarak müşterinize doğrudan okutabilirsiniz.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Image.network(
                          'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=$_mockTryOnLink',
                          width: 140,
                          height: 140,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // PAYLAŞIM MESAJI DÜZENLEME
              const Text(
                'Müşteriye Gönderilecek WhatsApp Mesajı',
                style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _messageController,
                maxLines: 4,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
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
              const SizedBox(height: 32),

              // AKSİYON BUTONLARI
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  minimumSize: const Size.fromHeight(56),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Try-On bağlantısı WhatsApp ile paylaşıldı!')),
                  );
                },
                icon: const Icon(Icons.share, color: Colors.white),
                label: const Text('Bağlantıyı WhatsApp ile Gönder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
