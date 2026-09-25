import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khaki_karobari/core/theme/app_theme.dart';
import 'package:khaki_karobari/features/splash/splash_screen.dart';
import 'package:khaki_karobari/features/onboarding/onboarding_screen.dart';
import 'package:khaki_karobari/features/auth/login_screen.dart';
import 'package:khaki_karobari/providers/auth_provider.dart';
import 'package:khaki_karobari/services/auth_service.dart';
import 'package:khaki_karobari/core/network/api_client.dart';

class _FakeAuthService extends AuthService {
  _FakeAuthService() : super(ApiClient());
  @override
  Future<bool> isLoggedIn() async => false;
}

GoRouter _createAuditRouter(Widget initialWidget) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => initialWidget,
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
        builder: (context, state) => const Scaffold(body: Text('DASHBOARD')),
      ),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Small Screen Responsiveness & Overflow Tests', () {
    // Standard small Android / iPhone SE screen sizes
    final testSizes = [
      const Size(360, 640), // Standard Android compact
      const Size(320, 568), // iPhone SE 1st gen
    ];

    for (final size in testSizes) {
      testWidgets('SplashScreen on ${size.width}x${size.height} has no overflow',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authServiceProvider.overrideWithValue(_FakeAuthService()),
            ],
            child: MaterialApp.router(
              themeMode: ThemeMode.light,
              routerConfig: _createAuditRouter(const SplashScreen()),
            ),
          ),
        );

        // Advance through splash delay to resolve timers and avoid unhandled navigation
        await tester.pump(const Duration(milliseconds: 1300));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('OnboardingScreen on ${size.width}x${size.height} has no overflow',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authServiceProvider.overrideWithValue(_FakeAuthService()),
            ],
            child: MaterialApp.router(
              routerConfig: _createAuditRouter(const OnboardingScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Advance to slide 2
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Advance to slide 3
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('LoginScreen on ${size.width}x${size.height} has no overflow',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authServiceProvider.overrideWithValue(_FakeAuthService()),
            ],
            child: MaterialApp.router(
              routerConfig: _createAuditRouter(const LoginScreen()),
            ),
          ),
        );

        await tester.pump();
        expect(tester.takeException(), isNull);

        // Switch to Instant OTP mode
        await tester.tap(find.text('Instant OTP'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('LoginScreen with virtual keyboard insets (bottom padding)',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      tester.view.viewInsets = const FakeViewPadding(bottom: 260);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(_FakeAuthService()),
          ],
          child: MaterialApp.router(
            routerConfig: _createAuditRouter(const LoginScreen()),
          ),
        ),
      );

      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('Dark & Light Theme Rendering Tests', () {
    testWidgets('SplashScreen renders properly in Dark Theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(_FakeAuthService()),
          ],
          child: MaterialApp.router(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            routerConfig: _createAuditRouter(const SplashScreen()),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('OnboardingScreen renders properly in Dark Theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(_FakeAuthService()),
          ],
          child: MaterialApp.router(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            routerConfig: _createAuditRouter(const OnboardingScreen()),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Create Invoices in Seconds'), findsOneWidget);
    });

    testWidgets('LoginScreen renders properly in Dark Theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(_FakeAuthService()),
          ],
          child: MaterialApp.router(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            routerConfig: _createAuditRouter(const LoginScreen()),
          ),
        ),
      );

      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Welcome Back'), findsOneWidget);
    });
  });
}
