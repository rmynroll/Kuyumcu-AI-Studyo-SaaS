import 'package:meta/meta.dart';

/// Backend `template_categories` tablosuyla birebir eşleşir
/// (bkz. internal/database/migrations/0004_templates.sql).
@immutable
class TemplateCategory {
  final String id;
  final String key; // 'basic' | 'model_presentation' | 'social_media'
  final String label; // "Temel Çekimler"

  const TemplateCategory({
    required this.id,
    required this.key,
    required this.label,
  });

  factory TemplateCategory.fromJson(Map<String, dynamic> json) =>
      TemplateCategory(
        id: json['id'] as String,
        key: json['key'] as String,
        label: json['label'] as String,
      );
}

/// Backend `templates` tablosuyla birebir eşleşir.
@immutable
class JewelryTemplate {
  final String id;
  final String categoryId;
  final String key;
  final String label;
  final String previewImageUrl;
  final String aspectRatio;
  final bool requiresModelPresentation;

  const JewelryTemplate({
    required this.id,
    required this.categoryId,
    required this.key,
    required this.label,
    required this.previewImageUrl,
    required this.aspectRatio,
    this.requiresModelPresentation = false,
  });

  factory JewelryTemplate.fromJson(Map<String, dynamic> json) =>
      JewelryTemplate(
        id: json['id'] as String,
        categoryId: json['category_id'] as String,
        key: json['key'] as String,
        label: json['label'] as String,
        previewImageUrl: json['preview_image_url'] as String,
        aspectRatio: json['aspect_ratio'] as String,
        requiresModelPresentation:
            (json['requires_model_presentation'] as bool?) ?? false,
      );

  /// Kullanıcıya üretim öncesi gösterilecek kredi rozeti metni.
  /// Gerçek kredi maliyeti backend'de hesaplanır (bkz. pricing.go);
  /// burada sadece kullanıcı bekleneni önceden görsün diye tahmini
  /// gösteriyoruz.
  String get creditBadgeLabel =>
      requiresModelPresentation ? '3 kredi' : '1 kredi';
}