import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khaki_karobari/main.dart';
import 'package:khaki_karobari/features/onboarding/onboarding_screen.dart';
import 'package:khaki_karobari/features/splash/splash_screen.dart';
import 'package:khaki_karobari/providers/auth_provider.dart';
import 'package:khaki_karobari/providers/onboarding_provider.dart';
import 'package:khaki_karobari/services/auth_service.dart';
import 'package:khaki_karobari/core/network/api_client.dart';

class _FakeAuthService extends AuthService {
  final bool _loggedIn;
  _FakeAuthService(this._loggedIn) : super(ApiClient());

  @override
  Future<bool> isLoggedIn() async => _loggedIn;
}

GoRouter _createTestRouter() {
  return GoRouter(
    initialLocation: '/splash',
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
        builder: (context, state) =>
            const Scaffold(body: Text('LOGIN_MOCK_SCREEN')),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) =>
            const Scaffold(body: Text('DASHBOARD_MOCK_SCREEN')),
      ),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Onboarding State & Provider Tests', () {
    test('Onboarding starts as false on fresh install', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = OnboardingNotifier();
      await Future.delayed(const Duration(milliseconds: 30));
      expect(notifier.state, isFalse);
    });

    test('completeOnboarding sets state to true and persists to SharedPreferences',
        () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = OnboardingNotifier();
      await notifier.completeOnboarding();

      expect(notifier.state, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(kHasCompletedOnboardingKey), isTrue);
    });

    test('Loads completed state if previously saved in SharedPreferences',
        () async {
      SharedPreferences.setMockInitialValues({
        kHasCompletedOnboardingKey: true,
      });

      final notifier = OnboardingNotifier();
      await Future.delayed(const Duration(milliseconds: 30));
      expect(notifier.state, isTrue);
    });
  });

  group('Onboarding UI & Flow Tests', () {
    testWidgets('Onboarding shows Page 1 content initially with Skip button',
        (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      // Verify Page 1 Title & elements
      expect(find.text('Create Invoices in Seconds'), findsOneWidget);
      expect(find.text('GST Ready'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('Tapping Continue navigates through pages to Get Started',
        (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      // Page 1
      expect(find.text('Create Invoices in Seconds'), findsOneWidget);

      // Tap Continue -> Page 2
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Manage Your Stock Easily'), findsOneWidget);
      expect(find.text('Multi-Godown'), findsOneWidget);

      // Tap Continue -> Page 3
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Understand Your Business'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('Tapping Skip completes onboarding flag in SharedPreferences',
        (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(kHasCompletedOnboardingKey), isTrue);
    });
  });

  group('Splash Screen UI Tests', () {
    testWidgets('Splash Screen renders brand title and professional tagline',
        (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );

      expect(find.text('Khaki Karobar'), findsOneWidget);
      expect(find.text('BUSINESS ERP & BILLING'), findsOneWidget);
      expect(find.text('Made for Indian MSMEs'), findsOneWidget);
    });
  });

  group('Startup Navigation Flow - All 3 Paths', () {
    testWidgets('Path 1: Fresh install -> Splash -> Onboarding -> Login',
        (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(_FakeAuthService(false)),
          ],
          child: MaterialApp.router(
            routerConfig: _createTestRouter(),
          ),
        ),
      );

      // Step 1: Splash screen displays
      expect(find.text('Khaki Karobar'), findsOneWidget);

      // Advance through splash delay
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();

      // Step 2: Navigates to Onboarding
      expect(find.text('Create Invoices in Seconds'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      // Step 3: Tap Skip to finish onboarding and land on Login
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Step 4: Login screen is displayed
      expect(find.text('LOGIN_MOCK_SCREEN'), findsOneWidget);

      // Verify onboarding marked completed
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(kHasCompletedOnboardingKey), isTrue);
    });

    testWidgets(
        'Path 2: Completed onboarding, unauthenticated -> Splash -> Login',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        kHasCompletedOnboardingKey: true,
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(_FakeAuthService(false)),
          ],
          child: MaterialApp.router(
            routerConfig: _createTestRouter(),
          ),
        ),
      );

      // Step 1: Splash screen displays
      expect(find.text('Khaki Karobar'), findsOneWidget);

      // Advance through splash delay
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();

      // Step 2: Navigates directly to Login
      expect(find.text('LOGIN_MOCK_SCREEN'), findsOneWidget);
    });

    testWidgets('Path 3: Already authenticated -> Splash -> Dashboard (Home)',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        kHasCompletedOnboardingKey: true,
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(_FakeAuthService(true)),
          ],
          child: MaterialApp.router(
            routerConfig: _createTestRouter(),
          ),
        ),
      );

      // Step 1: Splash screen displays
      expect(find.text('Khaki Karobar'), findsOneWidget);

      // Advance through splash delay
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();

      // Step 2: Navigates directly to Dashboard
      expect(find.text('DASHBOARD_MOCK_SCREEN'), findsOneWidget);
    });

    testWidgets('Live App Smoke with KhakiKarobariApp', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(_FakeAuthService(false)),
          ],
          child: const KhakiKarobariApp(),
        ),
      );

      expect(find.text('Khaki Karobar'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();

      // Should land on Onboarding
      expect(find.text('Create Invoices in Seconds'), findsOneWidget);
    });
  });
}
