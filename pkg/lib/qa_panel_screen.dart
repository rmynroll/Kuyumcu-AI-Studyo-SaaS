import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_colors.dart';
import 'credits_provider.dart';

class QaPanelScreen extends ConsumerStatefulWidget {
  const QaPanelScreen({super.key, required this.generationId});

  final String generationId;

  @override
  ConsumerState<QaPanelScreen> createState() => _QaPanelScreenState();
}

class _QaPanelScreenState extends ConsumerState<QaPanelScreen> {
  late bool _isSuccessCase;
  bool _isProcessingRefund = false;
  late String _beforeUrl;
  late String _afterUrl;
  late String _title;

  static final Set<String> _refundedIds = {};

  @override
  void initState() {
    super.initState();
    if (widget.generationId == '2') {
      _isSuccessCase = false;
      _beforeUrl = 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?q=80&w=400&auto=format&fit=crop';
      _afterUrl = 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?q=80&w=400&auto=format&fit=crop';
      _title = 'Elmas Baget Yüzük';

      // Automatically refund credit if it has not been refunded yet
      if (!_refundedIds.contains(widget.generationId)) {
        _refundedIds.add(widget.generationId);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(creditsProvider.notifier).addCredits(
              1,
              'Otomatik QA İadesi (Görsel #${widget.generationId})',
            );
          }
        });
      }
    } else {
      _isSuccessCase = true;
      _beforeUrl = 'https://images.unsplash.com/photo-1598560917505-59a3ad559071?q=80&w=400&auto=format&fit=crop';
      _afterUrl = 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?q=80&w=400&auto=format&fit=crop';
      _title = 'Altın Yakut Yüzük';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ürün Sadakat Kontrolü (QA)'),
        actions: [
          // SIMULATION TOGGLE FOR DEMO
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: _isSuccessCase ? AppColors.success.withOpacity(0.12) : AppColors.error.withOpacity(0.12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                setState(() {
                  _isSuccessCase = !_isSuccessCase;
                });
              },
              icon: Icon(
                _isSuccessCase ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                color: _isSuccessCase ? AppColors.success : AppColors.error,
                size: 16,
              ),
              label: Text(
                _isSuccessCase ? 'Durum: Temiz' : 'Durum: Sapma Var',
                style: TextStyle(
                  color: _isSuccessCase ? AppColors.success : AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. GÖRSEL ÖNİZLEME
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Orijinal Fotoğraf',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: AspectRatio(
                                aspectRatio: 1.2,
                                child: Image.network(_beforeUrl, fit: BoxFit.cover),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Yapay Zeka Çıktısı',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: AspectRatio(
                                aspectRatio: 1.2,
                                child: Image.network(_afterUrl, fit: BoxFit.cover),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 2. QA DURUM METRİKLERİ KARTI
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.analytics_outlined, color: AppColors.gold, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Otomatik Sadakat & Doğruluk Kontrolü',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        
                        // Metrik 1: Taş Sayısı
                        _buildMetricRow(
                          title: 'Taş Sayısı Eşleşmesi',
                          description: _isSuccessCase 
                              ? '18 Adet Yakut tespiti eşleşti (%100 Uyum)' 
                              : '15/18 Yakut tespit edildi (3 taş eksik/deforme)',
                          status: _isSuccessCase ? _QaStatus.success : _QaStatus.error,
                        ),
                        const SizedBox(height: 20),

                        // Metrik 2: Metal Tonu
                        _buildMetricRow(
                          title: 'Metal Tonu Sapması',
                          description: _isSuccessCase
                              ? 'Sapma: %1.2 (Sarı/Kırmızı kanal toleransı başarılı)'
                              : 'Sapma: %14.8 (Hedef 18K altın tonunda kayma tespiti)',
                          status: _isSuccessCase ? _QaStatus.success : _QaStatus.error,
                        ),
                        const SizedBox(height: 20),

                        // Metrik 3: Siluet Uyumu
                        _buildMetricRow(
                          title: 'Siluet ve Kalıp Uyumu',
                          description: _isSuccessCase
                              ? 'Form Kararlılığı: %99.4 (Ürün kalıbı korunmuştur)'
                              : 'Form Kararlılığı: %82.1 (Tırnak yapısında bükülme tespiti)',
                          status: _isSuccessCase ? _QaStatus.success : _QaStatus.error,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 3. RAPOR KANITI PANELİ VE UYARI
                  if (_isSuccessCase)
                    _buildSuccessBanner()
                  else
                    _buildFailureWarning(),
                  const SizedBox(height: 32),

                  // 4. AKSİYON BUTONLARI
                  if (_isSuccessCase) ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.textOnGold,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        minimumSize: const Size.fromHeight(56),
                      ),
                      onPressed: () {
                        context.go('/');
                      },
                      child: const Text('Onayla ve Galeriye Dön', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.gold, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        minimumSize: const Size.fromHeight(56),
                      ),
                      onPressed: () {
                        context.push(
                          '/comparison?before=${Uri.encodeComponent(_beforeUrl)}'
                          '&after=${Uri.encodeComponent(_afterUrl)}'
                          '&title=${Uri.encodeComponent(_title)}',
                        );
                      },
                      icon: const Icon(Icons.compare_arrows_rounded, color: AppColors.gold, size: 20),
                      label: const Text('Detaylı Önce / Sonra Kıyasla', style: TextStyle(color: AppColors.gold)),
                    ),
                  ] else ...[
                    if (_isProcessingRefund)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(color: AppColors.error),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.textOnGold,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          minimumSize: const Size.fromHeight(56),
                        ),
                        onPressed: () => _performRefundFlow(context),
                        icon: const Icon(Icons.refresh_rounded, color: AppColors.textOnGold),
                        label: const Text(
                          'Yeniden Üretimi Başlat',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/'),
                      child: const Text(
                        'Bu Görseli Yine de Kaydet',
                        style: TextStyle(color: AppColors.textSecondary, decoration: TextDecoration.underline),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _performRefundFlow(BuildContext context) async {
    setState(() {
      _isProcessingRefund = true;
    });

    // Simulate calling backend retry API
    await Future.delayed(const Duration(seconds: 1500 ~/ 1000));

    setState(() {
      _isProcessingRefund = false;
    });

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.surfaceElevated,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text('Üretim Başlatıldı'),
              ],
            ),
            content: const Text(
              'Yeni üretim sıraya alınmıştır. İade edilen krediniz bu işlem için kullanılacaktır.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  context.go('/'); // Back to dashboard
                },
                child: const Text('Kapat', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildMetricRow({
    required String title,
    required String description,
    required _QaStatus status,
  }) {
    Color statusColor;
    IconData icon;
    String badgeLabel;

    switch (status) {
      case _QaStatus.success:
        statusColor = AppColors.success;
        icon = Icons.check_circle_outline_rounded;
        badgeLabel = 'GEÇTİ';
        break;
      case _QaStatus.warning:
        statusColor = AppColors.warning;
        icon = Icons.error_outline_rounded;
        badgeLabel = 'DÜŞÜK';
        break;
      case _QaStatus.error:
      default:
        statusColor = AppColors.error;
        icon = Icons.cancel_outlined;
        badgeLabel = 'SAPMA';
        break;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          child: Icon(icon, color: statusColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Text(
            badgeLabel,
            style: TextStyle(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_outlined, color: AppColors.success, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ürününüzün tüm detayları kusursuz olarak korunmuştur. Görseli onaylayabilirsiniz.',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailureWarning() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.error.withOpacity(0.12), shape: BoxShape.circle),
                child: const Icon(Icons.shield_outlined, color: AppColors.error, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Takıya Özel Sadakat Garantisi',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Pebblely gibi genel AI araçlarının aksine, Kuyumcu AI Stüdyo takıya özel bir doğrulama katmanına (taş sayısı, metal tonu ve siluet kontrolü) sahiptir. '
            'Bu üretimde kalite puanı eşik değerin altında kaldığı için 1 krediniz otomatik olarak hesabınıza iade edilmiştir. '
            'Ürününüz bozulursa kredi bizden!',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check, color: AppColors.success, size: 16),
                SizedBox(width: 8),
                Text(
                  '+1 Kredi Otomatik İade Edildi (QA İadesi)',
                  style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _QaStatus { success, warning, error }
