import 'package:minecraft_server_automation/common/interfaces/auth_service.dart';
import 'package:minecraft_server_automation/common/interfaces/droplet_config_service.dart';
import 'package:minecraft_server_automation/common/interfaces/region_selection_service.dart';
import 'package:minecraft_server_automation/common/interfaces/biometric_auth_service.dart';
import 'package:minecraft_server_automation/common/interfaces/secure_storage_service.dart';
import 'package:minecraft_server_automation/common/interfaces/location_service.dart';
import 'package:minecraft_server_automation/common/interfaces/logging_service.dart';
import 'package:minecraft_server_automation/common/interfaces/api_key_cache_service.dart';
import 'package:minecraft_server_automation/common/interfaces/digitalocean_api_service.dart';
import 'package:minecraft_server_automation/common/interfaces/minecraft_versions_service.dart';
import 'package:minecraft_server_automation/common/interfaces/minecraft_server_service.dart';
import 'package:minecraft_server_automation/common/interfaces/path_provider_service.dart';
import 'package:minecraft_server_automation/providers/auth_provider.dart';
import 'package:minecraft_server_automation/providers/droplet_config_provider.dart';
import 'package:minecraft_server_automation/common/adapters/droplet_config_provider_adapter.dart';
import 'package:minecraft_server_automation/common/adapters/auth_provider_adapter.dart';
import 'package:minecraft_server_automation/common/adapters/ios_secure_storage_adapter.dart';
import 'package:minecraft_server_automation/common/adapters/location_service_adapter.dart';
import 'package:minecraft_server_automation/services/region_selection_service.dart';
import 'package:minecraft_server_automation/services/logging_service.dart';
import 'package:minecraft_server_automation/services/api_key_cache_service.dart';
import 'package:minecraft_server_automation/services/digitalocean_api_service.dart';
import 'package:minecraft_server_automation/services/minecraft_versions_service.dart';
import 'package:minecraft_server_automation/services/minecraft_server_service.dart';
import 'package:minecraft_server_automation/services/path_provider_service.dart';
import 'package:minecraft_server_automation/services/ios_biometric_encryption_service.dart';

/// Simple service locator for dependency injection
/// This makes it easy to swap implementations for testing
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, dynamic> _services = {};

  /// Register a service
  void register<T>(T service) {
    _services[T] = service;
  }

  /// Get a service
  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T not registered');
    }
    return service as T;
  }

  /// Check if a service is registered
  bool isRegistered<T>() {
    return _services.containsKey(T);
  }

  /// Clear all services (useful for testing)
  void clear() {
    _services.clear();
  }

  /// Register default services
  void registerDefaults({
    AuthProvider? authProvider,
    DropletConfigProvider? dropletConfigProvider,
  }) {
    // Register auth service - use adapter to make AuthProvider conform to AuthServiceInterface
    if (authProvider != null) {
      register<AuthServiceInterface>(AuthProviderAdapter(authProvider));
    }

    // Register droplet config service
    if (dropletConfigProvider != null) {
      register<DropletConfigServiceInterface>(
          DropletConfigProviderAdapter(dropletConfigProvider));
    }

    // Register core services (direct implementations)
    register<RegionSelectionServiceInterface>(RegionSelectionService());
    register<LoggingServiceInterface>(LoggingService());
    register<ApiKeyCacheServiceInterface>(ApiKeyCacheService());
    register<DigitalOceanApiServiceInterface>(DigitalOceanApiService());
    register<MinecraftVersionsServiceInterface>(MinecraftVersionsService());
    register<MinecraftServerServiceInterface>(MinecraftServerService());
    register<PathProviderServiceInterface>(PathProviderService());

    // Register platform services (keep adapters for platform-specific implementations)
    register<BiometricAuthServiceInterface>(IOSBiometricEncryptionService());
    register<SecureStorageServiceInterface>(IOSSecureStorageAdapter());
    register<LocationServiceInterface>(LocationServiceAdapter());
  }
}

/// Extension to make service locator easier to use
extension ServiceLocatorExtension on ServiceLocator {
  /// Get auth service
  AuthServiceInterface get authService => get<AuthServiceInterface>();

  /// Get droplet config service
  DropletConfigServiceInterface get dropletConfigService =>
      get<DropletConfigServiceInterface>();

  /// Get region selection service
  RegionSelectionServiceInterface get regionSelectionService =>
      get<RegionSelectionServiceInterface>();

  /// Get biometric auth service
  BiometricAuthServiceInterface get biometricAuthService =>
      get<BiometricAuthServiceInterface>();

  /// Get secure storage service
  SecureStorageServiceInterface get secureStorageService =>
      get<SecureStorageServiceInterface>();

  /// Get location service
  LocationServiceInterface get locationService =>
      get<LocationServiceInterface>();

  /// Get logging service
  LoggingServiceInterface get loggingService => get<LoggingServiceInterface>();

  /// Get API key cache service
  ApiKeyCacheServiceInterface get apiKeyCacheService =>
      get<ApiKeyCacheServiceInterface>();

  /// Get DigitalOcean API service
  DigitalOceanApiServiceInterface get digitalOceanApiService =>
      get<DigitalOceanApiServiceInterface>();

  /// Get Minecraft versions service
  MinecraftVersionsServiceInterface get minecraftVersionsService =>
      get<MinecraftVersionsServiceInterface>();

  /// Get Minecraft server service
  MinecraftServerServiceInterface get minecraftServerService =>
      get<MinecraftServerServiceInterface>();

  /// Get path provider service
  PathProviderServiceInterface get pathProviderService =>
      get<PathProviderServiceInterface>();
}
