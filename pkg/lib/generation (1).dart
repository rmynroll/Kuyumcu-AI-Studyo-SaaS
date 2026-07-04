import 'package:dio/dio.dart';

/// Backend'den veya ağdan gelen ham hatayı, arayüzde doğrudan
/// gösterilebilecek **teknik terim içermeyen** bir mesaja çevirir.
///
/// Backend'in `error.code` alanıyla dönmesi beklenen örnek sözleşme:
/// ```json
/// { "success": false, "error": { "code": "INSUFFICIENT_CREDIT", "message": "..." } }
/// ```
/// Kod bilinmiyorsa HTTP durum koduna göre genel bir mesaj üretilir.
class ApiException implements Exception {
  const ApiException({
    required this.userMessage,
    this.code,
    this.statusCode,
    this.isRetryable = true,
  });

  final String userMessage;
  final String? code;
  final int? statusCode;
  final bool isRetryable;

  @override
  String toString() => 'ApiException(code: $code, message: $userMessage)';

  factory ApiException.fromDioException(DioException e) {
    // Ağ bağlantısı yok / zaman aşımı
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const ApiException(
        userMessage: 'Bağlantı çok yavaş. İnternetini kontrol edip tekrar dener misin?',
        isRetryable: true,
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      return const ApiException(
        userMessage: 'İnternet bağlantısı bulunamadı.',
        isRetryable: true,
      );
    }

    final statusCode = e.response?.statusCode;
    final backendCode = _extractBackendCode(e.response?.data);

    // Backend'in gönderdiği bilinen iş kodları öncelikli
    final knownMessage = _messageForCode(backendCode);
    if (knownMessage != null) {
      return ApiException(
        userMessage: knownMessage,
        code: backendCode,
        statusCode: statusCode,
        isRetryable: backendCode != 'INSUFFICIENT_CREDIT',
      );
    }

    // Bilinmeyen kod → HTTP durum koduna göre genel sade mesaj
    return ApiException(
      userMessage: _messageForStatusCode(statusCode),
      code: backendCode,
      statusCode: statusCode,
      isRetryable: statusCode == null || statusCode >= 500,
    );
  }

  static String? _extractBackendCode(dynamic data) {
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        return error['code'] as String?;
      }
    }
    return null;
  }

  /// Bilinen iş kodları → sade, teknik olmayan Türkçe kullanıcı mesajı.
  /// Kaynak: teknik dokümandaki "Hata Senaryoları ve Kalite Kontrol" tablosu.
  static String? _messageForCode(String? code) {
    switch (code) {
      case 'INSUFFICIENT_CREDIT':
        return 'Kredin kalmadı. Devam etmek için paketini yükseltebilirsin.';
      case 'IMAGE_TOO_BLURRY':
        return 'Fotoğraf bulanık görünüyor. Daha net bir çekimle tekrar dener misin?';
      case 'AI_GENERATION_FAILED':
        return 'Görsel oluşturulamadı. Kredin iade edildi, tekrar deneyebilirsin.';
      case 'PRODUCT_INTEGRITY_BROKEN':
        return 'Sonuç ürününe tam benzemedi. Geri bildirim gönderip tekrar deneyebilirsin.';
      case 'REFERENCE_IMAGE_UNSUITABLE':
        return 'Bu örnek görselden stil çıkaramadık. Başka bir örnek dener misin?';
      case 'VIDEO_PROCESSING_TIMEOUT':
        return 'Video biraz uzun sürüyor, arka planda devam ediyor. Bildirim geldiğinde haber vereceğiz.';
      case 'UNAUTHORIZED':
      case 'TOKEN_EXPIRED':
        return 'Oturumun sona ermiş. Tekrar giriş yapar mısın?';
      case 'VALIDATION_ERROR':
        return 'Girdiğin bilgilerde eksik ya da hatalı bir şey var.';
      default:
        return null;
    }
  }

  static String _messageForStatusCode(int? statusCode) {
    if (statusCode == null) {
      return 'Bir şeyler ters gitti, tekrar dener misin?';
    }
    if (statusCode == 401) {
      return 'Oturumun sona ermiş. Tekrar giriş yapar mısın?';
    }
    if (statusCode == 403) {
      return 'Bu işlem için yetkin yok.';
    }
    if (statusCode == 404) {
      return 'Aradığımız kayıt bulunamadı.';
    }
    if (statusCode == 422) {
      return 'Girdiğin bilgilerde eksik ya da hatalı bir şey var.';
    }
    if (statusCode >= 500) {
      return 'Sistemimizde geçici bir sorun oldu. Birazdan tekrar dener misin?';
    }
    return 'Bir şeyler ters gitti, tekrar dener misin?';
  }
}
