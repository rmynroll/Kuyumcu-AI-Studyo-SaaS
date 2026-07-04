import 'dart:convert';
import 'package:http/http.dart' as http;

class ModelGenerationService {
  // Go sunucumuzun çalıştığı ana adres (Gerekirse kendi portuna göre güncelle)
  final String _baseUrl = 'http://localhost:8080/api/ai';

  /// Seçilen şablon ve yüklenen görseli Go backend'ine iletir
  Future<String?> generateWithModel({
    required String imageUrl,
    required String templateId,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/generate-model');
      
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_image_url': imageUrl,
          'template_id': templateId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Go'dan dönen, mankene giydirilmiş yeni ürün görselinin linki
        return data['generated_url']; 
      } else {
        print('API Hatası: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('AI Üretim servisine ulaşılamadı: $e');
      return null;
    }
  }
}
