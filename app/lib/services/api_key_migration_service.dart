import 'package:shared_preferences/shared_preferences.dart';
import 'encryption_service.dart';
import 'ios_secure_api_key_service.dart';
import 'ios_biometric_encryption_service.dart';

/// Service for migrating from password-based to biometric API key encryption
class ApiKeyMigrationService {
  final SharedPreferences _sharedPreferences;
  final EncryptionService _encryptionService;
  final IOSSecureApiKeyService _iosSecureApiKeyService;
  final IOSBiometricEncryptionService _biometricService;

  ApiKeyMigrationService({
    required SharedPreferences sharedPreferences,
    required EncryptionService encryptionService,
    required IOSSecureApiKeyService iosSecureApiKeyService,
    required IOSBiometricEncryptionService biometricService,
  }) : _sharedPreferences = sharedPreferences,
        _encryptionService = encryptionService,
        _iosSecureApiKeyService = iosSecureApiKeyService,
        _biometricService = biometricService;

  /// Checks if migration is needed
  Future<bool> needsMigration() async {
    try {
      // Check if password-based API key exists
      final passwordBasedKey = _sharedPreferences.getString('encrypted_api_key');
      if (passwordBasedKey == null || passwordBasedKey.isEmpty) {
        return false;
      }

      // Check if biometric API key already exists
      final hasBiometricKey = await _iosSecureApiKeyService.hasApiKey();
      if (hasBiometricKey) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Migrates from password-based to biometric encryption
  Future<void> migrateToBiometric(String password) async {
    try {
      // Get the password-based encrypted API key
      final encryptedApiKey = _sharedPreferences.getString('encrypted_api_key');
      if (encryptedApiKey == null || encryptedApiKey.isEmpty) {
        throw Exception('No password-based API key found to migrate');
      }

      // Decrypt using the old password-based method
      final decryptedApiKey = _encryptionService.decrypt(encryptedApiKey, password);
      if (decryptedApiKey.isEmpty) {
        throw Exception('Failed to decrypt API key with provided password');
      }

      // Check if biometric authentication is available
      final biometricAvailable = await _biometricService.isBiometricAvailable();
      if (!biometricAvailable) {
        throw BiometricNotAvailableException('Biometric authentication is not available on this device');
      }

      // Encrypt using biometric authentication
      await _biometricService.encryptWithBiometrics(decryptedApiKey);

      // Store in Firestore using the new biometric service
      await _iosSecureApiKeyService.storeApiKey(decryptedApiKey);

      // Remove the old password-based key
      await _sharedPreferences.remove('encrypted_api_key');

    } catch (e) {
      if (e is BiometricAuthenticationException || 
          e is BiometricNotAvailableException) {
        rethrow;
      }
      throw Exception('Migration failed: $e');
    }
  }

  /// Checks if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    return await _biometricService.isBiometricAvailable();
  }

  /// Gets the current migration status
  Future<Map<String, dynamic>> getMigrationStatus() async {
    try {
      final passwordBasedKey = _sharedPreferences.getString('encrypted_api_key');
      final hasPasswordBasedKey = passwordBasedKey != null && passwordBasedKey.isNotEmpty;
      final hasBiometricKey = await _iosSecureApiKeyService.hasApiKey();
      final biometricAvailable = await _biometricService.isBiometricAvailable();
      final needsMigration = hasPasswordBasedKey && !hasBiometricKey;

      return {
        'needsMigration': needsMigration,
        'biometricAvailable': biometricAvailable,
        'hasPasswordBasedKey': hasPasswordBasedKey,
        'hasBiometricKey': hasBiometricKey,
      };
    } catch (e) {
      return {
        'needsMigration': false,
        'biometricAvailable': false,
        'hasPasswordBasedKey': false,
        'hasBiometricKey': false,
        'error': e.toString(),
      };
    }
  }

  /// Clears all API key data (both password-based and biometric)
  Future<void> clearAllApiKeys() async {
    try {
      // Clear password-based key
      await _sharedPreferences.remove('encrypted_api_key');
      
      // Clear biometric key
      await _iosSecureApiKeyService.clearApiKey();
    } catch (e) {
      throw Exception('Failed to clear API keys: $e');
    }
  }

  /// Gets migration progress information
  Future<Map<String, dynamic>> getMigrationProgress() async {
    try {
      final status = await getMigrationStatus();
      
      if (!status['needsMigration']) {
        return {
          'step': 'completed',
          'message': 'Migration not needed or already completed',
          'progress': 100,
        };
      }

      if (!status['biometricAvailable']) {
        return {
          'step': 'biometric_setup_required',
          'message': 'Please set up Face ID or Touch ID to continue',
          'progress': 0,
        };
      }

      return {
        'step': 'ready_to_migrate',
        'message': 'Ready to migrate to biometric authentication',
        'progress': 50,
      };
    } catch (e) {
      return {
        'step': 'error',
        'message': 'Error checking migration status: $e',
        'progress': 0,
      };
    }
  }
}
