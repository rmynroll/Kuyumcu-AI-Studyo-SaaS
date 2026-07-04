import 'package:flutter/material.dart';

/// Kuyumcu AI Stüdyo marka paleti.
///
/// Felsefe: lüks kuyumcu markasına yakışan, sade ve az sayıda renk.
/// Kuyumcu kullanıcı teknoloji seviyesi düşük kabul edildiği için
/// arayüzde çok renk yerine yüksek kontrast + tek vurgu rengi (altın) kullanılır.
class AppColors {
  AppColors._();

  // Zemin
  static const Color background = Color(0xFF0B0B0C); // neredeyse siyah, kadife hissi
  static const Color surface = Color(0xFF17161A); // kart zemini
  static const Color surfaceElevated = Color(0xFF221F24);

  // Altın vurgu tonları
  static const Color gold = Color(0xFFD4AF37); // klasik altın
  static const Color goldLight = Color(0xFFF1D98B);
  static const Color goldDark = Color(0xFF9C7A24);

  // Metin
  static const Color textPrimary = Color(0xFFF5F1E8); // sıcak beyaz (fildişi)
  static const Color textSecondary = Color(0xFFB8B2A7);
  static const Color textOnGold = Color(0xFF16130A);

  // Durum renkleri (sade, teknik olmayan mesajlarla birlikte kullanılır)
  static const Color success = Color(0xFF3FA66B);
  static const Color warning = Color(0xFFE0A93A);
  static const Color error = Color(0xFFD9534F);

  // Kenarlık / ayraç
  static const Color divider = Color(0xFF2A2830);

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, gold, goldDark],
  );
}
