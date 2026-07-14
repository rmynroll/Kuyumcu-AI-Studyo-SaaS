import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:kuyumcu_flutter/api_exception.dart';
import 'package:kuyumcu_flutter/app_colors.dart';
import 'package:kuyumcu_flutter/generation.dart';
import 'package:kuyumcu_flutter/generation_polling_service.dart';

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
      appBar: AppBar(
        title: const Text('Görsel Oluşturuluyor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: asyncGeneration.when(
              data: (generation) => _ProgressContent(status: generation.status),
              loading: () => const _ProgressContent(status: GenerationStatus.pending),
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
  const _ProgressContent({required this.status});

  final GenerationStatus status;

  @override
  Widget build(BuildContext context) {
    // Aşamaların aktiflik/tamamlanmışlık durumları
    final step1Active = status == GenerationStatus.pending || status == GenerationStatus.queued || status == GenerationStatus.processing || status == GenerationStatus.analyzingProduct;
    final step1Done = status.index > GenerationStatus.analyzingProduct.index && status != GenerationStatus.failed && status != GenerationStatus.cancelled;

    final step2Active = status == GenerationStatus.removingBackground;
    final step2Done = status.index > GenerationStatus.removingBackground.index && status != GenerationStatus.failed && status != GenerationStatus.cancelled;

    final step3Active = status == GenerationStatus.generatingScene;
    final step3Done = status.index > GenerationStatus.generatingScene.index && status != GenerationStatus.failed && status != GenerationStatus.cancelled;

    final step4Active = status == GenerationStatus.compositingProduct;
    final step4Done = status.index > GenerationStatus.compositingProduct.index && status != GenerationStatus.failed && status != GenerationStatus.cancelled;

    final step5Active = status == GenerationStatus.qualityChecking;
    final step5Done = status.index > GenerationStatus.qualityChecking.index && status != GenerationStatus.failed && status != GenerationStatus.cancelled;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Altın Shimmer'lı Pırlanta İkonu ve Dönen Orbit
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Arka planda yavaşça dönen altın orbit halkası ve parıldayan gezegen
              const AnimatedOrbit(),
              // Shimmer'lı pırlanta
              Shimmer.fromColors(
                baseColor: AppColors.gold,
                highlightColor: const Color(0xFFFFF6D6),
                period: const Duration(milliseconds: 1500),
                child: const Icon(
                  Icons.diamond_outlined,
                  size: 60,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Aktif Aşama Etiketi
        Text(
          status.userLabel,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Mücevheriniz yapay zeka stüdyosunda işleniyor, lütfen ayrılmayın.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 36),

        // Aşamalı Durum Timeline Kartı
        Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimelineStep(context, '1. Ürün Analiz & Hazırlık', step1Active, step1Done),
              _buildLineSeparator(step1Done),
              _buildTimelineStep(context, '2. Arka Plan Ayrımı (SAM 2)', step2Active, step2Done),
              _buildLineSeparator(step2Done),
              _buildTimelineStep(context, '3. Stüdyo Sahne Tasarımı', step3Active, step3Done),
              _buildLineSeparator(step3Done),
              _buildTimelineStep(context, '4. Kompozisyon & Işık Entegrasyonu', step4Active, step4Done),
              _buildLineSeparator(step4Done),
              _buildTimelineStep(context, '5. Kalite Güvence Kontrolü (QA)', step5Active, step5Done),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineStep(BuildContext context, String label, bool isActive, bool isDone) {
    Color stepColor = AppColors.textSecondary;
    if (isActive) stepColor = AppColors.gold;
    if (isDone) stepColor = AppColors.success;

    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone 
                ? AppColors.success.withOpacity(0.12)
                : (isActive ? AppColors.gold.withOpacity(0.12) : Colors.transparent),
            border: Border.all(
              color: stepColor,
              width: isActive || isDone ? 2 : 1,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 12, color: AppColors.success)
                : (isActive
                    ? Shimmer.fromColors(
                        baseColor: AppColors.gold,
                        highlightColor: Colors.white,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.gold,
                          ),
                        ),
                      )
                    : null),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isActive || isDone ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLineSeparator(bool isDone) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Container(
        width: 2,
        height: 18,
        color: isDone ? AppColors.success : AppColors.divider,
      ),
    );
  }
}

class AnimatedOrbit extends StatefulWidget {
  const AnimatedOrbit({super.key});

  @override
  State<AnimatedOrbit> createState() => _AnimatedOrbitState();
}

class _AnimatedOrbitState extends State<AnimatedOrbit> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.gold.withOpacity(0.3),
            width: 1.2,
            style: BorderStyle.solid,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 55 - 6,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold,
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                ),
              ),
            ),
          ],
        ),
      ),
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
