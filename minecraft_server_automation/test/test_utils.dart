import 'package:mockito/mockito.dart';
import 'package:minecraft_server_automation/common/di/service_locator.dart';
import 'package:minecraft_server_automation/common/interfaces/auth_service.dart';
import 'package:minecraft_server_automation/common/interfaces/biometric_auth_service.dart';
import 'package:minecraft_server_automation/common/interfaces/secure_storage_service.dart';
import 'package:minecraft_server_automation/common/interfaces/droplet_config_service.dart';
import 'package:minecraft_server_automation/common/interfaces/location_service.dart';
import 'package:minecraft_server_automation/common/interfaces/logging_service.dart';
import 'package:minecraft_server_automation/common/interfaces/region_selection_service.dart';
import 'package:minecraft_server_automation/common/interfaces/api_key_cache_service.dart';
import 'package:minecraft_server_automation/common/interfaces/digitalocean_api_service.dart';
import 'package:minecraft_server_automation/common/interfaces/minecraft_versions_service.dart';
import 'package:minecraft_server_automation/common/interfaces/encryption_service.dart';
import 'package:minecraft_server_automation/common/interfaces/minecraft_server_service.dart';
import 'package:minecraft_server_automation/common/interfaces/path_provider_service.dart';
import 'mocks/mock_generation.mocks.dart';

/// Test utility functions for setting up mock services
class TestUtils {
  static final ServiceLocator _serviceLocator = ServiceLocator();

  /// Set up all services with mock implementations for testing
  static void setupMockServices() {
    _serviceLocator.clear();

    // Register mock services
    _serviceLocator.register<AuthServiceInterface>(MockAuthServiceInterface());
    _serviceLocator.register<DropletConfigServiceInterface>(
        MockDropletConfigServiceInterface());
    _serviceLocator.register<BiometricAuthServiceInterface>(
        MockBiometricAuthServiceInterface());
    _serviceLocator.register<SecureStorageServiceInterface>(
        MockSecureStorageServiceInterface());
    _serviceLocator
        .register<LocationServiceInterface>(MockLocationServiceInterface());
    _serviceLocator
        .register<LoggingServiceInterface>(MockLoggingServiceInterface());
    _serviceLocator.register<RegionSelectionServiceInterface>(
        MockRegionSelectionServiceInterface());
    _serviceLocator.register<ApiKeyCacheServiceInterface>(
        MockApiKeyCacheServiceInterface());
    _serviceLocator.register<DigitalOceanApiServiceInterface>(
        MockDigitalOceanApiServiceInterface());
    _serviceLocator.register<MinecraftVersionsServiceInterface>(
        MockMinecraftVersionsServiceInterface());
    _serviceLocator
        .register<EncryptionServiceInterface>(MockEncryptionServiceInterface());
    _serviceLocator.register<MinecraftServerServiceInterface>(
        MockMinecraftServerServiceInterface());
    _serviceLocator.register<PathProviderServiceInterface>(
        MockPathProviderServiceInterface());
  }

  /// Get mock auth service for test control
  static MockAuthServiceInterface get mockAuthService =>
      _serviceLocator.get<AuthServiceInterface>() as MockAuthServiceInterface;

  /// Get mock droplet config service for test control
  static MockDropletConfigServiceInterface get mockDropletConfigService =>
      _serviceLocator.get<DropletConfigServiceInterface>()
          as MockDropletConfigServiceInterface;

  /// Get mock biometric auth service for test control
  static MockBiometricAuthServiceInterface get mockBiometricAuthService =>
      _serviceLocator.get<BiometricAuthServiceInterface>()
          as MockBiometricAuthServiceInterface;

  /// Get mock secure storage service for test control
  static MockSecureStorageServiceInterface get mockSecureStorageService =>
      _serviceLocator.get<SecureStorageServiceInterface>()
          as MockSecureStorageServiceInterface;

  /// Get mock location service for test control
  static MockLocationServiceInterface get mockLocationService =>
      _serviceLocator.get<LocationServiceInterface>()
          as MockLocationServiceInterface;

  /// Get mock logging service for test control
  static MockLoggingServiceInterface get mockLoggingService =>
      _serviceLocator.get<LoggingServiceInterface>()
          as MockLoggingServiceInterface;

  /// Get mock region selection service for test control
  static MockRegionSelectionServiceInterface get mockRegionSelectionService =>
      _serviceLocator.get<RegionSelectionServiceInterface>()
          as MockRegionSelectionServiceInterface;

  /// Get mock API key cache service for test control
  static MockApiKeyCacheServiceInterface get mockApiKeyCacheService =>
      _serviceLocator.get<ApiKeyCacheServiceInterface>()
          as MockApiKeyCacheServiceInterface;

  /// Get mock DigitalOcean API service for test control
  static MockDigitalOceanApiServiceInterface get mockDigitalOceanApiService =>
      _serviceLocator.get<DigitalOceanApiServiceInterface>()
          as MockDigitalOceanApiServiceInterface;

  /// Get mock Minecraft versions service for test control
  static MockMinecraftVersionsServiceInterface
      get mockMinecraftVersionsService =>
          _serviceLocator.get<MinecraftVersionsServiceInterface>()
              as MockMinecraftVersionsServiceInterface;

  /// Get mock encryption service for test control
  static MockEncryptionServiceInterface get mockEncryptionService =>
      _serviceLocator.get<EncryptionServiceInterface>()
          as MockEncryptionServiceInterface;

  /// Get mock Minecraft server service for test control
  static MockMinecraftServerServiceInterface get mockMinecraftServerService =>
      _serviceLocator.get<MinecraftServerServiceInterface>()
          as MockMinecraftServerServiceInterface;

  /// Get mock path provider service for test control
  static MockPathProviderServiceInterface get mockPathProviderService =>
      _serviceLocator.get<PathProviderServiceInterface>()
          as MockPathProviderServiceInterface;

  /// Reset all mock services to default state
  static void resetAllMocks() {
    reset(mockAuthService);
    reset(mockDropletConfigService);
    reset(mockBiometricAuthService);
    reset(mockSecureStorageService);
    reset(mockLocationService);
    reset(mockLoggingService);
    reset(mockRegionSelectionService);
    reset(mockApiKeyCacheService);
    reset(mockDigitalOceanApiService);
    reset(mockMinecraftVersionsService);
    reset(mockEncryptionService);
    reset(mockMinecraftServerService);
    reset(mockPathProviderService);
  }

  /// Set up common test scenarios
  static void setupSuccessfulAuth() {
    when(mockAuthService.signIn(any, any)).thenAnswer((_) async {});
    when(mockAuthService.signUp(any, any)).thenAnswer((_) async {});
  }

  static void setupFailedAuth() {
    when(mockAuthService.signIn(any, any))
        .thenThrow(Exception('Authentication failed'));
    when(mockAuthService.signUp(any, any))
        .thenThrow(Exception('Authentication failed'));
  }

  static void setupSuccessfulLocation() {
    when(mockLocationService.checkPermission())
        .thenAnswer((_) async => LocationPermission.whileInUse);
    when(mockLocationService.getCurrentLocation())
        .thenAnswer((_) async => LocationData(
              latitude: 40.7128,
              longitude: -74.0060,
              timestamp: DateTime.now(),
            ));
  }

  static void setupBiometricAvailable() {
    when(mockBiometricAuthService.isBiometricAvailable()).thenAnswer((_) async => true);
    when(mockBiometricAuthService.encryptWithBiometrics(any)).thenAnswer((_) async => 'encrypted_data');
    when(mockBiometricAuthService.decryptWithBiometrics()).thenAnswer((_) async => 'decrypted_data');
  }

  static void setupBiometricUnavailable() {
    when(mockBiometricAuthService.isBiometricAvailable()).thenAnswer((_) async => false);
  }
}
