import 'package:flutter_test/flutter_test.dart';

import 'package:casino_dealers_flow/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CasinoDealersFlowApp());

    // Verify that the splash screen appears
    expect(find.text('Casino Dealer\'s'), findsOneWidget);
  });
}
