import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:minecraft_server_automation/common/interfaces/minecraft_server_service.dart';
import 'package:minecraft_server_automation/models/minecraft_server_info.dart';

/// Service for detecting and querying Minecraft servers
class MinecraftServerService implements MinecraftServerServiceInterface {
  static const String _baseUrl = 'https://api.mcsrvstat.us/2';
  http.Client? _client;

  /// Set a custom HTTP client for testing
  @override
  void setClient(dynamic client) {
    _client = client as http.Client?;
  }

  /// Get the HTTP client (for testing or default)
  http.Client get _httpClient => _client ?? http.Client();

  /// Checks if a server is running Minecraft by querying the mcsrvstat.us API
  /// Returns null if the server is not running Minecraft or if there's an error
  @override
  Future<MinecraftServerInfo?> checkMinecraftServer(String ipAddress) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/$ipAddress'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        return null;
      }

      final data = json.decode(response.body);

      // Check if the server is online
      if (data['online'] != true) {
        return null;
      }

      return MinecraftServerInfo.fromJson(data);
    } catch (e) {
      // Any network error or timeout means the server is not running Minecraft
      return null;
    }
  }
}
