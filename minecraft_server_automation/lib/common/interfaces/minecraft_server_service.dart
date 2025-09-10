import 'package:minecraft_server_automation/models/minecraft_server_info.dart';

/// Abstract interface for Minecraft server services
/// This allows for easy mocking in tests
abstract class MinecraftServerServiceInterface {
  /// Set a custom HTTP client for testing
  void setClient(dynamic client);

  /// Check if a Minecraft server is running at the given IP address
  /// Returns server info if found, null otherwise
  Future<MinecraftServerInfo?> checkMinecraftServer(String ipAddress);
}
