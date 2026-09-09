import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bricks_breaker_3d/main.dart';

void main() {
  testWidgets('Bricks Breaker 3D App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'has_completed_tutorial': true});
    await tester.pumpWidget(const BricksBreaker3DApp());
    expect(find.text('Loading...'), findsOneWidget);

    // Advance past splash timer into HomeScreen
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Level Map'), findsOneWidget);
    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('Challenge'), findsOneWidget);
    expect(find.text('Shop'), findsOneWidget);
    expect(find.text('Balls'), findsOneWidget);
  });
}
