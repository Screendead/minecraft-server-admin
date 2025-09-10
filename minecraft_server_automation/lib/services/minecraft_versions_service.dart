import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:minecraft_server_automation/models/minecraft_version.dart';
import 'package:minecraft_server_automation/common/interfaces/minecraft_versions_service.dart';

/// Service for fetching Minecraft versions from the official launcher manifest
class MinecraftVersionsService implements MinecraftVersionsServiceInterface {
  static const String _manifestUrl =
      'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json';
  http.Client? _client;

  /// Set a custom HTTP client for testing
  @override
  void setClient(dynamic client) {
    _client = client as http.Client?;
  }

  /// Get the HTTP client (for testing or default)
  http.Client get _httpClient => _client ?? http.Client();

  /// Fetches all available Minecraft versions from the official manifest
  /// Returns a list of MinecraftVersion objects sorted by release date (newest first)
  @override
  Future<List<MinecraftVersion>> getMinecraftVersions() async {
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
  }

  /// Fetches only release versions (stable releases)
  @override
  Future<List<MinecraftVersion>> getReleaseVersions() async {
    final allVersions = await getMinecraftVersions();
    return allVersions.where((version) => version.type == 'release').toList();
  }

  /// Fetches only snapshot versions (preview releases)
  @override
  Future<List<MinecraftVersion>> getSnapshotVersions() async {
    final allVersions = await getMinecraftVersions();
    return allVersions.where((version) => version.type == 'snapshot').toList();
  }

  /// Fetches the server JAR URL for a specific Minecraft version
  /// Throws an exception if the version is not found or the URL cannot be fetched
  @override
  Future<String> getServerJarUrlForVersion(String versionId) async {
    // First get all versions to find the specific one
    final versions = await getMinecraftVersions();
    final version = versions.firstWhere(
      (v) => v.id == versionId,
      orElse: () => throw Exception('Version $versionId not found'),
    );

    // Fetch the version manifest
    final response = await _httpClient.get(
      Uri.parse(version.url),
      headers: {
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to fetch version manifest: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final downloads = data['downloads'] as Map<String, dynamic>?;

    if (downloads == null) {
      throw Exception('No downloads section found in version manifest');
    }

    final server = downloads['server'] as Map<String, dynamic>?;
    if (server == null) {
      throw Exception('No server download found for version $versionId');
    }

    final url = server['url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception('Server JAR URL is empty for version $versionId');
    }

    return url;
  }
}

/// Data class representing a Minecraft version
