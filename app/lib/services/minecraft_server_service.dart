import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for detecting and querying Minecraft servers
class MinecraftServerService {
  static const String _baseUrl = 'https://api.mcsrvstat.us/2';
  static http.Client? _client;

  /// Set a custom HTTP client for testing
  static void setClient(http.Client client) {
    _client = client;
  }

  /// Get the HTTP client (for testing or default)
  static http.Client get _httpClient => _client ?? http.Client();

  /// Checks if a server is running Minecraft by querying the mcsrvstat.us API
  /// Returns null if the server is not running Minecraft or if there's an error
  static Future<MinecraftServerInfo?> checkMinecraftServer(
      String ipAddress) async {
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

/// Data class representing Minecraft server information
class MinecraftServerInfo {
  final String hostname;
  final String ip;
  final int port;
  final String version;
  final String protocol;
  final int playersOnline;
  final int playersMax;
  final String? motd;
  final String? software;
  final List<String>? players;

  const MinecraftServerInfo({
    required this.hostname,
    required this.ip,
    required this.port,
    required this.version,
    required this.protocol,
    required this.playersOnline,
    required this.playersMax,
    this.motd,
    this.software,
    this.players,
  });

  factory MinecraftServerInfo.fromJson(Map<String, dynamic> json) {
    return MinecraftServerInfo(
      hostname: json['hostname'] ?? json['ip'] ?? 'Unknown',
      ip: json['ip'] ?? 'Unknown',
      port: json['port'] ?? 25565,
      version: json['version'] ?? 'Unknown',
      protocol: json['protocol']?.toString() ?? 'Unknown',
      playersOnline: json['players']?['online'] ?? 0,
      playersMax: json['players']?['max'] ?? 0,
      motd: json['motd']?['clean']?.isNotEmpty == true
          ? json['motd']['clean'].join(' ')
          : json['motd']?['raw']?.isNotEmpty == true
              ? json['motd']['raw'].join(' ')
              : null,
      software: json['software'],
      players: json['players']?['list']?.cast<String>(),
    );
  }
}
