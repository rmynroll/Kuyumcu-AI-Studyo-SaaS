import 'package:flutter/material.dart';
import 'app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hakkında'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HERO BANNER
              _buildHeroBanner(context),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),

                        // PLATFORM İSTATİSTİKLERİ
                        _buildStatsRow(),
                        const SizedBox(height: 28),

                        // MİSYON KARTI
                        _buildMissionCard(),
                        const SizedBox(height: 24),

                        // TEKNOLOJİ YIG INI
                        _buildTechStackCard(context),
                        const SizedBox(height: 24),

                        // VERSİYON GEÇMİŞİ
                        _buildChangelogCard(context),
                        const SizedBox(height: 24),

                        // YASAL BELGELER
                        _buildLegalCard(context),
                        const SizedBox(height: 40),

                        // COPYRIGHT
                        const Center(
                          child: Text(
                            '© 2026 Kuyumcu AI Studio. Tüm Hakları Saklıdır.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1508),
            AppColors.background,
            const Color(0xFF12100A),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dekoratif altın çember
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold.withOpacity(0.08), width: 40),
              ),
            ),
          ),
          Positioned(
            left: -60,
            bottom: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold.withOpacity(0.05), width: 30),
              ),
            ),
          ),
          // Logo + versiyon
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.gold, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.25),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.diamond_outlined, color: AppColors.gold, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kuyumcu AI Stüdyo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                ),
                child: const Text(
                  'Sürüm 1.2.0  •  B2B SaaS Gold Edition',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatChip('1.500+', 'Kuyumcu Marka', Icons.store_rounded),
        _buildStatChip('2.1M+', 'Görsel Üretildi', Icons.image_rounded),
        _buildStatChip('%99.8', 'Uptime Oranı', Icons.cloud_done_rounded),
      ],
    );
  }

  Widget _buildStatChip(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.gold, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: AppColors.gold, size: 20),
              SizedBox(width: 8),
              Text(
                'Vizyonumuz',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          Divider(height: 24, color: AppColors.divider),
          Text(
            'Kuyumculuk sektöründe kurumsal dijitalleşme ve yapay zeka devrimine liderlik ediyoruz.',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, height: 1.5),
          ),
          SizedBox(height: 10),
          Text(
            'Fiziksel ürünlerinizi yüksek maliyetli stüdyo çekimlerinden kurtararak saniyeler içinde '
            'lüks AI kompozisyonlar üretiyoruz. 3D AR Müşteri Aynası ve kuyumculara özel '
            'canlı altın fiyat hesaplama modüllerimiz ile e-ticaretinizi tam otomatize ediyoruz.\n\n'
            'Kapalıçarşı\'dan global pazara açılan her kuyumcu firmasının dijital vitrini olma '
            'hedefiyle çalışıyoruz.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.65),
          ),
        ],
      ),
    );
  }

  Widget _buildTechStackCard(BuildContext context) {
    final techs = [
      {'name': 'Flutter 3.x', 'role': 'Uygulama Altyapısı', 'icon': '🎯'},
      {'name': 'Google Gemini', 'role': 'Görsel & Metin AI Motoru', 'icon': '🤖'},
      {'name': 'AWS S3 + CDN', 'role': 'Görsel Depolama', 'icon': '☁️'},
      {'name': 'BIST Altın API', 'role': 'Canlı Piyasa Verileri', 'icon': '📊'},
      {'name': 'WebRTC + AR', 'role': 'Müşteri Aynası Modülü', 'icon': '🪞'},
      {'name': 'Flutter Riverpod', 'role': 'Durum Yönetimi', 'icon': '⚡'},
    ];

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
          const Row(
            children: [
              Icon(Icons.memory_rounded, color: AppColors.gold, size: 20),
              SizedBox(width: 8),
              Text(
                'Teknoloji Altyapısı',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.divider),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3.2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: techs.length,
            itemBuilder: (context, index) {
              final tech = techs[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Text(tech['icon']!, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tech['name']!,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            tech['role']!,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 9),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChangelogCard(BuildContext context) {
    final changes = [
      {
        'version': 'v1.2.0',
        'date': 'Temmuz 2026',
        'tag': 'Güncel',
        'highlights': [
          'Güvenlik Paneli: Şifre, 2FA ve Oturum Yönetimi',
          'API & E-Ticaret Entegrasyon Merkezi',
          'Destek Talebi ve Video Rehberler',
        ],
      },
      {
        'version': 'v1.1.0',
        'date': 'Mayıs 2026',
        'tag': '',
        'highlights': [
          'Canlı Altın Piyasa Takip Ekranı',
          'Koleksiyon Stüdyosu ve AR Önizleme',
          'Üretim Takvimi & Kampanya Planlayıcı',
        ],
      },
      {
        'version': 'v1.0.0',
        'date': 'Mart 2026',
        'tag': '',
        'highlights': [
          'İlk sürüm yayına alındı',
          'AI Görsel Üretici (Stüdyo Modu)',
          'Ürün Yükleme ve Katalog Modülü',
        ],
      },
    ];

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
          const Row(
            children: [
              Icon(Icons.history_rounded, color: AppColors.gold, size: 20),
              SizedBox(width: 8),
              Text(
                'Versiyon Geçmişi',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.divider),
          ...changes.map((change) {
            final isCurrent = change['tag'] == 'Güncel';
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: isCurrent ? AppColors.gold : AppColors.divider,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(width: 1, height: 70, color: AppColors.divider),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              change['version'] as String,
                              style: TextStyle(
                                color: isCurrent ? AppColors.gold : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isCurrent)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('Güncel', style: TextStyle(color: AppColors.gold, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        Text(
                          change['date'] as String,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                        ),
                        const SizedBox(height: 6),
                        ...(change['highlights'] as List<String>).map((h) => Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: isCurrent ? AppColors.gold : AppColors.textSecondary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(h, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLegalCard(BuildContext context) {
    final policies = [
      'Kullanım Koşulları & Sözleşmesi',
      'Gizlilik & Veri Güvenliği Politikası',
      'KVKK Aydınlatma Metni',
      'Açık Kaynak Lisansları',
    ];

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
          const Row(
            children: [
              Icon(Icons.gavel_outlined, color: AppColors.gold, size: 20),
              SizedBox(width: 8),
              Text(
                'Yasal Belgeler',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.divider),
          ...policies.asMap().entries.map((entry) {
            final isLast = entry.key == policies.length - 1;
            return Column(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.surfaceElevated,
                        title: Text(
                          entry.value,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        content: SingleChildScrollView(
                          child: Text(
                            'Bu metin, Kuyumcu AI Stüdyo platformunun ${entry.value} şartlarını kapsamaktadır. '
                            'Tüm veriler AES-256 şifrelemesi ve AWS altyapısı üzerinde Türkiye\'deki veri merkezlerinde '
                            'Türkiye Cumhuriyeti yasalarına ve KVKK mevzuatına tam uyumlu şekilde işlenmektedir.',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Kapat', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.value,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 13),
                      ],
                    ),
                  ),
                ),
                if (!isLast) const Divider(height: 1, color: AppColors.divider),
              ],
            );
          }),
        ],
      ),
    );
  }
}
