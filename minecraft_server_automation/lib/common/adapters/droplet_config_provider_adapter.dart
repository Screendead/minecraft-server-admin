import 'package:minecraft_server_automation/providers/droplet_config_provider.dart';
import 'package:minecraft_server_automation/common/interfaces/droplet_config_service.dart';
import 'package:minecraft_server_automation/models/cpu_architecture.dart';
import 'package:minecraft_server_automation/models/cpu_category.dart';
import 'package:minecraft_server_automation/models/cpu_option.dart';
import 'package:minecraft_server_automation/models/storage_multiplier.dart';
import 'package:minecraft_server_automation/models/droplet_size.dart';
import 'package:minecraft_server_automation/models/region.dart';
import 'package:minecraft_server_automation/models/minecraft_version.dart';

/// Adapter that wraps DropletConfigProvider to implement DropletConfigService interface
/// This allows components to depend on the interface rather than the concrete provider
class DropletConfigProviderAdapter implements DropletConfigService {
  final DropletConfigProvider _provider;

  DropletConfigProviderAdapter(this._provider);

  @override
  List<DropletSize> get dropletSizes => _provider.dropletSizes;

  @override
  List<Region> get regions => _provider.regions;

  @override
  List<MinecraftVersion> get minecraftVersions => _provider.minecraftVersions;

  @override
  List<MinecraftVersion> get releaseVersions => _provider.releaseVersions;

  @override
  bool get isLoading => _provider.isLoading;

  @override
  String? get error => _provider.error;

  @override
  Future<void> loadConfigurationData() async {
    // This would need to be called with a BuildContext in the real implementation
    // For testing, we can mock this behavior
    throw UnimplementedError(
        'loadConfigurationData requires BuildContext - use provider directly');
  }

  @override
  List<CpuCategory> getAvailableCategoriesForArchitecture(
      CpuArchitecture architecture) {
    return _provider.getAvailableCategoriesForArchitecture(architecture);
  }

  @override
  List<CpuOption> getAvailableOptionsForCategory(CpuCategory category) {
    return _provider.getAvailableOptionsForCategory(category);
  }

  @override
  List<StorageMultiplier> getAvailableStorageMultipliersFor(
      CpuCategory category, CpuOption option) {
    return _provider.getAvailableStorageMultipliersFor(category, option);
  }

  @override
  List<DropletSize> getSizesForStorage(
    String regionSlug,
    CpuArchitecture architecture,
    CpuCategory category,
    CpuOption option,
    StorageMultiplier multiplier,
  ) {
    return _provider.getSizesForStorage(
        regionSlug, architecture, category, option, multiplier);
  }

  @override
  List<DropletSize> getRecommendedSizesForRegion(String regionSlug) {
    // This method doesn't exist in DropletConfigProvider, so we'll implement it here
    return _provider.dropletSizes.where((size) {
      return size.isAvailableInRegion(regionSlug) && size.isSharedCpu;
    }).toList();
  }
}
