import 'package:freezed_annotation/freezed_annotation.dart';

part 'generation.freezed.dart';
part 'generation.g.dart';

/// Backend `generations.status` kolonuyla birebir eşleşir
/// (bkz. teknik doküman, "Generation status değerleri").
enum GenerationStatus {
  pending,
  queued,
  processing,
  @JsonValue('analyzing_product')
  analyzingProduct,
  @JsonValue('removing_background')
  removingBackground,
  @JsonValue('generating_scene')
  generatingScene,
  @JsonValue('compositing_product')
  compositingProduct,
  @JsonValue('quality_checking')
  qualityChecking,
  completed,
  failed,
  cancelled,
}

extension GenerationStatusX on GenerationStatus {
  bool get isTerminal =>
      this == GenerationStatus.completed ||
      this == GenerationStatus.failed ||
      this == GenerationStatus.cancelled;

  bool get isInProgress => !isTerminal;

  /// Kullanıcıya gösterilecek sade, tek kelimelik durum metni.
  /// Ara aşamalar (analyzing_product, removing_background vb.) kasıtlı
  /// olarak tek bir "Hazırlanıyor" mesajında toplanır — kuyumcuya pipeline
  /// detayı gösterilmez.
  String get userLabel {
    switch (this) {
      case GenerationStatus.pending:
      case GenerationStatus.queued:
        return 'Sırada';
      case GenerationStatus.processing:
      case GenerationStatus.analyzingProduct:
      case GenerationStatus.removingBackground:
      case GenerationStatus.generatingScene:
      case GenerationStatus.compositingProduct:
      case GenerationStatus.qualityChecking:
        return 'Hazırlanıyor';
      case GenerationStatus.completed:
        return 'Tamamlandı';
      case GenerationStatus.failed:
        return 'Başarısız';
      case GenerationStatus.cancelled:
        return 'İptal edildi';
    }
  }
}

@freezed
class GenerationOutput with _$GenerationOutput {
  const factory GenerationOutput({
    @JsonKey(name: 'file_url') required String fileUrl,
    @JsonKey(name: 'thumbnail_url') required String thumbnailUrl,
    int? width,
    int? height,
  }) = _GenerationOutput;

  factory GenerationOutput.fromJson(Map<String, dynamic> json) =>
      _$GenerationOutputFromJson(json);
}

@freezed
class Generation with _$Generation {
  const factory Generation({
    required String id,
    @JsonKey(name: 'company_id') required String companyId,
    String? productId,
    required String generationMode, // template | reference
    @JsonKey(name: 'generation_type') required String generationType, // image | video
    required GenerationStatus status,
    @JsonKey(name: 'error_message') String? errorMessage,
    @Default(<GenerationOutput>[])
    @JsonKey(name: 'output_urls')
    List<GenerationOutput> outputUrls,
    @JsonKey(name: 'credit_cost') @Default(1) int creditCost,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Generation;

  factory Generation.fromJson(Map<String, dynamic> json) =>
      _$GenerationFromJson(json);
}
