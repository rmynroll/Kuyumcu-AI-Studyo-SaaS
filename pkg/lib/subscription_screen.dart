import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_colors.dart';
import 'membership_provider.dart';
import 'credits_provider.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membership = ref.watch(membershipProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Üyelik Planları'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // TITLE
                  Text(
                    'Kullanım Modelinizi Seçin',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'İster bireysel tasarımcı olun, ister binlerce ürünü yöneten büyük bir KOBİ. Size en uygun planla hemen başlayın.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 32),

                  // PLAN 1: BİREYSEL FREE
                  _buildPlanCard(
                    context,
                    ref: ref,
                    title: 'Bireysel Free',
                    price: '0 TL',
                    period: '/ Ay',
                    subtitle: 'Bireysel kuyumcular ve hobi amaçlı tasarımcılar için başlangıç seviyesi.',
                    features: [
                      'Aylık 5 Ücretsiz Kredi 💎',
                      'Standart AI Üretim Motoru',
                      'Tekli Ürün İşleme Görselleri',
                      'Filigranlı İndirme',
                      'Topluluk Desteği',
                    ],
                    isActive: membership.tier == MembershipTier.bireyselFree,
                    onSelect: () {
                      ref.read(membershipProvider.notifier).updateTier(MembershipTier.bireyselFree);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bireysel Free planına başarıyla geçiş yapıldı.')),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // PLAN 2: KOBİ PREMIUM (RECOMMENDED / GOLD ACCENTED)
                  _buildPlanCard(
                    context,
                    ref: ref,
                    title: 'KOBİ Premium',
                    price: '1.490 TL',
                    period: '/ Ay',
                    subtitle: 'B2B2C satış yapan, marka kimliğini korumak ve toplu üretim yapmak isteyen kuyumcular.',
                    features: [
                      'Aylık 100 Kredi Hediye 💎',
                      'Toplu Üretim (Koleksiyon Stüdyosu)',
                      'Marka Kiti Entegrasyonu (Logo/Watermark)',
                      'Müşteri Aynası (WhatsApp Try-On Linkleri)',
                      'Kampanya Kartları (Post Editörü)',
                      'Performans Raporu (Hangi Sahne Sattı?)',
                      'Öncelikli Yüksek Hızlı AI Sunucusu',
                    ],
                    isActive: membership.tier == MembershipTier.kobiPremium,
                    isPremium: true,
                    onSelect: () {
                      ref.read(membershipProvider.notifier).updateTier(MembershipTier.kobiPremium);
                      // Reward 100 credits for subscribing to premium
                      ref.read(creditsProvider.notifier).addCredits(100, 'KOBİ Premium Planı');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.success,
                          content: Text('Tebrikler! KOBİ Premium planına geçtiniz. 100 Kredi hesabınıza yüklendi! 💎'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required WidgetRef ref,
    required String title,
    required String price,
    required String period,
    required String subtitle,
    required List<String> features,
    required bool isActive,
    bool isPremium = false,
    required VoidCallback onSelect,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive 
              ? AppColors.gold 
              : (isPremium ? AppColors.gold.withOpacity(0.3) : AppColors.divider),
          width: isActive ? 2 : 1.2,
        ),
        boxShadow: isActive
            ? [BoxShadow(color: AppColors.gold.withOpacity(0.15), blurRadius: 20, spreadRadius: 2)]
            : null,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // PLAN TITLE AND ACTIVE BADGE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isPremium ? AppColors.gold : AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gold, width: 0.8),
                  ),
                  child: const Text(
                    'Aktif Plan',
                    style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // PRICE
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Outfit',
                ),
              ),
              Text(
                period,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4)),
          const Divider(height: 32),

          // FEATURES LIST
          Column(
            children: features.map((f) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        f,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // SELECT BUTTON
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive 
                  ? AppColors.surfaceElevated 
                  : (isPremium ? AppColors.gold : AppColors.divider.withOpacity(0.5)),
              foregroundColor: isActive 
                  ? AppColors.textSecondary 
                  : (isPremium ? AppColors.textOnGold : AppColors.textPrimary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              minimumSize: const Size.fromHeight(50),
              elevation: 0,
              side: isActive ? const BorderSide(color: AppColors.divider) : null,
            ),
            onPressed: isActive ? null : onSelect,
            child: Text(
              isActive ? 'Mevcut Planınız' : 'Bu Plana Geç',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
