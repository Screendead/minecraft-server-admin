import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/encryption_service.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  User,
  UserCredential,
  FirebaseFirestore,
  CollectionReference<Map<String, dynamic>>,
  DocumentReference<Map<String, dynamic>>,
  SharedPreferences
])
void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockSharedPreferences mockSharedPreferences;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;
    late MockCollectionReference mockCollectionReference;
    late MockDocumentReference mockDocumentReference;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockSharedPreferences = MockSharedPreferences();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();
      mockCollectionReference = MockCollectionReference();
      mockDocumentReference = MockDocumentReference();

      authService = AuthService(
        firebaseAuth: mockFirebaseAuth,
        firestore: mockFirestore,
        sharedPreferences: mockSharedPreferences,
      );
    });

    group('signUp', () {
      test('should create user account and store user data in Firestore',
          () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const apiKey = 'test-api-key';
        const uid = 'test-uid';

        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).thenAnswer((_) async => mockUserCredential);

        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(uid);
        when(mockUser.email).thenReturn(email);

        when(mockFirestore.collection('users')).thenReturn(
            mockCollectionReference
                as CollectionReference<Map<String, dynamic>>);
        when(mockCollectionReference.doc(uid)).thenReturn(
            mockDocumentReference as DocumentReference<Map<String, dynamic>>);
        when(mockDocumentReference.set(any)).thenAnswer((_) async => {});

        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);

        // Act
        final result = await authService.signUp(email, password, apiKey);

        // Assert
        expect(result, isTrue);
        verify(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).called(1);
        verify(mockDocumentReference.set(any)).called(1);
        verify(mockSharedPreferences.setString('encrypted_api_key', any))
            .called(1);
      });

      test('should return false when signup fails', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const apiKey = 'test-api-key';

        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).thenThrow(FirebaseAuthException(code: 'weak-password'));

        // Act
        final result = await authService.signUp(email, password, apiKey);

        // Assert
        expect(result, isFalse);
      });
    });

    group('signIn', () {
      test('should sign in user successfully', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenAnswer((_) async => mockUserCredential);

        when(mockUserCredential.user).thenReturn(mockUser);

        // Act
        final result = await authService.signIn(email, password);

        // Assert
        expect(result, isTrue);
        verify(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).called(1);
      });

      test('should return false when sign in fails', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrong-password';

        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenThrow(FirebaseAuthException(code: 'user-not-found'));

        // Act
        final result = await authService.signIn(email, password);

        // Assert
        expect(result, isFalse);
      });
    });

    group('signOut', () {
      test('should sign out user successfully', () async {
        // Arrange
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async => {});

        // Act
        await authService.signOut();

        // Assert
        verify(mockFirebaseAuth.signOut()).called(1);
      });
    });

    group('isSignedIn', () {
      test('should return true when user is signed in', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        // Act
        final result = await authService.isSignedIn();

        // Assert
        expect(result, isTrue);
      });

      test('should return false when user is not signed in', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Act
        final result = await authService.isSignedIn();

        // Assert
        expect(result, isFalse);
      });
    });

    group('getCurrentUser', () {
      test('should return current user when signed in', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        // Act
        final result = await authService.getCurrentUser();

        // Assert
        expect(result, mockUser);
      });

      test('should return null when not signed in', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Act
        final result = await authService.getCurrentUser();

        // Assert
        expect(result, isNull);
      });
    });
  });
}
