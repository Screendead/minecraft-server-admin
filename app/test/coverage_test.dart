import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart' as app;

void main() {
  group('Minecraft Server Admin App Tests', () {
    testWidgets('App should start without crashing', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const app.MyApp());

      // Verify that the app title is displayed (in the main text, not the app bar)
      expect(find.text('Minecraft Server Admin'), findsWidgets);
      
      // Verify that the gaming icon is displayed
      expect(find.byIcon(Icons.sports_esports), findsOneWidget);
      
      // Verify that the server status is displayed
      expect(find.text('Server status: Online'), findsOneWidget);
    });

    testWidgets('Counter should increment when button is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(const app.MyApp());

      // Verify initial counter value
      expect(find.text('Button clicks: 0'), findsOneWidget);

      // Tap the floating action button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify counter incremented
      expect(find.text('Button clicks: 1'), findsOneWidget);
    });

    testWidgets('App should have proper theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(const app.MyApp());

      // Verify the app bar exists
      expect(find.byType(AppBar), findsOneWidget);
      
      // Verify the floating action button exists
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
