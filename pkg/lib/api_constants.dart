
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kuyumcu_flutter/dashboard_screen.dart';
import 'package:kuyumcu_flutter/generation_mode_selection_screen.dart';
import 'package:kuyumcu_flutter/generation_progress_screen.dart';

/// Uygulamanın tüm route'ları tek yerde tanımlanır.
///
/// Not: `products/upload`, `generation/template`, `generation/reference`
/// ve `results` ekranları bu teslimatın kapsamı dışında (bu adımda yalnızca
/// dashboard, mod seçimi ve üretim ilerleme ekranları teslim edildi);
/// bu route'lar placeholder olarak bırakıldı, ilgili feature'lar eklenince
/// `builder` alanları doldurulmalı.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/generation/mode',
        builder: (context, state) => const GenerationModeSelectionScreen(),
      ),
      GoRoute(
        path: '/generation/progress/:id',
        builder: (context, state) => GenerationProgressScreen(
          generationId: state.pathParameters['id']!,
        ),
      ),
      // TODO: /products/upload
      // TODO: /generation/template
      // TODO: /generation/reference
      // TODO: /results ve /results/:id
    ],
  );
});
/// Go backend API'sine dair sabitler.
///
/// Base URL derleme zamanında `--dart-define=API_BASE_URL=...` ile
/// override edilebilir; verilmezse local geliştirme adresine düşer.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.kuyumcuaistudio.com',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String me = '/users/me';

  // Products
  static const String products = '/products';

  // Templates
  static const String templates = '/templates';
  static const String templateCategories = '/templates/categories';
  static String templatesByCategory(String categoryId) => '/templates?category_id=$categoryId';

  // Reference analyses
  static const String referenceAnalyses = '/reference-analyses';

  // Generations
  static const String generations = '/generations';
  static String generationById(String id) => '/generations/$id';
  static String generationRetry(String id) => '/generations/$id/retry';
  static String generationFeedback(String id) => '/generations/$id/feedback';

  // Billing
  static const String plans = '/plans';
  static const String checkout = '/payments/checkout';
  static const String billingHistory = '/billing/history';

  /// Generation durumu polling aralığı (teknik dokümandaki MVP kararı: 3-5 sn).
  static const Duration generationPollInterval = Duration(seconds: 4);

  /// Bir generation'ın "asıldı" kabul edileceği ve kullanıcıya sade bir
  /// hata mesajı gösterileceği maksimum bekleme süresi.
  static const Duration generationPollTimeout = Duration(minutes: 3);
}