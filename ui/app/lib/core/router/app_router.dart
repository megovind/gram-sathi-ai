import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/services/storage_service.dart';
import '../../presentation/screens/onboarding/language_selection_screen.dart';
import '../../presentation/screens/onboarding/phone_input_screen.dart';
import '../../presentation/screens/onboarding/welcome_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/health/health_screen.dart';
import '../../presentation/screens/health/nearby_screen.dart';
import '../../presentation/screens/commerce/shops_screen.dart';
import '../../presentation/screens/commerce/order_screen.dart';
import '../../presentation/screens/shop_owner/shop_dashboard_screen.dart';
import '../../presentation/screens/shop_owner/inventory_screen.dart';

class AppRoutes {
  static const languageSelection = '/';
  static const phoneInput = '/phone';
  static const welcome = '/welcome';
  static const home = '/home';
  static const health = '/health';
  static const nearby = '/health/nearby';
  static const shops = '/commerce/shops';
  static const order = '/commerce/order';
  static const shopDashboard = '/shop/dashboard';
  static const inventory = '/shop/inventory';
}

GoRouter buildRouter(StorageService storage) => GoRouter(
      initialLocation: AppRoutes.languageSelection,
      redirect: (context, state) {
        final loggedIn = storage.isLoggedIn;
        final onboardingPaths = {
          AppRoutes.languageSelection,
          AppRoutes.phoneInput,
          AppRoutes.welcome,
        };
        final isOnboarding = onboardingPaths.contains(state.matchedLocation);

        // Logged-in users skip onboarding unless explicitly changing language
        if (loggedIn && isOnboarding) {
          final changingLanguage = state.uri.queryParameters['change'] == '1';
          if (!changingLanguage) return AppRoutes.home;
        }

        // Unauthenticated users cannot access protected screens
        if (!loggedIn && !isOnboarding) return AppRoutes.languageSelection;

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.languageSelection,
          builder: (_, __) => const LanguageSelectionScreen(),
        ),
        GoRoute(
          path: AppRoutes.phoneInput,
          builder: (_, __) => const PhoneInputScreen(),
        ),
        GoRoute(
          path: AppRoutes.welcome,
          builder: (_, __) => const WelcomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.health,
          builder: (_, __) => const HealthScreen(),
        ),
        GoRoute(
          path: AppRoutes.nearby,
          builder: (_, __) => const NearbyScreen(),
        ),
        GoRoute(
          path: AppRoutes.shops,
          builder: (_, __) => const ShopsScreen(),
        ),
        GoRoute(
          path: AppRoutes.order,
          builder: (_, state) {
            final shopId = state.uri.queryParameters['shopId'] ?? '';
            return OrderScreen(shopId: shopId);
          },
        ),
        GoRoute(
          path: AppRoutes.shopDashboard,
          builder: (_, __) => const ShopDashboardScreen(),
        ),
        GoRoute(
          path: AppRoutes.inventory,
          builder: (_, state) {
            final shopId = state.uri.queryParameters['shopId'] ?? '';
            return InventoryScreen(shopId: shopId);
          },
        ),
      ],
    );
