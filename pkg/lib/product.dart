import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kuyumcu AI Stüdyosu bünyesindeki bir ürünü temsil eden model.
/// results_gallery_screen.dart içerisindeki JewelryItem sınıfının
/// tüm projede kullanılabilir hale getirilmiş ve 3D alanları eklenmiş halidir.
class Product {
  final String id;
  final String title;
  final String imageUrl;
  final String originalImageUrl;
  final String status; // 'completed', 'processing', 'failed'
  final DateTime date;
  final int qaScore;
  final bool isRefunded;
  
  // 3D model alanları
  final String? glbUrl; // 3D model dosyası URL'si
  final String? usdzUrl; // iOS Quick Look için (opsiyonel)

  Product({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.originalImageUrl,
    required this.status,
    required this.date,
    this.qaScore = 100,
    this.isRefunded = false,
    this.glbUrl,
    this.usdzUrl,
  });

  Product copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? originalImageUrl,
    String? status,
    DateTime? date,
    int? qaScore,
    bool? isRefunded,
    String? glbUrl,
    String? usdzUrl,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      originalImageUrl: originalImageUrl ?? this.originalImageUrl,
      status: status ?? this.status,
      date: date ?? this.date,
      qaScore: qaScore ?? this.qaScore,
      isRefunded: isRefunded ?? this.isRefunded,
      glbUrl: glbUrl ?? this.glbUrl,
      usdzUrl: usdzUrl ?? this.usdzUrl,
    );
  }
}

/// Uygulamadaki ürünlerin (JewelryItem / Product) listesini yöneten
/// Riverpod StateNotifier. results_gallery_screen.dart içerisindeki
/// yerel state'in küreselleştirilmiş halidir.
class ProductsNotifier extends StateNotifier<List<Product>> {
  ProductsNotifier() : super(_getInitialMockProducts());

  static List<Product> _getInitialMockProducts() {
    final now = DateTime.now();
    return [
      Product(
        id: '1',
        title: 'Altın Yakut Yüzük',
        originalImageUrl: 'https://images.unsplash.com/photo-1598560917505-59a3ad559071?q=80&w=400&auto=format&fit=crop',
        imageUrl: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?q=80&w=400&auto=format&fit=crop',
        status: 'completed',
        date: now.subtract(const Duration(hours: 1)),
        qaScore: 100,
        isRefunded: false,
        // Gerçekçi 3D Altın Yüzük GLB modeli
        glbUrl: 'https://raw.githubusercontent.com/AbdallahMuhammad2/provador-ajorsul/main/working-ring-7.glb',
      ),
      Product(
        id: '2',
        title: 'Elmas Baget Yüzük',
        originalImageUrl: 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?q=80&w=400&auto=format&fit=crop',
        imageUrl: 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?q=80&w=400&auto=format&fit=crop',
        status: 'completed',
        date: now.subtract(const Duration(hours: 4)),
        qaScore: 82,
        isRefunded: true,
        glbUrl: 'https://raw.githubusercontent.com/AbdallahMuhammad2/provador-ajorsul/main/working-ring-7.glb',
      ),
      Product(
        id: '3',
        title: 'Kuyumcu Gerdanlık',
        originalImageUrl: 'https://images.unsplash.com/photo-1611085583191-a3b1a3a355db?q=80&w=400&auto=format&fit=crop',
        imageUrl: 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=400&auto=format&fit=crop',
        status: 'completed',
        date: now.subtract(const Duration(days: 1)),
        qaScore: 98,
        isRefunded: false,
        glbUrl: 'https://raw.githubusercontent.com/AbdallahMuhammad2/provador-ajorsul/main/working-ring-7.glb',
      ),
      Product(
        id: '4',
        title: 'Safir Taş Kolye',
        originalImageUrl: 'https://images.unsplash.com/photo-1617038260897-41a1f14a8ca0?q=80&w=400&auto=format&fit=crop',
        imageUrl: 'https://images.unsplash.com/photo-1617038260897-41a1f14a8ca0?q=80&w=400&auto=format&fit=crop',
        status: 'processing',
        date: now,
        qaScore: 0,
        isRefunded: false,
      ),
      Product(
        id: '5',
        title: 'Altın Zincir Bileklik',
        originalImageUrl: 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?q=80&w=400&auto=format&fit=crop',
        imageUrl: 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?q=80&w=400&auto=format&fit=crop',
        status: 'failed',
        date: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  /// Seçilen ürünleri listeden kaldırır (Görselleri Sil işlemi)
  void deleteProducts(List<String> ids) {
    state = state.where((p) => !ids.contains(p.id)).toList();
  }

  /// Mevcut bir ürünü günceller (örn. QA iadesi durumunda isRefunded set etmek için)
  void updateProduct(Product updatedProduct) {
    state = [
      for (final product in state)
        if (product.id == updatedProduct.id) updatedProduct else product
    ];
  }

  /// Yeni üretilen ürünü galeriye ekler
  void addProduct(Product product) {
    if (state.any((p) => p.id == product.id)) return;
    state = [product, ...state];
  }
}

/// Global products provider
final productsProvider = StateNotifierProvider<ProductsNotifier, List<Product>>((ref) {
  return ProductsNotifier();
});
