import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khaki_karobari/features/auth/login_screen.dart';
import 'package:khaki_karobari/providers/auth_provider.dart';
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
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pump();

      // Verify Header
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to manage your business khata & invoices'),
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
          child: const MaterialApp(
            home: LoginScreen(),
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

    testWidgets('Tapping Forgot Password opens dialog with information',
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
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Understood'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Understood'));
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsNothing);
    });

    testWidgets('Tapping Create Account opens business setup dialog',
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
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.ensureVisible(find.text('Create Account'));
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('New Business Setup'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('New Business Setup'), findsNothing);
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
          child: const MaterialApp(
            home: LoginScreen(),
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
          child: const MaterialApp(
            home: LoginScreen(),
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
          child: const MaterialApp(
            home: LoginScreen(),
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
}
