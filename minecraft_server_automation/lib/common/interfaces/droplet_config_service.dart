import 'package:minecraft_server_automation/models/cpu_architecture.dart';
import 'package:minecraft_server_automation/models/cpu_category.dart';
import 'package:minecraft_server_automation/models/cpu_option.dart';
import 'package:minecraft_server_automation/models/storage_multiplier.dart';
import 'package:minecraft_server_automation/models/droplet_size.dart';
import 'package:minecraft_server_automation/models/region.dart';
import 'package:minecraft_server_automation/models/minecraft_version.dart';

/// Abstract interface for droplet configuration services
/// This allows for easy mocking in tests
abstract class DropletConfigService {
  List<DropletSize> get dropletSizes;
  List<Region> get regions;
  List<MinecraftVersion> get minecraftVersions;
  List<MinecraftVersion> get releaseVersions;
  bool get isLoading;
  String? get error;

  Future<void> loadConfigurationData();

  List<CpuCategory> getAvailableCategoriesForArchitecture(CpuArchitecture architecture);
  List<CpuOption> getAvailableOptionsForCategory(CpuCategory category);
  List<StorageMultiplier> getAvailableStorageMultipliersFor(CpuCategory category, CpuOption option);
  List<DropletSize> getSizesForStorage(
    String regionSlug,
    CpuArchitecture architecture,
    CpuCategory category,
    CpuOption option,
    StorageMultiplier multiplier,
  );
  List<DropletSize> getRecommendedSizesForRegion(String regionSlug);
}
