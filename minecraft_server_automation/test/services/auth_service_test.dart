import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:minecraft_server_automation/services/auth_service.dart';
import 'package:minecraft_server_automation/services/encryption_service.dart';

import 'auth_service_test.mocks.dart';

// Generate mocks for Firebase services
@GenerateMocks([
  FirebaseAuth,
  User,
  UserCredential,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  SharedPreferences,
  EncryptionService,
])
void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockSharedPreferences mockSharedPreferences;
    late MockEncryptionService mockEncryptionService;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;
    late MockDocumentSnapshot mockDocumentSnapshot;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockSharedPreferences = MockSharedPreferences();
      mockEncryptionService = MockEncryptionService();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();
      mockDocumentSnapshot = MockDocumentSnapshot();

      authService = AuthService(
        firebaseAuth: mockFirebaseAuth,
        firestore: mockFirestore,
        sharedPreferences: mockSharedPreferences,
        encryptionService: mockEncryptionService,
      );
    });

    group('Sign Up', () {
      test('should successfully sign up a new user', () async {
        // Setup mocks
        when(mockUser.uid).thenReturn('test-uid-123');
        when(mockUser.email).thenReturn('test@example.com');
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => mockUserCredential);

        // Mock Firestore collection and document operations
        final mockCollectionReference =
            MockCollectionReference<Map<String, dynamic>>();
        final mockDocumentReference =
            MockDocumentReference<Map<String, dynamic>>();
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(any))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.set(any, any)).thenAnswer((_) async {});

        final result =
            await authService.signUp('test@example.com', 'password123');

        expect(result, isTrue);
        verify(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
        verify(mockDocumentReference.set(any, any)).called(1);
      });

      test('should return false when Firebase sign up fails', () async {
        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(FirebaseAuthException(
          code: 'auth/email-already-in-use',
          message: 'Email already in use',
        ));

        final result =
            await authService.signUp('test@example.com', 'password123');

        expect(result, isFalse);
      });

      test('should return false when user creation returns null user',
          () async {
        when(mockUserCredential.user).thenReturn(null);
        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => mockUserCredential);

        final result =
            await authService.signUp('test@example.com', 'password123');

        expect(result, isFalse);
      });

      test('should return false when Firestore set fails', () async {
        // Setup successful Firebase auth
        when(mockUser.uid).thenReturn('test-uid-123');
        when(mockUser.email).thenReturn('test@example.com');
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => mockUserCredential);

        // Setup Firestore to throw
        final mockCollectionReference =
            MockCollectionReference<Map<String, dynamic>>();
        final mockDocumentReference =
            MockDocumentReference<Map<String, dynamic>>();
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(any))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.set(any, any))
            .thenThrow(Exception('Firestore error'));

        final result =
            await authService.signUp('test@example.com', 'password123');

        expect(result, isFalse);
      });
    });

    group('Sign In', () {
      test('should successfully sign in an existing user', () async {
        // Setup mocks
        when(mockUser.uid).thenReturn('test-uid-123');
        when(mockUser.email).thenReturn('test@example.com');
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => mockUserCredential);
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        // Mock Firestore update
        final mockCollectionReference =
            MockCollectionReference<Map<String, dynamic>>();
        final mockDocumentReference =
            MockDocumentReference<Map<String, dynamic>>();
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(any))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.update(any)).thenAnswer((_) async {});

        final result =
            await authService.signIn('test@example.com', 'password123');

        expect(result, isTrue);
        verify(mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
        verify(mockDocumentReference.update(any)).called(1);
      });

      test('should return false when Firebase sign in fails', () async {
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(FirebaseAuthException(
          code: 'auth/user-not-found',
          message: 'User not found',
        ));

        final result =
            await authService.signIn('test@example.com', 'password123');

        expect(result, isFalse);
      });

      test('should return false when Firestore update fails', () async {
        // Setup successful Firebase auth
        when(mockUser.uid).thenReturn('test-uid-123');
        when(mockUser.email).thenReturn('test@example.com');
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => mockUserCredential);
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        // Setup Firestore to throw
        final mockCollectionReference =
            MockCollectionReference<Map<String, dynamic>>();
        final mockDocumentReference =
            MockDocumentReference<Map<String, dynamic>>();
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(any))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.update(any))
            .thenThrow(Exception('Firestore update error'));

        final result =
            await authService.signIn('test@example.com', 'password123');

        expect(result, isFalse);
      });
    });

    group('Sign Out', () {
      test('should successfully sign out user', () async {
        // Setup signed-in user
        when(mockUser.uid).thenReturn('test-uid-123');
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});
        when(mockSharedPreferences.remove('encrypted_api_key'))
            .thenAnswer((_) async => true);

        await authService.signOut();

        verify(mockFirebaseAuth.signOut()).called(1);
        verify(mockSharedPreferences.remove('encrypted_api_key')).called(1);
      });

      test('should handle sign out when no user is signed in', () async {
        when(mockFirebaseAuth.currentUser).thenReturn(null);
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});
        when(mockSharedPreferences.remove('encrypted_api_key'))
            .thenAnswer((_) async => true);

        await authService.signOut();

        verify(mockFirebaseAuth.signOut()).called(1);
        verify(mockSharedPreferences.remove('encrypted_api_key')).called(1);
      });
    });

    group('Authentication Status', () {
      test('should return true when user is signed in', () async {
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        final isSignedIn = await authService.isSignedIn();

        expect(isSignedIn, isTrue);
      });

      test('should return false when no user is signed in', () async {
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        final isSignedIn = await authService.isSignedIn();

        expect(isSignedIn, isFalse);
      });

      test('should return current user when signed in', () async {
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        final currentUser = await authService.getCurrentUser();

        expect(currentUser, equals(mockUser));
      });

      test('should return null when no user is signed in', () async {
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        final currentUser = await authService.getCurrentUser();

        expect(currentUser, isNull);
      });
    });

    group('API Key Management', () {
      test('should successfully decrypt API key', () async {
        const testApiKey = 'test-api-key-123';
        const testPassword = 'test-password';
        const encryptedKey = 'encrypted_test-api-key-123';

        when(mockSharedPreferences.getString('encrypted_api_key'))
            .thenReturn(encryptedKey);
        when(mockEncryptionService.decrypt(encryptedKey, testPassword))
            .thenReturn(testApiKey);

        final decryptedKey = await authService.getDecryptedApiKey(testPassword);

        expect(decryptedKey, equals(testApiKey));
        verify(mockEncryptionService.decrypt(encryptedKey, testPassword))
            .called(1);
      });

      test('should return null when no encrypted key exists', () async {
        const testPassword = 'test-password';

        when(mockSharedPreferences.getString('encrypted_api_key'))
            .thenReturn(null);

        final decryptedKey = await authService.getDecryptedApiKey(testPassword);

        expect(decryptedKey, isNull);
        verifyNever(mockEncryptionService.decrypt(any, any));
      });

      test('should return null when decryption fails', () async {
        const testPassword = 'test-password';
        const encryptedKey = 'encrypted_test-api-key-123';

        when(mockSharedPreferences.getString('encrypted_api_key'))
            .thenReturn(encryptedKey);
        when(mockEncryptionService.decrypt(encryptedKey, testPassword))
            .thenThrow(Exception('Decryption failed'));

        final decryptedKey = await authService.getDecryptedApiKey(testPassword);

        expect(decryptedKey, isNull);
      });

      test('should successfully update API key', () async {
        const newApiKey = 'new-api-key-456';
        const password = 'test-password';
        const encryptedKey = 'encrypted_new-api-key-456';

        when(mockEncryptionService.encrypt(newApiKey, password))
            .thenReturn(encryptedKey);
        when(mockSharedPreferences.setString('encrypted_api_key', encryptedKey))
            .thenAnswer((_) async => true);

        final result = await authService.updateApiKey(newApiKey, password);

        expect(result, isTrue);
        verify(mockEncryptionService.encrypt(newApiKey, password)).called(1);
        verify(mockSharedPreferences.setString(
                'encrypted_api_key', encryptedKey))
            .called(1);
      });

      test('should return false when encryption fails during update', () async {
        const newApiKey = 'new-api-key-456';
        const password = 'test-password';

        when(mockEncryptionService.encrypt(newApiKey, password))
            .thenThrow(Exception('Encryption failed'));

        final result = await authService.updateApiKey(newApiKey, password);

        expect(result, isFalse);
        verifyNever(mockSharedPreferences.setString(any, any));
      });
    });

    group('User Data', () {
      test('should return null when no user is signed in', () async {
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        final userData = await authService.getUserData();

        expect(userData, isNull);
      });

      test('should return null when Firestore get fails', () async {
        when(mockUser.uid).thenReturn('test-uid-123');
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        final mockCollectionReference =
            MockCollectionReference<Map<String, dynamic>>();
        final mockDocumentReference =
            MockDocumentReference<Map<String, dynamic>>();
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(any))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.get())
            .thenThrow(Exception('Firestore get failed'));

        final userData = await authService.getUserData();

        expect(userData, isNull);
      });
    });

    group('Constructor', () {
      test('should create service with default encryption service', () {
        final service = AuthService(
          firebaseAuth: mockFirebaseAuth,
          firestore: mockFirestore,
          sharedPreferences: mockSharedPreferences,
        );

        expect(service, isNotNull);
      });

      test('should create service with custom encryption service', () {
        final customEncryptionService = MockEncryptionService();
        final service = AuthService(
          firebaseAuth: mockFirebaseAuth,
          firestore: mockFirestore,
          sharedPreferences: mockSharedPreferences,
          encryptionService: customEncryptionService,
        );

        expect(service, isNotNull);
      });
    });
  });
}
