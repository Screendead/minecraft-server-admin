import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for fetching Minecraft versions from the official launcher manifest
class MinecraftVersionsService {
  static const String _manifestUrl =
      'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json';
  static http.Client? _client;

  /// Set a custom HTTP client for testing
  static void setClient(http.Client client) {
    _client = client;
  }

  /// Get the HTTP client (for testing or default)
  static http.Client get _httpClient => _client ?? http.Client();

  /// Fetches all available Minecraft versions from the official manifest
  /// Returns a list of MinecraftVersion objects sorted by release date (newest first)
  static Future<List<MinecraftVersion>> getMinecraftVersions() async {
    try {
      final response = await _httpClient.get(
        Uri.parse(_manifestUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch Minecraft versions: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final versions = data['versions'] as List<dynamic>;

      return versions
          .map((version) => MinecraftVersion.fromJson(version))
          .where((version) =>
              version.type == 'release' || version.type == 'snapshot')
          .toList()
        ..sort((a, b) => b.releaseTime.compareTo(a.releaseTime));
    } catch (e) {
      throw Exception('Error fetching Minecraft versions: $e');
    }
  }

  /// Fetches only release versions (stable releases)
  static Future<List<MinecraftVersion>> getReleaseVersions() async {
    final allVersions = await getMinecraftVersions();
    return allVersions.where((version) => version.type == 'release').toList();
  }

  /// Fetches only snapshot versions (preview releases)
  static Future<List<MinecraftVersion>> getSnapshotVersions() async {
    final allVersions = await getMinecraftVersions();
    return allVersions.where((version) => version.type == 'snapshot').toList();
  }
}

/// Data class representing a Minecraft version
class MinecraftVersion {
  final String id;
  final String type;
  final String url;
  final DateTime time;
  final DateTime releaseTime;
  final String sha1;
  final int complianceLevel;

  const MinecraftVersion({
    required this.id,
    required this.type,
    required this.url,
    required this.time,
    required this.releaseTime,
    required this.sha1,
    required this.complianceLevel,
  });

  factory MinecraftVersion.fromJson(Map<String, dynamic> json) {
    return MinecraftVersion(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      url: json['url'] ?? '',
      time: DateTime.parse(json['time'] ?? DateTime.now().toIso8601String()),
      releaseTime: DateTime.parse(
          json['releaseTime'] ?? DateTime.now().toIso8601String()),
      sha1: json['sha1'] ?? '',
      complianceLevel: (json['complianceLevel'] ?? 0).toInt(),
    );
  }

  /// Returns true if this is a release version
  bool get isRelease => type == 'release';

  /// Returns true if this is a snapshot version
  bool get isSnapshot => type == 'snapshot';

  /// Returns a formatted display name
  String get displayName {
    if (isRelease) {
      return id;
    } else {
      return '$id (Snapshot)';
    }
  }
}
