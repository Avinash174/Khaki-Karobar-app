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
import 'package:khaki_karobari/providers/theme_provider.dart';
import 'package:khaki_karobari/services/auth_service.dart';
import 'package:khaki_karobari/core/network/api_client.dart';

class _MockAuthService extends AuthService {
  final bool Function(String, String)? onLogin;
  final bool Function(String, String)? onOtp;

  _MockAuthService({this.onLogin, this.onOtp}) : super(ApiClient());

  @override
  Future<bool> isLoggedIn() async => false;

  @override
  Future<Map<String, dynamic>> login(String phone, String password) async {
    if (onLogin != null) {
      final ok = onLogin!(phone, password);
      if (!ok) throw Exception('Invalid credentials provided');
      return {'user': null, 'business': null};
    }
    return {'user': null, 'business': null};
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp,
      {String? name}) async {
    if (onOtp != null) {
      final ok = onOtp!(phone, otp);
      if (!ok) throw Exception('Invalid OTP code');
      return {'user': null, 'business': null};
    }
    return {'user': null, 'business': null};
  }

  @override
  Future<void> requestOtp(String phone, {String purpose = 'LOGIN'}) async {}
}

GoRouter _createLoginTestRouter(Widget initialWidget) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => initialWidget,
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (context, state) => const OtpVerificationScreen(
          phone: '9876543210',
          purpose: 'LOGIN',
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Login Screen UI & Interaction Tests', () {
    testWidgets('Renders all required elements in Password mode by default',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(_MockAuthService()),
          ],
          child: MaterialApp.router(
            routerConfig: _createLoginTestRouter(const LoginScreen()),
          ),
        ),
      );
      await tester.pump();

      // Verify Header
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Manage your business smarter with Khaki Karobar.'),
          findsOneWidget);

      // Verify Fields & Buttons
      expect(find.text('Mobile Number or Email'), findsOneWidget);
      expect(find.text('Password'), findsNWidgets(2)); // Tab title & input label
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);

      // Verify Mode Tabs
      expect(find.text('Instant OTP'), findsOneWidget);

      // Verify Create Account Option
      expect(find.text("Don't have an account?"), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('Switching to Instant OTP mode updates fields and button label',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(_MockAuthService()),
          ],
          child: MaterialApp.router(
            routerConfig: _createLoginTestRouter(const LoginScreen()),
          ),
        ),
      );

      // Tap on 'Instant OTP' tab
      await tester.tap(find.text('Instant OTP'));
      await tester.pumpAndSettle();

      // Verify OTP field is displayed
      expect(find.text('6-Digit OTP'), findsOneWidget);
      expect(find.text('Verify & Sign In'), findsOneWidget);

      // Verify Password field is hidden
      expect(find.text('Forgot Password?'), findsNothing);
    });

    testWidgets('Tapping Forgot Password navigates to ForgotPasswordScreen',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(_MockAuthService()),
          ],
          child: MaterialApp.router(
            routerConfig: _createLoginTestRouter(const LoginScreen()),
          ),
        ),
      );

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('Tapping Create Account navigates to RegisterScreen',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(_MockAuthService()),
          ],
          child: MaterialApp.router(
            routerConfig: _createLoginTestRouter(const LoginScreen()),
          ),
        ),
      );

      await tester.ensureVisible(find.text('Create Account'));
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);
      expect(find.text('Create Your Account'), findsOneWidget);
    });

    testWidgets('Shows validation error if input fields are empty',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(_MockAuthService()),
          ],
          child: MaterialApp.router(
            routerConfig: _createLoginTestRouter(const LoginScreen()),
          ),
        ),
      );

      // Clear the mobile number and password fields
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Mobile Number or Email'), '');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), '');

      // Tap Sign In
      await tester.ensureVisible(find.text('Sign In'));
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(
          find.text('Please enter your mobile number or email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Displays formatted API error banner on failed login',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(
              _MockAuthService(
                onLogin: (phone, pass) => false,
              ),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: _createLoginTestRouter(const LoginScreen()),
          ),
        ),
      );

      await tester.pump();

      // Tap Sign In with prefilled credentials
      await tester.ensureVisible(find.text('Sign In'));
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Error banner should be displayed
      expect(find.text('Invalid credentials provided'), findsOneWidget);
    });

    testWidgets('Displays formatted API error banner on failed OTP verification',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(
              _MockAuthService(
                onOtp: (phone, otp) => false,
              ),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: _createLoginTestRouter(const LoginScreen()),
          ),
        ),
      );

      await tester.pump();

      // Switch to Instant OTP mode
      await tester.tap(find.text('Instant OTP'));
      await tester.pumpAndSettle();

      // Tap Verify & Sign In
      await tester.ensureVisible(find.text('Verify & Sign In'));
      await tester.tap(find.text('Verify & Sign In'));
      await tester.pumpAndSettle();

      // Error banner should be displayed
      expect(find.text('Invalid OTP code'), findsOneWidget);
    });
  });

  group('Appearance / Theme Settings Screen Tests', () {
    testWidgets('Renders all theme options: Light, Dark, System Default',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AppearanceScreen(),
          ),
        ),
      );

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Light Theme'), findsOneWidget);
      expect(find.text('Dark Theme'), findsOneWidget);
      expect(find.text('System Default'), findsOneWidget);
    });

    testWidgets('Selecting Dark Theme updates themeProvider and persists',
        (tester) async {
      late ProviderContainer container;

      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, child) {
              container = ProviderScope.containerOf(context);
              return const MaterialApp(
                home: AppearanceScreen(),
              );
            },
          ),
        ),
      );

      // Select Dark Theme
      await tester.tap(find.text('Dark Theme'));
      await tester.pumpAndSettle();

      expect(container.read(themeProvider), equals(ThemeMode.dark));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('khaki_theme_mode'), equals('dark'));
    });
  });
}
