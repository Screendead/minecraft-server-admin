import 'package:minecraft_server_automation/common/interfaces/auth_service.dart';
import 'package:minecraft_server_automation/common/interfaces/droplet_config_service.dart';
import 'package:minecraft_server_automation/common/interfaces/region_selection_service.dart';
import 'package:minecraft_server_automation/common/interfaces/biometric_auth_service.dart';
import 'package:minecraft_server_automation/common/interfaces/secure_storage_service.dart';
import 'package:minecraft_server_automation/common/interfaces/location_service.dart';
import 'package:minecraft_server_automation/common/interfaces/logging_service.dart';
import 'package:minecraft_server_automation/providers/auth_provider.dart';
import 'package:minecraft_server_automation/providers/droplet_config_provider.dart';
import 'package:minecraft_server_automation/common/adapters/droplet_config_provider_adapter.dart';
import 'package:minecraft_server_automation/common/adapters/auth_provider_adapter.dart';
import 'package:minecraft_server_automation/common/adapters/ios_biometric_auth_adapter.dart';
import 'package:minecraft_server_automation/common/adapters/ios_secure_storage_adapter.dart';
import 'package:minecraft_server_automation/common/adapters/location_service_adapter.dart';
import 'package:minecraft_server_automation/common/adapters/logging_service_adapter.dart';
import 'package:minecraft_server_automation/services/region_selection_service.dart';
import 'package:minecraft_server_automation/services/logging_service.dart';

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

    // Register region selection service
    register<RegionSelectionServiceInterface>(RegionSelectionService());

    // Register platform services
    register<BiometricAuthServiceInterface>(IOSBiometricAuthAdapter());
    register<SecureStorageServiceInterface>(IOSSecureStorageAdapter());
    register<LocationServiceInterface>(LocationServiceAdapter());
    
    // Register logging service
    register<LoggingServiceInterface>(LoggingServiceAdapter(LoggingService()));
  }
}

/// Extension to make service locator easier to use
extension ServiceLocatorExtension on ServiceLocator {
  /// Get auth service
  AuthServiceInterface get authService => get<AuthServiceInterface>();

  /// Get droplet config service
  DropletConfigServiceInterface get dropletConfigService => get<DropletConfigServiceInterface>();

  /// Get region selection service
  RegionSelectionServiceInterface get regionSelectionService =>
      get<RegionSelectionServiceInterface>();

  /// Get biometric auth service
  BiometricAuthServiceInterface get biometricAuthService => get<BiometricAuthServiceInterface>();

  /// Get secure storage service
  SecureStorageServiceInterface get secureStorageService => get<SecureStorageServiceInterface>();

  /// Get location service
  LocationServiceInterface get locationService => get<LocationServiceInterface>();

  /// Get logging service
  LoggingServiceInterface get loggingService => get<LoggingServiceInterface>();
}
