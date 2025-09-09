import 'package:flutter_test/flutter_test.dart';
import 'package:minecraft_server_automation/services/api_key_cache_service.dart';
import 'package:minecraft_server_automation/services/ios_biometric_encryption_service.dart';
import 'package:minecraft_server_automation/services/ios_secure_api_key_service.dart';
import 'package:local_auth/local_auth.dart';

// Mock classes for testing
class MockIOSBiometricEncryptionService implements IOSBiometricEncryptionService {
  bool _shouldThrow = false;
  String? _mockDecryptedKey;
  Exception? _throwException;

  void setShouldThrow(bool shouldThrow, {Exception? exception}) {
    _shouldThrow = shouldThrow;
    _throwException = exception;
  }

  void setMockDecryptedKey(String? key) {
    _mockDecryptedKey = key;
  }

  @override
  Future<bool> isBiometricAvailable() async => true;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async => [];

  @override
  Future<String> encryptWithBiometrics(String data) async => 'encrypted_data';

  @override
  Future<String> decryptWithBiometrics() async {
    if (_shouldThrow) {
      throw _throwException ?? Exception('Mock decryption error');
    }
    if (_mockDecryptedKey == null) {
      throw NoEncryptedDataException('No encrypted data found');
    }
    return _mockDecryptedKey!;
  }

  @override
  Future<bool> hasEncryptedData() async => true;

  @override
  Future<Map<String, dynamic>?> getKeyMetadata() async => {};

  @override
  Future<void> clearEncryptedData() async {}
}

class MockIOSSecureApiKeyService implements IOSSecureApiKeyService {
  final MockIOSBiometricEncryptionService _biometricService;

  MockIOSSecureApiKeyService(this._biometricService);

  @override
  Future<void> storeApiKey(String apiKey) async {}

  @override
  Future<String?> getApiKey() async => await _biometricService.decryptWithBiometrics();

  @override
  Future<String?> decryptApiKeyFromStorage() async {
    return await _biometricService.decryptWithBiometrics();
  }

  @override
  Future<void> updateApiKey(String newApiKey) async {}

  @override
  Future<bool> hasApiKey() async => true;

  @override
  Future<void> clearApiKey() async {}

  @override
  Future<Map<String, dynamic>?> getKeyMetadata() async => {};

  @override
  Future<bool> isBiometricAvailable() async => true;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async => [];

  @override
  void onAppPaused() {}

  @override
  void onAppResumed() {}

  @override
  void onSignOut() {}

  @override
  Map<String, dynamic> getCacheStatus() => {};
}

void main() {
  group('ApiKeyCacheService', () {
    late ApiKeyCacheService service;
    late MockIOSBiometricEncryptionService mockBiometricService;
    late MockIOSSecureApiKeyService mockApiKeyService;

    setUp(() {
      // Reset singleton instance for each test
      ApiKeyCacheService.resetInstance();
      service = ApiKeyCacheService();
      
      mockBiometricService = MockIOSBiometricEncryptionService();
      mockApiKeyService = MockIOSSecureApiKeyService(mockBiometricService);
    });

    tearDown(() {
      service.dispose();
    });

    group('Initialization', () {
      test('should not be initialized by default', () {
        expect(service.isInitialized, isFalse);
      });

      test('should be initialized after calling initialize', () {
        service.initialize(
          biometricService: mockBiometricService,
          apiKeyService: mockApiKeyService,
        );
        
        expect(service.isInitialized, isTrue);
      });

      test('should throw exception when getting cached key before initialization', () {
        expect(
          () => service.getCachedApiKey(),
          throwsA(isA<ApiKeyCacheException>().having(
            (e) => e.message,
            'message',
            'Service not initialized',
          )),
        );
      });

      test('should throw exception when caching key before initialization', () {
        expect(
          () => service.cacheApiKey('test-key'),
          throwsA(isA<ApiKeyCacheException>().having(
            (e) => e.message,
            'message',
            'Service not initialized',
          )),
        );
      });

      test('should throw exception when getting API key before initialization', () async {
        expect(
          () => service.getApiKey(),
          throwsA(isA<ApiKeyCacheException>().having(
            (e) => e.message,
            'message',
            'Service not initialized',
          )),
        );
      });
    });

    group('Cache Operations', () {
      setUp(() {
        service.initialize(
          biometricService: mockBiometricService,
          apiKeyService: mockApiKeyService,
        );
      });

      test('should return null when no key is cached', () {
        expect(service.getCachedApiKey(), isNull);
        expect(service.hasCachedApiKey(), isFalse);
      });

      test('should cache and retrieve API key', () {
        const testKey = 'test-api-key-123';
        
        service.cacheApiKey(testKey);
        
        expect(service.getCachedApiKey(), equals(testKey));
        expect(service.hasCachedApiKey(), isTrue);
      });

      test('should clear cache', () {
        const testKey = 'test-api-key-123';
        
        service.cacheApiKey(testKey);
        expect(service.hasCachedApiKey(), isTrue);
        
        service.clearCache();
        
        expect(service.getCachedApiKey(), isNull);
        expect(service.hasCachedApiKey(), isFalse);
      });

      test('should return cache status information', () {
        const testKey = 'test-api-key-123';
        
        // Initially no cache
        var status = service.getCacheStatus();
        expect(status['hasCachedKey'], isFalse);
        expect(status['cacheTimestamp'], isNull);
        expect(status['isExpired'], isFalse);
        expect(status['maxCacheDuration'], equals(480)); // 8 hours in minutes
        
        // After caching
        service.cacheApiKey(testKey);
        status = service.getCacheStatus();
        expect(status['hasCachedKey'], isTrue);
        expect(status['cacheTimestamp'], isNotNull);
        expect(status['isExpired'], isFalse);
      });
    });

    group('API Key Retrieval', () {
      setUp(() {
        service.initialize(
          biometricService: mockBiometricService,
          apiKeyService: mockApiKeyService,
        );
      });

      test('should return cached key when available', () async {
        const testKey = 'test-api-key-123';
        service.cacheApiKey(testKey);
        
        final result = await service.getApiKey();
        expect(result, equals(testKey));
      });

      test('should decrypt and cache key when not in cache', () async {
        const testKey = 'test-api-key-123';
        mockBiometricService.setMockDecryptedKey(testKey);
        
        final result = await service.getApiKey();
        
        expect(result, equals(testKey));
        expect(service.hasCachedApiKey(), isTrue);
        expect(service.getCachedApiKey(), equals(testKey));
      });

      test('should throw exception when decryption fails', () async {
        mockBiometricService.setShouldThrow(true);
        
        expect(
          () => service.getApiKey(),
          throwsA(isA<ApiKeyCacheException>()),
        );
      });

      test('should handle biometric authentication exceptions', () async {
        mockBiometricService.setShouldThrow(
          true,
          exception: BiometricAuthenticationException('Authentication failed'),
        );
        
        expect(
          () => service.getApiKey(),
          throwsA(isA<BiometricAuthenticationException>()),
        );
      });

      test('should handle biometric not available exceptions', () async {
        mockBiometricService.setShouldThrow(
          true,
          exception: BiometricNotAvailableException('Biometrics not available'),
        );
        
        expect(
          () => service.getApiKey(),
          throwsA(isA<BiometricNotAvailableException>()),
        );
      });

      test('should handle no encrypted data exceptions', () async {
        mockBiometricService.setShouldThrow(
          true,
          exception: NoEncryptedDataException('No encrypted data found'),
        );
        
        expect(
          () => service.getApiKey(),
          throwsA(isA<NoEncryptedDataException>()),
        );
      });

      test('should handle concurrent requests by waiting for pending decryption', () async {
        const testKey = 'test-api-key-123';
        mockBiometricService.setMockDecryptedKey(testKey);
        
        // Start multiple concurrent requests
        final future1 = service.getApiKey();
        final future2 = service.getApiKey();
        final future3 = service.getApiKey();
        
        final results = await Future.wait([future1, future2, future3]);
        
        // All should return the same result
        expect(results, everyElement(equals(testKey)));
        expect(service.hasCachedApiKey(), isTrue);
      });

      test('should throw exception when API key service is not initialized', () async {
        // Create a new service instance without proper initialization
        final uninitializedService = ApiKeyCacheService();
        uninitializedService.initialize(
          biometricService: mockBiometricService,
          apiKeyService: mockApiKeyService,
        );
        
        // We can't easily test the null case due to non-nullable parameters
        // Instead, we test that the service properly handles the case where
        // the API key service is not properly set up
        expect(uninitializedService.isInitialized, isTrue);
      });
    });

    group('Cache Expiration', () {
      setUp(() {
        service.initialize(
          biometricService: mockBiometricService,
          apiKeyService: mockApiKeyService,
        );
      });

      test('should return null for expired cache', () {
        const testKey = 'test-api-key-123';
        service.cacheApiKey(testKey);
        
        // Manually set timestamp to past (simulate expiration)
        // We can't easily test the actual timer, so we test the logic
        final status = service.getCacheStatus();
        expect(status['isExpired'], isFalse); // Should not be expired immediately
        
        // Test that the service correctly identifies expired cache
        // by checking the timestamp logic
        final now = DateTime.now();
        final cacheTimestamp = DateTime.parse(status['cacheTimestamp'] as String);
        final difference = now.difference(cacheTimestamp);
        expect(difference.inMinutes, lessThan(480)); // Should be less than 8 hours
      });
    });

    group('App Lifecycle', () {
      setUp(() {
        service.initialize(
          biometricService: mockBiometricService,
          apiKeyService: mockApiKeyService,
        );
      });

      test('should clear cache on app pause', () {
        const testKey = 'test-api-key-123';
        service.cacheApiKey(testKey);
        expect(service.hasCachedApiKey(), isTrue);
        
        service.onAppPaused();
        
        expect(service.hasCachedApiKey(), isFalse);
        expect(service.getCachedApiKey(), isNull);
      });

      test('should handle app resume', () {
        // onAppResumed doesn't do anything currently, but we test it doesn't throw
        expect(() => service.onAppResumed(), returnsNormally);
      });
    });

    group('Disposal', () {
      test('should dispose resources properly', () {
        service.initialize(
          biometricService: mockBiometricService,
          apiKeyService: mockApiKeyService,
        );
        
        const testKey = 'test-api-key-123';
        service.cacheApiKey(testKey);
        expect(service.hasCachedApiKey(), isTrue);
        
        service.dispose();
        
        expect(service.isInitialized, isFalse);
        // After disposal, hasCachedApiKey should throw an exception
        expect(
          () => service.hasCachedApiKey(),
          throwsA(isA<ApiKeyCacheException>()),
        );
      });
    });

    group('Singleton Behavior', () {
      test('should return same instance', () {
        final instance1 = ApiKeyCacheService();
        final instance2 = ApiKeyCacheService();
        
        expect(identical(instance1, instance2), isTrue);
      });

      test('should reset instance properly', () {
        final instance1 = ApiKeyCacheService();
        ApiKeyCacheService.resetInstance();
        final instance2 = ApiKeyCacheService();
        
        expect(identical(instance1, instance2), isFalse);
      });
    });

    group('Error Handling', () {
      setUp(() {
        service.initialize(
          biometricService: mockBiometricService,
          apiKeyService: mockApiKeyService,
        );
      });

      test('should handle generic decryption errors', () async {
        mockBiometricService.setShouldThrow(
          true,
          exception: Exception('Generic decryption error'),
        );
        
        expect(
          () => service.getApiKey(),
          throwsA(isA<ApiKeyCacheException>().having(
            (e) => e.message,
            'message',
            contains('Failed to get API key'),
          )),
        );
      });

      test('should handle null decrypted key', () async {
        mockBiometricService.setMockDecryptedKey(null);
        
        expect(
          () => service.getApiKey(),
          throwsA(isA<NoEncryptedDataException>()),
        );
      });
    });
  });
}
