import 'package:mockito/annotations.dart';
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
import 'package:minecraft_server_automation/common/interfaces/minecraft_server_service.dart';
import 'package:minecraft_server_automation/common/interfaces/path_provider_service.dart';

@GenerateMocks([
  AuthServiceInterface,
  BiometricAuthServiceInterface,
  SecureStorageServiceInterface,
  DropletConfigServiceInterface,
  LocationServiceInterface,
  LoggingServiceInterface,
  RegionSelectionServiceInterface,
  ApiKeyCacheServiceInterface,
  DigitalOceanApiServiceInterface,
  MinecraftVersionsServiceInterface,
  MinecraftServerServiceInterface,
  PathProviderServiceInterface,
])
void main() {}
