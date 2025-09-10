import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:minecraft_server_automation/services/ios_biometric_encryption_service.dart';
import '../test_helpers/ios_biometric_test_helper.dart';

import 'ios_biometric_encryption_service_test.mocks.dart';

@GenerateMocks([LocalAuthentication, FlutterSecureStorage])
void main() {
  group('IOSBiometricEncryptionService', () {
    late IOSBiometricEncryptionService service;
    late MockLocalAuthentication mockLocalAuth;
    late MockFlutterSecureStorage mockSecureStorage;

    setUp(() {
      mockLocalAuth = MockLocalAuthentication();
      mockSecureStorage = MockFlutterSecureStorage();
      service = IOSBiometricEncryptionService(
        localAuth: mockLocalAuth,
        secureStorage: mockSecureStorage,
      );
    });

    group('isBiometricAvailable', () {
      test(
          'should return true when biometrics are available and device is supported',
          () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);

        // Act
        final result = await service.isBiometricAvailable();

        // Assert
        expect(result, isTrue);
        verify(mockLocalAuth.canCheckBiometrics).called(1);
        verify(mockLocalAuth.isDeviceSupported()).called(1);
      });

      test('should return false when biometrics are not available', () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => false);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);

        // Act
        final result = await service.isBiometricAvailable();

        // Assert
        expect(result, isFalse);
      });

      test('should return false when device is not supported', () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => false);

        // Act
        final result = await service.isBiometricAvailable();

        // Assert
        expect(result, isFalse);
      });

      test('should return false when exception occurs', () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics)
            .thenThrow(Exception('Test error'));

        // Act
        final result = await service.isBiometricAvailable();

        // Assert
        expect(result, isFalse);
      });
    });

    group('getAvailableBiometrics', () {
      test('should return available biometric types', () async {
        // Arrange
        final expectedBiometrics = [
          BiometricType.fingerprint,
          BiometricType.face
        ];
        when(mockLocalAuth.getAvailableBiometrics())
            .thenAnswer((_) async => expectedBiometrics);

        // Act
        final result = await service.getAvailableBiometrics();

        // Assert
        expect(result, equals(expectedBiometrics));
        verify(mockLocalAuth.getAvailableBiometrics()).called(1);
      });

      test('should return empty list when exception occurs', () async {
        // Arrange
        when(mockLocalAuth.getAvailableBiometrics())
            .thenThrow(Exception('Test error'));

        // Act
        final result = await service.getAvailableBiometrics();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('encryptWithBiometrics', () {
      test('should throw ArgumentError when data is empty', () async {
        // Act & Assert
        expect(
          () => service.encryptWithBiometrics(''),
          throwsA(isA<ArgumentError>()),
        );
      });

      test(
          'should throw BiometricNotAvailableException when biometrics are not available',
          () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => false);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);

        // Act & Assert
        expect(
          () => service.encryptWithBiometrics('test data'),
          throwsA(isA<BiometricNotAvailableException>()),
        );
      });

      test(
          'should throw BiometricAuthenticationException when authentication fails',
          () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => false);

        // Act & Assert
        expect(
          () => service.encryptWithBiometrics('test data'),
          throwsA(isA<BiometricAuthenticationException>()),
        );
      });

      test(
          'should successfully encrypt data when biometric authentication succeeds',
          () async {
        // Arrange
        const testData = 'test data';
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => true);

        // Mock secure storage to return null for existing key (new key generation)
        when(mockSecureStorage.read(key: 'ios_encryption_key'))
            .thenAnswer((_) async => null);
        when(mockSecureStorage.write(
                key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async {});

        // Act
        final result = await service.encryptWithBiometrics(testData);

        // Assert
        expect(result, isNotEmpty);
        expect(result, isA<String>());

        // Verify authentication was called
        verify(mockLocalAuth.authenticate(
          localizedReason: 'Authenticate to encrypt your API key securely',
          options: anyNamed('options'),
        )).called(1);

        // Verify secure storage operations
        verify(mockSecureStorage.read(key: 'ios_encryption_key')).called(1);
        verify(mockSecureStorage.write(
                key: 'ios_encryption_key', value: anyNamed('value')))
            .called(1);
        verify(mockSecureStorage.write(
                key: 'ios_encrypted_api_key', value: anyNamed('value')))
            .called(1);
        verify(mockSecureStorage.write(
                key: 'ios_key_metadata', value: anyNamed('value')))
            .called(1);
      });

      test('should use existing encryption key when available', () async {
        // Arrange
        const testData = 'test data';
        // Create a valid 32-byte key and encode it as base64
        final existingKey = IOSBiometricTestHelper.encodeTestKey();

        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => true);

        // Mock secure storage to return existing key
        when(mockSecureStorage.read(key: 'ios_encryption_key'))
            .thenAnswer((_) async => existingKey);
        when(mockSecureStorage.write(
                key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async {});

        // Act
        final result = await service.encryptWithBiometrics(testData);

        // Assert
        expect(result, isNotEmpty);

        // Verify existing key was read
        verify(mockSecureStorage.read(key: 'ios_encryption_key')).called(1);
        // Should not write a new key
        verifyNever(mockSecureStorage.write(
            key: 'ios_encryption_key', value: anyNamed('value')));
      });
    });

    group('decryptWithBiometrics', () {
      test(
          'should throw BiometricNotAvailableException when biometrics are not available',
          () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => false);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);

        // Act & Assert
        expect(
          () => service.decryptWithBiometrics(),
          throwsA(isA<BiometricNotAvailableException>()),
        );
      });

      test(
          'should throw NoEncryptedDataException when no encrypted data exists',
          () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockSecureStorage.read(key: 'ios_encrypted_api_key'))
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => service.decryptWithBiometrics(),
          throwsA(isA<NoEncryptedDataException>()),
        );
      });

      test(
          'should throw BiometricAuthenticationException when authentication fails',
          () async {
        // Arrange
        const encryptedData = 'base64EncodedData';
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockSecureStorage.read(key: 'ios_encrypted_api_key'))
            .thenAnswer((_) async => encryptedData);
        when(mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => false);

        // Act & Assert
        expect(
          () => service.decryptWithBiometrics(),
          throwsA(isA<BiometricAuthenticationException>()),
        );
      });

      test('should successfully decrypt data when authentication succeeds',
          () async {
        // Arrange
        const testData = 'test data';
        // Create a valid 32-byte key and encode it as base64
        final existingKey = IOSBiometricTestHelper.encodeTestKey();

        // Create a valid encrypted data structure (IV + encrypted data)
        final combined =
            IOSBiometricTestHelper.createValidEncryptedData(testData);

        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockSecureStorage.read(key: 'ios_encrypted_api_key'))
            .thenAnswer((_) async => combined);
        when(mockSecureStorage.read(key: 'ios_encryption_key'))
            .thenAnswer((_) async => existingKey);
        when(mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => true);

        // Act
        final result = await service.decryptWithBiometrics();

        // Assert
        expect(result, equals(testData));

        // Verify authentication was called
        verify(mockLocalAuth.authenticate(
          localizedReason: 'Authenticate to decrypt your API key',
          options: anyNamed('options'),
        )).called(1);
      });
    });

    group('hasEncryptedData', () {
      test('should return true when encrypted data exists', () async {
        // Arrange
        when(mockSecureStorage.read(key: 'ios_encrypted_api_key'))
            .thenAnswer((_) async => 'some data');

        // Act
        final result = await service.hasEncryptedData();

        // Assert
        expect(result, isTrue);
        verify(mockSecureStorage.read(key: 'ios_encrypted_api_key')).called(1);
      });

      test('should return false when no encrypted data exists', () async {
        // Arrange
        when(mockSecureStorage.read(key: 'ios_encrypted_api_key'))
            .thenAnswer((_) async => null);

        // Act
        final result = await service.hasEncryptedData();

        // Assert
        expect(result, isFalse);
      });
    });

    group('getKeyMetadata', () {
      test('should return metadata when it exists', () async {
        // Arrange
        final metadata = IOSBiometricTestHelper.createValidMetadata();
        final metadataJson = jsonEncode(metadata);
        when(mockSecureStorage.read(key: 'ios_key_metadata'))
            .thenAnswer((_) async => metadataJson);

        // Act
        final result = await service.getKeyMetadata();

        // Assert
        expect(result, isNotNull);
        expect(result!['algorithm'], equals('AES-256-GCM'));
        verify(mockSecureStorage.read(key: 'ios_key_metadata')).called(1);
      });

      test('should return null when no metadata exists', () async {
        // Arrange
        when(mockSecureStorage.read(key: 'ios_key_metadata'))
            .thenAnswer((_) async => null);

        // Act
        final result = await service.getKeyMetadata();

        // Assert
        expect(result, isNull);
      });

      test('should return null when metadata is invalid JSON', () async {
        // Arrange
        when(mockSecureStorage.read(key: 'ios_key_metadata')).thenAnswer(
            (_) async => IOSBiometricTestHelper.createInvalidJsonMetadata());

        // Act
        final result = await service.getKeyMetadata();

        // Assert
        expect(result, isNull);
      });
    });

    group('clearEncryptedData', () {
      test('should clear all encrypted data and metadata', () async {
        // Arrange
        when(mockSecureStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async {});

        // Act
        await service.clearEncryptedData();

        // Assert
        verify(mockSecureStorage.delete(key: 'ios_encrypted_api_key'))
            .called(1);
        verify(mockSecureStorage.delete(key: 'ios_key_metadata')).called(1);
        verify(mockSecureStorage.delete(key: 'ios_encryption_key')).called(1);
      });
    });

    group('rotateEncryptionKey', () {
      test('should clear all data when rotating encryption key', () async {
        // Arrange
        when(mockSecureStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async {});

        // Act
        await service.rotateEncryptionKey();

        // Assert
        verify(mockSecureStorage.delete(key: 'ios_encrypted_api_key'))
            .called(1);
        verify(mockSecureStorage.delete(key: 'ios_key_metadata')).called(1);
        verify(mockSecureStorage.delete(key: 'ios_encryption_key')).called(1);
      });
    });

    group('Edge Cases', () {
      test('should handle corrupted encrypted data during decryption',
          () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockSecureStorage.read(key: 'ios_encrypted_api_key')).thenAnswer(
            (_) async => IOSBiometricTestHelper.createInvalidBase64Data());
        when(mockSecureStorage.read(key: 'ios_encryption_key'))
            .thenAnswer((_) async => IOSBiometricTestHelper.encodeTestKey());
        when(mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => true);

        // Act & Assert
        expect(
          () => service.decryptWithBiometrics(),
          throwsA(isA<BiometricAuthenticationException>()),
        );
      });

      test('should handle corrupted key data during decryption', () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockSecureStorage.read(key: 'ios_encrypted_api_key')).thenAnswer(
            (_) async =>
                IOSBiometricTestHelper.createValidEncryptedData('test'));
        when(mockSecureStorage.read(key: 'ios_encryption_key')).thenAnswer(
            (_) async => IOSBiometricTestHelper.createCorruptedKeyData());
        when(mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => true);

        // Act & Assert
        expect(
          () => service.decryptWithBiometrics(),
          throwsA(isA<BiometricAuthenticationException>()),
        );
      });

      test('should handle corrupted key data during encryption', () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => true);
        when(mockSecureStorage.read(key: 'ios_encryption_key')).thenAnswer(
            (_) async => IOSBiometricTestHelper.createCorruptedKeyData());

        // Act & Assert
        expect(
          () => service.encryptWithBiometrics('test data'),
          throwsA(isA<BiometricAuthenticationException>()),
        );
      });

      test('should handle secure storage read errors during key retrieval',
          () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => true);
        when(mockSecureStorage.read(key: 'ios_encryption_key'))
            .thenThrow(Exception('Storage error'));
        when(mockSecureStorage.write(
                key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async {});

        // Act
        final result = await service.encryptWithBiometrics('test data');

        // Assert - should still work by generating a new key
        expect(result, isNotEmpty);
      });
    });
  });
}
