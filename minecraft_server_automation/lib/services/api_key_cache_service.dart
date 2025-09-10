import 'dart:async';
import 'ios_biometric_encryption_service.dart';
import 'ios_secure_api_key_service.dart';
import '../common/interfaces/api_key_cache_service.dart' as interfaces;

/// Exception thrown when API key cache operations fail
class ApiKeyCacheException implements Exception {
  final String message;
  ApiKeyCacheException(this.message);

  @override
  String toString() => 'ApiKeyCacheException: $message';
}

/// Secure in-memory API key cache service
///
/// This service provides a secure way to cache decrypted API keys in memory
/// to avoid repeated Face ID/Touch ID prompts. The cache is automatically
/// cleared when the app goes to background or when the user signs out.
///
/// Security features:
/// - Keys are stored in memory only (not persisted)
/// - Automatic cache invalidation on app backgrounding
/// - Cache is cleared on user sign out
/// - Thread-safe operations
class ApiKeyCacheService implements interfaces.ApiKeyCacheServiceInterface {
  static ApiKeyCacheService? _instance;
  factory ApiKeyCacheService() => _instance ??= ApiKeyCacheService._internal();
  ApiKeyCacheService._internal();

  /// Reset the singleton instance (for testing only)
  static void resetInstance() {
    _instance?.dispose();
    _instance = null;
  }

  // Private fields
  String? _cachedApiKey;
  DateTime? _cacheTimestamp;
  Timer? _cacheTimer;
  bool _isInitialized = false;
  final Duration _maxCacheDuration =
      const Duration(hours: 8); // Maximum 8 hours in cache

  // Services
  IOSSecureApiKeyService? _apiKeyService;

  // Synchronization for concurrent access
  Future<String?>? _pendingDecryption;

  /// Initialize the cache service with required dependencies
  void initialize({
    required IOSSecureApiKeyService apiKeyService,
  }) {
    _apiKeyService = apiKeyService;
    _isInitialized = true;
  }

  /// Check if the service is properly initialized
  bool get isInitialized => _isInitialized;

  /// Get the cached API key if available and not expired
  String? getCachedApiKey() {
    if (!_isInitialized) {
      throw ApiKeyCacheException('Service not initialized');
    }

    if (_cachedApiKey == null || _cacheTimestamp == null) {
      return null;
    }

    // Check if cache has expired
    final now = DateTime.now();
    if (now.difference(_cacheTimestamp!) > _maxCacheDuration) {
      _clearCache();
      return null;
    }

    return _cachedApiKey;
  }

  /// Cache an API key with timestamp
  void cacheApiKey(String apiKey) {
    if (!_isInitialized) {
      throw ApiKeyCacheException('Service not initialized');
    }

    _cachedApiKey = apiKey;
    _cacheTimestamp = DateTime.now();

    // Set up automatic cache expiration timer
    _setupCacheTimer();
  }

  /// Get API key from cache or decrypt from secure storage
  /// This is the main method that should be used throughout the app
  Future<String?> getApiKey() async {
    if (!_isInitialized) {
      throw ApiKeyCacheException('Service not initialized');
    }

    // First, try to get from cache
    final cachedKey = getCachedApiKey();
    if (cachedKey != null) {
      return cachedKey;
    }

    // If there's already a decryption in progress, wait for it
    final pendingDecryption = _pendingDecryption;
    if (pendingDecryption != null) {
      return await pendingDecryption;
    }

    // If not in cache, decrypt from secure storage using biometrics
    if (_apiKeyService == null) {
      throw ApiKeyCacheException('API key service not initialized');
    }

    // Create a new decryption future and store it
    _pendingDecryption = _performDecryption();

    try {
      final result = await _pendingDecryption!;
      return result;
    } finally {
      // Clear the pending decryption when done
      _pendingDecryption = null;
    }
  }

  /// Internal method to perform the actual decryption
  Future<String?> _performDecryption() async {
    try {
      // Call the internal decryption method to avoid circular dependency
      final decryptedKey = await _apiKeyService!.decryptApiKeyFromStorage();
      if (decryptedKey != null) {
        // Cache the decrypted key for future use
        cacheApiKey(decryptedKey);
      }
      return decryptedKey;
    } catch (e) {
      // Re-throw biometric authentication exceptions
      if (e is BiometricAuthenticationException ||
          e is BiometricNotAvailableException ||
          e is NoEncryptedDataException) {
        rethrow;
      }
      throw ApiKeyCacheException('Failed to get API key: $e');
    }
  }

  /// Clear the cached API key
  void clearCache() {
    _clearCache();
  }

  /// Check if there's a valid cached API key
  bool hasCachedApiKey() {
    return getCachedApiKey() != null;
  }

  /// Get cache status information
  Map<String, dynamic> getCacheStatus() {
    return {
      'hasCachedKey': _cachedApiKey != null,
      'cacheTimestamp': _cacheTimestamp?.toIso8601String(),
      'isExpired': _cachedApiKey != null && _cacheTimestamp != null
          ? DateTime.now().difference(_cacheTimestamp!) > _maxCacheDuration
          : false,
      'maxCacheDuration': _maxCacheDuration.inMinutes,
    };
  }

  /// Private method to clear the cache
  void _clearCache() {
    _cachedApiKey = null;
    _cacheTimestamp = null;
    _cacheTimer?.cancel();
    _cacheTimer = null;
    _pendingDecryption = null;
  }

  /// Set up automatic cache expiration timer
  void _setupCacheTimer() {
    _cacheTimer?.cancel();
    _cacheTimer = Timer(_maxCacheDuration, () {
      _clearCache();
    });
  }

  /// Handle app lifecycle changes
  void onAppPaused() {
    // Clear cache when app goes to background for security
    _clearCache();
  }

  /// Handle app resume (optional - could be used for re-authentication)
  void onAppResumed() {
    // Cache is cleared on pause, so nothing to do here
    // The next API call will trigger biometric authentication
  }

  /// Dispose of resources
  void dispose() {
    _clearCache();
    _isInitialized = false;
    _apiKeyService = null;
  }
}
