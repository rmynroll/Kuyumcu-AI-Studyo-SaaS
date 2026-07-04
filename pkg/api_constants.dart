import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/generation/presentation/generation_mode_selection_screen.dart';
import '../features/generation/presentation/generation_progress_screen.dart';
import '../features/home/presentation/dashboard_screen.dart';

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
