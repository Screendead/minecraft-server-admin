import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/services/api_key_cache_service.dart';
import 'package:app/services/ios_biometric_encryption_service.dart';
import 'package:app/services/ios_secure_api_key_service.dart';
import 'test_helpers.dart';

import 'api_key_cache_service_test.mocks.dart';

@GenerateMocks([
  IOSBiometricEncryptionService, 
  IOSSecureApiKeyService,
  FirebaseFirestore,
  FirebaseAuth,
])
void main() {
  group('ApiKeyCacheService', () {
    late ApiKeyCacheService cacheService;
    late MockIOSBiometricEncryptionService mockBiometricService;
    late MockIOSSecureApiKeyService mockApiKeyService;

    setUp(() {
      // Reset all singletons for each test
      TestHelpers.resetSingletons();
      
      cacheService = ApiKeyCacheService();
      mockBiometricService = MockIOSBiometricEncryptionService();
      mockApiKeyService = MockIOSSecureApiKeyService();
      
      // Initialize the service
      cacheService.initialize(
        biometricService: mockBiometricService,
        apiKeyService: mockApiKeyService,
      );
    });

    tearDown(() {
      cacheService.dispose();
    });

    group('Initialization', () {
      test('should be initialized after calling initialize', () {
        expect(cacheService.isInitialized, true);
      });

      test('should throw exception when not initialized', () {
        // Reset and create a new instance without initializing
        ApiKeyCacheService.resetInstance();
        final uninitializedService = ApiKeyCacheService();
        expect(
          () => uninitializedService.getCachedApiKey(),
          throwsA(isA<ApiKeyCacheException>()),
        );
      });
    });

    group('Caching', () {
      test('should cache API key and return it', () {
        const testApiKey = 'test-api-key-123';

        cacheService.cacheApiKey(testApiKey);

        expect(cacheService.getCachedApiKey(), testApiKey);
        expect(cacheService.hasCachedApiKey(), true);
      });

      test('should return null when no key is cached', () {
        expect(cacheService.getCachedApiKey(), null);
        expect(cacheService.hasCachedApiKey(), false);
      });

      test('should clear cache when clearCache is called', () {
        const testApiKey = 'test-api-key-123';

        cacheService.cacheApiKey(testApiKey);
        expect(cacheService.hasCachedApiKey(), true);

        cacheService.clearCache();
        expect(cacheService.hasCachedApiKey(), false);
        expect(cacheService.getCachedApiKey(), null);
      });
    });

    group('getApiKey', () {
      test('should return cached key when available', () async {
        const testApiKey = 'cached-api-key-123';
        cacheService.cacheApiKey(testApiKey);

        final result = await cacheService.getApiKey();

        expect(result, testApiKey);
        verifyNever(mockApiKeyService.getApiKey());
      });

      test('should decrypt from secure storage when not cached', () async {
        const testApiKey = 'decrypted-api-key-123';
        when(mockApiKeyService.decryptApiKeyFromStorage())
            .thenAnswer((_) async => testApiKey);

        final result = await cacheService.getApiKey();

        expect(result, testApiKey);
        verify(mockApiKeyService.decryptApiKeyFromStorage()).called(1);

        // Should now be cached
        expect(cacheService.getCachedApiKey(), testApiKey);
      });

      test('should cache decrypted key for future use', () async {
        const testApiKey = 'decrypted-api-key-123';
        when(mockApiKeyService.decryptApiKeyFromStorage())
            .thenAnswer((_) async => testApiKey);

        // First call should decrypt and cache
        final result1 = await cacheService.getApiKey();
        expect(result1, testApiKey);

        // Second call should use cache
        final result2 = await cacheService.getApiKey();
        expect(result2, testApiKey);

        // Should only call the service once
        verify(mockApiKeyService.decryptApiKeyFromStorage()).called(1);
      });

      test('should rethrow biometric authentication exceptions', () async {
        when(mockApiKeyService.decryptApiKeyFromStorage()).thenThrow(
          BiometricAuthenticationException('Biometric failed'),
        );

        expect(
          () => cacheService.getApiKey(),
          throwsA(isA<BiometricAuthenticationException>()),
        );
      });

      test('should rethrow biometric not available exceptions', () async {
        when(mockApiKeyService.decryptApiKeyFromStorage()).thenThrow(
          BiometricNotAvailableException('Biometric not available'),
        );

        expect(
          () => cacheService.getApiKey(),
          throwsA(isA<BiometricNotAvailableException>()),
        );
      });

      test('should rethrow no encrypted data exceptions', () async {
        when(mockApiKeyService.decryptApiKeyFromStorage()).thenThrow(
          NoEncryptedDataException('No encrypted data'),
        );

        expect(
          () => cacheService.getApiKey(),
          throwsA(isA<NoEncryptedDataException>()),
        );
      });

      test('should wrap other exceptions in ApiKeyCacheException', () async {
        when(mockApiKeyService.decryptApiKeyFromStorage()).thenThrow(
          Exception('Some other error'),
        );

        expect(
          () => cacheService.getApiKey(),
          throwsA(isA<ApiKeyCacheException>()),
        );
      });

      test('should return null when service returns null', () async {
        when(mockApiKeyService.decryptApiKeyFromStorage())
            .thenAnswer((_) async => null);

        final result = await cacheService.getApiKey();

        expect(result, null);
        expect(cacheService.hasCachedApiKey(), false);
      });

      test('should handle concurrent calls without multiple decryptions', () async {
        const testApiKey = 'concurrent-test-key';
        when(mockApiKeyService.decryptApiKeyFromStorage()).thenAnswer((_) async {
          // Simulate some delay to ensure concurrent calls happen
          await Future.delayed(const Duration(milliseconds: 100));
          return testApiKey;
        });
        
        // Make multiple concurrent calls
        final futures = List.generate(5, (_) => cacheService.getApiKey());
        final results = await Future.wait(futures);
        
        // All should return the same key
        for (final result in results) {
          expect(result, testApiKey);
        }
        
        // Should only call the service once
        verify(mockApiKeyService.decryptApiKeyFromStorage()).called(1);
        
        // Should be cached
        expect(cacheService.getCachedApiKey(), testApiKey);
      });

      test('should share cache across multiple service instances', () async {
        const testApiKey = 'shared-cache-key';
        when(mockApiKeyService.decryptApiKeyFromStorage()).thenAnswer((_) async => testApiKey);
        
        // First service instance gets the key
        final result1 = await cacheService.getApiKey();
        expect(result1, testApiKey);
        
        // Create a new service instance (simulating different parts of the app)
        final anotherService = IOSSecureApiKeyService(
          firestore: MockFirebaseFirestore(),
          auth: MockFirebaseAuth(),
          biometricService: MockIOSBiometricEncryptionService(),
        );
        
        // Second service instance should get the cached key without decryption
        final result2 = await anotherService.getApiKey();
        expect(result2, testApiKey);
        
        // Should only call the service once (from the first instance)
        verify(mockApiKeyService.decryptApiKeyFromStorage()).called(1);
      });
    });

    group('Cache Status', () {
      test('should return correct cache status when empty', () {
        final status = cacheService.getCacheStatus();

        expect(status['hasCachedKey'], false);
        expect(status['cacheTimestamp'], null);
        expect(status['isExpired'], false);
        expect(status['maxCacheDuration'], 480); // 8 hours in minutes
      });

      test('should return correct cache status when cached', () {
        const testApiKey = 'test-api-key-123';
        cacheService.cacheApiKey(testApiKey);

        final status = cacheService.getCacheStatus();

        expect(status['hasCachedKey'], true);
        expect(status['cacheTimestamp'], isNotNull);
        expect(status['isExpired'], false);
        expect(status['maxCacheDuration'], 480);
      });
    });

    group('App Lifecycle', () {
      test('should clear cache on app pause', () {
        const testApiKey = 'test-api-key-123';
        cacheService.cacheApiKey(testApiKey);
        expect(cacheService.hasCachedApiKey(), true);

        cacheService.onAppPaused();

        expect(cacheService.hasCachedApiKey(), false);
      });

      test('should handle app resume without issues', () {
        // Should not throw any exceptions
        expect(() => cacheService.onAppResumed(), returnsNormally);
      });
    });

    group('Disposal', () {
      test('should clear cache and reset state on dispose', () {
        const testApiKey = 'test-api-key-123';
        cacheService.cacheApiKey(testApiKey);
        expect(cacheService.isInitialized, true);
        expect(cacheService.hasCachedApiKey(), true);

        cacheService.dispose();

        expect(cacheService.isInitialized, false);
        // After dispose, hasCachedApiKey should throw an exception
        expect(
          () => cacheService.hasCachedApiKey(),
          throwsA(isA<ApiKeyCacheException>()),
        );
      });

      test('should throw exception after disposal', () {
        final testService = ApiKeyCacheService();
        testService.initialize(
          biometricService: mockBiometricService,
          apiKeyService: mockApiKeyService,
        );
        testService.dispose();
        
        expect(
          () => testService.getCachedApiKey(),
          throwsA(isA<ApiKeyCacheException>()),
        );
      });
    });
  });
}
