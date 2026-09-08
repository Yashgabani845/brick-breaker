import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bricks_breaker_3d/main.dart';

void main() {
  testWidgets('Bricks Breaker 3D App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const BricksBreaker3DApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('BRICKS BREAKER'), findsOneWidget);
    expect(find.text('3D'), findsOneWidget);
  });
}
