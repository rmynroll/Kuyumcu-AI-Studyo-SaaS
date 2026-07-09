import 'package:flutter/material.dart';
import 'app_colors.dart';

class PerformancePocketScreen extends StatelessWidget {
  const PerformancePocketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Performans Cebi'),
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
                  Text(
                    'Görsel Etkileşim Analizi',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ürettiğiniz görsellerin indirilme, paylaşılma ve Try-On linki üzerinden tıklanma istatistiklerini takip edin.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 28),

                  // ANA METRİKLER (GRID KARTLARI)
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          title: 'Try-On Tıklama',
                          value: '1,432',
                          change: '+24%',
                          icon: Icons.ads_click_rounded,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          title: 'Görsel İndirme',
                          value: '352',
                          change: '+12%',
                          icon: Icons.file_download_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // TOPLANTI VE GRAFİK ALANI
                  _buildSectionHeader('Tıklanma Trendi (Haftalık)'),
                  const SizedBox(height: 12),
                  _buildWeeklyBarChart(context),
                  const SizedBox(height: 32),

                  // YAPAY ZEKA SATIŞ İÇGÖRÜLERİ (AI INSIGHTS)
                  _buildSectionHeader('Yapay Zeka Satış İçgörüleri'),
                  const SizedBox(height: 12),
                  _buildInsightCard(
                    title: 'Kadife Kutu Tercihi',
                    description: 'Kırmızı Kadife Kutu temalı görsel tasarımlarınız, klasik beyaz fon tasarımlara göre %40 daha fazla WhatsApp tıklaması aldı.',
                    color: AppColors.gold,
                  ),
                  const SizedBox(height: 12),
                  _buildInsightCard(
                    title: 'En Yoğun Saatler',
                    description: 'Müşterileriniz try-on deneme linklerini en yoğun olarak akşam 19:00 - 21:00 saatleri arasında açıyor. Paylaşımları bu saatlere odaklayabilirsiniz.',
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 12),
                  _buildInsightCard(
                    title: 'Kompozisyon Önerisi',
                    description: 'Sonuçlarınızdan "Elmas Baget Yüzük" modelinin yansımalı mermer zemin çıktısı, galerinizdeki diğer sahnelerden %28 daha fazla paylaşıldı.',
                    color: AppColors.gold,
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
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.gold,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String change,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.gold, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  change,
                  style: const TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBarChart(BuildContext context) {
    final List<double> heightsFraction = [0.4, 0.6, 0.5, 0.85, 0.7, 0.95, 0.65];
    final List<String> days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 14,
                    height: 100 * heightsFraction[index],
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [AppColors.goldDark, AppColors.gold],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(days[index], style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.tips_and_updates_outlined, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
