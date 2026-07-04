import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuyumcu_flutter/api_client.dart';
import 'package:kuyumcu_flutter/generation.dart';
import 'package:kuyumcu_flutter/logging_interceptors.dart';



/// `/generations` endpoint'lerine dair tüm HTTP çağrılarını tek yerde toplar.
/// UI/provider katmanı Dio veya JSON detaylarıyla hiç ilgilenmez.
class GenerationRepository {
  GenerationRepository(this._client);

  final ApiClient _client;

  /// Hazır şablon modunda yeni üretim başlatır.
  Future<Generation> createFromTemplate({
    required String productId,
    required String templateId,
    int outputCount = 4,
    String aspectRatio = '1:1',
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.generations,
      data: {
        'generation_mode': 'template',
        'product_id': productId,
        'template_id': templateId,
        'generation_type': 'image',
        'output_count': outputCount,
        'aspect_ratio': aspectRatio,
      },
    );
    return Generation.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  /// Referans görsel modunda yeni üretim başlatır.
  Future<Generation> createFromReference({
    required String productId,
    required String referenceAnalysisId,
    int outputCount = 4,
    String aspectRatio = '1:1',
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.generations,
      data: {
        'generation_mode': 'reference',
        'product_id': productId,
        'reference_analysis_id': referenceAnalysisId,
        'generation_type': 'image',
        'preserve_product': true,
        'output_count': outputCount,
        'aspect_ratio': aspectRatio,
      },
    );
    return Generation.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  /// Tek bir generation'ın güncel durumunu getirir (polling servisi bunu çağırır).
  Future<Generation> getById(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.generationById(id),
    );
    return Generation.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  /// "Sonuçlarım" ekranı için üretim geçmişi.
  Future<List<Generation>> list() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.generations,
    );
    final items = response.data!['data'] as List<dynamic>;
    return items
        .map((e) => Generation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Generation> retry(String id) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.generationRetry(id),
    );
    return Generation.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  Future<void> sendFeedback(String id, String feedbackCode) async {
    await _client.post<void>(
      ApiConstants.generationFeedback(id),
      data: {'feedback_code': feedbackCode},
    );
  }
}

final generationRepositoryProvider = Provider<GenerationRepository>((ref) {
  return GenerationRepository(ref.watch(apiClientProvider));
});
