import 'package:minecraft_server_automation/models/minecraft_version.dart';

/// Abstract interface for Minecraft versions services
/// This allows for easy mocking in tests
abstract class MinecraftVersionsServiceInterface {
  /// Set a custom HTTP client for testing
  void setClient(dynamic client);

  /// Get all available Minecraft versions
  Future<List<MinecraftVersion>> getMinecraftVersions();

  /// Get only release versions
  Future<List<MinecraftVersion>> getReleaseVersions();

  /// Get only snapshot versions
  Future<List<MinecraftVersion>> getSnapshotVersions();

  /// Get the server JAR URL for a specific version
  Future<String> getServerJarUrlForVersion(String versionId);
}
