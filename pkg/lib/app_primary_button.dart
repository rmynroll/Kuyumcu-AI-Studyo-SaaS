/// Feature katmanlarının UI'a döndüreceği, teknik detaydan arındırılmış hata tipi.
///
/// `ApiException` (core/network) ham hatayı taşırken, `Failure` bunu
/// ekranda doğrudan gösterilebilecek sade bir mesaja indirger.
class Failure {
  const Failure({
    required this.message,
    this.code,
    this.isRetryable = true,
  });

  /// Kullanıcıya gösterilecek, teknik terim içermeyen mesaj.
  /// Örn: "Fotoğraf bulanık, tekrar çekelim."
  final String message;

  /// Backend'den gelen makine-okunur hata kodu (varsa), log/analytics için.
  final String? code;

  /// Kullanıcıya "Tekrar Dene" butonu gösterilip gösterilmeyeceği.
  final bool isRetryable;

  factory Failure.generic() => const Failure(
        message: 'Bir şeyler ters gitti, tekrar dener misin?',
      );
}
