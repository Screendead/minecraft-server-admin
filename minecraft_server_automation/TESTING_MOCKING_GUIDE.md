# Testing & Mocking Guide

This guide explains how to use the comprehensive mocking system in the Minecraft Server Automation app for writing effective tests.

## Overview

The app uses a **dependency injection pattern** with **interface-based abstractions** to make all external dependencies mockable. This allows you to test components in isolation without making real network calls, accessing real device features, or depending on external services.

## Mocking Strategy

The project uses **two complementary mocking approaches**:

1. **Mockito** - For complex services with many dependencies (recommended)
2. **Custom Mock Classes** - For simple services or when you need fine-grained control

### When to Use Mockito
- Services with complex dependencies (e.g., `AuthServiceInterface`, `ApiKeyCacheServiceInterface`)
- When you need powerful verification capabilities
- For services that interact with external APIs or databases
- When you want type-safe mocking with generated code

### When to Use Custom Mocks
- Simple utility services (e.g., `EncryptionServiceInterface`, `RegionSelectionServiceInterface`)
- When you need custom behavior that's hard to achieve with Mockito
- For services that are pure functions or stateless utilities
- When you want explicit control over mock state

### When to Use Real Instances
- **Data models** - Test the actual business logic
- **Pure utility functions** - No external dependencies
- **Stateless services** - No side effects or external calls

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   UI Widgets    │───▶│   Interfaces     │◀───│   Mock Services │
│                 │    │                  │    │                 │
│ - AuthForm      │    │ - AuthService*   │    │ - Mockito Mocks │
│ - DropletForm   │    │ - HttpClient*    │    │ - Custom Mocks  │
│ - LocationUI    │    │ - LocationSvc*   │    │ - Real Instances│
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌──────────────────┐
                       │  Service Locator │
                       │  (DI Container)  │
                       │                  │
                       │ - register<T>()  │
                       │ - get<T>()       │
                       │ - clear()        │
                       └──────────────────┘
```

### Service Locator Pattern

The app uses a **ServiceLocator** for dependency injection:

```dart
// Register services
ServiceLocator().register<AuthServiceInterface>(authService);
ServiceLocator().register<HttpClientInterface>(httpClient);

// Get services
final authService = ServiceLocator().get<AuthServiceInterface>();
final httpClient = ServiceLocator().get<HttpClientInterface>();

// Clear for testing
ServiceLocator().clear();
```

**Benefits:**
- Easy to swap implementations for testing
- Clean separation of concerns
- No complex DI framework overhead
- Explicit service registration

## Available Mock Services

### Mockito-Based Mocks (Recommended)

#### 1. **AuthServiceInterface** - Authentication
- **Interface**: `AuthServiceInterface`
- **Implementation**: `AuthService`
- **Mock Generation**: `@GenerateMocks([FirebaseAuth, User, UserCredential, FirebaseFirestore, SharedPreferences, EncryptionService])`
- **Location**: `test/services/auth_service_test.dart`
- **Controls**: Firebase auth, user management, API key encryption

#### 2. **ApiKeyCacheServiceInterface** - API Key Caching
- **Interface**: `ApiKeyCacheServiceInterface`
- **Implementation**: `ApiKeyCacheService`
- **Mock Generation**: `@GenerateMocks([IOSBiometricEncryptionService, IOSSecureApiKeyService])`
- **Location**: `test/services/api_key_cache_service_test.dart`
- **Controls**: Biometric decryption, key caching, app lifecycle

#### 3. **DigitalOceanApiServiceInterface** - DigitalOcean API
- **Interface**: `DigitalOceanApiServiceInterface`
- **Implementation**: `DigitalOceanApiService`
- **Mock Generation**: `@GenerateMocks([http.Client, LoggingServiceInterface])`
- **Location**: `test/services/digitalocean_api_service_test.dart`
- **Controls**: DigitalOcean API calls, droplet management, logging

### Custom Mock Classes

#### 4. **MockSecureStorageService** - Secure Storage (Keychain)
- **Interface**: `SecureStorageServiceInterface`
- **Implementation**: `IOSSecureApiKeyService`
- **Location**: `lib/common/mocks/mock_secure_storage_service.dart`
- **Controls**: Key-value storage simulation, operation tracking

#### 5. **MockBiometricAuthService** - Biometric Authentication
- **Interface**: `BiometricAuthServiceInterface`
- **Implementation**: `IOSBiometricEncryptionService`
- **Location**: `lib/common/mocks/mock_biometric_auth_service.dart`
- **Controls**: Face ID/Touch ID simulation, authentication flow

#### 6. **MockLocationService** - Location Services
- **Interface**: `LocationServiceInterface`
- **Implementation**: `LocationServiceAdapter`
- **Location**: `lib/common/mocks/mock_location_service.dart`
- **Controls**: GPS location simulation, permission handling

#### 7. **MockDropletConfigService** - Droplet Configuration
- **Interface**: `DropletConfigServiceInterface`
- **Implementation**: `DropletConfigProviderAdapter`
- **Location**: `lib/common/mocks/mock_droplet_config_service.dart`
- **Controls**: Droplet sizes, regions, Minecraft versions

### Real Instances (No Mocking Needed)

#### 8. **EncryptionServiceInterface** - Data Encryption
- **Interface**: `EncryptionServiceInterface`
- **Implementation**: `EncryptionService`
- **Location**: `test/services/encryption_service_test.dart`
- **Reason**: No external dependencies, stateless

#### 9. **RegionSelectionServiceInterface** - Location Services
- **Interface**: `RegionSelectionServiceInterface`
- **Implementation**: `RegionSelectionService`
- **Location**: `test/services/region_selection_service_test.dart`
- **Reason**: No external dependencies, mathematical calculations only

#### 10. **Data Models** - Business Objects
- **Types**: `Region`, `DropletSize`, `LogEntry`, etc.
- **Location**: `test/models/`
- **Reason**: Pure data classes with business logic

## Quick Start

### 1. Mockito-Based Testing (Recommended)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:minecraft_server_automation/services/auth_service.dart';
import 'package:minecraft_server_automation/common/interfaces/auth_service.dart';

// Generate mocks for external dependencies
@GenerateMocks([
  FirebaseAuth,
  User,
  UserCredential,
  FirebaseFirestore,
  SharedPreferences,
  EncryptionService,
])
void main() {
  group('AuthService Tests', () {
    late AuthServiceInterface authService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockEncryptionService mockEncryptionService;

    setUp(() {
      // Create mock instances
      mockFirebaseAuth = MockFirebaseAuth();
      mockEncryptionService = MockEncryptionService();
      
      // Create service with mocked dependencies
      authService = AuthService(
        firebaseAuth: mockFirebaseAuth,
        encryptionService: mockEncryptionService,
        // ... other dependencies
      );
    });

    test('should sign in successfully', () async {
      // Configure mock behavior
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);
      
      // Test the service
      final result = await authService.signIn('test@example.com', 'password');
      
      // Verify results
      expect(result, isTrue);
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password',
      )).called(1);
    });
  });
}
```

### 2. Custom Mock Testing

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:minecraft_server_automation/common/mocks/mock_secure_storage_service.dart';
import 'package:minecraft_server_automation/common/interfaces/secure_storage_service.dart';
import 'package:minecraft_server_automation/services/some_service.dart';

void main() {
  group('SomeService Tests', () {
    late SomeService service;
    late SecureStorageServiceInterface mockStorage;

    setUp(() {
      mockStorage = MockSecureStorageService();
      service = SomeService(storage: mockStorage);
    });

    test('should store data successfully', () async {
      // Configure mock behavior
      mockStorage.setValue('test-key', 'test-value');
      
      // Test the service
      await service.storeData('test-key', 'test-value');
      
      // Verify mock was called
      expect(mockStorage.operations.length, equals(1));
      expect(mockStorage.operations.first.type, equals(StorageOperationType.write));
    });
  });
}
```

### 3. Real Instance Testing (No Mocking)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:minecraft_server_automation/services/encryption_service.dart';
import 'package:minecraft_server_automation/common/interfaces/encryption_service.dart';

void main() {
  group('EncryptionService Tests', () {
    late EncryptionServiceInterface service;

    setUp(() {
      service = EncryptionService(); // Use real instance
    });

    test('should encrypt and decrypt data', () {
      const text = 'Hello, World!';
      const password = 'test-password';
      
      final encrypted = service.encrypt(text, password);
      final decrypted = service.decrypt(encrypted, password);
      
      expect(decrypted, equals(text));
      expect(encrypted, isNot(equals(text)));
    });
  });
}
```

## Detailed Examples

### 1. Testing Authentication with Mockito

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minecraft_server_automation/services/auth_service.dart';
import 'package:minecraft_server_automation/common/interfaces/auth_service.dart';

@GenerateMocks([
  FirebaseAuth,
  User,
  UserCredential,
  FirebaseFirestore,
  SharedPreferences,
  EncryptionService,
])
void main() {
  group('AuthService Tests', () {
    late AuthServiceInterface authService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();
      
      authService = AuthService(
        firebaseAuth: mockFirebaseAuth,
        // ... other dependencies
      );
    });

    test('should sign in successfully', () async {
      // Configure mocks
      when(mockUser.uid).thenReturn('test-uid');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);
      
      // Test
      final result = await authService.signIn('test@example.com', 'password123');
      
      // Verify
      expect(result, isTrue);
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    test('should handle sign in failure', () async {
      // Configure mock to throw exception
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(
        code: 'auth/user-not-found',
        message: 'User not found',
      ));
      
      // Test
      final result = await authService.signIn('test@example.com', 'wrongpassword');
      
      // Verify
      expect(result, isFalse);
    });
  });
}
```

### 2. Testing API Key Cache Service with Mockito

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:minecraft_server_automation/services/api_key_cache_service.dart';
import 'package:minecraft_server_automation/common/interfaces/api_key_cache_service.dart';
import 'package:minecraft_server_automation/services/ios_biometric_encryption_service.dart';
import 'package:minecraft_server_automation/services/ios_secure_api_key_service.dart';

@GenerateMocks([
  IOSBiometricEncryptionService,
  IOSSecureApiKeyService,
])
void main() {
  group('ApiKeyCacheService Tests', () {
    late ApiKeyCacheServiceInterface service;
    late MockIOSBiometricEncryptionService mockBiometricService;
    late MockIOSSecureApiKeyService mockApiKeyService;

    setUp(() {
      ApiKeyCacheService.resetInstance();
      service = ApiKeyCacheService();
      mockBiometricService = MockIOSBiometricEncryptionService();
      mockApiKeyService = MockIOSSecureApiKeyService();
      
      service.initialize(
        biometricService: mockBiometricService,
        apiKeyService: mockApiKeyService,
      );
    });

    test('should decrypt and cache key when not in cache', () async {
      const testKey = 'test-api-key-123';
      when(mockApiKeyService.decryptApiKeyFromStorage())
          .thenAnswer((_) async => testKey);
      
      final result = await service.getApiKey();
      
      expect(result, equals(testKey));
      expect(service.hasCachedApiKey(), isTrue);
      verify(mockApiKeyService.decryptApiKeyFromStorage()).called(1);
    });

    test('should handle decryption errors', () async {
      when(mockApiKeyService.decryptApiKeyFromStorage())
          .thenThrow(Exception('Decryption failed'));
      
      expect(
        () => service.getApiKey(),
        throwsA(isA<ApiKeyCacheException>()),
      );
    });
  });
}
```

### 3. Testing Pure Utility Services (No Mocking)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:minecraft_server_automation/services/encryption_service.dart';
import 'package:minecraft_server_automation/common/interfaces/encryption_service.dart';
import 'package:minecraft_server_automation/services/region_selection_service.dart';
import 'package:minecraft_server_automation/common/interfaces/region_selection_service.dart';

void main() {
  group('EncryptionService Tests', () {
    late EncryptionServiceInterface service;

    setUp(() {
      service = EncryptionService(); // Use real instance
    });

    test('should encrypt and decrypt data correctly', () {
      const text = 'Hello, World!';
      const password = 'test-password';
      
      final encrypted = service.encrypt(text, password);
      final decrypted = service.decrypt(encrypted, password);
      
      expect(decrypted, equals(text));
      expect(encrypted, isNot(equals(text)));
    });

    test('should produce different encrypted text for same input', () {
      const text = 'Hello, World!';
      const password = 'test-password';
      
      final encrypted1 = service.encrypt(text, password);
      final encrypted2 = service.encrypt(text, password);
      
      // Should be different due to random IV
      expect(encrypted1, isNot(equals(encrypted2)));
    });
  });

  group('RegionSelectionService Tests', () {
    late RegionSelectionServiceInterface service;

    setUp(() {
      service = RegionSelectionService(); // Use real instance
    });

    test('should calculate distance between coordinates', () {
      // Distance between New York and London (approximately 5570 km)
      final distance = service.calculateDistance(40.7128, -74.0060, 51.5074, -0.1278);
      expect(distance, greaterThan(5500));
      expect(distance, lessThan(5600));
    });

    test('should find closest region to position', () {
      final regions = [
        Region(name: 'NYC1', slug: 'nyc1', features: [], available: true),
        Region(name: 'LON1', slug: 'lon1', features: [], available: true),
      ];
      
      final closest = service.findClosestRegionToPosition(
        regions, 40.7128, -74.0060); // NYC coordinates
      
      expect(closest?.slug, equals('nyc1'));
    });
  });
}
```

## Interface Naming Convention

The project follows a **standardized naming pattern** to avoid conflicts and improve clarity:

### **Interface Naming**
- **All interfaces** use the `*Interface` suffix
- **Examples**: `AuthServiceInterface`, `HttpClientInterface`, `LoggingServiceInterface`

### **Implementation Naming**
- **All implementations** use the same name without the `Interface` suffix
- **Examples**: `AuthService`, `HttpClient`, `LoggingService`

### **Adapter Naming**
- **All adapters** use the `*Adapter` suffix
- **Examples**: `AuthProviderAdapter`, `HttpClientAdapter`, `LoggingServiceAdapter`

### **Mock Naming**
- **Mockito mocks** use `Mock*` prefix
- **Custom mocks** use `Mock*` prefix
- **Examples**: `MockAuthService`, `MockHttpClient`, `MockLoggingService`

### **Benefits of This Pattern**
- ✅ **No name collisions** between interfaces and implementations
- ✅ **Clear separation** between contracts and implementations
- ✅ **Easy to identify** what type of class you're working with
- ✅ **Consistent across** the entire codebase
- ✅ **IDE autocomplete** works better with distinct names

## Best Practices

### 1. **Choose the Right Mocking Strategy**

#### Use Mockito When:
- Testing services with complex dependencies
- You need powerful verification capabilities
- Working with external APIs or databases
- You want type-safe mocking

```dart
@GenerateMocks([FirebaseAuth, User, UserCredential])
void main() {
  // Use Mockito for complex services
}
```

#### Use Custom Mocks When:
- You need fine-grained control over behavior
- The service has simple, predictable behavior
- You want explicit state management

```dart
void main() {
  final mockStorage = MockSecureStorageService();
  // Use custom mocks for simple services
}
```

#### Use Real Instances When:
- Testing pure utility functions
- No external dependencies
- Testing business logic in data models

```dart
void main() {
  final service = EncryptionService(); // Use real instance
  // No mocking needed for pure utilities
}
```

### 2. **Mock Generation and Setup**

#### Generate Mocks Properly
```dart
// Always run build_runner after adding @GenerateMocks
flutter packages pub run build_runner build

// Or use the shorter version
dart run build_runner build
```

#### Set Up Mocks in setUp()
```dart
setUp(() {
  mockFirebaseAuth = MockFirebaseAuth();
  mockUser = MockUser();
  
  // Configure default behavior
  when(mockUser.uid).thenReturn('test-uid');
  when(mockUser.email).thenReturn('test@example.com');
});
```

### 3. **Test Structure and Organization**

#### Group Related Tests
```dart
group('AuthService', () {
  group('Sign In', () {
    test('should succeed with valid credentials', () async {
      // Test implementation
    });
    
    test('should fail with invalid credentials', () async {
      // Test implementation
    });
  });
  
  group('Sign Up', () {
    // More tests
  });
});
```

#### Use Descriptive Test Names
```dart
test('should return false when Firebase sign up fails with email already in use', () async {
  // Test implementation
});
```

### 4. **Mock Configuration**

#### Configure Mocks for Each Test
```dart
test('should handle specific error case', () async {
  // Configure mock for this specific test
  when(mockService.doSomething())
      .thenThrow(SpecificException('Error message'));
  
  // Test the behavior
  expect(() => service.method(), throwsA(isA<SpecificException>()));
});
```

#### Use `anyNamed()` for Named Parameters
```dart
when(mockFirebaseAuth.signInWithEmailAndPassword(
  email: anyNamed('email'),
  password: anyNamed('password'),
)).thenAnswer((_) async => mockUserCredential);
```

### 5. **Verification and Assertions**

#### Verify Mock Interactions
```dart
test('should call correct methods', () async {
  await service.doSomething();
  
  verify(mockService.expectedMethod()).called(1);
  verifyNever(mockService.unexpectedMethod());
});
```

#### Test Both Success and Failure Cases
```dart
group('API Service', () {
  test('should handle successful response', () async {
    when(mockHttp.get(any)).thenAnswer((_) async => HttpResponse(200, '{}'));
    // Test success case
  });
  
  test('should handle error response', () async {
    when(mockHttp.get(any)).thenThrow(Exception('Network error'));
    // Test error case
  });
});
```

### 6. **Service Locator Testing**

#### Clear Service Locator Between Tests
```dart
setUp(() {
  ServiceLocator().clear();
  // Register test mocks
  ServiceLocator().register<AuthServiceInterface>(mockAuthService);
});

tearDown(() {
  ServiceLocator().clear();
});
```

#### Register Mocks for Testing
```dart
test('should use registered service', () async {
  final mockService = MockSomeService();
  ServiceLocator().register<SomeServiceInterface>(mockService);
  
  // Your test code that uses ServiceLocator().get<SomeServiceInterface>()
});
```

## Common Patterns

### Testing Loading States
```dart
testWidgets('should show loading state', (tester) async {
  // Configure mock to simulate async operation
  when(mockService.doSomething()).thenAnswer((_) async {
    await Future.delayed(Duration(milliseconds: 100));
    return 'result';
  });
  
  await tester.pumpWidget(MyWidget());
  await tester.tap(find.text('Load'));
  await tester.pump(); // Don't wait for completion
  
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

### Testing Error States
```dart
testWidgets('should show error message', (tester) async {
  // Configure mock to fail
  when(mockService.doSomething())
      .thenThrow(Exception('Network error'));
  
  await tester.pumpWidget(MyWidget());
  await tester.tap(find.text('Load'));
  await tester.pump();
  
  expect(find.text('Network error'), findsOneWidget);
});
```

### Testing Success States
```dart
testWidgets('should display data on success', (tester) async {
  // Configure mock to return data
  when(mockService.getData()).thenReturn(['item1', 'item2']);
  
  await tester.pumpWidget(MyWidget());
  await tester.tap(find.text('Load'));
  await tester.pump();
  
  expect(find.text('item1'), findsOneWidget);
  expect(find.text('item2'), findsOneWidget);
});
```

## Troubleshooting

### Common Issues

1. **Mock not being used**: Ensure mocks are properly registered in `setUp()`
2. **State not resetting**: Ensure `ServiceLocator().clear()` is called in `tearDown()`
3. **Async operations**: Use `await tester.pump()` or `await tester.pumpAndSettle()` for async operations
4. **Widget not found**: Use `find.byType()` or `find.byKey()` with proper keys
5. **Mock generation errors**: Run `dart run build_runner build` after adding `@GenerateMocks`

### Debug Tips

```dart
// Print mock state for debugging
print('Mock calls: ${verify(mockService.method()).callCount}');

// Verify widget tree
debugDumpApp();

// Check mock configuration
print('Mock configured: ${mockService.isConfigured}');
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/auth_service_test.dart

# Run tests with coverage
flutter test --coverage

# Generate mocks
dart run build_runner build
```

## Summary

This comprehensive mocking system provides:

- **Mockito** for complex services with powerful verification
- **Custom mocks** for simple services with fine-grained control  
- **Real instances** for pure utilities and data models
- **Service Locator** for clean dependency injection
- **Interface-based design** for easy testing and swapping implementations
- **Standardized naming** with `*Interface` suffix for all interfaces
- **No name collisions** between interfaces and implementations
- **Consistent patterns** across the entire codebase

### **Available Interfaces**
- `AuthServiceInterface` - Authentication
- `ApiKeyCacheServiceInterface` - API Key Caching
- `DigitalOceanApiServiceInterface` - DigitalOcean API
- `EncryptionServiceInterface` - Data Encryption
- `MinecraftServerServiceInterface` - Minecraft Server Detection
- `MinecraftVersionsServiceInterface` - Minecraft Version Management
- `BiometricAuthServiceInterface` - Biometric Authentication
- `SecureStorageServiceInterface` - Secure Storage
- `LocationServiceInterface` - Location Services
- `DropletConfigServiceInterface` - Droplet Configuration
- `LoggingServiceInterface` - Logging
- `HttpClientInterface` - HTTP Client
- `RegionSelectionServiceInterface` - Region Selection

The combination of these approaches makes it easy to write comprehensive, reliable tests for the Minecraft Server Automation app while maintaining clean, maintainable code.
