import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/widgets/auth_wrapper.dart';
import 'package:app/widgets/auth_page.dart';

import 'auth_widget_test.mocks.dart';

@GenerateMocks([AuthService, User])
void main() {
  group('AuthWrapper', () {
    late MockAuthService mockAuthService;
    late MockUser mockUser;

    setUp(() {
      mockAuthService = MockAuthService();
      mockUser = MockUser();
    });

    testWidgets('should show AuthPage when user is not signed in',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.isSignedIn()).thenAnswer((_) async => false);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: AuthWrapper(authService: mockAuthService),
        ),
      );

      // Assert
      expect(find.byType(AuthPage), findsOneWidget);
      expect(find.text('Sign In'), findsNWidgets(2)); // Title and button
    });

    testWidgets('should show home page when user is signed in',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.isSignedIn()).thenAnswer((_) async => true);
      when(mockAuthService.getCurrentUser()).thenAnswer((_) async => mockUser);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: AuthWrapper(authService: mockAuthService),
        ),
      );

      // Assert
      expect(find.byType(AuthPage), findsNothing);
      expect(find.text('Minecraft Server Admin'), findsOneWidget);
    });
  });

  group('AuthPage', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    testWidgets('should show login form by default',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: AuthPage(authService: mockAuthService),
        ),
      );

      // Assert
      expect(find.text('Sign In'), findsNWidgets(2)); // Title and button
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Don\'t have an account? Sign Up'), findsOneWidget);
    });

    testWidgets('should switch to signup form when signup button is tapped',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: AuthPage(authService: mockAuthService),
        ),
      );

      await tester.tap(find.text('Don\'t have an account? Sign Up'));
      await tester.pump();

      // Assert
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('API Key'), findsOneWidget);
    });

    testWidgets('should show loading indicator during authentication',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.signIn(any, any)).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
        return true;
      });

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: AuthPage(authService: mockAuthService),
        ),
      );

      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message when authentication fails',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.signIn(any, any)).thenAnswer((_) async => false);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: AuthPage(authService: mockAuthService),
        ),
      );

      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'wrong-password');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Authentication failed. Please try again.'),
          findsOneWidget);
    });

    testWidgets('should validate required fields', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: AuthPage(authService: mockAuthService),
        ),
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('should validate email format', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: AuthPage(authService: mockAuthService),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.enterText(find.byType(TextFormField).at(1), 'password');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });
  });
}
