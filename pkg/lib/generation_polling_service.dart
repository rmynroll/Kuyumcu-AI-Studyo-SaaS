import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:kuyumcu_flutter/api_exception.dart';
import 'package:kuyumcu_flutter/generation.dart';
import 'package:kuyumcu_flutter/generation_repository.dart';
import 'package:kuyumcu_flutter/logging_interceptors.dart';

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

class TemplateSelectionGrid extends StatelessWidget {
  final List<Map<String, dynamic>> templates = [
    {'id': 'white_bg', 'category': 'Temel', 'title': 'Beyaz Fon', 'icon': Icons.crop_square, 'cost': 1},
    {'id': 'velvet_box', 'category': 'Temel', 'title': 'Kadife Kutu', 'icon': Icons.card_giftcard, 'cost': 1},
    {'id': 'model_hand', 'category': 'Manken', 'title': 'Kadın Eli', 'icon': Icons.back_hand, 'cost': 2},
  ];

  TemplateSelectionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Yan yana 2 kutu
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return Card(
          color: const Color(0xFF17161A), // app_colors.dart'tan aldığımız surface rengi
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              // Seçilen şablonun ID'sini state'e kaydet ve sonraki ekrana geç
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(template['icon'], size: 48, color: const Color(0xFFFFD4AF37)), // Altın rengi
                const SizedBox(height: 12),
                Text(template['title'], style: const TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${template['cost']} Kredi', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}