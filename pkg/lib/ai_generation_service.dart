import 'dart:io';
import 'package:http/http.dart' as http;

class AiGenerationService {
  // Emülatörden bilgisayarın localhost'una erişmek için 10.0.2.2 kullanılır.
  final String _baseUrl = 'http://10.0.2.2:8080/api/ai';

  /// Fotoğrafı ve promptu Go sunucusuna gönderir
  Future<bool> generateImage(File imageFile, String customPrompt) async {
    try {
      var uri = Uri.parse('$_baseUrl/upload'); 
      var request = http.MultipartRequest('POST', uri);
      
      // Prompt ve şablon bilgilerini ekle
      request.fields['prompt'] = customPrompt;
      request.fields['template_id'] = 'white_background'; // Şimdilik varsayılan
      
      // Fiziksel fotoğraf dosyasını isteğe ekle
      var pic = await http.MultipartFile.fromPath('product_image', imageFile.path);
      request.files.add(pic);

      // İsteği Go sunucusuna gönder
      var response = await request.send();

      if (response.statusCode == 200) {
        return true; // İşlem başarılı
      } else {
        print('Sunucu Hatası: ${response.statusCode}');
        return false; // İşlem başarısız
      }
    } catch (e) {
      print('İstek atılırken hata oluştu: $e');
      return false;
    }
  }
}