import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// JWT access/refresh token'larını platforma uygun güvenli depoda tutar.
///
/// `auth_interceptor.dart` bu servisi kullanarak her isteğe token ekler
/// ve 401 durumunda yenileme akışını tetikler.
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'kuyumcu_access_token';
  static const _refreshTokenKey = 'kuyumcu_refresh_token';

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);
  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
