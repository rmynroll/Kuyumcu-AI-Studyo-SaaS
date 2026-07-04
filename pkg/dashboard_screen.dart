import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';

/// Ana ekran (Dashboard).
///
/// Ürün felsefesi: "3 dokunuşla profesyonel görsel". Bu yüzden ekranda
/// bilinçli olarak yalnızca 3 büyük, net etiketli aksiyon kartı var:
/// Ürün Yükle → Görsel Oluştur → Sonuçlarım. Kalan kredi küçük ve sade
/// gösterilir; karmaşık bir dashboard/istatistik grid'i kasıtlı olarak yok
/// (bkz. teknik doküman, "Çok basit kullanım için ekran prensipleri").
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, this.creditBalance = 0, this.companyName});

  final int creditBalance;
  final String? companyName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 720; // web/tablet

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(companyName: companyName, creditBalance: creditBalance),
                    const SizedBox(height: 40),
                    _ActionList(isWide: isWide),
                    const SizedBox(height: 32),
                    _FooterNote(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.companyName, required this.creditBalance});

  final String? companyName;
  final int creditBalance;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Merhaba${companyName != null ? ', $companyName' : ''} 👋',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Bugün hangi ürünü öne çıkaralım?',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        _CreditBadge(creditBalance: creditBalance),
      ],
    );
  }
}

class _CreditBadge extends StatelessWidget {
  const _CreditBadge({required this.creditBalance});

  final int creditBalance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          const Icon(Icons.diamond_outlined, color: AppColors.gold, size: 18),
          const SizedBox(height: 4),
          Text(
            '$creditBalance',
            style: const TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          Text(
            'kredi',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ActionList extends StatelessWidget {
  const _ActionList({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final cards = [
      AppPrimaryActionCard(
        icon: Icons.add_a_photo_outlined,
        label: 'Ürün Yükle',
        subtitle: 'Yeni bir yüzük, kolye veya bileklik ekle',
        onTap: () => context.push('/products/upload'),
      ),
      AppPrimaryActionCard(
        icon: Icons.auto_awesome_outlined,
        label: 'Görsel Oluştur',
        subtitle: 'Hazır şablon ya da örnek görselle üret',
        onTap: () => context.push('/generation/mode'),
      ),
      AppPrimaryActionCard(
        icon: Icons.photo_library_outlined,
        label: 'Sonuçlarım',
        subtitle: 'Üretilen görselleri gör ve indir',
        onTap: () => context.push('/results'),
      ),
    ];

    return Column(
      children: [
        for (final card in cards) ...[
          card,
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _FooterNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.shield_outlined, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Ürünlerinin tasarımı, taş sayısı ve metal rengi asla değiştirilmez.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
