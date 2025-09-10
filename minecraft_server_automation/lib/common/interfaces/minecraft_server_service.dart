/// Abstract interface for Minecraft server services
/// This allows for easy mocking in tests
abstract class MinecraftServerServiceInterface {
  /// Set a custom HTTP client for testing
  void setClient(dynamic client);

  /// Check if a Minecraft server is running at the given IP and port
  /// Returns server info if found, null otherwise
  Future<Map<String, dynamic>?> checkMinecraftServer(
    String ip,
    int port,
  );
}
