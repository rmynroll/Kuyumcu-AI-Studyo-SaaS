
import 'package:dio/dio.dart';
import 'package:kuyumcu_flutter/api_client.dart';
import 'package:kuyumcu_flutter/logging_interceptors.dart';
/// Her isteğe `Authorization: Bearer <token>` header'ı ekler.
///
/// 401 (token süresi dolmuş) alındığında `refresh` endpoint'i ile tek
/// seferlik otomatik yenileme dener; başarısız olursa hatayı olduğu gibi
/// yukarı fırlatır (üst katman kullanıcıyı login'e yönlendirir).
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.storage,
    required this.refreshDio,
    required this.onSessionExpired,
  });

  final SecureStorageService storage;

  /// Refresh çağrısı için AYRI bir Dio instance'ı kullanılır ki
  /// ana client'taki interceptor zincirine (özellikle bu interceptor'a)
  /// tekrar takılıp sonsuz döngü oluşturmasın.
  final Dio refreshDio;

  /// Refresh de başarısız olduğunda çağrılır; UI katmanı bunu dinleyip
  /// kullanıcıyı login ekranına yönlendirebilir.
  final Future<void> Function() onSessionExpired;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra['retried'] == true;

    if (!isUnauthorized || alreadyRetried) {
      return handler.next(err);
    }

    try {
      final refreshToken = await storage.readRefreshToken();
      if (refreshToken == null) {
        await onSessionExpired();
        return handler.next(err);
      }

      final response = await refreshDio.post(
        ApiConstants.refresh,
        data: {'refresh_token': refreshToken},
      );

      final newAccessToken = response.data['access_token'] as String?;
      final newRefreshToken = response.data['refresh_token'] as String?;

      if (newAccessToken == null) {
        await onSessionExpired();
        return handler.next(err);
      }

      await storage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken ?? refreshToken,
      );

      // Orijinal isteği yeni token ile bir kez daha dener.
      final retryOptions = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newAccessToken'
        ..extra['retried'] = true;

      final retryResponse = await refreshDio.fetch(retryOptions);
      return handler.resolve(retryResponse);
    } catch (_) {
      await onSessionExpired();
      return handler.next(err);
    }
  }
}

extension on Object {
  bool get isNotEmpty => this is String && (this as String).isNotEmpty;
}
