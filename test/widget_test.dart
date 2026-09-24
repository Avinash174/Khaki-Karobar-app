import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khaki_karobari/main.dart';

void main() {
  testWidgets('Khaki Karobar app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KhakiKarobariApp(),
      ),
    );

    // Verify brand title is loaded
    expect(find.text('KHAKI KAROBAR'), findsOneWidget);
  });
}
