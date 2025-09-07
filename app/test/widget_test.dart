// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/main.dart';
import 'package:app/services/auth_service.dart';

void main() {
  testWidgets('App shows authentication page when not signed in',
      (WidgetTester tester) async {
    // Create mock services
    final mockAuthService = MockAuthService();
    when(mockAuthService.isSignedIn()).thenAnswer((_) async => false);

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(authService: mockAuthService));
    await tester.pumpAndSettle();

    // Verify that authentication page is shown
    expect(find.text('Sign In'), findsNWidgets(2)); // Title and button
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}

class MockAuthService extends Mock implements AuthService {}
