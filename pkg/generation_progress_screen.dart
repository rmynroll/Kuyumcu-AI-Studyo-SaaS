import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/network/api_exception.dart';
import 'application/generation_polling_service.dart';

/// Üretim başlatıldıktan sonra gösterilen bekleme ekranı.
///
/// [generationStatusProvider] üzerinden 3-5 saniyede bir durumu sorgular
/// (bkz. `generation_polling_service.dart`) ve `completed` olduğunda
/// otomatik olarak sonuç ekranına yönlendirir.
class GenerationProgressScreen extends ConsumerWidget {
  const GenerationProgressScreen({super.key, required this.generationId});

  final String generationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncGeneration = ref.watch(generationStatusProvider(generationId));

    ref.listen(generationStatusProvider(generationId), (previous, next) {
      final generation = next.value;
      if (generation != null && generation.status.name == 'completed') {
        context.go('/results/$generationId');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Görsel Oluşturuluyor')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: asyncGeneration.when(
              data: (generation) => _ProgressContent(statusLabel: generation.status.userLabel),
              loading: () => const _ProgressContent(statusLabel: 'Hazırlanıyor'),
              error: (error, _) => _ErrorContent(
                message: error is ApiException
                    ? error.userMessage
                    : 'Bir şeyler ters gitti, tekrar dener misin?',
                onRetry: () => ref.invalidate(generationStatusProvider(generationId)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressContent extends StatelessWidget {
  const _ProgressContent({required this.statusLabel});

  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.goldGradient,
          ),
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(
              color: AppColors.textOnGold,
              strokeWidth: 3,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(statusLabel, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Bu genelde 1-2 dakika sürer. Ekrandan ayrılabilirsin, '
          'bittiğinde "Sonuçlarım" bölümünde seni bekliyor olacak.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, color: AppColors.error, size: 56),
        const SizedBox(height: 20),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: onRetry,
          child: const Text('Tekrar Dene'),
        ),
      ],
    );
  }
}
