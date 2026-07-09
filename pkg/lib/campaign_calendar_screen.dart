import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_colors.dart';

class CampaignCalendarScreen extends StatefulWidget {
  const CampaignCalendarScreen({super.key});

  @override
  State<CampaignCalendarScreen> createState() => _CampaignCalendarScreenState();
}

class _CampaignCalendarScreenState extends State<CampaignCalendarScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<_CampaignEvent> _campaigns = [
    _CampaignEvent(
      title: 'Anneler Günü',
      date: 'Mayıs 2. Haftası',
      prepPeriod: 'Hazırlık Dönemi: Mart - Nisan',
      description: 'Yılın en yüksek ciro getiren dönemi. Baget yüzükler ve anne-çocuk kolyeleri için tanıtımlara başlayın.',
      presetConcept: 'Lüks İtalyan Çekimi (Sıcak & Spot Işık)',
      color: Colors.redAccent,
      imageUrl: 'https://images.unsplash.com/photo-1542038784456-1ea8e935640e?q=80&w=400&auto=format&fit=crop',
      promptTheme: 'Lüks gül yaprakları ve altın yansımalı kırmızı kadife stüdyo arka planı',
    ),
    _CampaignEvent(
      title: 'Düğün & Nişan Sezonu',
      date: 'Haziran - Ağustos',
      prepPeriod: 'Hazırlık Dönemi: Nisan - Mayıs',
      description: 'Alyans, takı seti ve kelepçe bilezik satışlarının pik yaptığı dönem. Katalog görsellerini tekleştirin.',
      presetConcept: 'Doğal Gün Işığı Yaprak (Gölge & Ahşap Zemin)',
      color: Colors.amber,
      imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=400&auto=format&fit=crop',
      promptTheme: 'Doğal gün ışığı gölgeli ahşap zemin, beyaz zambak ve nişan çiçekleri',
    ),
    _CampaignEvent(
      title: 'Sevgililer Günü',
      date: '14 Şubat',
      prepPeriod: 'Hazırlık Dönemi: Aralık - Ocak',
      description: 'Tektaş yüzükler, kalpli kolyeler ve kişiselleştirilmiş ürün tasarımları için anahtar kampanya dönemi.',
      presetConcept: 'Siyah Kadife Kompozisyon (Yüksek Kontrast & Gölgeli)',
      color: Colors.pinkAccent,
      imageUrl: 'https://images.unsplash.com/photo-1518199266791-5375a83190b7?q=80&w=400&auto=format&fit=crop',
      promptTheme: 'Siyah kadife kutu, sol yan stüdyo ışığı, kırmızı romantik güller and altın parıltılar',
    ),
    _CampaignEvent(
      title: 'Yılbaşı Hediye Dönemi',
      date: 'Aralık Sonu',
      prepPeriod: 'Hazırlık Dönemi: Ekim - Kasım',
      description: 'Minimal kolyeler, şans bileklikleri ve bütçe dostu gümüş hediyelikler için e-ticaret sitenizi güncelleyin.',
      presetConcept: 'Lüks Siyah Mermer (Yansımalı & Lüks)',
      color: Colors.blueAccent,
      imageUrl: 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400&auto=format&fit=crop',
      promptTheme: 'Yansımalı cilalı siyah mermer zemin, çam ağacı gölgeleri, minik karlı kozalaklar ve gümüş ışıltılar',
    ),
  ];

  final List<_CadRecommendation> _cadModels = [
    _CadRecommendation(
      title: 'Asimetrik Baget Zümrüt Yüzük',
      difficulty: 'Orta Seviye',
      trendScore: '94%',
      description: 'Genç neslin yoğun ilgi gösterdiği, modern çizgilerle süslenmiş asimetrik zümrüt taş dizilimi. 2026 evlilik yüzüğü trendi.',
      imageUrl: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?q=80&w=200&auto=format&fit=crop',
    ),
    _CadRecommendation(
      title: 'Lale Motifli Kelepçe Bilezik',
      difficulty: 'İleri Seviye',
      trendScore: '89%',
      description: 'Geleneksel Türk lale deseninin modern döküm teknikleriyle hafifletilmiş minimalist yorumu. KOBİ dökümhaneleri için optimize edilmiştir.',
      imageUrl: 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?q=80&w=200&auto=format&fit=crop',
    ),
    _CadRecommendation(
      title: 'Geometrik Çift Renkli Alyans',
      difficulty: 'Kolay Seviye',
      trendScore: '91%',
      description: 'Beyaz ve sarı altının geometrik pres tekniğiyle birleştiği, düşük gramajlı fakat yüksek hacimli alyans tasarımı.',
      imageUrl: 'https://images.unsplash.com/photo-1598560917505-59a3ad559071?q=80&w=200&auto=format&fit=crop',
    ),
    _CadRecommendation(
      title: 'Minimalist Baget Şans Kolyesi',
      difficulty: 'Kolay Seviye',
      trendScore: '93%',
      description: 'Düşük gramajlı döküm kanalları içeren, seri üretime çok uygun baget taşlı minimalist şans kolyesi.',
      imageUrl: 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=200&auto=format&fit=crop',
    ),
    _CadRecommendation(
      title: 'Helisel Sarma Alyans (3D Doku)',
      difficulty: 'İleri Seviye',
      trendScore: '92%',
      description: '3D yazıcılarda destek gerektirmeden basılabilen, döküm sonrası tesviye süresini yarı yarıya indiren helisel örgü alyans.',
      imageUrl: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?q=80&w=200&auto=format&fit=crop',
    ),
    _CadRecommendation(
      title: 'Hafifletilmiş Telkari Küpe',
      difficulty: 'Orta Seviye',
      trendScore: '88%',
      description: 'Geleneksel telkari sanatının CAD yazılımı ile ağırlığı %40 düşürülmüş sürümü. Üretici dostu yolluk sistemiyle entegre.',
      imageUrl: 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?q=80&w=200&auto=format&fit=crop',
    ),
    _CadRecommendation(
      title: 'Mekanik Kilitli Zincir Kilidi',
      difficulty: 'Orta Seviye',
      trendScore: '95%',
      description: 'Yay mekanizması CAD içinde modüllendirilen ve mikro döküm hassasiyetine göre toleranslandırılmış modern kilit tasarımı.',
      imageUrl: 'https://images.unsplash.com/photo-1617038260897-41a1f14a8ca0?q=80&w=200&auto=format&fit=crop',
    ),
  ];

  late final List<TextEditingController> _promptControllers;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _promptControllers = List.generate(
      _campaigns.length,
      (_) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _promptControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Üretim Takvimi & Öneriler'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go('/'),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Sezonluk Kampanyalar'),
            Tab(text: 'KOBİ CAD Model Önerileri'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // TAB 1: SEZONLUK KAMPANYALAR
            _buildCampaignList(context),

            // TAB 2: KOBİ MODEL ÖNERİLERİ
            _buildCadRecommendationsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: _campaigns.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final camp = _campaigns[index];

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.gold.withOpacity(0.25)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // VISUAL IMAGE BANNER WITH OVERLAY
              SizedBox(
                height: 200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(camp.imageUrl, fit: BoxFit.cover),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black87,
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                camp.title,
                                style: TextStyle(
                                  color: camp.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  shadows: const [
                                    Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: camp.color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: camp.color.withOpacity(0.5)),
                                ),
                                child: Text(
                                  camp.date,
                                  style: TextStyle(
                                    color: camp.color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
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
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.alarm_on, color: AppColors.gold, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          camp.prepPeriod,
                          style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      camp.description,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Önerilen Konsept:',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          camp.presetConcept,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // IDEA PROMPT INPUT
                    TextField(
                      controller: _promptControllers[index],
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Bu Kampanya İçin Aklınızdaki Fikir / Detaylar',
                        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        hintText: 'Örn: Zümrüt kolyemin etrafında kırmızı güller olsun...',
                        hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
                        prefixIcon: const Icon(Icons.lightbulb_outline, color: AppColors.gold, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.divider),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.gold),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.textOnGold,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: () {
                        final customIdea = _promptControllers[index].text.trim();
                        final campaignPrompt = '${camp.presetConcept}. ' + 
                            (customIdea.isNotEmpty 
                                ? 'Konsept detayları: $customIdea' 
                                : 'Konsept detayları: ${camp.promptTheme}');
                        
                        // Redirection directly to the inspiration board with template (tab 0) and prompt params
                        context.go('/generation/template?prompt=${Uri.encodeComponent(campaignPrompt)}');

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${camp.title} konsept şablonu ve fikriniz stüdyoya yüklendi!')),
                        );
                      },
                      icon: const Icon(Icons.auto_awesome, size: 16),
                      label: const Text('Bu Kampanyaya Görsel Üret 🚀', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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

  Widget _buildCadRecommendationsList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: _cadModels.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final model = _cadModels[index];

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(model.imageUrl, width: 80, height: 80, fit: BoxFit.cover),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            model.title,
                            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            model.trendScore,
                            style: const TextStyle(color: AppColors.gold, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Zorluk Derecesi: ${model.difficulty}',
                      style: const TextStyle(color: AppColors.goldLight, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      model.description,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.4),
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.divider),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('3D CAD Matrix dosyası indirildi! (Simüle edildi)')),
                              );
                            },
                            child: const Text('CAD Dosyası İndir', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: AppColors.textOnGold,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () {
                              final modelPrompt = 'CAD Tasarım Görselleştirme: ${model.title}. ${model.description}';
                              context.go('/generation/template?prompt=${Uri.encodeComponent(modelPrompt)}');
                            },
                            child: const Text('AI ile Görsel Üret', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
}

class _CampaignEvent {
  final String title;
  final String date;
  final String prepPeriod;
  final String description;
  final String presetConcept;
  final Color color;
  final String imageUrl;
  final String promptTheme;

  _CampaignEvent({
    required this.title,
    required this.date,
    required this.prepPeriod,
    required this.description,
    required this.presetConcept,
    required this.color,
    required this.imageUrl,
    required this.promptTheme,
  });
}

class _CadRecommendation {
  final String title;
  final String difficulty;
  final String trendScore;
  final String description;
  final String imageUrl;

  _CadRecommendation({
    required this.title,
    required this.difficulty,
    required this.trendScore,
    required this.description,
    required this.imageUrl,
  });
}
