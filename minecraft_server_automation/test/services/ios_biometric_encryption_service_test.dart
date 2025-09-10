import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart';
import 'package:minecraft_server_automation/services/ios_biometric_encryption_service.dart';

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
        final keyBytes = Uint8List(32);
        for (int i = 0; i < 32; i++) {
          keyBytes[i] = i;
        }
        final existingKey = base64.encode(keyBytes);

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
        final keyBytes = Uint8List(32);
        for (int i = 0; i < 32; i++) {
          keyBytes[i] = i;
        }
        final existingKey = base64.encode(keyBytes);

        // Create a valid encrypted data structure (IV + encrypted data)
        final key = Key(keyBytes);
        final encrypter = Encrypter(AES(key));
        final iv = IV.fromSecureRandom(16);
        final encrypted = encrypter.encrypt(testData, iv: iv);
        final combined = base64.encode(iv.bytes + encrypted.bytes);

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
        const metadataJson =
            '{"algorithm": "AES-256-GCM", "createdAt": "2023-01-01T00:00:00.000Z"}';
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
        when(mockSecureStorage.read(key: 'ios_key_metadata'))
            .thenAnswer((_) async => 'invalid json');

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
  });
}
