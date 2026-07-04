// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GenerationOutputImpl _$$GenerationOutputImplFromJson(
        Map<String, dynamic> json) =>
    _$GenerationOutputImpl(
      fileUrl: json['file_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$GenerationOutputImplToJson(
        _$GenerationOutputImpl instance) =>
    <String, dynamic>{
      'file_url': instance.fileUrl,
      'thumbnail_url': instance.thumbnailUrl,
      'width': instance.width,
      'height': instance.height,
    };

_$GenerationImpl _$$GenerationImplFromJson(Map<String, dynamic> json) =>
    _$GenerationImpl(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      productId: json['product_id'] as String?,
      generationMode: json['generation_mode'] as String,
      generationType: json['generation_type'] as String,
      status: $enumDecode(_$GenerationStatusEnumMap, json['status']),
      errorMessage: json['error_message'] as String?,
      outputUrls: (json['output_urls'] as List<dynamic>?)
              ?.map((e) => GenerationOutput.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <GenerationOutput>[],
      creditCost: (json['credit_cost'] as num?)?.toInt() ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$GenerationImplToJson(_$GenerationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'company_id': instance.companyId,
      'product_id': instance.productId,
      'generation_mode': instance.generationMode,
      'generation_type': instance.generationType,
      'status': _$GenerationStatusEnumMap[instance.status]!,
      'error_message': instance.errorMessage,
      'output_urls': instance.outputUrls,
      'credit_cost': instance.creditCost,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$GenerationStatusEnumMap = {
  GenerationStatus.pending: 'pending',
  GenerationStatus.queued: 'queued',
  GenerationStatus.processing: 'processing',
  GenerationStatus.analyzingProduct: 'analyzing_product',
  GenerationStatus.removingBackground: 'removing_background',
  GenerationStatus.generatingScene: 'generating_scene',
  GenerationStatus.compositingProduct: 'compositing_product',
  GenerationStatus.qualityChecking: 'quality_checking',
  GenerationStatus.completed: 'completed',
  GenerationStatus.failed: 'failed',
  GenerationStatus.cancelled: 'cancelled',
};
