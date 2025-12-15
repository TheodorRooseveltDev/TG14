// Basic Flutter widget test for Lucky Royale Slots app

import 'package:flutter_test/flutter_test.dart';
import 'package:casino_dealers_flow_2/main.dart';

void main() {
  testWidgets('App loads splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SocialCasinoApp());
    
    // Wait for animations
    await tester.pump();
    
    // The app should load without errors
    expect(find.byType(SocialCasinoApp), findsOneWidget);
  });
}
