import 'package:minecraft_server_automation/common/interfaces/droplet_config_service.dart';
import 'package:minecraft_server_automation/models/cpu_architecture.dart';
import 'package:minecraft_server_automation/models/cpu_category.dart';
import 'package:minecraft_server_automation/models/cpu_option.dart';
import 'package:minecraft_server_automation/models/storage_multiplier.dart';
import 'package:minecraft_server_automation/models/droplet_size.dart';
import 'package:minecraft_server_automation/models/region.dart';
import 'package:minecraft_server_automation/models/minecraft_version.dart';

/// Mock implementation of DropletConfigService for testing
class MockDropletConfigService implements DropletConfigServiceInterface {
  final List<DropletSize> _dropletSizes = [];
  final List<Region> _regions = [];
  final List<MinecraftVersion> _minecraftVersions = [];
  bool _isLoading = false;
  String? _error;

  // Test control properties
  bool shouldThrowOnLoad = false;
  bool shouldReturnEmptyData = false;

  @override
  List<DropletSize> get dropletSizes => _dropletSizes;

  @override
  List<Region> get regions => _regions;

  @override
  List<MinecraftVersion> get minecraftVersions => _minecraftVersions;

  @override
  List<MinecraftVersion> get releaseVersions =>
      _minecraftVersions.where((v) => v.isRelease).toList();

  @override
  bool get isLoading => _isLoading;

  @override
  String? get error => _error;

  @override
  Future<void> loadConfigurationData() async {
    _isLoading = true;
    _error = null;

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    if (shouldThrowOnLoad) {
      _isLoading = false;
      _error = 'Mock load error';
      throw Exception('Mock load error');
    }

    if (!shouldReturnEmptyData) {
      _loadMockData();
    }

    _isLoading = false;
  }

  @override
  List<CpuCategory> getAvailableCategoriesForArchitecture(
      CpuArchitecture architecture) {
    if (architecture == CpuArchitecture.shared) {
      return [CpuCategory.basic];
    } else {
      return CpuCategory.values;
    }
  }

  @override
  List<CpuOption> getAvailableOptionsForCategory(CpuCategory category) {
    return CpuOption.values;
  }

  @override
  List<StorageMultiplier> getAvailableStorageMultipliersFor(
      CpuCategory category, CpuOption option) {
    return StorageMultiplier.values;
  }

  @override
  List<DropletSize> getSizesForStorage(
    String regionSlug,
    CpuArchitecture architecture,
    CpuCategory category,
    CpuOption option,
    StorageMultiplier multiplier,
  ) {
    return _dropletSizes.where((size) {
      return size.isAvailableInRegion(regionSlug) &&
          size.cpuArchitecture == architecture &&
          size.cpuCategory == category &&
          size.cpuOption == option &&
          size.storageMultiplier == multiplier;
    }).toList();
  }

  @override
  List<DropletSize> getRecommendedSizesForRegion(String regionSlug) {
    return _dropletSizes.where((size) {
      return size.isAvailableInRegion(regionSlug) && size.isSharedCpu;
    }).toList();
  }

  void _loadMockData() {
    // Mock regions
    _regions.addAll([
      const Region(
        name: 'New York 1',
        slug: 'nyc1',
        features: [
          'virtio',
          'private_networking',
          'backups',
          'ipv6',
          'metadata'
        ],
        available: true,
      ),
      const Region(
        name: 'San Francisco 2',
        slug: 'sfo2',
        features: [
          'virtio',
          'private_networking',
          'backups',
          'ipv6',
          'metadata'
        ],
        available: true,
      ),
    ]);

    // Mock droplet sizes
    _dropletSizes.addAll([
      const DropletSize(
        slug: 's-1vcpu-512mb-10gb',
        memory: 512,
        vcpus: 1,
        disk: 10,
        transfer: 1.0,
        priceMonthly: 4.0,
        priceHourly: 0.006,
        regions: ['nyc1', 'sfo2'],
        available: true,
        description: 'Basic shared CPU droplet',
      ),
      const DropletSize(
        slug: 's-1vcpu-1gb-25gb',
        memory: 1024,
        vcpus: 1,
        disk: 25,
        transfer: 1.0,
        priceMonthly: 6.0,
        priceHourly: 0.009,
        regions: ['nyc1', 'sfo2'],
        available: true,
        description: 'Basic shared CPU droplet',
      ),
    ]);

    // Mock Minecraft versions
    _minecraftVersions.addAll([
      MinecraftVersion(
        id: '1.20.1',
        type: 'release',
        url:
            'https://launcher.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec60ec15b/server.jar',
        time: DateTime.parse('2023-06-12T22:00:00+00:00'),
        releaseTime: DateTime.parse('2023-06-12T22:00:00+00:00'),
        sha1: '1b557e7b033b583cd9f66746b7a9ab1ec60ec15b',
        complianceLevel: 1,
      ),
    ]);
  }

  // Test helper methods
  void reset() {
    _dropletSizes.clear();
    _regions.clear();
    _minecraftVersions.clear();
    _isLoading = false;
    _error = null;
    shouldThrowOnLoad = false;
    shouldReturnEmptyData = false;
  }

  void addMockDropletSize(DropletSize size) {
    _dropletSizes.add(size);
  }

  void addMockRegion(Region region) {
    _regions.add(region);
  }

  void addMockMinecraftVersion(MinecraftVersion version) {
    _minecraftVersions.add(version);
  }

  void setLoading(bool value) {
    _isLoading = value;
  }

  void setError(String? error) {
    _error = error;
  }
}
