import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khaki_karobari/features/auth/login_screen.dart';
import 'package:khaki_karobari/features/auth/register_screen.dart';
import 'package:khaki_karobari/features/auth/forgot_password_screen.dart';
import 'package:khaki_karobari/features/auth/otp_verification_screen.dart';
import 'package:khaki_karobari/features/settings/appearance_screen.dart';
import 'package:khaki_karobari/providers/auth_provider.dart';
import 'package:khaki_karobari/services/auth_service.dart';
import 'package:khaki_karobari/core/network/api_client.dart';

class _FakeAuthService extends AuthService {
  bool registerCalled = false;
  bool requestOtpCalled = false;
  bool verifyOtpCalled = false;

  _FakeAuthService() : super(ApiClient());

  @override
  Future<bool> isLoggedIn() async => false;

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    String? email,
    required String password,
    String? businessName,
  }) async {
    registerCalled = true;
    return {'user': null, 'business': null};
  }

  @override
  Future<void> requestOtp(String phone, {String purpose = 'LOGIN'}) async {
    requestOtpCalled = true;
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp,
      {String? name}) async {
    verifyOtpCalled = true;
    return {'user': null, 'business': null};
  }
}

GoRouter _createAuthFlowRouter(Widget initialWidget, _FakeAuthService service) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => initialWidget,
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
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return OtpVerificationScreen(
            phone: extra?['phone'] ?? '9876543210',
            purpose: extra?['purpose'] ?? 'LOGIN',
          );
        },
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const Scaffold(body: Text('DASHBOARD_HOME')),
      ),
      GoRoute(
        path: '/settings/appearance',
        builder: (context, state) => const AppearanceScreen(),
      ),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('RegisterScreen Tests', () {
    testWidgets('Validates required fields and shows validation messages',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2200);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeAuth = _FakeAuthService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(fakeAuth),
          ],
          child: MaterialApp.router(
            routerConfig: _createAuthFlowRouter(const RegisterScreen(), fakeAuth),
          ),
        ),
      );
      await tester.pump();

      // Tap Create Account with empty fields
      await tester.ensureVisible(find.text('Create Account'));
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your name'), findsOneWidget);
      expect(find.text('Please enter your mobile number'), findsOneWidget);
      expect(find.text('Please enter a password'), findsOneWidget);
    });

    testWidgets('Submitting valid registration form calls register API',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2200);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeAuth = _FakeAuthService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(fakeAuth),
          ],
          child: MaterialApp.router(
            routerConfig: _createAuthFlowRouter(const RegisterScreen(), fakeAuth),
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Full Name'), 'Avinash Magar');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Mobile Number'), '9876543210');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'Pass1234');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Confirm Password'), 'Pass1234');

      await tester.ensureVisible(find.text('Create Account'));
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(fakeAuth.registerCalled, isTrue);
      expect(find.text('DASHBOARD_HOME'), findsOneWidget);
    });
  });

  group('ForgotPasswordScreen Tests', () {
    testWidgets('Submitting phone calls requestOtp and navigates to OTP screen',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2200);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeAuth = _FakeAuthService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(fakeAuth),
          ],
          child: MaterialApp.router(
            routerConfig:
                _createAuthFlowRouter(const ForgotPasswordScreen(), fakeAuth),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(fakeAuth.requestOtpCalled, isTrue);
      expect(find.byType(OtpVerificationScreen), findsOneWidget);
    });
  });

  group('OtpVerificationScreen Tests', () {
    testWidgets('Submitting 6-digit OTP calls verifyOtp API', (tester) async {
      tester.view.physicalSize = const Size(1080, 2200);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeAuth = _FakeAuthService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(fakeAuth),
          ],
          child: MaterialApp.router(
            routerConfig: _createAuthFlowRouter(
              const OtpVerificationScreen(
                phone: '9876543210',
                purpose: 'LOGIN',
              ),
              fakeAuth,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Verify Code'), findsOneWidget);
      expect(find.text('Verify & Proceed'), findsOneWidget);

      await tester.ensureVisible(find.text('Verify & Proceed'));
      await tester.tap(find.text('Verify & Proceed'));
      await tester.pumpAndSettle();

      expect(fakeAuth.verifyOtpCalled, isTrue);
      expect(find.text('DASHBOARD_HOME'), findsOneWidget);
    });
  });

  group('No Theme Switcher on Auth Screens', () {
    testWidgets('LoginScreen, RegisterScreen, ForgotPassword, and OTP have no theme switcher',
        (tester) async {
      final fakeAuth = _FakeAuthService();

      // Check LoginScreen
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authServiceProvider.overrideWithValue(fakeAuth)],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      expect(find.byTooltip('Switch Theme'), findsNothing);

      // Check RegisterScreen
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authServiceProvider.overrideWithValue(fakeAuth)],
          child: const MaterialApp(home: RegisterScreen()),
        ),
      );
      expect(find.byTooltip('Switch Theme'), findsNothing);

      // Check ForgotPasswordScreen
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authServiceProvider.overrideWithValue(fakeAuth)],
          child: const MaterialApp(home: ForgotPasswordScreen()),
        ),
      );
      expect(find.byTooltip('Switch Theme'), findsNothing);

      // Check OtpVerificationScreen
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authServiceProvider.overrideWithValue(fakeAuth)],
          child: const MaterialApp(
            home: OtpVerificationScreen(phone: '9876543210'),
          ),
        ),
      );
      expect(find.byTooltip('Switch Theme'), findsNothing);
    });
  });
}
