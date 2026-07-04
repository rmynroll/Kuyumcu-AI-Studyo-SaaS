

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuyumcu_flutter/api_exception.dart';
import 'package:kuyumcu_flutter/auth_interceptor.dart';
import 'package:kuyumcu_flutter/logging_interceptor.dart';
import 'package:kuyumcu_flutter/logging_interceptors.dart';



/// Go backend API'sine bağlanan tek merkezi Dio istemcisi.
///
/// Tüm feature repository'leri (products, generations, auth vb.) HTTP
/// çağrılarını doğrudan `Dio` ile değil, bu sınıf üzerinden yapar; böylece
/// base URL, timeout, auth ve hata dönüşümü tek yerde yönetilir.
class ApiClient {
  ApiClient({required this.storage}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: const {'Accept': 'application/json'},
        // 401'i burada exception fırlatmadan interceptor'a taşıyabilmek için
        // Dio'nun kendi validateStatus'unu kullanıyoruz.
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Refresh çağrıları için ayrı, interceptor'sız bir Dio (bkz. AuthInterceptor).
    final refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(
        storage: storage,
        refreshDio: refreshDio,
        onSessionExpired: () async {
          await storage.clear();
          _sessionExpiredController.add(null);
        },
      ),
      ErrorInterceptor(),
      LoggingInterceptor(),
    ]);
  }

  final SecureStorageService storage;
  late final Dio _dio;

  /// UI katmanının dinleyip kullanıcıyı login ekranına yönlendirebileceği
  /// basit bir yayın kanalı (router'daki redirect guard'ı bunu dinler).
  final _sessionExpiredController = StreamController<void>.broadcast();
  Stream<void> get onSessionExpired => _sessionExpiredController.stream;

  Dio get raw => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _guard(() => _dio.get<T>(path, queryParameters: queryParameters));
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _guard(
      () => _dio.post<T>(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<Response<T>> patch<T>(String path, {Object? data}) {
    return _guard(() => _dio.patch<T>(path, data: data));
  }

  Future<Response<T>> delete<T>(String path) {
    return _guard(() => _dio.delete<T>(path));
  }

  /// Ürün/referans görsel yükleme gibi multipart form-data istekleri için.
  Future<Response<T>> uploadFile<T>(
    String path, {
    required String filePath,
    required String fileFieldName,
    Map<String, dynamic>? fields,
    void Function(int sent, int total)? onSendProgress,
  }) {
    return _guard(() async {
      final formData = FormData.fromMap({
        ...?fields,
        fileFieldName: await MultipartFile.fromFile(filePath),
      });
      return _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
    });
  }

  /// Dio'dan gelen hatayı daima `ApiException` olarak fırlatır; repository
  /// katmanı `try/catch (ApiException e)` dışında bir tip görmez.
  Future<Response<T>> _guard<T>(Future<Response<T>> Function() call) async {
    try {
      final response = await call();
      // validateStatus < 500 olduğundan 4xx'ler burada da elden geçirilmeli.
      if (response.statusCode != null && response.statusCode! >= 400) {
        throw ApiException.fromDioException(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
          ),
        );
      }
      return response;
    } on DioException catch (e) {
      final error = e.error;
      if (error is ApiException) throw error;
      throw ApiException.fromDioException(e);
    }
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Let other interceptors or callers handle the error; keep signature
    // compatible with Dio's Interceptor so it can be added to interceptors list.
    handler.next(err);
  }
}

class SecureStorageService {
  Future<void> clear() async {}

  Future<Object?> readAccessToken() async {}

  Future<void> saveTokens({required String accessToken, required refreshToken}) async {}

  Future<Object?> readRefreshToken() async {}
}

/// Uygulama genelinde tek bir `ApiClient` örneği paylaşılır.
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = SecureStorageService();
  return ApiClient(storage: storage);
});
