import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_colors.dart';
import 'package:kuyumcu_flutter/membership_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membership = ref.watch(membershipProvider);
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
                    'Ayarlar',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Profilinizi ve mağaza yapılandırmanızı yönetin.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 32),

                  // 1. PROFİL KARTI
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.surfaceElevated,
                          backgroundImage: const AssetImage('assets/icon/app_icon.png'),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kuyumcu Sarraf A.Ş.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'iletisim@kuyumcusarraf.com',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => context.push('/subscription'),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: membership.isKobiPremium ? AppColors.gold.withOpacity(0.12) : AppColors.divider.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: membership.isKobiPremium ? AppColors.gold : AppColors.divider,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              membership.isKobiPremium ? 'PREMIUM' : 'FREE',
                              style: TextStyle(
                                color: membership.isKobiPremium ? AppColors.gold : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 2. AYAR SEÇENEKLERİ LİSTESİ
                  _buildSectionHeader('Hesap & Firma'),
                  _buildSettingsTile(
                    icon: Icons.business_center_outlined,
                    title: 'Firma Detayları',
                    subtitle: 'Vergi no, fatura adresleri ve firma bilgileri',
                    onTap: () => context.push('/premium/company-details'),
                  ),
                  _buildSettingsTile(
                    icon: Icons.palette_outlined,
                    title: 'Marka Kiti',
                    subtitle: 'Logo, filigran ve kurumsal kimlik ayarları',
                    onTap: () => context.push('/premium/brand-kit'),
                  ),
                  _buildSettingsTile(
                    icon: Icons.notifications_active_outlined,
                    title: 'Bildirim Tercihleri',
                    subtitle: 'SMS, e-posta ve anlık bildirim ayarları',
                    onTap: () => context.push('/premium/notification-preferences'),
                  ),
                  _buildSettingsTile(
                    icon: Icons.security_outlined,
                    title: 'Güvenlik',
                    subtitle: 'Şifre değiştirme ve iki adımlı doğrulama',
                    onTap: () => context.push('/premium/security'),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader('Entegrasyonlar & Destek'),
                  _buildSettingsTile(
                    icon: Icons.api_rounded,
                    title: 'API Anahtarları',
                    subtitle: 'E-ticaret entegrasyonu için API bağlantıları',
                    onTap: () => context.push('/premium/api-keys'),
                  ),
                  _buildSettingsTile(
                    icon: Icons.circle_outlined,
                    title: 'Yüzük Ölçer',
                    subtitle: 'Fiziksel yüzük ölçme aracı',
                    onTap: () => context.push('/premium/ring-sizer'),
                  ),
                  _buildSettingsTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Destek ve Yardım',
                    subtitle: 'Sıkça sorulan sorular ve canlı destek',
                    onTap: () => context.push('/premium/support'),
                  ),
                  _buildSettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Hakkında',
                    subtitle: 'Kuyumcu AI Stüdyo v1.2.0',
                    onTap: () => context.push('/premium/about'),
                  ),
                  const SizedBox(height: 40),

                  // 3. ÇIKIŞ YAP BUTONU
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      minimumSize: const Size.fromHeight(56),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Çıkış yapıldı (Simüle edildi)')),
                      );
                    },
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    label: const Text('Çıkış Yap'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.gold,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.textSecondary, size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          onTap: onTap,
        ),
      ),
    );
  }
}
