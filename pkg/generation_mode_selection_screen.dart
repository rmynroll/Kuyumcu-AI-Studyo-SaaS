import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import 'widgets/mode_selection_card.dart';

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
