import 'package:minecraft_server_automation/models/cpu_architecture.dart';
import 'package:minecraft_server_automation/models/cpu_category.dart';
import 'package:minecraft_server_automation/models/cpu_option.dart';
import 'package:minecraft_server_automation/models/storage_multiplier.dart';
import 'package:minecraft_server_automation/models/droplet_size.dart';
import 'package:minecraft_server_automation/models/region.dart';
import 'package:minecraft_server_automation/common/interfaces/droplet_config_service.dart';

/// Business logic for droplet configuration
/// This class can be easily unit tested without UI dependencies
class DropletConfigurationLogic {
  final DropletConfigService _configService;

  DropletConfigurationLogic(this._configService);

  /// Get available categories for a given architecture
  List<CpuCategory> getAvailableCategories(CpuArchitecture architecture) {
    return _configService.getAvailableCategoriesForArchitecture(architecture);
  }

  /// Get available options for a given category
  List<CpuOption> getAvailableOptions(CpuCategory category) {
    return _configService.getAvailableOptionsForCategory(category);
  }

  /// Get available storage multipliers for a given category and option
  List<StorageMultiplier> getAvailableStorageMultipliers(
    CpuCategory category,
    CpuOption option,
  ) {
    return _configService.getAvailableStorageMultipliersFor(category, option);
  }

  /// Get available droplet sizes for a given configuration
  List<DropletSize> getAvailableSizes({
    required String regionSlug,
    required CpuArchitecture architecture,
    required CpuCategory category,
    required CpuOption option,
    required StorageMultiplier multiplier,
  }) {
    return _configService.getSizesForStorage(
      regionSlug,
      architecture,
      category,
      option,
      multiplier,
    );
  }

  /// Get recommended sizes for a region
  List<DropletSize> getRecommendedSizes(String regionSlug) {
    return _configService.getRecommendedSizesForRegion(regionSlug);
  }

  /// Check if a configuration is valid
  bool isConfigurationValid({
    required Region? region,
    required CpuArchitecture? architecture,
    required CpuCategory? category,
    required CpuOption? option,
    required StorageMultiplier? multiplier,
  }) {
    if (region == null || architecture == null || category == null || 
        option == null || multiplier == null) {
      return false;
    }

    final sizes = getAvailableSizes(
      regionSlug: region.slug,
      architecture: architecture,
      category: category,
      option: option,
      multiplier: multiplier,
    );

    return sizes.isNotEmpty;
  }

  /// Get the best size for a given configuration
  DropletSize? getBestSize({
    required String regionSlug,
    required CpuArchitecture architecture,
    required CpuCategory category,
    required CpuOption option,
    required StorageMultiplier multiplier,
  }) {
    final sizes = getAvailableSizes(
      regionSlug: regionSlug,
      architecture: architecture,
      category: category,
      option: option,
      multiplier: multiplier,
    );

    if (sizes.isEmpty) return null;

    // Return the first available size (could be enhanced with better selection logic)
    return sizes.first;
  }

  /// Get configuration summary
  Map<String, dynamic> getConfigurationSummary({
    required Region? region,
    required CpuArchitecture? architecture,
    required CpuCategory? category,
    required CpuOption? option,
    required StorageMultiplier? multiplier,
    required DropletSize? size,
  }) {
    return {
      'region': region?.name,
      'architecture': architecture?.displayName,
      'category': category?.displayName,
      'option': option?.displayName,
      'multiplier': multiplier?.displayName,
      'size': size?.displayName,
      'isValid': isConfigurationValid(
        region: region,
        architecture: architecture,
        category: category,
        option: option,
        multiplier: multiplier,
      ),
    };
  }
}
