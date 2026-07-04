import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuyumcu_flutter/app_colors.dart';



/// Kullanıcı "Görsel Oluştur"a bastığında açılan ekran.
///
/// İki büyük karttan birini seçer: "Hazır Şablonla Üret" veya
/// "Referans Görsele Göre Üret" (bkz. teknik doküman, bölüm 4 —
/// "Üretim Modları: Hazır Şablon ve Referans Görsel").
class GenerationModeSelectionScreen extends StatelessWidget {
  const GenerationModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Görsel Oluştur')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nasıl üretelim?',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'İkisinden birini seç, gerisini biz hallederiz.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 28),
                  ModeSelectionCard(
                    icon: Icons.dashboard_customize_outlined,
                    title: 'Hazır Şablonla Üret',
                    description:
                        'Beyaz fon, kadife kutu, mermer sahne gibi hazır '
                        'stillerden seç.',
                    badgeText: 'En hızlı',
                    onTap: () => context.push('/generation/template'),
                  ),
                  const SizedBox(height: 16),
                  ModeSelectionCard(
                    icon: Icons.image_search_outlined,
                    title: 'Örnek Görsele Göre Üret',
                    description:
                        'Beğendiğin bir fotoğrafı yükle, ürününü aynı '
                        'tarzda üretelim.',
                    onTap: () => context.push('/generation/reference'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ModeSelectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? badgeText;
  final VoidCallback? onTap;

  const ModeSelectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.badgeText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
                        ),
                        if (badgeText != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(badgeText!, style: Theme.of(context).textTheme.labelSmall),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(description, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
