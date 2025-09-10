import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'ios_biometric_encryption_service.dart';
import 'api_key_cache_service.dart';
import 'package:minecraft_server_automation/common/interfaces/biometric_auth_service.dart'
    as interfaces;
import 'package:minecraft_server_automation/common/di/service_locator.dart';

/// iOS Secure API Key Service for storing encrypted API keys in Firestore
/// Now includes in-memory caching to reduce Face ID/Touch ID prompts
class IOSSecureApiKeyService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final IOSBiometricEncryptionService _biometricService;
  final ApiKeyCacheService _cacheService;

  IOSSecureApiKeyService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required IOSBiometricEncryptionService biometricService,
    ApiKeyCacheService? cacheService,
  })  : _firestore = firestore,
        _auth = auth,
        _biometricService = biometricService,
        _cacheService = cacheService ?? ApiKeyCacheService() {
    // Initialize the cache service with our dependencies
    _cacheService.initialize(
      apiKeyService: this,
    );
  }

  /// Stores an encrypted API key in Firestore with biometric protection
  Future<void> storeApiKey(String apiKey) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated to store API key');
    }

    try {
      // Validate the API key before storing
      final isValid =
          await ServiceLocator().digitalOceanApiService.validateApiKey(apiKey);
      if (!isValid) {
        throw Exception(
            'Invalid DigitalOcean API key. Please check your key and try again.');
      }

      // Encrypt the API key using biometric authentication
      final encryptedApiKey =
          await _biometricService.encryptWithBiometrics(apiKey);

      // Get key metadata
      final metadata = await _biometricService.getKeyMetadata();

      // Store in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'encryptedApiKey': encryptedApiKey,
        'keyMetadata': metadata ??
            {
              'algorithm': 'AES-256-GCM',
              'secureEnclaveBacked': true,
              'faceIdRequired': true,
              'touchIdRequired': true,
              'createdAt': DateTime.now().toIso8601String(),
              'lastUpdated': DateTime.now().toIso8601String(),
            },
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (e is BiometricAuthenticationException ||
          e is BiometricNotAvailableException) {
        rethrow;
      }
      throw Exception('Failed to store API key: $e');
    }
  }

  /// Retrieves and decrypts the API key using biometric authentication
  /// Uses in-memory cache to avoid repeated Face ID/Touch ID prompts
  Future<String?> getApiKey() async {
    return await _cacheService.getApiKey();
  }

  /// Internal method to decrypt API key from secure storage
  /// This is called by the cache service when needed
  Future<String?> decryptApiKeyFromStorage() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated to retrieve API key');
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final data = doc.data()!;
      final encryptedApiKey = data['encryptedApiKey'] as String?;

      if (encryptedApiKey == null) {
        return null;
      }

      // Decrypt using biometric authentication
      return await _biometricService.decryptWithBiometrics();
    } catch (e) {
      if (e is BiometricAuthenticationException ||
          e is BiometricNotAvailableException ||
          e is NoEncryptedDataException) {
        rethrow;
      }
      throw Exception('Failed to retrieve API key: $e');
    }
  }

  /// Updates the existing API key with new encrypted data
  Future<void> updateApiKey(String newApiKey) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated to update API key');
    }

    try {
      // Validate the new API key before updating
      final isValid = await ServiceLocator()
          .digitalOceanApiService
          .validateApiKey(newApiKey);
      if (!isValid) {
        throw Exception(
            'Invalid DigitalOcean API key. Please check your key and try again.');
      }

      // Encrypt the new API key using biometric authentication
      final encryptedApiKey =
          await _biometricService.encryptWithBiometrics(newApiKey);

      // Get updated key metadata
      final metadata = await _biometricService.getKeyMetadata();

      // Update in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'encryptedApiKey': encryptedApiKey,
        'keyMetadata': metadata ??
            {
              'algorithm': 'AES-256-GCM',
              'secureEnclaveBacked': true,
              'faceIdRequired': true,
              'touchIdRequired': true,
              'lastUpdated': DateTime.now().toIso8601String(),
            },
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Clear the cache since we have a new API key
      _cacheService.clearCache();
    } catch (e) {
      if (e is BiometricAuthenticationException ||
          e is BiometricNotAvailableException) {
        rethrow;
      }
      throw Exception('Failed to update API key: $e');
    }
  }

  /// Checks if an API key exists for the current user
  Future<bool> hasApiKey() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated to check for API key');
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists || doc.data() == null) {
        return false;
      }

      final data = doc.data()!;
      return data['encryptedApiKey'] != null;
    } catch (e) {
      throw Exception('Failed to check for API key: $e');
    }
  }

  /// Clears the API key from both Firestore and local secure storage
  Future<void> clearApiKey() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated to clear API key');
    }

    try {
      // Clear only the API key fields from Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'encryptedApiKey': FieldValue.delete(),
        'keyMetadata': FieldValue.delete(),
      });

      // Clear from local secure storage
      await _biometricService.clearEncryptedData();

      // Clear the cache
      _cacheService.clearCache();
    } catch (e) {
      throw Exception('Failed to clear API key: $e');
    }
  }

  /// Gets the key metadata for the current user
  Future<Map<String, dynamic>?> getKeyMetadata() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated to get key metadata');
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final data = doc.data()!;
      return data['keyMetadata'] as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Failed to get key metadata: $e');
    }
  }

  /// Checks if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    return await _biometricService.isBiometricAvailable();
  }

  /// Gets available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    final biometricTypes = await _biometricService.getAvailableBiometrics();
    return biometricTypes.map((type) {
      switch (type) {
        case interfaces.BiometricType.fingerprint:
          return BiometricType.fingerprint;
        case interfaces.BiometricType.face:
          return BiometricType.face;
        case interfaces.BiometricType.iris:
          return BiometricType.iris;
        // Note: voice is not available in local_auth package
        // case interfaces.BiometricType.voice:
        //   return BiometricType.voice;
        default:
          return BiometricType.fingerprint;
      }
    }).toList();
  }

  /// Handle app lifecycle changes - clear cache when app goes to background
  void onAppPaused() {
    _cacheService.onAppPaused();
  }

  /// Handle app resume
  void onAppResumed() {
    _cacheService.onAppResumed();
  }

  /// Clear cache on sign out
  void onSignOut() {
    _cacheService.clearCache();
  }

  /// Get cache status for debugging
  Map<String, dynamic> getCacheStatus() {
    return _cacheService.getCacheStatus();
  }
}
