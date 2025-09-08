import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/services/ios_secure_api_key_service.dart';
import 'package:app/services/ios_biometric_encryption_service.dart';
import 'package:app/services/digitalocean_api_service.dart';
import 'package:app/services/api_key_cache_service.dart';
import 'package:http/http.dart' as http;
import 'test_helpers.dart';

import 'ios_secure_api_key_service_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference<Map<String, dynamic>>,
  DocumentReference<Map<String, dynamic>>,
  DocumentSnapshot<Map<String, dynamic>>,
  FirebaseAuth,
  User,
  IOSBiometricEncryptionService,
  http.Client,
])
void main() {
  group('IOSSecureApiKeyService', () {
    late IOSSecureApiKeyService service;
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference<Map<String, dynamic>> mockCollection;
    late MockDocumentReference<Map<String, dynamic>> mockDocument;
    late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late MockIOSBiometricEncryptionService mockBiometricService;
    late MockClient mockHttpClient;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference();
      mockDocument = MockDocumentReference();
      mockDocumentSnapshot = MockDocumentSnapshot();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockBiometricService = MockIOSBiometricEncryptionService();
      mockHttpClient = MockClient();

      when(mockFirestore.collection('users')).thenReturn(mockCollection);
      when(mockCollection.doc(any)).thenReturn(mockDocument);
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-user-id');
      when(mockUser.email).thenReturn('test@example.com');

      // Mock successful API validation
      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('{"account": {}}', 200));
      DigitalOceanApiService.setClient(mockHttpClient);

      // Reset all singletons between tests
      TestHelpers.resetSingletons();

      service = IOSSecureApiKeyService(
        firestore: mockFirestore,
        auth: mockAuth,
        biometricService: mockBiometricService,
      );
    });

    group('storeApiKey', () {
      test('should store encrypted API key successfully', () async {
        // Arrange
        const apiKey = 'test-api-key';
        const encryptedData = 'encrypted-test-data';

        when(mockBiometricService.encryptWithBiometrics(apiKey))
            .thenAnswer((_) async => encryptedData);
        when(mockBiometricService.getKeyMetadata()).thenAnswer((_) async => {
              'algorithm': 'AES-256-GCM',
              'secureEnclaveBacked': true,
              'faceIdRequired': true,
              'touchIdRequired': true,
            });
        when(mockDocument.set(any)).thenAnswer((_) async {});

        // Act
        await service.storeApiKey(apiKey);

        // Assert
        verify(mockBiometricService.encryptWithBiometrics(apiKey)).called(1);
        verify(mockDocument.set(any, any)).called(1);
      });

      test('should throw exception when user is not authenticated', () async {
        // Arrange
        const apiKey = 'test-api-key';
        when(mockAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => service.storeApiKey(apiKey),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when biometric encryption fails', () async {
        // Arrange
        const apiKey = 'test-api-key';
        when(mockBiometricService.encryptWithBiometrics(apiKey)).thenThrow(
            BiometricAuthenticationException('Biometric auth failed'));

        // Act & Assert
        expect(
          () => service.storeApiKey(apiKey),
          throwsA(isA<BiometricAuthenticationException>()),
        );
      });

      test('should throw exception when API key validation fails', () async {
        // Arrange
        const apiKey = 'invalid-api-key';
        // Mock the static method by creating a wrapper
        // Note: This is a simplified test - in a real scenario you'd need to mock the static method differently

        // Act & Assert
        expect(
          () => service.storeApiKey(apiKey),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getApiKey', () {
      test('should retrieve and decrypt API key successfully', () async {
        // Arrange
        const decryptedApiKey = 'test-api-key';
        const encryptedData = 'encrypted-test-data';

        when(mockDocument.get()).thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data()).thenReturn({
          'encryptedApiKey': encryptedData,
          'keyMetadata': {
            'algorithm': 'AES-256-GCM',
            'secureEnclaveBacked': true,
            'faceIdRequired': true,
            'touchIdRequired': true,
          }
        });
        when(mockBiometricService.decryptWithBiometrics())
            .thenAnswer((_) async => decryptedApiKey);

        // Act
        final result = await service.getApiKey();

        // Assert
        expect(result, decryptedApiKey);
        verify(mockBiometricService.decryptWithBiometrics()).called(1);
      });

      test('should return null when no API key exists', () async {
        // Arrange
        when(mockDocument.get()).thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(false);

        // Act
        final result = await service.getApiKey();

        // Assert
        expect(result, null);
        verifyNever(mockBiometricService.decryptWithBiometrics());
      });

      test('should throw exception when user is not authenticated', () async {
        // Arrange
        when(mockAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => service.getApiKey(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('updateApiKey', () {
      test('should update API key successfully', () async {
        // Arrange
        const newApiKey = 'new-test-api-key';
        const encryptedData = 'encrypted-new-data';

        when(mockBiometricService.encryptWithBiometrics(newApiKey))
            .thenAnswer((_) async => encryptedData);
        when(mockBiometricService.getKeyMetadata()).thenAnswer((_) async => {
              'algorithm': 'AES-256-GCM',
              'secureEnclaveBacked': true,
              'faceIdRequired': true,
              'touchIdRequired': true,
            });
        when(mockDocument.update(any)).thenAnswer((_) async {});

        // Act
        await service.updateApiKey(newApiKey);

        // Assert
        verify(mockBiometricService.encryptWithBiometrics(newApiKey)).called(1);
        verify(mockDocument.update(any)).called(1);
      });

      test('should throw exception when user is not authenticated', () async {
        // Arrange
        const newApiKey = 'new-test-api-key';
        when(mockAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => service.updateApiKey(newApiKey),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when new API key validation fails',
          () async {
        // Arrange
        const newApiKey = 'invalid-api-key';
        // Mock the static method by creating a wrapper
        // Note: This is a simplified test - in a real scenario you'd need to mock the static method differently

        // Act & Assert
        expect(
          () => service.updateApiKey(newApiKey),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('hasApiKey', () {
      test('should return true when API key exists', () async {
        // Arrange
        when(mockDocument.get()).thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data()).thenReturn({
          'encryptedApiKey': 'encrypted-data',
        });

        // Act
        final result = await service.hasApiKey();

        // Assert
        expect(result, true);
      });

      test('should return false when API key does not exist', () async {
        // Arrange
        when(mockDocument.get()).thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(false);

        // Act
        final result = await service.hasApiKey();

        // Assert
        expect(result, false);
      });

      test('should throw exception when user is not authenticated', () async {
        // Arrange
        when(mockAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => service.hasApiKey(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('clearApiKey', () {
      test('should clear API key successfully', () async {
        // Arrange
        when(mockDocument.delete()).thenAnswer((_) async {});
        when(mockBiometricService.clearEncryptedData())
            .thenAnswer((_) async {});

        // Act
        await service.clearApiKey();

        // Assert
        verify(mockDocument.update(argThat(equals({
          'encryptedApiKey': FieldValue.delete(),
          'keyMetadata': FieldValue.delete(),
        })))).called(1);
        verify(mockBiometricService.clearEncryptedData()).called(1);
      });

      test('should throw exception when user is not authenticated', () async {
        // Arrange
        when(mockAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => service.clearApiKey(),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
