import 'package:minecraft_server_automation/common/interfaces/auth_service.dart';
import 'package:minecraft_server_automation/common/interfaces/droplet_config_service.dart';
import 'package:minecraft_server_automation/common/interfaces/region_selection_service.dart';
import 'package:minecraft_server_automation/common/interfaces/http_client.dart';
import 'package:minecraft_server_automation/common/interfaces/biometric_auth_service.dart';
import 'package:minecraft_server_automation/common/interfaces/secure_storage_service.dart';
import 'package:minecraft_server_automation/common/interfaces/location_service.dart';
import 'package:minecraft_server_automation/common/interfaces/logging_service.dart';
import 'package:minecraft_server_automation/providers/auth_provider.dart';
import 'package:minecraft_server_automation/providers/droplet_config_provider.dart';
import 'package:minecraft_server_automation/common/adapters/droplet_config_provider_adapter.dart';
import 'package:minecraft_server_automation/common/adapters/auth_provider_adapter.dart';
import 'package:minecraft_server_automation/common/adapters/http_client_adapter.dart';
import 'package:minecraft_server_automation/common/adapters/ios_biometric_auth_adapter.dart';
import 'package:minecraft_server_automation/common/adapters/ios_secure_storage_adapter.dart';
import 'package:minecraft_server_automation/common/adapters/location_service_adapter.dart';
import 'package:minecraft_server_automation/common/adapters/logging_service_adapter.dart';
import 'package:minecraft_server_automation/services/region_selection_service.dart';
import 'package:minecraft_server_automation/services/logging_service.dart';
import 'package:http/http.dart' as http;

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
    http.Client? httpClient,
  }) {
    // Register HTTP client
    register<HttpClientInterface>(
        HttpClientAdapter(httpClient ?? http.Client()));

    // Register auth service - use adapter to make AuthProvider conform to AuthService
    if (authProvider != null) {
      register<AuthService>(AuthProviderAdapter(authProvider));
    }

    // Register droplet config service
    if (dropletConfigProvider != null) {
      register<DropletConfigService>(
          DropletConfigProviderAdapter(dropletConfigProvider));
    }

    // Register region selection service
    register<RegionSelectionServiceInterface>(RegionSelectionService());

    // Register platform services
    register<BiometricAuthService>(IOSBiometricAuthAdapter());
    register<SecureStorageService>(IOSSecureStorageAdapter());
    register<LocationService>(LocationServiceAdapter());
    
    // Register logging service
    register<LoggingServiceInterface>(LoggingServiceAdapter(LoggingService()));
  }
}

/// Extension to make service locator easier to use
extension ServiceLocatorExtension on ServiceLocator {
  /// Get auth service
  AuthService get authService => get<AuthService>();

  /// Get droplet config service
  DropletConfigService get dropletConfigService => get<DropletConfigService>();

  /// Get region selection service
  RegionSelectionServiceInterface get regionSelectionService =>
      get<RegionSelectionServiceInterface>();

  /// Get HTTP client
  HttpClientInterface get httpClient => get<HttpClientInterface>();

  /// Get biometric auth service
  BiometricAuthService get biometricAuthService => get<BiometricAuthService>();

  /// Get secure storage service
  SecureStorageService get secureStorageService => get<SecureStorageService>();

  /// Get location service
  LocationService get locationService => get<LocationService>();

  /// Get logging service
  LoggingServiceInterface get loggingService => get<LoggingServiceInterface>();
}
