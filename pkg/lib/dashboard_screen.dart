
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kuyumcu_flutter/app_colors.dart';
import 'package:kuyumcu_flutter/credits_provider.dart';
import 'package:kuyumcu_flutter/membership_provider.dart';

/// Ana ekran (Dashboard).
///
/// Ürün felsefesi: "3 dokunuşla profesyonel görsel". Bu yüzden ekranda
/// bilinçli olarak yalnızca 3 büyük, net etiketli aksiyon kartı var:
/// Ürün Yükle → Görsel Oluştur → Sonuçlarım. Kalan kredi küçük ve sade
/// gösterilir; karmaşık bir dashboard/istatistik grid'i kasıtlı olarak yok
/// (bkz. teknik doküman, "Çok basit kullanım için ekran prensipleri").
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key, this.companyName});

  final String? companyName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creditsState = ref.watch(creditsProvider);
    final activeCompanyName = companyName ?? 'Kuyumcu Sarraf';

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
                    _Header(
                      companyName: activeCompanyName,
                      creditBalance: creditsState.balance,
                    ),
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


class _Header extends ConsumerWidget {
  const _Header({required this.companyName, required this.creditBalance});

  final String? companyName;
  final int creditBalance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membership = ref.watch(membershipProvider);

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
              InkWell(
                onTap: () => context.push('/subscription'),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: membership.isKobiPremium ? AppColors.gold.withOpacity(0.12) : AppColors.divider.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: membership.isKobiPremium ? AppColors.gold : AppColors.divider,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        membership.isKobiPremium ? Icons.verified_user : Icons.person_outline,
                        color: membership.isKobiPremium ? AppColors.gold : AppColors.textSecondary,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        membership.displayName.toUpperCase(),
                        style: TextStyle(
                          color: membership.isKobiPremium ? AppColors.gold : AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
        icon: Icons.face_retouching_natural_outlined,
        label: 'Yapay Zeka Manken Stüdyosu',
        subtitle: 'Yüzükleri el mankeninde, kolyeleri gerdanda görün',
        onTap: () => context.push('/generation/inspiration?tab=3'),
      ),
      AppPrimaryActionCard(
        icon: Icons.inventory_2_outlined,
        label: 'Lüks Kutu Sunum Tasarımı',
        subtitle: 'Takınızı kadife, ahşap veya kraliyet kutularına yerleştirin',
        onTap: () => context.push('/generation/inspiration?tab=2'),
      ),
      AppPrimaryActionCard(
        icon: Icons.wallpaper_rounded,
        label: 'Akıllı Arka Plan Değiştirici',
        subtitle: 'Yapay zeka ile stüdyo fonu ve spot ışığı tarif edin',
        onTap: () => context.push('/generation/inspiration?tab=4'),
      ),
      AppPrimaryActionCard(
        icon: Icons.palette_outlined,
        label: 'İlham Panosu (Stil Aktarımı)',
        subtitle: 'Instagram/Pinterest stilini kendi ürününe uygula',
        onTap: () => context.push('/generation/inspiration?tab=0'),
      ),
      AppPrimaryActionCard(
        icon: Icons.auto_awesome_motion_outlined,
        label: 'Koleksiyon Stüdyosu (Toplu Üretim)',
        subtitle: 'Koleksiyonundaki ürünleri tek şablonla aynı stilde toplu üret',
        onTap: () => context.push('/generation/collection'),
      ),
      AppPrimaryActionCard(
        icon: Icons.calendar_today_rounded,
        label: 'Üretim Takvimi & CAD Önerileri',
        subtitle: 'Sezonluk kampanya takvimi ve KOBİ model önerileri',
        onTap: () => context.push('/premium/calendar'),
      ),
      AppPrimaryActionCard(
        icon: Icons.circle_outlined,
        label: 'Yüzük Ölçer',
        subtitle: 'Fiziksel kalibrasyon ile parmak ölçüsü hesaplayın',
        onTap: () => context.push('/premium/ring-sizer'),
      ),
      AppPrimaryActionCard(
        icon: Icons.insights_rounded,
        label: 'Performans Cebi',
        subtitle: 'Hangi görselleriniz daha çok sipariş getirdi?',
        onTap: () => context.push('/premium/performance'),
      ),
      AppPrimaryActionCard(
        icon: Icons.trending_up_rounded,
        label: 'Canlı Altın Takip',
        subtitle: 'Canlı altın fiyatları ve robot hesaplayıcı',
        onTap: () => context.push('/premium/gold-tracking'),
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

class AppPrimaryActionCard extends StatelessWidget {
  const AppPrimaryActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 24, color: AppColors.gold),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
