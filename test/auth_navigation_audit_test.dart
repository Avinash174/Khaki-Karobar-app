import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khaki_karobari/main.dart';
import 'package:khaki_karobari/features/onboarding/onboarding_screen.dart';
import 'package:khaki_karobari/features/splash/splash_screen.dart';
import 'package:khaki_karobari/features/auth/login_screen.dart';
import 'package:khaki_karobari/features/auth/register_screen.dart';
import 'package:khaki_karobari/features/auth/forgot_password_screen.dart';
import 'package:khaki_karobari/providers/auth_provider.dart';
import 'package:khaki_karobari/providers/onboarding_provider.dart';
import 'package:khaki_karobari/services/auth_service.dart';
import 'package:khaki_karobari/core/network/api_client.dart';
import 'package:khaki_karobari/routes/app_router.dart';

class _AuditAuthService extends AuthService {
  bool _loggedIn;
  _AuditAuthService(this._loggedIn) : super(ApiClient());

  @override
  Future<bool> isLoggedIn() async => _loggedIn;

  @override
  Future<void> logout() async {
    _loggedIn = false;
  }
}

GoRouter _createAuditTestRouter(WidgetRef ref) {
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
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (context, state) =>
            const Scaffold(body: Text('AUDIT_OTP_SCREEN')),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) =>
            const Scaffold(body: Text('AUDIT_DASHBOARD_HOME')),
      ),
      GoRoute(
        path: '/sales',
        builder: (context, state) =>
            const Scaffold(body: Text('AUDIT_SALES_SCREEN')),
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) =>
            const Scaffold(body: Text('AUDIT_INVENTORY_SCREEN')),
      ),
    ],
  );
}

class _AuditTestApp extends ConsumerWidget {
  const _AuditTestApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = _createAuditTestRouter(ref);
    return MaterialApp.router(
      title: 'Khaki Karobar Audit',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Startup & Auth Navigation Audit Tests', () {
    testWidgets('1. FIRST INSTALL: Splash -> Onboarding -> Login',
        (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(_AuditAuthService(false)),
          ],
          child: const KhakiKarobariApp(),
        ),
      );

      // Splash is shown
      expect(find.byType(SplashScreen), findsOneWidget);

      // Advance through splash delay
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();

      // Lands on Onboarding
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Create Invoices in Seconds'), findsOneWidget);

      // Complete Onboarding via Skip
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Lands on Login
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);

      // Verify persistence
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(kHasCompletedOnboardingKey), isTrue);
    });

    testWidgets('2. AFTER ONBOARDING: Splash -> Login (Onboarding skipped)',
        (tester) async {
      // Simulate that onboarding was previously completed
      SharedPreferences.setMockInitialValues({
        kHasCompletedOnboardingKey: true,
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(_AuditAuthService(false)),
          ],
          child: const KhakiKarobariApp(),
        ),
      );

      expect(find.byType(SplashScreen), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();

      // Lands directly on Login; Onboarding never shown
      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('3. AUTHENTICATED USER: Splash -> Home (/dashboard)',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        kHasCompletedOnboardingKey: true,
      });

      final auditAuth = _AuditAuthService(true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(auditAuth),
          ],
          child: const _AuditTestApp(),
        ),
      );

      expect(find.byType(SplashScreen), findsOneWidget);

      // Advance through splash delay
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();

      // Transitions to Home Dashboard
      expect(find.text('AUDIT_DASHBOARD_HOME'), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets(
        '4. LOGOUT & AFTER LOGOUT: Home -> Login, Onboarding must NOT appear again',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        kHasCompletedOnboardingKey: true,
      });

      final auditAuth = _AuditAuthService(true);
      late ProviderContainer container;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(auditAuth),
          ],
          child: Consumer(
            builder: (context, ref, child) {
              container = ProviderScope.containerOf(context);
              return const _AuditTestApp();
            },
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();

      // User starts on Home Dashboard
      expect(find.text('AUDIT_DASHBOARD_HOME'), findsOneWidget);

      // Trigger logout
      await container.read(authProvider.notifier).logout();
      await tester.pumpAndSettle();

      // Router automatically redirects from Home to Login
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);

      // Verify onboarding key is still true in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(kHasCompletedOnboardingKey), isTrue);

      // Attempt manual navigation to /onboarding after logout
      final routerState = tester.state<NavigatorState>(find.byType(Navigator));
      GoRouter.of(routerState.context).go('/onboarding');
      await tester.pumpAndSettle();

      // Guard keeps user on Login and prevents onboarding from reappearing
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
    });

    testWidgets('5. GoRouter Redirects Guard Protected Routes',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        kHasCompletedOnboardingKey: true,
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(_AuditAuthService(false)),
          ],
          child: const _AuditTestApp(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);

      final navContext = tester.element(find.byType(LoginScreen));
      final router = GoRouter.of(navContext);

      // Test route guard: unauthenticated access to /dashboard redirects to /login
      router.go('/dashboard');
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);

      // Test route guard: unauthenticated access to /sales redirects to /login
      router.go('/sales');
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);

      // Test route guard: access to /onboarding when completed redirects to /login
      router.go('/onboarding');
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('6. Onboarding back navigation cycles through slides',
        (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      // Slide 1
      expect(find.text('Create Invoices in Seconds'), findsOneWidget);

      // Advance to Slide 2
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Manage Your Stock Easily'), findsOneWidget);

      // Trigger back navigation
      final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
      await widgetsAppState.didPopRoute();
      await tester.pumpAndSettle();

      // Should return to Slide 1
      expect(find.text('Create Invoices in Seconds'), findsOneWidget);
    });
  });
}
