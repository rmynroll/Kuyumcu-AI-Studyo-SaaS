import 'package:flutter/material.dart';
import 'app_colors.dart';

class SupportHelpScreen extends StatefulWidget {
  const SupportHelpScreen({super.key});

  @override
  State<SupportHelpScreen> createState() => _SupportHelpScreenState();
}

class _SupportHelpScreenState extends State<SupportHelpScreen> {
  final _ticketFormKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  String _selectedCategory = 'Teknik Destek';
  int? _expandedFaq;

  final List<Map<String, String>> _faqs = [
    {
      'q': 'Üretilen görsellerin ticari kullanım hakları kime aittir?',
      'a': 'Kuyumcu AI Stüdyo ile ürettiğiniz tüm görsellerin telif ve ticari kullanım hakları tamamen firmanıza aittir. Kataloglarınızda, e-ticaret sitelerinizde ve sosyal medyada özgürce kullanabilirsiniz.',
      'icon': '🖼️',
    },
    {
      'q': 'Kredi sistemi nasıl çalışır ve iadeler nasıl yapılır?',
      'a': 'Her görsel oluşturma işlemi 1 kredi tüketir. Yapay zeka çıktısının QA skoru eşiğin altında kalırsa kredi otomatik iade edilir. İade durumunu "Sonuçlarım" ekranından takip edebilirsiniz.',
      'icon': '💎',
    },
    {
      'q': 'Canlı altın fiyat senkronizasyonu nasıl çalışır?',
      'a': 'BIST ve uluslararası altın ons fiyatları anlık çekilir. Milyem (ayar) ve işçilik bedeli parametreleri ile çarpılarak e-ticaret sitenizdeki fiyatlar otomatik güncellenir.',
      'icon': '📈',
    },
    {
      'q': 'Müşteri Aynası (AR) için 3D CAD dosyası yüklemek zorunlu mu?',
      'a': 'Hayır. Yapay zeka motorumuz tek bir stüdyo fotoğrafından derinlik haritası çıkararak 3D döndürme ve AR deneyimini otomatik simüle edebilir.',
      'icon': '🔮',
    },
    {
      'q': 'Hangi e-ticaret platformları destekleniyor?',
      'a': 'Shopify, WooCommerce (WordPress), Magento, Trendyol, Hepsiburada ve özel REST API entegrasyonu desteklenmektedir. Platform SDK kodları "API Anahtarları" sayfanızda hazır mevcuttur.',
      'icon': '🛒',
    },
    {
      'q': 'Bir günde en fazla kaç görsel üretebilirim?',
      'a': 'Abonelik planınıza bağlıdır. Starter: 50/gün, Pro: 300/gün, Business: Sınırsız. Kredi satın alarak günlük limitin üzerine çıkabilirsiniz.',
      'icon': '⚡',
    },
  ];

  final List<Map<String, String>> _videoGuides = [
    {
      'title': 'İlk Görselinizi Üretin',
      'desc': 'Ürün fotoğrafından AI görseline: adım adım rehber',
      'duration': '3:42',
      'icon': '🎬',
    },
    {
      'title': 'Koleksiyon Stüdyosu Kullanımı',
      'desc': 'Çoklu ürün kartları ve sezon koleksiyonu oluşturma',
      'duration': '5:15',
      'icon': '💍',
    },
    {
      'title': 'Shopify Entegrasyonu Kurulumu',
      'desc': 'API anahtarı ile fiyat senkronizasyonu',
      'duration': '7:30',
      'icon': '🔗',
    },
    {
      'title': 'AR Müşteri Aynası Aktivasyonu',
      'desc': 'QR kodunu ürün sayfanıza gömmek',
      'duration': '4:00',
      'icon': '🪞',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Destek ve Yardım'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // BAŞLIK
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.headset_mic_rounded, color: AppColors.gold, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Yardım Merkezi',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Ortalama yanıt süresi: 3 dakika',
                            style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // CANLI DESTEK KANALLARI
                  _buildContactChannels(),
                  const SizedBox(height: 28),

                  // VİDEO REHBERLER
                  _buildSectionLabel('Video Rehberler', Icons.play_circle_outline_rounded),
                  const SizedBox(height: 12),
                  _buildVideoGuides(),
                  const SizedBox(height: 28),

                  // FAQ
                  _buildSectionLabel('Sıkça Sorulan Sorular', Icons.quiz_outlined),
                  const SizedBox(height: 12),
                  _buildFaqSection(),
                  const SizedBox(height: 28),

                  // DESTEK TALEBİ FORMU
                  _buildTicketForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.gold, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildContactChannels() {
    return Column(
      children: [
        // WhatsApp VIP + Durum çipi
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF25D366).withOpacity(0.35)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF25D366),
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  'W',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                                ),
                              ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WhatsApp VIP Destek',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 7, height: 7,
                          decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Çevrimiçi • Ort. yanıt: 3 dk',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('WhatsApp VIP Destek kanalına yönlendiriliyorsunuz...')),
                  );
                },
                child: const Text('Bağlan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // E-POSTA + VİDEO RANDEVU yanyana
        Row(
          children: [
            Expanded(
              child: _buildChannelChip(
                icon: Icons.email_outlined,
                color: Colors.blueAccent,
                title: 'E-Posta',
                desc: 'destek@kuyumcuai.com',
                buttonLabel: 'Yaz',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildChannelChip(
                icon: Icons.video_call_rounded,
                color: Colors.purpleAccent,
                title: 'Video Randevu',
                desc: 'Uzman ekranından destek',
                buttonLabel: 'Planla',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChannelChip({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
    required String buttonLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 2),
          Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$title kanalına yönlendiriliyorsunuz...')),
                );
              },
              child: Text(buttonLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoGuides() {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _videoGuides.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final guide = _videoGuides[index];
          return GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"${guide['title']}" videosu oynatılıyor...')),
              );
            },
            child: Container(
              width: 210,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(guide['icon']!, style: const TextStyle(fontSize: 22)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.play_arrow_rounded, color: AppColors.gold, size: 12),
                            const SizedBox(width: 3),
                            Text(guide['duration']!, style: const TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    guide['title']!,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    guide['desc']!,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFaqSection() {
    return Column(
      children: List.generate(_faqs.length, (index) {
        final faq = _faqs[index];
        final isExpanded = _expandedFaq == index;
        return GestureDetector(
          onTap: () {
            setState(() {
              _expandedFaq = isExpanded ? null : index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isExpanded ? AppColors.surfaceElevated : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isExpanded ? AppColors.gold.withOpacity(0.35) : AppColors.divider,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(faq['icon']!, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        faq['q']!,
                        style: TextStyle(
                          color: isExpanded ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: isExpanded ? AppColors.gold : AppColors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 12),
                  Container(height: 1, color: AppColors.divider),
                  const SizedBox(height: 12),
                  Text(
                    faq['a']!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.55,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTicketForm() {
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
              Icon(Icons.support_agent_rounded, color: AppColors.gold, size: 20),
              SizedBox(width: 8),
              Text(
                'Destek Talebi Oluştur',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.divider),
          Form(
            key: _ticketFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Talep Kategorisi', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      dropdownColor: AppColors.surfaceElevated,
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.gold),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'Teknik Destek', child: Text('🔧  Teknik Destek / Hata Raporu')),
                        DropdownMenuItem(value: 'Ödeme & Fatura', child: Text('💳  Ödeme, Fatura & Üyelik')),
                        DropdownMenuItem(value: 'Görsel Kalitesi', child: Text('🖼️  Görsel Oluşturma Kalitesi')),
                        DropdownMenuItem(value: 'API & Entegrasyon', child: Text('🔗  API & Entegrasyon Yardımı')),
                        DropdownMenuItem(value: 'Öneri & Geri Bildirim', child: Text('💡  Öneri & Geri Bildirim')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Mesajınız', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _messageController,
                  maxLines: 5,
                  validator: (v) => v!.isEmpty ? 'Lütfen mesajınızı yazın' : null,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Sorununuzu veya talebinizi detaylıca açıklayın...',
                    hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    contentPadding: const EdgeInsets.all(14),
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
                const SizedBox(height: 20),
                // EK DOSYA BUTTON
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.divider),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size.fromHeight(40),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dosya ekleme işlevi (ekran görüntüsü veya log dosyası)')),
                    );
                  },
                  icon: const Icon(Icons.attach_file_rounded, size: 16),
                  label: const Text('Ekran Görüntüsü veya Dosya Ekle', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.textOnGold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: () {
                    if (_ticketFormKey.currentState!.validate()) {
                      _messageController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.success,
                          content: Text('Destek talebiniz alındı! 24 saat içinde e-posta ile dönüş yapılacaktır.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Talebi Gönder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
