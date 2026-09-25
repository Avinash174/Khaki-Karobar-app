import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khaki_karobari/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Khaki Karobar app smoke test - splash screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KhakiKarobariApp(),
      ),
    );

    // Verify brand name and professional branding loads on splash screen
    expect(find.text('Khaki Karobar'), findsOneWidget);
    expect(find.text('BUSINESS ERP & BILLING'), findsOneWidget);
  });
}

