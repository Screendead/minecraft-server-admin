# Testing & Mocking Guide

This guide explains how to use the comprehensive mocking system in the Minecraft Server Automation app for writing effective tests.

## Overview

The app uses a **dependency injection pattern** with **interface-based abstractions** to make all external dependencies mockable. This allows you to test components in isolation without making real network calls, accessing real device features, or depending on external services.

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   UI Widgets    │───▶│   Interfaces     │◀───│   Mock Services │
│                 │    │                  │    │                 │
│ - AuthForm      │    │ - AuthService    │    │ - MockAuth      │
│ - DropletForm   │    │ - HttpClient     │    │ - MockHttp      │
│ - LocationUI    │    │ - LocationService│    │ - MockLocation  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌──────────────────┐
                       │  Service Locator │
                       │  (DI Container)  │
                       └──────────────────┘
```

## Available Mock Services

### 1. **MockAuthService** - Authentication
- **Interface**: `AuthService`
- **Location**: `lib/common/mocks/mock_auth_service.dart`
- **Controls**: Sign in/up success/failure, loading states, error messages

### 2. **MockHttpClient** - HTTP Requests
- **Interface**: `HttpClientInterface`
- **Location**: `lib/common/mocks/mock_http_client.dart`
- **Controls**: Response mocking, request verification, error simulation

### 3. **MockDropletConfigService** - Droplet Configuration
- **Interface**: `DropletConfigService`
- **Location**: `lib/common/mocks/mock_droplet_config_service.dart`
- **Controls**: Mock data for regions, CPU options, droplet sizes

### 4. **MockBiometricAuthService** - Biometric Authentication
- **Interface**: `BiometricAuthService`
- **Location**: `lib/common/mocks/mock_biometric_auth_service.dart`
- **Controls**: Biometric availability, authentication success/failure

### 5. **MockSecureStorageService** - Secure Storage (Keychain)
- **Interface**: `SecureStorageService`
- **Location**: `lib/common/mocks/mock_secure_storage_service.dart`
- **Controls**: Key-value storage simulation

### 6. **MockLocationService** - Location Services
- **Interface**: `LocationService`
- **Location**: `lib/common/mocks/mock_location_service.dart`
- **Controls**: Location permissions, mock GPS coordinates

## Quick Start

### Basic Test Setup

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:minecraft_server_automation/common/testing/test_helpers.dart';

void main() {
  group('Authentication Tests', () {
    setUp(() {
      // Set up all mock services
      TestHelpers.setupMockServices();
    });

    tearDown(() {
      // Reset all mocks after each test
      TestHelpers.resetAllMocks();
    });

    test('should sign in successfully', () async {
      // Configure mock behavior
      TestHelpers.setupSuccessfulAuth();
      
      // Your test code here
      // The UI will use the mock services automatically
    });
  });
}
```

## Detailed Examples

### 1. Testing Authentication

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:minecraft_server_automation/common/testing/test_helpers.dart';
import 'package:minecraft_server_automation/common/widgets/forms/auth_form.dart';

void main() {
  group('AuthForm Tests', () {
    setUp(() {
      TestHelpers.setupMockServices();
    });

    tearDown(() {
      TestHelpers.resetAllMocks();
    });

    testWidgets('should show loading state during sign in', (tester) async {
      // Configure mock to simulate loading
      final mockAuth = TestHelpers.mockAuthService;
      mockAuth.shouldSucceedOnSignIn = true;
      
      await tester.pumpWidget(
        MaterialApp(
          home: AuthForm(
            authService: mockAuth,
            onAuthSuccess: () {},
          ),
        ),
      );

      // Trigger sign in
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Verify loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message on failed sign in', (tester) async {
      // Configure mock to fail
      final mockAuth = TestHelpers.mockAuthService;
      mockAuth.shouldSucceedOnSignIn = false;
      mockAuth.setError('Invalid credentials');

      await tester.pumpWidget(
        MaterialApp(
          home: AuthForm(
            authService: mockAuth,
            onAuthSuccess: () {},
          ),
        ),
      );

      // Trigger sign in
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'wrongpassword');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Verify error message
      expect(find.text('Invalid credentials'), findsOneWidget);
    });
  });
}
```

### 2. Testing HTTP Requests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:minecraft_server_automation/common/testing/test_helpers.dart';
import 'package:minecraft_server_automation/services/digitalocean_api_service.dart';

void main() {
  group('DigitalOcean API Service Tests', () {
    setUp(() {
      TestHelpers.setupMockServices();
    });

    tearDown(() {
      TestHelpers.resetAllMocks();
    });

    test('should fetch regions successfully', () async {
      final mockHttp = TestHelpers.mockHttpClient;
      
      // Mock successful response
      mockHttp.setResponse('GET', 'https://api.digitalocean.com/v2/regions', 
        HttpResponse(200, '{"regions": [{"name": "NYC1", "slug": "nyc1"}]}'));
      
      final service = DigitalOceanApiService();
      final regions = await service.getRegions();
      
      expect(regions, isNotEmpty);
      expect(regions.first.name, equals('NYC1'));
      
      // Verify the request was made
      expect(mockHttp.requests.length, equals(1));
      expect(mockHttp.requests.first.method, equals('GET'));
    });

    test('should handle HTTP errors gracefully', () async {
      final mockHttp = TestHelpers.mockHttpClient;
      
      // Mock error response
      mockHttp.setResponse('GET', 'https://api.digitalocean.com/v2/regions',
        HttpResponse(500, 'Internal Server Error'));
      
      final service = DigitalOceanApiService();
      
      expect(() => service.getRegions(), throwsException);
    });
  });
}
```

### 3. Testing Location Services

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:minecraft_server_automation/common/testing/test_helpers.dart';
import 'package:minecraft_server_automation/common/widgets/forms/location_dropdown.dart';

void main() {
  group('Location Dropdown Tests', () {
    setUp(() {
      TestHelpers.setupMockServices();
    });

    tearDown(() {
      TestHelpers.resetAllMocks();
    });

    testWidgets('should show location permission dialog when needed', (tester) async {
      // Configure mock to require permission
      final mockLocation = TestHelpers.mockLocationService;
      mockLocation.setPermission(LocationPermission.denied);
      
      await tester.pumpWidget(
        MaterialApp(
          home: LocationDropdown(
            selectedRegion: null,
            onRegionChanged: (region) {},
          ),
        ),
      );

      // Trigger location request
      await tester.tap(find.byIcon(Icons.location_on));
      await tester.pump();

      // Verify permission dialog appears
      expect(find.text('Location Permission Required'), findsOneWidget);
    });

    testWidgets('should use current location when available', (tester) async {
      // Configure mock with location data
      TestHelpers.setupSuccessfulLocation();
      
      await tester.pumpWidget(
        MaterialApp(
          home: LocationDropdown(
            selectedRegion: null,
            onRegionChanged: (region) {},
          ),
        ),
      );

      // The widget should automatically use the mock location
      // and suggest the nearest region
    });
  });
}
```

### 4. Testing Biometric Authentication

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:minecraft_server_automation/common/testing/test_helpers.dart';

void main() {
  group('Biometric Auth Tests', () {
    setUp(() {
      TestHelpers.setupMockServices();
    });

    tearDown(() {
      TestHelpers.resetAllMocks();
    });

    test('should authenticate successfully when biometrics available', () async {
      // Configure mock for successful biometric auth
      TestHelpers.setupBiometricAvailable();
      
      final mockBiometric = TestHelpers.mockBiometricAuthService;
      final result = await mockBiometric.authenticate(reason: 'Test authentication');
      
      expect(result, isTrue);
    });

    test('should fail when biometrics unavailable', () async {
      // Configure mock for unavailable biometrics
      TestHelpers.setupBiometricUnavailable();
      
      final mockBiometric = TestHelpers.mockBiometricAuthService;
      final result = await mockBiometric.authenticate(reason: 'Test authentication');
      
      expect(result, isFalse);
    });
  });
}
```

## Advanced Mock Configuration

### Custom Mock Responses

```dart
test('should handle custom API responses', () async {
  final mockHttp = TestHelpers.mockHttpClient;
  
  // Set up custom response
  mockHttp.setResponse('POST', 'https://api.digitalocean.com/v2/droplets', 
    HttpResponse(201, '''
    {
      "droplet": {
        "id": 12345,
        "name": "test-droplet",
        "status": "new"
      }
    }
    '''));
  
  // Your test code here
});
```

### Verifying Mock Interactions

```dart
test('should make correct API calls', () async {
  final mockHttp = TestHelpers.mockHttpClient;
  
  // Perform actions that trigger HTTP calls
  await someService.createDroplet('test-droplet');
  
  // Verify the calls were made
  expect(mockHttp.requests.length, equals(1));
  expect(mockHttp.requests.first.method, equals('POST'));
  expect(mockHttp.requests.first.url, contains('/droplets'));
});
```

### Simulating Network Delays

```dart
test('should handle slow network responses', () async {
  final mockHttp = TestHelpers.mockHttpClient;
  
  // Configure mock to simulate delay
  mockHttp.setDelay(Duration(seconds: 2));
  mockHttp.setResponse('GET', 'https://api.example.com/data',
    HttpResponse(200, '{"data": "slow response"}'));
  
  // Test loading states and timeouts
});
```

## Test Helper Methods

The `TestHelpers` class provides convenient methods for common test scenarios:

```dart
// Set up successful authentication
TestHelpers.setupSuccessfulAuth();

// Set up failed authentication
TestHelpers.setupFailedAuth();

// Set up location services
TestHelpers.setupSuccessfulLocation();

// Set up biometric authentication
TestHelpers.setupBiometricAvailable();
TestHelpers.setupBiometricUnavailable();

// Reset all mocks to default state
TestHelpers.resetAllMocks();
```

## Best Practices

### 1. **Always Reset Mocks**
```dart
tearDown(() {
  TestHelpers.resetAllMocks();
});
```

### 2. **Use Descriptive Test Names**
```dart
test('should show error message when authentication fails with invalid credentials', () async {
  // Test implementation
});
```

### 3. **Test Both Success and Failure Cases**
```dart
group('API Service Tests', () {
  test('should handle successful response', () async {
    // Success case
  });
  
  test('should handle error response', () async {
    // Error case
  });
});
```

### 4. **Verify Mock Interactions**
```dart
test('should call correct API endpoint', () async {
  // Perform action
  await service.doSomething();
  
  // Verify mock was called correctly
  expect(mockHttp.requests.length, equals(1));
  expect(mockHttp.requests.first.url, contains('/expected-endpoint'));
});
```

### 5. **Use Widget Tests for UI Components**
```dart
testWidgets('should display loading indicator during API call', (tester) async {
  // Configure mock to simulate loading
  mockHttp.setDelay(Duration(seconds: 1));
  
  await tester.pumpWidget(MyWidget());
  await tester.tap(find.text('Load Data'));
  await tester.pump();
  
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

## Common Patterns

### Testing Loading States
```dart
testWidgets('should show loading state', (tester) async {
  // Configure mock to simulate async operation
  mockService.setDelay(Duration(milliseconds: 100));
  
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
  mockService.shouldThrowOnRequest = true;
  mockService.throwMessage = 'Network error';
  
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
  mockService.setMockData(['item1', 'item2']);
  
  await tester.pumpWidget(MyWidget());
  await tester.tap(find.text('Load'));
  await tester.pump();
  
  expect(find.text('item1'), findsOneWidget);
  expect(find.text('item2'), findsOneWidget);
});
```

## Troubleshooting

### Common Issues

1. **Mock not being used**: Ensure `TestHelpers.setupMockServices()` is called in `setUp()`
2. **State not resetting**: Ensure `TestHelpers.resetAllMocks()` is called in `tearDown()`
3. **Async operations**: Use `await tester.pump()` or `await tester.pumpAndSettle()` for async operations
4. **Widget not found**: Use `find.byType()` or `find.byKey()` with proper keys

### Debug Tips

```dart
// Print mock state for debugging
print('Mock requests: ${mockHttp.requests}');
print('Mock responses: ${mockHttp.responses}');

// Verify widget tree
debugDumpApp();

// Check mock configuration
print('Auth mock state: ${mockAuth.isSignedIn}');
```

This mocking system provides complete control over all external dependencies, making it easy to write comprehensive, reliable tests for the Minecraft Server Automation app.
