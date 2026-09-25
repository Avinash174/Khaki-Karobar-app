import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/main/main_shell_screen.dart';
import '../features/sales/sales_screen.dart';
import '../features/sales/new_sale_screen.dart';
import '../features/purchases/purchases_screen.dart';
import '../features/inventory/inventory_screen.dart';
import '../features/customers/customers_screen.dart';
import '../features/suppliers/suppliers_screen.dart';
import '../features/payments/payments_screen.dart';
import '../features/ledger/ledger_screen.dart';
import '../features/reports/reports_screen.dart';
import '../features/more/more_screen.dart';
import '../features/settings/settings_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (_, __) => notifyListeners(),
    );
    _ref.listen<bool>(
      onboardingProvider,
      (_, __) => notifyListeners(),
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authProvider);
    final hasCompletedOnboarding = _ref.read(onboardingProvider);

    final location = state.matchedLocation;
    final isSplash = location == '/splash';
    final isOnboarding = location == '/onboarding';
    final isLogin = location == '/login';

    // 1. Always allow splash screen to render its startup flow
    if (isSplash) {
      return null;
    }

    // 2. Unauthenticated user flow
    if (!authState.isAuthenticated) {
      if (isOnboarding) {
        // If onboarding completed or after logout, onboarding must NOT appear again
        if (hasCompletedOnboarding) {
          return '/login';
        }
        return null;
      }

      if (isLogin) {
        return null;
      }

      // Any protected route (dashboard, sales, etc.) -> redirect to login
      return '/login';
    }

    // 3. Authenticated user flow
    if (authState.isAuthenticated) {
      // Authenticated users should not see onboarding or login
      if (isLogin || isOnboarding) {
        return '/dashboard';
      }
      return null;
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const MainShellScreen(),
      ),
      GoRoute(
        path: '/sales',
        builder: (context, state) => const SalesScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const NewSaleScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/purchases',
        builder: (context, state) => const PurchasesScreen(),
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const InventoryScreen(),
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) => const InventoryScreen(),
      ),
      GoRoute(
        path: '/customers',
        builder: (context, state) => const CustomersScreen(),
      ),
      GoRoute(
        path: '/suppliers',
        builder: (context, state) => const SuppliersScreen(),
      ),
      GoRoute(
        path: '/payments',
        builder: (context, state) => const PaymentsScreen(),
      ),
      GoRoute(
        path: '/ledger',
        builder: (context, state) => const LedgerScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/more',
        builder: (context, state) => const MoreScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
