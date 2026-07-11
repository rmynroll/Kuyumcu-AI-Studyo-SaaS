import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'app_colors.dart';
import 'credits_provider.dart';

class TokenStoreScreen extends ConsumerWidget {
  const TokenStoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creditsState = ref.watch(creditsProvider);
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 720;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kredi Deposu',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'AI fotoğraf üretimleri için hesabınıza kredi yükleyin.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 32),

                  // 1. AKTİF BAKİYE KARTI
                  _BalanceCard(balance: creditsState.balance),
                  const SizedBox(height: 40),

                  // 2. KREDİ PAKETLERİ BAŞLIĞI
                  Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined,
                          color: AppColors.gold, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Kredi Paketleri',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. PAKET LİSTESİ
                  _PackageList(),
                  const SizedBox(height: 40),

                  // 4. KREDİ GEÇMİŞİ BAŞLIĞI
                  Row(
                    children: [
                      const Icon(Icons.history_rounded,
                          color: AppColors.gold, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Kredi Harcama Geçmişi',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 5. GEÇMİŞ LİSTESİ
                  _HistoryList(history: creditsState.history),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final int balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF221F24),
            Color(0xFF1D1B1E),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1),
              shape: BoxShape.circle,
              border:
                  Border.all(color: AppColors.gold.withOpacity(0.3), width: 1),
            ),
            child: const Icon(
              Icons.diamond_rounded,
              color: AppColors.gold,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kullanılabilir Bakiye',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  textBaseline: TextBaseline.alphabetic,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  children: [
                    Text(
                      '$balance',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Kredi (💎)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w600,
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
  }
}

class _PackageList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final packages = [
      _CreditPackageInfo(
        name: 'Bronz Paket',
        credits: 50,
        price: '299 TL',
        description: 'Ufak denemeler ve başlangıç için ideal',
        isPopular: false,
      ),
      _CreditPackageInfo(
        name: 'Gümüş Paket',
        credits: 150,
        price: '799 TL',
        description: 'Orta boy kuyumcular için en iyi dengeli paket',
        isPopular: false,
      ),
      _CreditPackageInfo(
        name: 'Altın Paket',
        credits: 500,
        price: '1.999 TL',
        description: 'Düzenli üretim yapan mağazalar için popüler tercih',
        isPopular: true,
      ),
      _CreditPackageInfo(
        name: 'Platin Paket',
        credits: 1000,
        price: '3.499 TL',
        description: 'Profesyonel AI stüdyo entegrasyonu ve toplu üretim',
        isPopular: false,
      ),
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: packages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final package = packages[index];
        return _PackageCard(package: package);
      },
    );
  }
}

class _CreditPackageInfo {
  final String name;
  final int credits;
  final String price;
  final String description;
  final bool isPopular;

  _CreditPackageInfo({
    required this.name,
    required this.credits,
    required this.price,
    required this.description,
    required this.isPopular,
  });
}

class _PackageCard extends ConsumerWidget {
  const _PackageCard({required this.package});

  final _CreditPackageInfo package;

  void _showCheckoutSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            bool isLoading = false;

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Satın Alımı Onayla',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.diamond_rounded,
                          color: AppColors.gold,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              package.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${package.credits} Fotoğraf Üretim Kredisi',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        package.price,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: CircularProgressIndicator(color: AppColors.gold),
                      ),
                    )
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.textOnGold,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        setLocalState(() {
                          isLoading = true;
                        });
                        // Simulate payment processing
                        await Future.delayed(
                            const Duration(seconds: 1500 ~/ 1000));

                        ref.read(creditsProvider.notifier).addCredits(
                              package.credits,
                              package.name,
                            );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.success,
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline,
                                      color: Colors.white),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Teşekkürler! ${package.credits} kredi başarıyla hesabınıza eklendi.',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Güvenli Ödeme Yap',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ödemeniz 256-bit SSL güvencesiyle Iyzico altyapısı kullanılarak tahsil edilir.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: package.isPopular ? AppColors.gold : AppColors.divider,
          width: package.isPopular ? 1.8 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      package.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    if (package.isPopular)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.gold.withOpacity(0.4), width: 1),
                        ),
                        child: const Text(
                          'POPÜLER',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  package.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.diamond_rounded,
                            color: AppColors.gold, size: 22),
                        const SizedBox(width: 6),
                        Text(
                          '${package.credits} Kredi',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: package.isPopular
                            ? AppColors.gold
                            : AppColors.surfaceElevated,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _showCheckoutSheet(context, ref),
                      child: Text(
                        package.price,
                        style: TextStyle(
                          color: package.isPopular
                              ? AppColors.textOnGold
                              : AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
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
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.history});

  final List<CreditTransaction> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Center(
          child: Text(
            'Henüz herhangi bir kredi işlemi bulunmuyor.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final tx = history[index];
        final isPositive = tx.amount > 0;
        final formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(tx.date);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isPositive
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.textSecondary.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPositive
                      ? Icons.add_circle_outline
                      : Icons.remove_circle_outline,
                  color:
                      isPositive ? AppColors.success : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                isPositive ? '+${tx.amount}' : '${tx.amount}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: isPositive ? AppColors.success : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.diamond_rounded,
                  color: AppColors.gold, size: 14),
            ],
          ),
        );
      },
    );
  }
}
