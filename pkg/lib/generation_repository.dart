import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuyumcu_flutter/api_client.dart';
import 'package:kuyumcu_flutter/generation.dart';
import 'package:kuyumcu_flutter/api_constants.dart';
import 'package:kuyumcu_flutter/product.dart';

/// `/generations` endpoint'lerine dair tüm HTTP çağrılarını tek yerde toplar.
/// Demo ortamında (Go backend sunucusu yokken) uçtan uca akışı çalıştırmak için
/// yerel mock veritabanı ve durum ilerleme simülasyonu içerir.
class GenerationRepository {
  GenerationRepository(this._client, this._ref);

  final ApiClient _client;
  final Ref _ref;

  // Yerel mock veritabanı koleksiyonları
  static final Map<String, Generation> _localGenerations = {};
  static final Map<String, String> _generationBeforeUrls = {};
  static final Map<String, String> _generationStyleUrls = {};
  static final Map<String, String> _generationStyleNames = {};
  static final Map<String, String> _generationTitles = {};

  // Dışarıdan erişilebilir public getter'lar
  static Map<String, Generation> get localGenerations => _localGenerations;
  static Map<String, String> get generationBeforeUrls => _generationBeforeUrls;
  static Map<String, String> get generationTitles => _generationTitles;

  // Mock yakut yüzük görseli
  static const String _mockProductUrl = 'https://images.unsplash.com/photo-1598560917505-59a3ad559071?q=80&w=400&auto=format&fit=crop';
  
  // Şablon görsel URL'leri ve çıktıları eşlemesi (Demo yakut yüzük için)
  static final Map<String, String> _mockProductPresetOutputs = {
    // Lüks İtalyan (Boş mermer -> Gerçekçi yakut yüzük mermer üzerinde)
    'https://images.unsplash.com/photo-1533090161767-e6ffed986c88?q=80&w=400&auto=format&fit=crop': 
        'https://images.unsplash.com/photo-1605100804763-247f67b3557e?q=80&w=400&auto=format&fit=crop',
    // Doğal Gün Işığı (Boş taş/ahşap -> Gerçekçi yüzük model elinde)
    'https://images.unsplash.com/photo-1541123437800-1bb1317badc2?q=80&w=400&auto=format&fit=crop':
        'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?q=80&w=400&auto=format&fit=crop',
    // Siyah Kadife (Boş kadife -> Gerçekçi yüzük kadife kutuda)
    'https://images.unsplash.com/photo-1502239608882-93b729c6af43?q=80&w=400&auto=format&fit=crop':
        'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=400&auto=format&fit=crop',
  };

  // UI şablon ID'lerini görsel URL'lerine çevirir (varsayılan temiz fonlar)
  static final Map<String, String> _templateIdToStyleUrl = {
    'white_bg': 'https://images.unsplash.com/photo-1533090161767-e6ffed986c88?q=80&w=400&auto=format&fit=crop',
    'velvet_box': 'https://images.unsplash.com/photo-1502239608882-93b729c6af43?q=80&w=400&auto=format&fit=crop',
    'model_hand': 'https://images.unsplash.com/photo-1602751584552-8ba73aad10e1?q=80&w=400&auto=format&fit=crop',
    'white_background': 'https://images.unsplash.com/photo-1533090161767-e6ffed986c88?q=80&w=400&auto=format&fit=crop',
  };

  /// Hazır şablon modunda yeni üretim başlatır.
  Future<Generation> createFromTemplate({
    required String productId,
    required String templateId,
    int outputCount = 4,
    String aspectRatio = '1:1',
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Şablon URL'si belirle
    String styleUrl = templateId;
    if (_templateIdToStyleUrl.containsKey(templateId)) {
      styleUrl = _templateIdToStyleUrl[templateId]!;
    }

    // Şablon ismi belirle
    String styleName = 'Özel Şablon';
    if (templateId.contains('white_bg') || templateId.contains('white_background')) {
      styleName = 'Beyaz Fon';
    } else if (templateId.contains('velvet') || templateId.contains('velvet_box')) {
      styleName = 'Siyah Kadife';
    } else if (templateId.contains('model_hand') || templateId.contains('model')) {
      styleName = 'Manken Eli (Doğal)';
    } else if (templateId.contains('1605100804763')) {
      styleName = 'Lüks İtalyan';
    } else if (templateId.contains('1603561591411')) {
      styleName = 'Doğal Gün Işığı';
    } else if (templateId.contains('1599643478518')) {
      styleName = 'Siyah Kadife';
    }

    final gen = Generation(
      id: id,
      companyId: 'company_123',
      productId: productId,
      generationMode: 'template',
      generationType: 'image',
      status: GenerationStatus.pending,
      creditCost: 1,
      createdAt: DateTime.now(),
      outputUrls: const [],
    );

    _localGenerations[id] = gen;
    _generationBeforeUrls[id] = productId;
    _generationStyleUrls[id] = styleUrl;
    _generationStyleNames[id] = styleName;

    // Ürün başlığı oluştur
    String title = 'Özel Tasarım Takı';
    if (productId == _mockProductUrl) {
      title = 'Altın Yakut Yüzük';
    } else {
      title = 'Yeni Yüzük';
    }
    _generationTitles[id] = title;

    return gen;
  }

  /// Referans görsel modunda yeni üretim başlatır.
  Future<Generation> createFromReference({
    required String productId,
    required String referenceAnalysisId,
    int outputCount = 4,
    String aspectRatio = '1:1',
  }) async {
    return createFromTemplate(
      productId: productId,
      templateId: referenceAnalysisId,
      outputCount: outputCount,
      aspectRatio: aspectRatio,
    );
  }

  /// Tek bir generation'ın güncel durumunu getirir (polling servisi bunu çağırır).
  Future<Generation> getById(String id) async {
    final gen = _localGenerations[id];
    if (gen == null) {
      // Yerel listede yoksa, varsayılan bir tamamlanmış mock üret
      final fallbackGen = Generation(
        id: id,
        companyId: 'company_123',
        generationMode: 'template',
        generationType: 'image',
        status: GenerationStatus.completed,
        createdAt: DateTime.now(),
        outputUrls: const [
          GenerationOutput(
            fileUrl: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?q=80&w=400&auto=format&fit=crop',
            thumbnailUrl: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?q=80&w=400&auto=format&fit=crop',
          )
        ],
      );
      return fallbackGen;
    }

    // Polling esnasında geçen süreye göre durumları simüle et
    final elapsedMs = DateTime.now().difference(gen.createdAt).inMilliseconds;
    
    GenerationStatus currentStatus;
    if (elapsedMs < 1500) {
      currentStatus = GenerationStatus.removingBackground;
    } else if (elapsedMs < 3000) {
      currentStatus = GenerationStatus.generatingScene;
    } else if (elapsedMs < 4500) {
      currentStatus = GenerationStatus.compositingProduct;
    } else if (elapsedMs < 6000) {
      currentStatus = GenerationStatus.qualityChecking;
    } else {
      currentStatus = GenerationStatus.completed;
    }

    List<GenerationOutput> outputs = const [];
    if (currentStatus == GenerationStatus.completed) {
      final beforeUrl = _generationBeforeUrls[id] ?? '';
      final styleUrl = _generationStyleUrls[id] ?? '';
      
      String finalOutputUrl;
      if (beforeUrl == _mockProductUrl) {
        // Orijinal demo yüzüğü seçilmişse hazır pre-rendered görsele eşle
        finalOutputUrl = _mockProductPresetOutputs[styleUrl] ?? styleUrl;
      } else {
        // Kullanıcı kendi görselini yüklemişse dinamik stack kompozit etiketini yapıştır
        finalOutputUrl = 'composite:productUrl=${Uri.encodeComponent(beforeUrl)}&styleUrl=${Uri.encodeComponent(styleUrl)}';
      }

      outputs = [
        GenerationOutput(
          fileUrl: finalOutputUrl,
          thumbnailUrl: finalOutputUrl,
        )
      ];

      // Ürünü global galeri geçmişine ekle!
      final title = _generationTitles[id] ?? 'Yeni Tasarım';
      final newProduct = Product(
        id: id,
        title: title,
        originalImageUrl: beforeUrl,
        imageUrl: finalOutputUrl,
        status: 'completed',
        date: DateTime.now(),
        glbUrl: 'https://raw.githubusercontent.com/AbdallahMuhammad2/provador-ajorsul/main/working-ring-7.glb',
      );

      // Provider state güncellemesini microtask içine alarak frame hatasını önlüyoruz
      Future.microtask(() {
        _ref.read(productsProvider.notifier).addProduct(newProduct);
      });
    }

    final updatedGen = gen.copyWith(
      status: currentStatus,
      outputUrls: outputs,
    );
    _localGenerations[id] = updatedGen;
    return updatedGen;
  }

  /// "Sonuçlarım" ekranı için üretim geçmişi.
  Future<List<Generation>> list() async {
    return _localGenerations.values.toList();
  }

  Future<Generation> retry(String id) async {
    final gen = _localGenerations[id];
    if (gen != null) {
      final retried = gen.copyWith(
        status: GenerationStatus.pending,
        createdAt: DateTime.now(),
      );
      _localGenerations[id] = retried;
      return retried;
    }
    return getById(id);
  }

  Future<void> sendFeedback(String id, String feedbackCode) async {
    return;
  }
}

final generationRepositoryProvider = Provider<GenerationRepository>((ref) {
  return GenerationRepository(ref.watch(apiClientProvider), ref);
});
