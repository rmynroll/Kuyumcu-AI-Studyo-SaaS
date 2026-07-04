import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuyumcu_flutter/api_client.dart';
import 'package:kuyumcu_flutter/logging_interceptors.dart';
import 'package:kuyumcu_flutter/template.dart';



/// `/templates` ve `/templates/categories` endpoint'lerine dair tüm HTTP
/// çağrılarını tek yerde toplar (bkz. internal/database/migrations/
/// 0004_templates.sql).
class TemplateRepository {
  TemplateRepository(this._client);

  final ApiClient _client;

  Future<List<TemplateCategory>> getCategories() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.templateCategories!,
    );
    final items = response.data!['data'] as List<dynamic>;
    return items
        .map((e) => TemplateCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<JewelryTemplate>> getTemplatesByCategory(String categoryId) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.templatesByCategory(categoryId),
    );
    final items = response.data!['data'] as List<dynamic>;
    return items
        .map((e) => JewelryTemplate.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  return TemplateRepository(ref.watch(apiClientProvider));
});

/// Kategori listesi — nadiren değişir, `autoDispose` yerine kalıcı
/// tutulur ki her ekrana girişte tekrar tekrar sorgulanmasın.
final templateCategoriesProvider =
    FutureProvider<List<TemplateCategory>>((ref) async {
  return ref.watch(templateRepositoryProvider).getCategories();
});

/// Kategori bazlı şablon listesi. `family` ile her kategori kendi
/// önbelleğinde tutulur (TabBarView'daki sekmeler arasında geçişte
/// tekrar network isteği atılmaz).
final templatesByCategoryProvider =
    FutureProvider.family<List<JewelryTemplate>, String>((ref, categoryId) async {
  return ref.watch(templateRepositoryProvider).getTemplatesByCategory(categoryId);
});