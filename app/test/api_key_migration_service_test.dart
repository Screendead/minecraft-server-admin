import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/services/api_key_migration_service.dart';
import 'package:app/services/encryption_service.dart';
import 'package:app/services/ios_secure_api_key_service.dart';
import 'package:app/services/ios_biometric_encryption_service.dart';

import 'api_key_migration_service_test.mocks.dart';

@GenerateMocks([
  SharedPreferences,
  EncryptionService,
  IOSSecureApiKeyService,
  IOSBiometricEncryptionService,
])
void main() {
  group('ApiKeyMigrationService', () {
    late ApiKeyMigrationService service;
    late MockSharedPreferences mockSharedPreferences;
    late MockEncryptionService mockEncryptionService;
    late MockIOSSecureApiKeyService mockIOSSecureApiKeyService;
    late MockIOSBiometricEncryptionService mockBiometricService;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      mockEncryptionService = MockEncryptionService();
      mockIOSSecureApiKeyService = MockIOSSecureApiKeyService();
      mockBiometricService = MockIOSBiometricEncryptionService();

      service = ApiKeyMigrationService(
        sharedPreferences: mockSharedPreferences,
        encryptionService: mockEncryptionService,
        iosSecureApiKeyService: mockIOSSecureApiKeyService,
        biometricService: mockBiometricService,
      );
    });

    group('needsMigration', () {
      test('should return true when password-based API key exists', () async {
        // Arrange
        when(mockSharedPreferences.getString('encrypted_api_key'))
            .thenReturn('encrypted-password-based-key');
        when(mockIOSSecureApiKeyService.hasApiKey()).thenAnswer((_) async => false);

        // Act
        final result = await service.needsMigration();

        // Assert
        expect(result, true);
      });

      test('should return false when no password-based API key exists', () async {
        // Arrange
        when(mockSharedPreferences.getString('encrypted_api_key'))
            .thenReturn(null);
        when(mockIOSSecureApiKeyService.hasApiKey()).thenAnswer((_) async => false);

        // Act
        final result = await service.needsMigration();

        // Assert
        expect(result, false);
      });

      test('should return false when biometric API key already exists', () async {
        // Arrange
        when(mockSharedPreferences.getString('encrypted_api_key'))
            .thenReturn('encrypted-password-based-key');
        when(mockIOSSecureApiKeyService.hasApiKey()).thenAnswer((_) async => true);

        // Act
        final result = await service.needsMigration();

        // Assert
        expect(result, false);
      });
    });

    group('migrateToBiometric', () {
      test('should migrate API key successfully', () async {
        // Arrange
        const password = 'test-password';
        const apiKey = 'test-api-key';
        const encryptedApiKey = 'encrypted-password-based-key';
        
        when(mockSharedPreferences.getString('encrypted_api_key'))
            .thenReturn(encryptedApiKey);
        when(mockEncryptionService.decrypt(encryptedApiKey, password))
            .thenReturn(apiKey);
        when(mockBiometricService.isBiometricAvailable())
            .thenAnswer((_) async => true);
        when(mockBiometricService.encryptWithBiometrics(apiKey))
            .thenAnswer((_) async => 'encrypted-biometric-key');
        when(mockIOSSecureApiKeyService.storeApiKey(apiKey))
            .thenAnswer((_) async {});
        when(mockSharedPreferences.remove('encrypted_api_key'))
            .thenAnswer((_) async => true);

        // Act
        await service.migrateToBiometric(password);

        // Assert
        verify(mockEncryptionService.decrypt(encryptedApiKey, password)).called(1);
        verify(mockBiometricService.encryptWithBiometrics(apiKey)).called(1);
        verify(mockIOSSecureApiKeyService.storeApiKey(apiKey)).called(1);
        verify(mockSharedPreferences.remove('encrypted_api_key')).called(1);
      });

      test('should throw exception when no password-based API key exists', () async {
        // Arrange
        const password = 'test-password';
        when(mockSharedPreferences.getString('encrypted_api_key'))
            .thenReturn(null);

        // Act & Assert
        expect(
          () => service.migrateToBiometric(password),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when password decryption fails', () async {
        // Arrange
        const password = 'wrong-password';
        const encryptedApiKey = 'encrypted-password-based-key';
        
        when(mockSharedPreferences.getString('encrypted_api_key'))
            .thenReturn(encryptedApiKey);
        when(mockEncryptionService.decrypt(encryptedApiKey, password))
            .thenReturn(''); // Empty string indicates decryption failure

        // Act & Assert
        expect(
          () => service.migrateToBiometric(password),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when biometric encryption fails', () async {
        // Arrange
        const password = 'test-password';
        const apiKey = 'test-api-key';
        const encryptedApiKey = 'encrypted-password-based-key';
        
        when(mockSharedPreferences.getString('encrypted_api_key'))
            .thenReturn(encryptedApiKey);
        when(mockEncryptionService.decrypt(encryptedApiKey, password))
            .thenReturn(apiKey);
        when(mockBiometricService.isBiometricAvailable())
            .thenAnswer((_) async => true);
        when(mockBiometricService.encryptWithBiometrics(apiKey))
            .thenThrow(BiometricAuthenticationException('Biometric auth failed'));

        // Act & Assert
        expect(
          () => service.migrateToBiometric(password),
          throwsA(isA<BiometricAuthenticationException>()),
        );
      });
    });

    group('isBiometricAvailable', () {
      test('should return true when biometric authentication is available', () async {
        // Arrange
        when(mockBiometricService.isBiometricAvailable())
            .thenAnswer((_) async => true);

        // Act
        final result = await service.isBiometricAvailable();

        // Assert
        expect(result, true);
      });

      test('should return false when biometric authentication is not available', () async {
        // Arrange
        when(mockBiometricService.isBiometricAvailable())
            .thenAnswer((_) async => false);

        // Act
        final result = await service.isBiometricAvailable();

        // Assert
        expect(result, false);
      });
    });

    group('getMigrationStatus', () {
      test('should return migration status correctly', () async {
        // Arrange
        when(mockSharedPreferences.getString('encrypted_api_key'))
            .thenReturn('encrypted-password-based-key');
        when(mockIOSSecureApiKeyService.hasApiKey()).thenAnswer((_) async => false);
        when(mockBiometricService.isBiometricAvailable())
            .thenAnswer((_) async => true);

        // Act
        final result = await service.getMigrationStatus();

        // Assert
        expect(result['needsMigration'], true);
        expect(result['biometricAvailable'], true);
        expect(result['hasPasswordBasedKey'], true);
        expect(result['hasBiometricKey'], false);
      });
    });
  });
}
