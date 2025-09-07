import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart';
import 'package:app/services/ios_biometric_encryption_service.dart';

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
      test('should return true when biometrics are available', () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);

        // Act
        final result = await service.isBiometricAvailable();

        // Assert
        expect(result, true);
        verify(mockLocalAuth.canCheckBiometrics).called(1);
        verify(mockLocalAuth.isDeviceSupported()).called(1);
      });

      test('should return false when biometrics are not available', () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => false);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => false);

        // Act
        final result = await service.isBiometricAvailable();

        // Assert
        expect(result, false);
        verify(mockLocalAuth.canCheckBiometrics).called(1);
        verify(mockLocalAuth.isDeviceSupported()).called(1);
      });
    });

    group('encryptWithBiometrics', () {
      test('should encrypt data successfully with biometric authentication', () async {
        // Arrange
        const testData = 'test-api-key';
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => true);
        when(mockSecureStorage.write(
          key: anyNamed('key'),
          value: anyNamed('value'),
        )).thenAnswer((_) async {});

        // Act
        final result = await service.encryptWithBiometrics(testData);

        // Assert
        expect(result, isNotEmpty);
        verify(mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          options: anyNamed('options'),
        )).called(1);
        verify(mockSecureStorage.write(
          key: anyNamed('key'),
          value: anyNamed('value'),
        )).called(2); // Called twice: once for encrypted data, once for metadata
      });

      test('should throw exception when biometric authentication fails', () async {
        // Arrange
        const testData = 'test-api-key';
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => false);

        // Act & Assert
        expect(
          () => service.encryptWithBiometrics(testData),
          throwsA(isA<BiometricAuthenticationException>()),
        );
      });

      test('should throw exception when biometric authentication is not available', () async {
        // Arrange
        const testData = 'test-api-key';
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => false);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => false);

        // Act & Assert
        expect(
          () => service.encryptWithBiometrics(testData),
          throwsA(isA<BiometricNotAvailableException>()),
        );
      });
    });

    group('decryptWithBiometrics', () {
      test('should attempt to decrypt data with biometric authentication', () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => true);
        when(mockSecureStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => 'invalid-encrypted-data');
        when(mockSecureStorage.write(
          key: anyNamed('key'),
          value: anyNamed('value'),
        )).thenAnswer((_) async {});

        // Act & Assert
        // This test verifies that biometric authentication is called
        // The actual decryption will fail due to invalid data, but that's expected
        expect(
          () => service.decryptWithBiometrics(),
          throwsA(isA<BiometricAuthenticationException>()),
        );
        // Verify that biometric availability is checked
        verify(mockLocalAuth.canCheckBiometrics).called(1);
      });

      test('should throw exception when no encrypted data exists', () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => true);
        when(mockSecureStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => service.decryptWithBiometrics(),
          throwsA(isA<NoEncryptedDataException>()),
        );
      });

      test('should throw exception when biometric authentication fails', () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
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
    });

    group('clearEncryptedData', () {
      test('should clear encrypted data successfully', () async {
        // Arrange
        when(mockSecureStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async {});

        // Act
        await service.clearEncryptedData();

        // Assert
        verify(mockSecureStorage.delete(key: anyNamed('key'))).called(2); // Called twice: once for encrypted data, once for metadata
      });
    });
  });
}
