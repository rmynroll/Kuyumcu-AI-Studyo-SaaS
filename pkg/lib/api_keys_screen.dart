import 'package:flutter/material.dart';
import 'app_colors.dart';

class ApiKeysScreen extends StatefulWidget {
  const ApiKeysScreen({super.key});

  @override
  State<ApiKeysScreen> createState() => _ApiKeysScreenState();
}

class _ApiKeysScreenState extends State<ApiKeysScreen> {
  // Mock API Keys
  final List<Map<String, String>> _apiKeys = [
    {
      'name': 'Shopify Entegrasyon Anahtarı',
      'key': 'sk_live_51Nv2...8xK9p',
      'created': '14 Mart 2026',
      'lastUsed': '2 dakika önce',
      'platform': 'Shopify',
    },
    {
      'name': 'Trendyol Fiyat Senkronizasyonu',
      'key': 'sk_live_92Kd...2mP7w',
      'created': '1 Nisan 2026',
      'lastUsed': '1 saat önce',
      'platform': 'Trendyol',
    },
  ];

  // Selected preset details for integration guide
  String _selectedPlatform = 'Shopify';

  // State
  bool _showSecretKey = false;
  String _apiOutput = '{\n  "status": "success",\n  "sync_type": "gold_price_recalculation",\n  "synced_products_count": 142,\n  "base_gold_gr_price_try": 3140.20,\n  "timestamp": "2026-07-09T23:51:00Z"\n}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('API & Entegrasyon'),
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
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Kuyumcu E-Ticaret API Paneli',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ürettiğiniz AI görsellerini ve canlı altın fiyatı çarpanlı ürün fiyatlarını e-ticaret sitenizle otomatik senkronize edin.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 32),

                  // PIYASADAN FARKLI METRİKLER PANELİ (API Sağlık & Performans)
                  _buildMetricSection(),
                  const SizedBox(height: 24),

                  // 1. API ANAHTARLARI LİSTESİ
                  _buildSectionCard(
                    title: 'Aktif API Anahtarlarınız',
                    icon: Icons.key_rounded,
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _apiKeys.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final apiKey = _apiKeys[index];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      apiKey['name']!,
                                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.gold.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        apiKey['platform']!,
                                        style: const TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _showSecretKey ? apiKey['key']! : '••••••••••••••••••••••••••••',
                                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'monospace'),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(_showSecretKey ? Icons.visibility_off : Icons.visibility, color: AppColors.textSecondary),
                                      onPressed: () {
                                        setState(() {
                                          _showSecretKey = !_showSecretKey;
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.copy, color: AppColors.gold),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('API anahtarı panoya kopyalandı!')),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Oluşturulma: ${apiKey['created']}',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                                    ),
                                    Text(
                                      'Son Kullanım: ${apiKey['lastUsed']}',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.gold,
                          shadowColor: Colors.transparent,
                          side: const BorderSide(color: AppColors.gold, width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Yeni API Anahtarı oluşturuldu! (Simüle edildi)')),
                          );
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Yeni API Anahtarı Üret', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 2. PIYASADAN FARKLI ENTEGRASYON KILAVUZU (Platforma Özel Webhook & Snippets)
                  _buildSectionCard(
                    title: 'Kuyumcu Platform Özel Entegrasyon Kodları',
                    icon: Icons.integration_instructions_outlined,
                    children: [
                      const Text(
                        'E-Ticaret altyapınızı seçerek ürün görselleri ve AR aynası bağlantılarını senkronize eden hazır kod bloğunu kopyalayın.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['Shopify', 'WooCommerce', 'Magento', 'Trendyol'].map((plat) {
                          final isSel = _selectedPlatform == plat;
                          return ChoiceChip(
                            label: Text(plat),
                            selected: isSel,
                            onSelected: (val) {
                              if (val) {
                                setState(() {
                                  _selectedPlatform = plat;
                                });
                              }
                            },
                            selectedColor: AppColors.gold.withOpacity(0.12),
                            labelStyle: TextStyle(
                              color: isSel ? AppColors.gold : AppColors.textSecondary,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            backgroundColor: AppColors.surfaceElevated,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: isSel ? AppColors.gold : AppColors.divider),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$_selectedPlatform SDK / Webhook Örneği',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, color: AppColors.gold, size: 16),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Kod örneği panoya kopyalandı!')),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const Divider(color: AppColors.divider),
                            const SizedBox(height: 8),
                            SelectableText(
                              _getPlatformCodeSnippet(_selectedPlatform),
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 3. CANLI SİMÜLASYON TEST ALANI (Developer Sandbox)
                  _buildSectionCard(
                    title: 'Fiyat & Görsel Senkronizasyon Test İstasyonu',
                    icon: Icons.terminal_rounded,
                    children: [
                      const Text(
                        'Aşağıdaki butona basarak e-ticaret sitenizin otomatik altın fiyatı bazlı tetikleme çağrısını simüle edin.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 140,
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            _apiOutput,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: AppColors.success,
                              fontSize: 10,
                            ),
                          ),
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
                          setState(() {
                            _apiOutput = '{\n  "status": "success",\n  "sync_type": "gold_price_recalculation",\n  "synced_products_count": 142,\n  "base_gold_gr_price_try": 3140.20,\n  "timestamp": "${DateTime.now().toUtc().toIso8601String()}"\n}';
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.success,
                              content: Text('Test isteği başarıyla simüle edildi!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Test İstek Gönder', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildMetricSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Entegrasyon Sağlık Durumu',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricItem(
                label: 'İstek Başarı Oranı',
                value: '99.98%',
                icon: Icons.check_circle_outline,
                color: AppColors.success,
              ),
              _buildMetricItem(
                label: 'Toplam İstek (Bugün)',
                value: '4,821 / 10K',
                icon: Icons.swap_horiz,
                color: AppColors.gold,
              ),
              _buildMetricItem(
                label: 'Ortalama Cevap Süresi',
                value: '142ms',
                icon: Icons.timer_outlined,
                color: Colors.blueAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
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

  String _getPlatformCodeSnippet(String platform) {
    switch (platform) {
      case 'Shopify':
        return '// Shopify Webhook Handler (Node.js)\n'
            'const client = new KuyumcuAiAPI("sk_live_51Nv2...");\n'
            'app.post("/webhooks/gold-price", async (req, res) => {\n'
            '  const update = await client.prices.syncWithMarket({\n'
            '    storefront: "shopify",\n'
            '    pricingMultiplier: 1.15 // %15 Kâr Marjı\n'
            '  });\n'
            '  console.log("Fiyatlar güncellendi:", update.synced);\n'
            '  res.sendStatus(200);\n'
            '});';
      case 'WooCommerce':
        return '// WooCommerce WordPress Hook (PHP)\n'
            'add_action(\'kuyumcu_gold_price_updated\', \'sync_woo_prices\');\n'
            'function sync_woo_prices(\$gold_gr_price) {\n'
            '  \$api = new Kuyumcu_AI_API(\'sk_live_51Nv2...\');\n'
            '  \$api->sync_woocommerce_catalog([\n'
            '    \'labor_cost_gr\' => 25.0, // 25 USD işçilik/gr\n'
            '    \'tax_rate\' => 0.20\n'
            '  ]);\n'
            '}';
      case 'Trendyol':
        return '// Trendyol Pazaryeri Entegrasyon Servisi (Python)\n'
            'import kuyumcu_ai\n'
            'api = kuyumcu_ai.Client(api_key="sk_live_92Kd...")\n'
            'response = api.sync_marketplace_prices(\n'
            '    channel="trendyol",\n'
            '    automatic_updates=True,\n'
            '    margin_percentage=18\n'
            ')\n'
            'print(f"Trendyol senkronizasyonu aktif: {response[\'active\']}")';
      case 'Magento':
      default:
        return '// Magento REST API Integration (JSON)\n'
            'POST /rest/V1/kuyumcu-ai/sync\n'
            'Headers: {\n'
            '  "Authorization": "Bearer sk_live_51Nv2...",\n'
            '  "Content-Type": "application/json"\n'
            '}\n'
            'Body: {\n'
            '  "auto_publish_ar": true,\n'
            '  "auto_publish_cad": false\n'
            '}';
    }
  }
}
