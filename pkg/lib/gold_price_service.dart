import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoldPriceData {
  final double gramAltin;
  final double gramHasAltin;
  final double ceyrekAltin;
  final double yarimAltin;
  final double tamAltin;
  final double cumhuriyetAltini;
  final double ataAltin;
  final double ayar14;
  final double ayar18;
  final double ayar22;
  final DateTime updateDate;

  GoldPriceData({
    required this.gramAltin,
    required this.gramHasAltin,
    required this.ceyrekAltin,
    required this.yarimAltin,
    required this.tamAltin,
    required this.cumhuriyetAltini,
    required this.ataAltin,
    required this.ayar14,
    required this.ayar18,
    required this.ayar22,
    required this.updateDate,
  });

  factory GoldPriceData.fromJson(Map<String, dynamic> json) {
    double parsePrice(dynamic value) {
      if (value == null) return 0.0;
      final salePrice = value['Satış']?.toString() ?? '0';
      // Normalize Turkish number formats: e.g. "6.192,11" -> "6192.11"
      final normalized = salePrice.replaceAll('.', '').replaceAll(',', '.');
      return double.tryParse(normalized) ?? 0.0;
    }

    DateTime parseDate(String? dateStr) {
      if (dateStr == null) return DateTime.now();
      try {
        return DateTime.parse(dateStr);
      } catch (_) {
        return DateTime.now();
      }
    }

    return GoldPriceData(
      gramAltin: parsePrice(json['gram-altin']),
      gramHasAltin: parsePrice(json['gram-has-altin']),
      ceyrekAltin: parsePrice(json['ceyrek-altin']),
      yarimAltin: parsePrice(json['yarim-altin']),
      tamAltin: parsePrice(json['tam-altin']),
      cumhuriyetAltini: parsePrice(json['cumhuriyet-altini']),
      ataAltin: parsePrice(json['ata-altin']),
      ayar14: parsePrice(json['14-ayar-altin']),
      ayar18: parsePrice(json['18-ayar-altin']),
      ayar22: parsePrice(json['22-ayar-bilezik']),
      updateDate: parseDate(json['Update_Date']?.toString()),
    );
  }

  double getRateByType(String key) {
    switch (key) {
      case 'gram-altin':
        return gramAltin;
      case 'gram-has-altin':
        return gramHasAltin;
      case '22-ayar-bilezik':
        return ayar22;
      case '18-ayar-altin':
        return ayar18;
      case '14-ayar-altin':
        return ayar14;
      case 'ceyrek-altin':
        return ceyrekAltin;
      default:
        return gramAltin;
    }
  }

  static String getGoldTypeName(String key) {
    switch (key) {
      case 'gram-altin':
        return 'Gram Altın (24 Ayar)';
      case 'gram-has-altin':
        return 'Has Altın (24 Ayar)';
      case '22-ayar-bilezik':
        return '22 Ayar Bilezik';
      case '18-ayar-altin':
        return '18 Ayar Altın';
      case '14-ayar-altin':
        return '14 Ayar Altın';
      case 'ceyrek-altin':
        return 'Çeyrek Altın';
      default:
        return 'Gram Altın';
    }
  }
}

class GoldPriceService {
  final Dio _dio = Dio();

  Future<GoldPriceData> fetchGoldPrices() async {
    try {
      final response = await _dio.get(
        'https://finans.truncgil.com/today.json',
        options: Options(
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return GoldPriceData.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Invalid response format');
    } catch (e) {
      // Fallback rate data if API is offline or restricted
      return GoldPriceData(
        gramAltin: 6192.11,
        gramHasAltin: 6161.15,
        ceyrekAltin: 10150.43,
        yarimAltin: 20300.86,
        tamAltin: 40477.56,
        cumhuriyetAltini: 41779.00,
        ataAltin: 41967.53,
        ayar14: 3538.68,
        ayar18: 4532.00,
        ayar22: 5661.89,
        updateDate: DateTime.now(),
      );
    }
  }
}

final goldPriceServiceProvider = Provider((ref) => GoldPriceService());

final goldPriceProvider = FutureProvider<GoldPriceData>((ref) async {
  final service = ref.watch(goldPriceServiceProvider);
  return service.fetchGoldPrices();
});
