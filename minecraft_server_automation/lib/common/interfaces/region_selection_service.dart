import 'package:minecraft_server_automation/models/region.dart';

/// Abstract interface for region selection services
/// This allows for easy mocking in tests
abstract class RegionSelectionServiceInterface {
  Future<Region?> findClosestRegion(List<Region> availableRegions);
}
