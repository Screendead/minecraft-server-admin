# Testing & Mocking Guide

This guide covers the testing approach for the Minecraft Server Automation app. The app uses dependency injection with interface-based abstractions to make all external dependencies mockable.

## Quick Start

### 1. Mocking Strategy

**Use Mockito** for all services:
- All services use Mockito-generated mocks for consistency
- Provides verification capabilities and flexible behavior setup
- Examples: `AuthServiceInterface`, `DigitalOceanApiServiceInterface`, `BiometricAuthServiceInterface`

**Use Real Instances** for:
- Data models and pure business logic
- Services with no external dependencies

### 2. Service Locator Pattern

The app uses `ServiceLocator` for dependency injection:

```dart
// Register services
ServiceLocator().register<AuthServiceInterface>(authService);

// Get services
final authService = ServiceLocator().get<AuthServiceInterface>();

// Clear for testing
ServiceLocator().clear();
```

## Available Mock Services

### Mockito-Based Mocks
- `AuthServiceInterface` - Firebase authentication
- `BiometricAuthServiceInterface` - Face ID/Touch ID simulation
- `SecureStorageServiceInterface` - Keychain storage simulation
- `LocationServiceInterface` - GPS location simulation
- `DropletConfigServiceInterface` - Droplet configuration data
- `LoggingServiceInterface` - Logging functionality
- `RegionSelectionServiceInterface` - Region selection logic
- `ApiKeyCacheServiceInterface` - API key caching with biometric encryption
- `DigitalOceanApiServiceInterface` - DigitalOcean API calls
- `MinecraftVersionsServiceInterface` - Minecraft version management
- `EncryptionServiceInterface` - Data encryption
- `MinecraftServerServiceInterface` - Minecraft server detection
- `http.Client` - HTTP client for network requests (used by various services)

### Real Instances (No Mocking)
- Data models (`Region`, `DropletSize`, `LogEntry`, `MinecraftServerInfo`)

## Interface Naming Convention

All interfaces use the `*Interface` suffix to avoid naming conflicts:
- `AuthServiceInterface` → `AuthService` (implementation)
- `MockAuthServiceInterface` (Mockito-generated mock)
- `AuthProviderAdapter` (adapter)

## TestUtils Helper

The `TestUtils` class provides convenient methods for setting up mocks in tests:

```dart
import 'package:minecraft_server_automation/test/test_utils.dart';

// Setup all mocks
TestUtils.setupMockServices();

// Access individual mocks
TestUtils.mockAuthService
TestUtils.mockBiometricAuthService
TestUtils.mockSecureStorageService
// ... etc

// Reset all mocks
TestUtils.resetAllMocks();

// Setup common scenarios
TestUtils.setupSuccessfulAuth();
TestUtils.setupFailedAuth();
TestUtils.setupSuccessfulLocation();
TestUtils.setupBiometricAvailable();
TestUtils.setupBiometricUnavailable();
```

## Essential Commands

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/auth_service_test.dart

# Run tests with coverage
flutter test --coverage

# Generate Mockito mocks
dart run build_runner build

# Clean and regenerate mocks
dart run build_runner build --delete-conflicting-outputs
```

## Basic Test Structure

### Using TestUtils (Recommended)
```dart
import 'package:minecraft_server_automation/test/test_utils.dart';

void main() {
  group('AuthService Tests', () {
    setUp(() {
      TestUtils.setupMockServices();
    });

    tearDown(() {
      TestUtils.resetAllMocks();
    });

    test('should sign in successfully', () async {
      // Setup mock behavior
      when(TestUtils.mockAuthService.signIn(any, any)).thenAnswer((_) async {});
      
      // Test your service
      final result = await authService.signIn('test@example.com', 'password');
      
      // Verify behavior
      expect(result, isTrue);
      verify(TestUtils.mockAuthService.signIn('test@example.com', 'password')).called(1);
    });
  });
}
```

### Direct Mockito Example
```dart
import 'package:minecraft_server_automation/test/mocks/mock_generation.mocks.dart';

void main() {
  group('SomeService Tests', () {
    late SomeService service;
    late MockSecureStorageServiceInterface mockStorage;

    setUp(() {
      mockStorage = MockSecureStorageServiceInterface();
      service = SomeService(storage: mockStorage);
    });

    test('should store data successfully', () async {
      when(mockStorage.write(any, any)).thenAnswer((_) async {});
      
      await service.storeData('key', 'value');
      
      verify(mockStorage.write('key', 'value')).called(1);
    });
  });
}
```

### Real Instance Example
```dart
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
    });
  });
}
```

### HTTP Client Mocking Example
```dart
@GenerateMocks([http.Client])
void main() {
  group('MinecraftServerService Tests', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      MinecraftServerService.setClient(mockClient);
    });

    tearDown(() {
      MinecraftServerService.setClient(http.Client());
    });

    test('should return server info when server is online', () async {
      // Arrange
      const responseBody = '''
      {
        "online": true,
        "ip": "192.168.1.100",
        "port": 25565,
        "hostname": "Test Server",
        "version": "1.20.1",
        "players": {"online": 5, "max": 20}
      }
      ''';

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await MinecraftServerService.checkMinecraftServer('192.168.1.100');

      // Assert
      expect(result, isNotNull);
      expect(result!.hostname, equals('Test Server'));
      expect(result.playersOnline, equals(5));
      
      // Verify the correct URL was called
      verify(mockClient.get(
        Uri.parse('https://api.mcsrvstat.us/2/192.168.1.100'),
        headers: {'Content-Type': 'application/json'},
      )).called(1);
    });

    test('should return null when server is offline', () async {
      // Arrange
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('{"online": false}', 200));

      // Act
      final result = await MinecraftServerService.checkMinecraftServer('192.168.1.100');

      // Assert
      expect(result, isNull);
    });

    test('should handle network errors gracefully', () async {
      // Arrange
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenThrow(Exception('Network error'));

      // Act
      final result = await MinecraftServerService.checkMinecraftServer('192.168.1.100');

      // Assert
      expect(result, isNull);
    });
  });
}
```

## Best Practices

1. **Clear Service Locator between tests:**
   ```dart
   setUp(() {
     ServiceLocator().clear();
     // Register test mocks
   });
   ```

2. **Use descriptive test names:**
   ```dart
   test('should return false when Firebase sign up fails with email already in use', () async {
   ```

3. **Test both success and failure cases:**
   ```dart
   test('should handle network error', () async {
     when(mockService.call()).thenThrow(Exception('Network error'));
     expect(() => service.method(), throwsA(isA<Exception>()));
   });
   ```

4. **Use `anyNamed()` for named parameters:**
   ```dart
   when(mockService.method(param: anyNamed('param'))).thenReturn('result');
   ```

## Troubleshooting

- **Mock not working**: Ensure mocks are registered in `setUp()`
- **State not resetting**: Call `ServiceLocator().clear()` in `tearDown()`
- **Mock generation errors**: Run `dart run build_runner build` after adding `@GenerateMocks`
- **Async operations**: Use `await tester.pump()` for widget tests

## Available Interfaces

- `AuthServiceInterface` - Authentication
- `ApiKeyCacheServiceInterface` - API Key Caching
- `DigitalOceanApiServiceInterface` - DigitalOcean API
- `EncryptionServiceInterface` - Data Encryption
- `BiometricAuthServiceInterface` - Biometric Authentication
- `SecureStorageServiceInterface` - Secure Storage
- `LocationServiceInterface` - Location Services
- `DropletConfigServiceInterface` - Droplet Configuration
- `LoggingServiceInterface` - Logging
- `RegionSelectionServiceInterface` - Region Selection

This mocking system allows you to test components in isolation without external dependencies while maintaining clean, maintainable code.