import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/widgets/api_key_input_dialog.dart';

void main() {
  group('ApiKeyInputDialog Success Feedback Tests', () {
    testWidgets('closes dialog when API key is successfully added',
        (WidgetTester tester) async {
      // Create a mock onConfirm function that returns true
      bool onConfirmCalled = false;
      Future<bool> mockOnConfirm(String apiKey) async {
        onConfirmCalled = true;
        return true;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApiKeyInputDialog(
              isUpdate: false,
              onConfirm: mockOnConfirm,
            ),
          ),
        ),
      );

      // Enter API key
      await tester.enterText(find.byType(TextField), 'test-api-key');
      await tester.pump();

      // Tap the Add button
      await tester.tap(find.text('Add'));
      await tester.pump();

      // Wait for async operations
      await tester.pumpAndSettle();

      // Verify onConfirm was called
      expect(onConfirmCalled, isTrue);

      // Verify success snackbar is NOT shown (handled by parent)
      expect(find.text('API key linked successfully!'), findsNothing);
      expect(find.byType(SnackBar), findsNothing);

      // Verify dialog is closed
      expect(find.byType(ApiKeyInputDialog), findsNothing);
    });

    testWidgets('closes dialog when API key is successfully updated',
        (WidgetTester tester) async {
      // Create a mock onConfirm function that returns true
      bool onConfirmCalled = false;
      Future<bool> mockOnConfirm(String apiKey) async {
        onConfirmCalled = true;
        return true;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApiKeyInputDialog(
              isUpdate: true,
              onConfirm: mockOnConfirm,
            ),
          ),
        ),
      );

      // Enter API key
      await tester.enterText(find.byType(TextField), 'test-api-key');
      await tester.pump();

      // Tap the Update button
      await tester.tap(find.text('Update'));
      await tester.pump();

      // Wait for async operations
      await tester.pumpAndSettle();

      // Verify onConfirm was called
      expect(onConfirmCalled, isTrue);

      // Verify success snackbar is NOT shown (handled by parent)
      expect(find.text('API key updated successfully!'), findsNothing);
      expect(find.byType(SnackBar), findsNothing);

      // Verify dialog is closed
      expect(find.byType(ApiKeyInputDialog), findsNothing);
    });

    testWidgets('does not show success snackbar when onConfirm returns false',
        (WidgetTester tester) async {
      // Create a mock onConfirm function that returns false
      bool onConfirmCalled = false;
      Future<bool> mockOnConfirm(String apiKey) async {
        onConfirmCalled = true;
        return false;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApiKeyInputDialog(
              isUpdate: false,
              onConfirm: mockOnConfirm,
            ),
          ),
        ),
      );

      // Enter API key
      await tester.enterText(find.byType(TextField), 'test-api-key');
      await tester.pump();

      // Tap the Add button
      await tester.tap(find.text('Add'));
      await tester.pump();

      // Wait for async operations
      await tester.pumpAndSettle();

      // Verify onConfirm was called
      expect(onConfirmCalled, isTrue);

      // Verify success snackbar is NOT shown
      expect(find.text('API key linked successfully!'), findsNothing);
      expect(find.byType(SnackBar), findsNothing);

      // Verify dialog is still open
      expect(find.byType(ApiKeyInputDialog), findsOneWidget);
    });

    testWidgets(
        'does not show success snackbar when onConfirm throws exception',
        (WidgetTester tester) async {
      // Create a mock onConfirm function that throws an exception
      bool onConfirmCalled = false;
      Future<bool> mockOnConfirm(String apiKey) async {
        onConfirmCalled = true;
        throw Exception('Test error');
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApiKeyInputDialog(
              isUpdate: false,
              onConfirm: mockOnConfirm,
            ),
          ),
        ),
      );

      // Enter API key
      await tester.enterText(find.byType(TextField), 'test-api-key');
      await tester.pump();

      // Tap the Add button
      await tester.tap(find.text('Add'));
      await tester.pump();

      // Wait for async operations
      await tester.pumpAndSettle();

      // Verify onConfirm was called
      expect(onConfirmCalled, isTrue);

      // Verify success snackbar is NOT shown
      expect(find.text('API key linked successfully!'), findsNothing);
      expect(find.byType(SnackBar), findsNothing);

      // Verify error message is shown instead (Exception message without prefix)
      expect(find.text('Test error'), findsOneWidget);

      // Verify dialog is still open
      expect(find.byType(ApiKeyInputDialog), findsOneWidget);
    });

    testWidgets('shows correct button text for add vs update',
        (WidgetTester tester) async {
      // Test Add mode
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApiKeyInputDialog(
              isUpdate: false,
              onConfirm: (apiKey) async => true,
            ),
          ),
        ),
      );

      expect(find.text('Add API Key'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);

      // Test Update mode
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApiKeyInputDialog(
              isUpdate: true,
              onConfirm: (apiKey) async => true,
            ),
          ),
        ),
      );

      expect(find.text('Update API Key'), findsOneWidget);
      expect(find.text('Update'), findsOneWidget);
    });
  });
}
