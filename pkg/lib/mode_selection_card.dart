import 'package:dio/dio.dart';
import '../../api_exception.dart';

/// Ham `DioException`'ı, uygulamanın her yerinde tutarlı biçimde
/// kullanılan `ApiException`'a (sade, kuyumcu-dostu mesajlı) çevirir.
///
/// Böylece repository/provider katmanları `DioException` detaylarıyla
/// hiç uğraşmaz; her zaman `error.userMessage`'ı doğrudan ekranda gösterir.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = ApiException.fromDioException(err);
    handler.next(
      err.copyWith(error: apiException),
    );
  }
}
