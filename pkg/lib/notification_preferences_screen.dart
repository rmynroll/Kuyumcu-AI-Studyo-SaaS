import 'package:flutter/material.dart';
import 'app_colors.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  // AI & Generation
  bool _genPush = true;
  bool _genEmail = true;
  bool _genSms = false;
  bool _qaPush = true;
  bool _qaSms = true;

  // Gold & Market
  bool _goldDailyEmail = true;
  bool _goldAlertPush = true;
  bool _goldAlertSms = false;

  // Calendar
  bool _calendarEmail = true;
  bool _calendarPush = true;

  // Customer Interactions
  bool _arViewPush = true;
  bool _qrScanPush = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bildirim Tercihleri'),
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
                    'Bildirim & Alarm Tercihleri',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'AI üretimi, altın piyasası hareketleri ve müşteri etkileşimlerine dair alacağınız bildirimleri özelleştirin.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 32),

                  // 1. YAPAY ZEKA & ÜRETİM BİLDİRİMLERİ
                  _buildCategoryCard(
                    title: 'Yapay Zeka & Üretim Bildirimleri',
                    icon: Icons.auto_awesome_outlined,
                    children: [
                      _buildNotificationRow(
                        title: 'Görsel Üretimi Tamamlandığında',
                        subtitle: 'AI görsel oluşturmayı tamamladığında haber ver.',
                        pushVal: _genPush,
                        emailVal: _genEmail,
                        smsVal: _genSms,
                        onPushChanged: (v) => setState(() => _genPush = v),
                        onEmailChanged: (v) => setState(() => _genEmail = v),
                        onSmsChanged: (v) => setState(() => _genSms = v),
                      ),
                      const Divider(height: 24, color: AppColors.divider),
                      _buildNotificationRow(
                        title: 'QA Başarısızlık ve Kredi İadesi',
                        subtitle: 'Görsel kalite testinden geçemediğinde ve kredi iade edildiğinde haber ver.',
                        pushVal: _qaPush,
                        emailVal: null,
                        smsVal: _qaSms,
                        onPushChanged: (v) => setState(() => _qaPush = v),
                        onSmsChanged: (v) => setState(() => _qaSms = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 2. ALTIN PİYASASI ALARMLARI
                  _buildCategoryCard(
                    title: 'Altın Fiyat & Piyasa Alarmları',
                    icon: Icons.trending_up_rounded,
                    children: [
                      _buildNotificationRow(
                        title: 'Günlük Altın Fiyat Özeti',
                        subtitle: 'Her sabah piyasa açılışında anlık altın fiyat raporu al.',
                        pushVal: null,
                        emailVal: _goldDailyEmail,
                        smsVal: null,
                        onEmailChanged: (v) => setState(() => _goldDailyEmail = v),
                      ),
                      const Divider(height: 24, color: AppColors.divider),
                      _buildNotificationRow(
                        title: 'Sert Fiyat Hareketleri (%2+ Değişim)',
                        subtitle: 'Has altın fiyatında %2 ve üzeri ani dalgalanmalarda haber ver.',
                        pushVal: _goldAlertPush,
                        emailVal: null,
                        smsVal: _goldAlertSms,
                        onPushChanged: (v) => setState(() => _goldAlertPush = v),
                        onSmsChanged: (v) => setState(() => _goldAlertSms = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 3. ÜRETİM TAKVİMİ HATIRLATICILARI
                  _buildCategoryCard(
                    title: 'Üretim Takvimi Hatırlatıcıları',
                    icon: Icons.calendar_month_outlined,
                    children: [
                      _buildNotificationRow(
                        title: 'Özel Gün Kampanya Yaklaştığında',
                        subtitle: 'Anneler Günü, Sevgililer Günü gibi özel günler yaklaştığında uyar.',
                        pushVal: _calendarPush,
                        emailVal: _calendarEmail,
                        smsVal: null,
                        onPushChanged: (v) => setState(() => _calendarPush = v),
                        onEmailChanged: (v) => setState(() => _calendarEmail = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 4. MÜŞTERİ ETKİLEŞİMLERİ
                  _buildCategoryCard(
                    title: 'Müşteri Etkileşim Bildirimleri',
                    icon: Icons.people_outline_rounded,
                    children: [
                      _buildNotificationRow(
                        title: 'Müşteri AR Aynası Görüntüleme',
                        subtitle: 'Müşteri paylaştığınız takıyı telefon kamerasıyla denediğinde.',
                        pushVal: _arViewPush,
                        emailVal: null,
                        smsVal: null,
                        onPushChanged: (v) => setState(() => _arViewPush = v),
                      ),
                      const Divider(height: 24, color: AppColors.divider),
                      _buildNotificationRow(
                        title: 'Katalog QR Tarama Bildirimi',
                        subtitle: 'Müşterileriniz katalog bağlantısını QR ile açtığında bildirim gönder.',
                        pushVal: _qrScanPush,
                        emailVal: null,
                        smsVal: null,
                        onPushChanged: (v) => setState(() => _qrScanPush = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // SAVE BUTTON
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.textOnGold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      minimumSize: const Size.fromHeight(56),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.success,
                          content: Text('Bildirim tercihleri başarıyla kaydedildi!'),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Bildirim Ayarlarını Kaydet',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
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

  Widget _buildNotificationRow({
    required String title,
    required String subtitle,
    bool? pushVal,
    bool? emailVal,
    bool? smsVal,
    void Function(bool)? onPushChanged,
    void Function(bool)? onEmailChanged,
    void Function(bool)? onSmsChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // PUSH
            if (pushVal != null) ...[
              _buildChannelChip(
                label: 'Mobil Bildirim',
                icon: Icons.notifications_active_outlined,
                isActive: pushVal,
                onChanged: onPushChanged!,
              ),
              const SizedBox(width: 8),
            ],
            // EMAIL
            if (emailVal != null) ...[
              _buildChannelChip(
                label: 'E-Posta',
                icon: Icons.alternate_email_rounded,
                isActive: emailVal,
                onChanged: onEmailChanged!,
              ),
              const SizedBox(width: 8),
            ],
            // SMS
            if (smsVal != null) ...[
              _buildChannelChip(
                label: 'SMS Cep Telefonu',
                icon: Icons.sms_outlined,
                isActive: smsVal,
                onChanged: onSmsChanged!,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildChannelChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required void Function(bool) onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!isActive),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.gold.withOpacity(0.12) : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? AppColors.gold : AppColors.divider,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isActive ? AppColors.gold : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? AppColors.gold : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
