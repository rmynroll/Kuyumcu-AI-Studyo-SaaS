import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_colors.dart';

class JewelryItem {
  final String id;
  final String title;
  final String imageUrl;
  final String originalImageUrl;
  final String status; // 'completed', 'processing', 'failed'
  final DateTime date;

  JewelryItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.originalImageUrl,
    required this.status,
    required this.date,
  });
}

class ResultsGalleryScreen extends ConsumerWidget {
  const ResultsGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Premium Mock data for jewelry results showing Before (original) and After (AI Studio)
    final items = [
      JewelryItem(
        id: '1',
        title: 'Altın Yakut Yüzük',
        originalImageUrl: 'https://images.unsplash.com/photo-1598560917505-59a3ad559071?q=80&w=400&auto=format&fit=crop',
        imageUrl: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?q=80&w=400&auto=format&fit=crop',
        status: 'completed',
        date: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      JewelryItem(
        id: '2',
        title: 'Elmas Baget Yüzük',
        originalImageUrl: 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?q=80&w=400&auto=format&fit=crop',
        imageUrl: 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?q=80&w=400&auto=format&fit=crop',
        status: 'completed',
        date: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      JewelryItem(
        id: '3',
        title: 'Kuyumcu Gerdanlık',
        originalImageUrl: 'https://images.unsplash.com/photo-1611085583191-a3b1a3a355db?q=80&w=400&auto=format&fit=crop',
        imageUrl: 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=400&auto=format&fit=crop',
        status: 'completed',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      JewelryItem(
        id: '4',
        title: 'Safir Taş Kolye',
        originalImageUrl: 'https://images.unsplash.com/photo-1617038260897-41a1f14a8ca0?q=80&w=400&auto=format&fit=crop',
        imageUrl: 'https://images.unsplash.com/photo-1617038260897-41a1f14a8ca0?q=80&w=400&auto=format&fit=crop',
        status: 'processing',
        date: DateTime.now(),
      ),
      JewelryItem(
        id: '5',
        title: 'Altın Zincir Bileklik',
        originalImageUrl: 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?q=80&w=400&auto=format&fit=crop',
        imageUrl: 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?q=80&w=400&auto=format&fit=crop',
        status: 'failed',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sonuçlarım',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Yapay zeka ile ürettiğiniz stüdyo görselleri.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),

              // GRID VIEW
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.78,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _JewelryGalleryCard(item: item);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JewelryGalleryCard extends StatelessWidget {
  const _JewelryGalleryCard({required this.item});

  final JewelryItem item;

  void _showImageDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      color: AppColors.surface,
                      child: const Icon(Icons.broken_image_outlined, color: AppColors.textSecondary),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _StatusBadge(status: item.status),
                        const Spacer(),
                        Text(
                          'ID: #${item.id}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (item.status == 'completed') ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.gold,
                          shadowColor: Colors.transparent,
                          side: const BorderSide(color: AppColors.gold, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                          context.push(
                            '/comparison?before=${Uri.encodeComponent(item.originalImageUrl)}'
                            '&after=${Uri.encodeComponent(item.imageUrl)}'
                            '&title=${Uri.encodeComponent(item.title)}',
                          );
                        },
                        icon: const Icon(Icons.compare_rounded, size: 20),
                        label: const Text('Önce / Sonra Kıyasla', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.gold,
                          shadowColor: Colors.transparent,
                          side: const BorderSide(color: AppColors.gold, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                          context.push('/results/${item.id}');
                        },
                        icon: const Icon(Icons.analytics_outlined, size: 20),
                        label: const Text('QA Sadakat Raporu', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.gold,
                          shadowColor: Colors.transparent,
                          side: const BorderSide(color: AppColors.gold, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                          context.push(
                            '/premium/customer-mirror?title=${Uri.encodeComponent(item.title)}'
                            '&imageUrl=${Uri.encodeComponent(item.imageUrl)}',
                          );
                        },
                        icon: const Icon(Icons.camera_front_rounded, size: 20),
                        label: const Text('Müşteri Aynası (AR Paylaş)', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.gold,
                          shadowColor: Colors.transparent,
                          side: const BorderSide(color: AppColors.gold, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                          context.push(
                            '/premium/campaign?imageUrl=${Uri.encodeComponent(item.imageUrl)}',
                          );
                        },
                        icon: const Icon(Icons.card_giftcard_rounded, size: 20),
                        label: const Text('Kampanya Kartı Üret', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.divider),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              minimumSize: const Size.fromHeight(48),
                            ),
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Kapat', style: TextStyle(fontSize: 14)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: AppColors.textOnGold,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              minimumSize: const Size.fromHeight(48),
                            ),
                            onPressed: item.status == 'completed'
                                ? () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Görsel galeriye kaydedildi! (Simüle edildi)'),
                                      ),
                                    );
                                  }
                                : null,
                            icon: const Icon(Icons.download, size: 18),
                            label: const Text('İndir', style: TextStyle(fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: InkWell(
        onTap: () => _showImageDetails(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // IMAGE
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.surfaceElevated,
                        child: const Icon(Icons.image_outlined, color: AppColors.textSecondary),
                      );
                    },
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _StatusBadge(status: item.status),
                  ),
                ],
              ),
            ),
            // TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case 'completed':
        color = AppColors.success;
        icon = Icons.check_circle;
        label = 'Tamamlandı';
        break;
      case 'processing':
        color = AppColors.warning;
        icon = Icons.hourglass_empty;
        label = 'İşleniyor';
        break;
      case 'failed':
      default:
        color = AppColors.error;
        icon = Icons.error_outline;
        label = 'Başarısız';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
