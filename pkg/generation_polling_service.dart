import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_exception.dart';
import '../data/generation_repository.dart';
import '../data/models/generation.dart';

/// AI üretimi Go worker tarafında asenkron işlendiği için, sonucu almanın
/// tek yolu `/generations/{id}` endpoint'ini durum `completed`/`failed`/
/// `cancelled` olana kadar periyodik olarak sorgulamaktır (bkz. teknik
/// doküman, bölüm 14.2 "Polling mi WebSocket mi?" — MVP kararı: polling).
///
/// Bu servis:
/// - her [ApiConstants.generationPollInterval] (varsayılan 4 sn) durumu sorgular,
/// - terminal duruma ulaşınca (`completed`/`failed`/`cancelled`) otomatik durur,
/// - [ApiConstants.generationPollTimeout] süresini aşarsa sade bir "asıldı" hatası verir,
/// - ağ hatalarında polling'i kesmez, bir sonraki tick'te tekrar dener
///   (kullanıcının internet kesintisi yüzünden akışın çökmemesi için).
class GenerationPollingService {
  GenerationPollingService(this._repository);

  final GenerationRepository _repository;

  /// [generationId] için durumu polling ile takip eden bir stream döner.
  /// Stream, terminal duruma ulaşıldığında son değeri yayınlayıp kapanır.
  Stream<Generation> watch(String generationId) {
    late final StreamController<Generation> controller;
    Timer? timer;
    final startedAt = DateTime.now();

    Future<void> tick() async {
      try {
        final generation = await _repository.getById(generationId);
        controller.add(generation);

        if (generation.status.isTerminal) {
          await controller.close();
          timer?.cancel();
          return;
        }

        if (DateTime.now().difference(startedAt) >
            ApiConstants.generationPollTimeout) {
          controller.addError(
            const ApiException(
              userMessage:
                  'Görsel oluşturma normalden uzun sürüyor. Sonuç hazır olunca '
                  '"Sonuçlarım" bölümünde göreceksin.',
              isRetryable: false,
            ),
          );
          await controller.close();
          timer?.cancel();
        }
      } on ApiException catch (_) {
        // Ağ/backend hatası: akışı kesmiyoruz, bir sonraki tick'te tekrar
        // deneriz. Kullanıcıya her geçici hatada hata göstermek yerine
        // yalnızca timeout'ta sade bir mesaj veriyoruz.
      }
    }

    controller = StreamController<Generation>(
      onListen: () {
        // İlk sorguyu beklemeden hemen yap, sonra periyodik devam et.
        tick();
        timer = Timer.periodic(
          ApiConstants.generationPollInterval,
          (_) => tick(),
        );
      },
      onCancel: () {
        timer?.cancel();
      },
    );

    return controller.stream;
  }
}

final generationPollingServiceProvider =
    Provider<GenerationPollingService>((ref) {
  return GenerationPollingService(ref.watch(generationRepositoryProvider));
});

/// UI'ın doğrudan dinleyeceği provider. Örnek kullanım:
/// ```dart
/// final asyncGeneration = ref.watch(generationStatusProvider(generationId));
/// asyncGeneration.when(
///   data: (g) => ...,
///   loading: () => ...,
///   error: (e, _) => Text((e as ApiException).userMessage),
/// );
/// ```
final generationStatusProvider =
    StreamProvider.autoDispose.family<Generation, String>((ref, generationId) {
  final service = ref.watch(generationPollingServiceProvider);
  return service.watch(generationId);
});
