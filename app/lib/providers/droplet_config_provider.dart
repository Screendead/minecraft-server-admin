import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/digitalocean_api_service.dart';
import '../services/minecraft_versions_service.dart';
import '../models/cpu_architecture.dart';
import '../models/cpu_category.dart';
import '../models/cpu_option.dart';
import '../models/storage_multiplier.dart';
import 'auth_provider.dart' as auth_provider;

/// Provider for managing droplet configuration data
class DropletConfigProvider extends ChangeNotifier {
  List<DropletSize> _dropletSizes = [];
  List<Region> _regions = [];
  List<MinecraftVersion> _minecraftVersions = [];
  bool _isLoading = false;
  String? _error;

  List<DropletSize> get dropletSizes => _dropletSizes;
  List<Region> get regions => _regions;
  List<MinecraftVersion> get minecraftVersions => _minecraftVersions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get shared CPU droplet sizes
  List<DropletSize> get sharedCpuSizes => _dropletSizes
      .where((size) => size.isSharedCpu && size.available)
      .toList();

  /// Get dedicated CPU droplet sizes
  List<DropletSize> get dedicatedCpuSizes => _dropletSizes
      .where((size) => size.isDedicatedCpu && size.available)
      .toList();

  /// Get shared CPU droplet sizes filtered by region
  List<DropletSize> getSharedCpuSizesForRegion(String regionSlug) =>
      _dropletSizes
          .where((size) =>
              size.isSharedCpu &&
              size.available &&
              size.isAvailableInRegion(regionSlug))
          .toList();

  /// Get dedicated CPU droplet sizes filtered by region and category
  List<DropletSize> getDedicatedCpuSizesForRegion(
      String regionSlug, String? category) {
    return _dropletSizes.where((size) {
      if (!size.isDedicatedCpu ||
          !size.available ||
          !size.isAvailableInRegion(regionSlug)) {
        return false;
      }
      if (category == null) return true;
      return size.dedicatedCpuCategory == category;
    }).toList();
  }

  /// Get all available dedicated CPU categories
  List<String> get dedicatedCpuCategories => [
        'general_purpose',
        'cpu_optimized',
        'memory_optimized',
        'storage_optimized'
      ];

  /// Get droplet sizes filtered by CPU architecture
  List<DropletSize> getSizesForArchitecture(
      String regionSlug, CpuArchitecture architecture) {
    return _dropletSizes.where((size) {
      return size.available &&
          size.isAvailableInRegion(regionSlug) &&
          size.cpuArchitecture == architecture;
    }).toList();
  }

  /// Get droplet sizes filtered by CPU architecture and category
  List<DropletSize> getSizesForCategory(
      String regionSlug, CpuArchitecture architecture, CpuCategory category) {
    return _dropletSizes.where((size) {
      return size.available &&
          size.isAvailableInRegion(regionSlug) &&
          size.cpuArchitecture == architecture &&
          size.cpuCategory == category;
    }).toList();
  }

  /// Get droplet sizes filtered by CPU architecture, category, and option
  List<DropletSize> getSizesForOption(String regionSlug,
      CpuArchitecture architecture, CpuCategory category, CpuOption option) {
    return _dropletSizes.where((size) {
      return size.available &&
          size.isAvailableInRegion(regionSlug) &&
          size.cpuArchitecture == architecture &&
          size.cpuCategory == category &&
          size.cpuOption == option;
    }).toList();
  }

  /// Get droplet sizes filtered by CPU architecture, category, option, and storage multiplier
  List<DropletSize> getSizesForStorage(
      String regionSlug,
      CpuArchitecture architecture,
      CpuCategory category,
      CpuOption option,
      StorageMultiplier multiplier) {
    return _dropletSizes.where((size) {
      return size.available &&
          size.isAvailableInRegion(regionSlug) &&
          size.cpuArchitecture == architecture &&
          size.cpuCategory == category &&
          size.cpuOption == option &&
          size.storageMultiplier == multiplier;
    }).toList();
  }

  /// Get available CPU categories for a given architecture
  List<CpuCategory> getAvailableCategoriesForArchitecture(
      CpuArchitecture architecture) {
    return CpuCategory.values
        .where((category) => category.isAvailableFor(architecture))
        .toList();
  }

  /// Get available CPU options for a given category
  List<CpuOption> getAvailableOptionsForCategory(CpuCategory category) {
    return CpuOption.values
        .where((option) => option.isAvailableFor(category))
        .toList();
  }

  /// Get available storage multipliers for a given category and option
  List<StorageMultiplier> getAvailableStorageMultipliersFor(
      CpuCategory category, CpuOption option) {
    return StorageMultiplier.values
        .where((multiplier) => multiplier.isAvailableFor(category, option))
        .toList();
  }

  /// Get available regions
  List<Region> get availableRegions =>
      _regions.where((region) => region.available).toList();

  /// Get release Minecraft versions only
  List<MinecraftVersion> get releaseVersions =>
      _minecraftVersions.where((version) => version.isRelease).toList();

  /// Load all configuration data
  Future<void> loadConfigurationData(BuildContext context) async {
    _setLoading(true);
    _error = null;

    try {
      // Get the API key from the AuthProvider's cached service
      final authProvider = context.read<auth_provider.AuthProvider>();
      final apiKeyService = authProvider.iosApiKeyService;

      if (apiKeyService == null) {
        _error = 'User not authenticated. Please sign in.';
        _setLoading(false);
        return;
      }

      final apiKey = await apiKeyService.getApiKey();
      if (apiKey == null) {
        _error = 'No API key found. Please add your DigitalOcean API key.';
        _setLoading(false);
        return;
      }

      // Load data in parallel
      final results = await Future.wait([
        DigitalOceanApiService.getDropletSizes(apiKey),
        DigitalOceanApiService.getRegions(apiKey),
        MinecraftVersionsService.getReleaseVersions(),
      ]);

      _dropletSizes = results[0] as List<DropletSize>;
      _regions = results[1] as List<Region>;
      _minecraftVersions = results[2] as List<MinecraftVersion>;

      // Sort droplet sizes by price (cheapest first)
      _dropletSizes.sort((a, b) => a.priceMonthly.compareTo(b.priceMonthly));

      // Sort regions by name
      _regions.sort((a, b) => a.name.compareTo(b.name));

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Load only Minecraft versions (doesn't require API key)
  Future<void> loadMinecraftVersions() async {
    _setLoading(true);
    _error = null;

    try {
      _minecraftVersions = await MinecraftVersionsService.getReleaseVersions();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Clear all data
  void clear() {
    _dropletSizes.clear();
    _regions.clear();
    _minecraftVersions.clear();
    _error = null;
    notifyListeners();
  }
}
