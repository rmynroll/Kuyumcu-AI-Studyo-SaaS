import 'package:flutter/material.dart';
import 'app_colors.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _passwordFormKey = GlobalKey<FormState>();

  // Controllers
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // States
  bool _twoFactorSms = false;
  bool _twoFactorAuthApp = false;
  bool _showAuthQr = false;

  final List<Map<String, String>> _sessions = [
    {
      'device': 'Windows PC • Chrome (Bu Cihaz)',
      'location': 'İstanbul, Türkiye',
      'ip': '193.140.23.41',
      'time': 'Aktif',
      'isCurrent': 'true',
    },
    {
      'device': 'iPhone 15 Pro • Safari',
      'location': 'Ankara, Türkiye',
      'ip': '85.105.144.12',
      'time': '2 saat önce',
      'isCurrent': 'false',
    },
    {
      'device': 'MacBook Pro • Chrome',
      'location': 'İzmir, Türkiye',
      'ip': '176.234.90.115',
      'time': '3 gün önce',
      'isCurrent': 'false',
    },
  ];

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Güvenlik Ayarları'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Hesap Güvenliği',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Şifrenizi güncelleyin, iki adımlı doğrulamayı kurun ve aktif oturumlarınızı yönetin.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 32),

                  // 1. ŞİFRE DEĞİŞTİRME FORMU
                  _buildSectionCard(
                    title: 'Şifre Değiştir',
                    icon: Icons.lock_outline_rounded,
                    children: [
                      Form(
                        key: _passwordFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildPasswordField(
                              label: 'Mevcut Şifre',
                              controller: _currentPasswordController,
                              validator: (v) => v!.isEmpty ? 'Mevcut şifrenizi girin' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildPasswordField(
                              label: 'Yeni Şifre',
                              controller: _newPasswordController,
                              validator: (v) => v!.length < 6 ? 'En az 6 karakter olmalıdır' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildPasswordField(
                              label: 'Yeni Şifre (Tekrar)',
                              controller: _confirmPasswordController,
                              validator: (v) {
                                if (v != _newPasswordController.text) {
                                  return 'Şifreler eşleşmiyor';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.surfaceElevated,
                                foregroundColor: AppColors.gold,
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: AppColors.gold, width: 1.2),
                                ),
                              ),
                              onPressed: () {
                                if (_passwordFormKey.currentState!.validate()) {
                                  _currentPasswordController.clear();
                                  _newPasswordController.clear();
                                  _confirmPasswordController.clear();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: AppColors.success,
                                      content: Text('Şifreniz başarıyla güncellendi!'),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Şifreyi Güncelle', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 2. İKİ ADIMLI DOĞRULAMA (2FA)
                  _buildSectionCard(
                    title: 'İki Adımlı Doğrulama (2FA)',
                    icon: Icons.verified_user_outlined,
                    children: [
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('SMS Doğrulaması', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                        subtitle: const Text('Giriş yaparken telefonunuza tek kullanımlık SMS şifresi gönderilir.', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        value: _twoFactorSms,
                        activeColor: AppColors.gold,
                        onChanged: (val) {
                          setState(() {
                            _twoFactorSms = val;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(val ? 'SMS Doğrulaması aktif edildi.' : 'SMS Doğrulaması kapatıldı.'),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 24, color: AppColors.divider),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Authenticator Uygulaması', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                        subtitle: const Text('Google Authenticator veya Microsoft Authenticator kodlarını kullanın.', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        value: _twoFactorAuthApp,
                        activeColor: AppColors.gold,
                        onChanged: (val) {
                          setState(() {
                            _twoFactorAuthApp = val;
                            _showAuthQr = val;
                          });
                        },
                      ),
                      if (_showAuthQr) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Aşağıdaki QR kodunu Authenticator uygulamanız ile taratın:',
                                style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Image.network(
                                    'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=otpauth://totp/KuyumcuStudio:iletisim@kuyumcusarraf.com?secret=JBSWY3DPEHPK3PXP&issuer=KuyumcuStudio',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const SelectableText(
                                'Gizli Anahtar: JBSW Y3DP EHPK 3PXP',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gold,
                                  foregroundColor: AppColors.textOnGold,
                                  minimumSize: const Size.fromHeight(40),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showAuthQr = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: AppColors.success,
                                      content: Text('Authenticator kurulumu doğrulandı ve aktifleştirildi!'),
                                    ),
                                  );
                                },
                                child: const Text('Taratma İşlemini Tamamladım', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 3. AKTİF OTURUMLAR
                  _buildSectionCard(
                    title: 'Aktif Oturumlar',
                    icon: Icons.devices_rounded,
                    children: [
                      const Text(
                        'Hesabınızda aktif olan oturumları ve bağlı cihazları görüntüleyin.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                      const SizedBox(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _sessions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final session = _sessions[index];
                          final isCurrent = session['isCurrent'] == 'true';
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isCurrent ? Icons.laptop_windows_rounded : Icons.phone_android_rounded,
                                  color: isCurrent ? AppColors.gold : AppColors.textSecondary,
                                  size: 24,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        session['device']!,
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 12,
                                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${session['location']} • IP: ${session['ip']}',
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isCurrent ? AppColors.gold.withOpacity(0.12) : AppColors.divider.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    session['time']!,
                                    style: TextStyle(
                                      color: isCurrent ? AppColors.gold : AppColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent, width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Diğer tüm cihazlardaki oturumlar kapatıldı.'),
                            ),
                          );
                        },
                        child: const Text('Diğer Tüm Cihazlardan Çıkış Yap', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.divider),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: true,
          validator: validator,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceElevated,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gold),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}
