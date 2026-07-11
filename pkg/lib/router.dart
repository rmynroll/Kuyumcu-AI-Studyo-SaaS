import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kuyumcu_flutter/generation_mode_selection_screen.dart';
import 'package:kuyumcu_flutter/generation_progress_screen.dart';
import 'package:kuyumcu_flutter/main_navigation_screen.dart';
import 'package:kuyumcu_flutter/comparison_screen.dart';
import 'package:kuyumcu_flutter/qa_panel_screen.dart';
import 'package:kuyumcu_flutter/inspiration_board_screen.dart';
import 'package:kuyumcu_flutter/collection_studio_screen.dart';
import 'package:kuyumcu_flutter/ring_sizer_screen.dart';
import 'package:kuyumcu_flutter/customer_mirror_screen.dart';
import 'package:kuyumcu_flutter/performance_pocket_screen.dart';
import 'package:kuyumcu_flutter/brand_kit_screen.dart';
import 'package:kuyumcu_flutter/campaign_cards_screen.dart';
import 'package:kuyumcu_flutter/subscription_screen.dart';
import 'package:kuyumcu_flutter/campaign_calendar_screen.dart';
import 'package:kuyumcu_flutter/shared_product_view_screen.dart';
import 'package:kuyumcu_flutter/gold_tracking_screen.dart';
import 'package:kuyumcu_flutter/product_upload_screen.dart';
import 'package:kuyumcu_flutter/company_details_screen.dart';
import 'package:kuyumcu_flutter/notification_preferences_screen.dart';
import 'package:kuyumcu_flutter/security_screen.dart';
import 'package:kuyumcu_flutter/api_keys_screen.dart';
import 'package:kuyumcu_flutter/support_help_screen.dart';
import 'package:kuyumcu_flutter/about_screen.dart';
import 'package:kuyumcu_flutter/product_3d_viewer_screen.dart';

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
        builder: (context, state) => const MainNavigationScreen(),
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
      GoRoute(
        path: '/comparison',
        builder: (context, state) {
          final before = state.uri.queryParameters['before'] ?? '';
          final after = state.uri.queryParameters['after'] ?? '';
          final title = state.uri.queryParameters['title'] ?? 'Ürün Kıyaslama';
          return ComparisonScreen(
            beforeImageUrl: before,
            afterImageUrl: after,
            productTitle: title,
          );
        },
      ),
      GoRoute(
        path: '/results/:id',
        builder: (context, state) => QaPanelScreen(
          generationId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/generation/inspiration',
        builder: (context, state) {
          final tabStr = state.uri.queryParameters['tab'];
          final initialTab = tabStr != null ? int.tryParse(tabStr) : null;
          final prompt = state.uri.queryParameters['prompt'];
          return InspirationBoardScreen(
            initialTab: initialTab,
            initialPrompt: prompt,
          );
        },
      ),
      GoRoute(
        path: '/generation/collection',
        builder: (context, state) => const CollectionStudioScreen(),
      ),
      GoRoute(
        path: '/premium/ring-sizer',
        builder: (context, state) {
          final client = state.uri.queryParameters['client'] == '1';
          return RingSizerScreen(isClientMode: client);
        },
      ),
      GoRoute(
        path: '/shared-product-view',
        builder: (context, state) {
          final imageUrl = state.uri.queryParameters['imageUrl'] ?? '';
          final title = state.uri.queryParameters['title'] ?? '';
          final price = state.uri.queryParameters['price'] ?? '14.990 TL';
          final ar = state.uri.queryParameters['ar'] == '1';
          final sizer = state.uri.queryParameters['sizer'] == '1';
          return SharedProductViewScreen(
            imageUrl: imageUrl,
            productTitle: title,
            price: price,
            include3D: ar,
            includeSizer: sizer,
          );
        },
      ),
      GoRoute(
        path: '/premium/customer-mirror',
        builder: (context, state) {
          final title = state.uri.queryParameters['title'] ?? '';
          final imageUrl = state.uri.queryParameters['imageUrl'] ?? '';
          return CustomerMirrorScreen(
            productTitle: title,
            productImageUrl: imageUrl,
          );
        },
      ),
      GoRoute(
        path: '/premium/performance',
        builder: (context, state) => const PerformancePocketScreen(),
      ),
      GoRoute(
        path: '/premium/brand-kit',
        builder: (context, state) => const BrandKitScreen(),
      ),
      GoRoute(
        path: '/premium/campaign',
        builder: (context, state) {
          final imageUrl = state.uri.queryParameters['imageUrl'] ?? '';
          return CampaignCardsScreen(productImageUrl: imageUrl);
        },
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/premium/calendar',
        builder: (context, state) => const CampaignCalendarScreen(),
      ),
      GoRoute(
        path: '/premium/gold-tracking',
        builder: (context, state) => const GoldTrackingScreen(),
      ),
      GoRoute(
        path: '/premium/company-details',
        builder: (context, state) => const CompanyDetailsScreen(),
      ),
      GoRoute(
        path: '/premium/notification-preferences',
        builder: (context, state) => const NotificationPreferencesScreen(),
      ),
      GoRoute(
        path: '/premium/security',
        builder: (context, state) => const SecurityScreen(),
      ),
      GoRoute(
        path: '/premium/api-keys',
        builder: (context, state) => const ApiKeysScreen(),
      ),
      GoRoute(
        path: '/premium/support',
        builder: (context, state) => const SupportHelpScreen(),
      ),
      GoRoute(
        path: '/premium/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/products/upload',
        builder: (context, state) => const ProductUploadScreen(),
      ),
      GoRoute(
        path: '/products/:id/3d',
        builder: (context, state) => Product3DViewerScreen(
          productId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/generation/template',
        builder: (context, state) {
          final prompt = state.uri.queryParameters['prompt'];
          return InspirationBoardScreen(
            initialTab: 0,
            initialPrompt: prompt,
          );
        },
      ),
      GoRoute(
        path: '/generation/reference',
        builder: (context, state) {
          final prompt = state.uri.queryParameters['prompt'];
          return InspirationBoardScreen(
            initialTab: 1,
            initialPrompt: prompt,
          );
        },
      ),
      // TODO: /results
    ],
  );
});
