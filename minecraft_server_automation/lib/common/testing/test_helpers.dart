import 'package:minecraft_server_automation/common/mocks/mock_auth_service.dart';
import 'package:minecraft_server_automation/common/mocks/mock_droplet_config_service.dart';
import 'package:minecraft_server_automation/common/mocks/mock_biometric_auth_service.dart';
import 'package:minecraft_server_automation/common/mocks/mock_secure_storage_service.dart';
import 'package:minecraft_server_automation/common/mocks/mock_location_service.dart';
import 'package:minecraft_server_automation/common/interfaces/auth_service.dart';
import 'package:minecraft_server_automation/common/interfaces/droplet_config_service.dart';
import 'package:minecraft_server_automation/common/interfaces/biometric_auth_service.dart';
import 'package:minecraft_server_automation/common/interfaces/secure_storage_service.dart';
import 'package:minecraft_server_automation/common/interfaces/location_service.dart';
import 'package:minecraft_server_automation/common/di/service_locator.dart';

/// Test helper utilities for setting up mock services
class TestHelpers {
  static final ServiceLocator _serviceLocator = ServiceLocator();

  /// Set up all services with mock implementations for testing
  static void setupMockServices() {
    _serviceLocator.clear();

    // Register mock services
    _serviceLocator.register<AuthServiceInterface>(MockAuthService());
    _serviceLocator
        .register<DropletConfigServiceInterface>(MockDropletConfigService());
    _serviceLocator
        .register<BiometricAuthServiceInterface>(MockBiometricAuthService());
    _serviceLocator
        .register<SecureStorageServiceInterface>(MockSecureStorageService());
    _serviceLocator.register<LocationServiceInterface>(MockLocationService());
  }

  /// Get mock auth service for test control
  static MockAuthService get mockAuthService =>
      _serviceLocator.get<AuthServiceInterface>() as MockAuthService;

  /// Get mock droplet config service for test control
  static MockDropletConfigService get mockDropletConfigService =>
      _serviceLocator.get<DropletConfigServiceInterface>()
          as MockDropletConfigService;

  /// Get mock biometric auth service for test control
  static MockBiometricAuthService get mockBiometricAuthService =>
      _serviceLocator.get<BiometricAuthServiceInterface>()
          as MockBiometricAuthService;

  /// Get mock secure storage service for test control
  static MockSecureStorageService get mockSecureStorageService =>
      _serviceLocator.get<SecureStorageServiceInterface>()
          as MockSecureStorageService;

  /// Get mock location service for test control
  static MockLocationService get mockLocationService =>
      _serviceLocator.get<LocationServiceInterface>() as MockLocationService;

  /// Reset all mock services to default state
  static void resetAllMocks() {
    mockAuthService.reset();
    mockDropletConfigService.reset();
    mockBiometricAuthService.reset();
    mockSecureStorageService.reset();
    mockLocationService.reset();
  }

  /// Set up common test scenarios
  static void setupSuccessfulAuth() {
    mockAuthService.shouldSucceedOnSignIn = true;
    mockAuthService.shouldSucceedOnSignUp = true;
  }

  static void setupFailedAuth() {
    mockAuthService.shouldSucceedOnSignIn = false;
    mockAuthService.shouldSucceedOnSignUp = false;
    mockAuthService.setError('Authentication failed');
  }

  static void setupSuccessfulLocation() {
    mockLocationService.setPermission(LocationPermission.whileInUse);
    mockLocationService.setMockLocation(LocationData(
      latitude: 40.7128,
      longitude: -74.0060,
      timestamp: DateTime.now(),
    ));
  }

  static void setupBiometricAvailable() {
    mockBiometricAuthService.setAvailable(true);
    mockBiometricAuthService.setShouldSucceed(true);
  }

  static void setupBiometricUnavailable() {
    mockBiometricAuthService.setAvailable(false);
  }
}
