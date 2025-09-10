import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minecraft_server_automation/services/digitalocean_api_service.dart';
import 'package:minecraft_server_automation/services/minecraft_server_service.dart';
import 'auth_provider.dart' as auth_provider;

/// Provider for managing DigitalOcean droplets and their Minecraft server status
class DropletsProvider with ChangeNotifier {
  List<DropletInfo> _droplets = [];
  bool _isLoading = false;
  String? _error;

  List<DropletInfo> get droplets => _droplets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get droplets that are running Minecraft servers
  List<DropletInfo> get minecraftDroplets =>
      _droplets.where((droplet) => droplet.isMinecraftServer).toList();

  /// Get droplets that are not running Minecraft servers
  List<DropletInfo> get nonMinecraftDroplets =>
      _droplets.where((droplet) => !droplet.isMinecraftServer).toList();

  /// Load all droplets and check for Minecraft servers (for testing)
  Future<void> loadDropletsWithApiKey(String apiKey) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load droplets using the provided API key
      final dropletsData = await DigitalOceanApiService.getDroplets(apiKey);
      _droplets =
          dropletsData.map((data) => DropletInfo.fromJson(data)).toList();

      // Check Minecraft server status for each droplet
      for (final droplet in _droplets) {
        if (droplet.publicIp != null) {
          final minecraftInfo =
              await MinecraftServerService.checkMinecraftServer(
            droplet.publicIp!,
          );
          if (minecraftInfo != null) {
            droplet.setMinecraftInfo(minecraftInfo);
          }
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load droplets: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all droplets and check for Minecraft servers
  Future<void> loadDroplets(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get the API key from the AuthProvider's cached service
      final authProvider = context.read<auth_provider.AuthProvider>();
      final apiKeyService = authProvider.iosApiKeyService;

      if (apiKeyService == null) {
        _error = 'User not authenticated. Please sign in.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final apiKey = await apiKeyService.getApiKey();
      if (apiKey == null) {
        _error = 'No API key found. Please add your DigitalOcean API key.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch droplets from DigitalOcean API
      final dropletsData = await DigitalOceanApiService.getDroplets(apiKey);

      // Convert to DropletInfo objects and check for Minecraft servers
      final List<DropletInfo> droplets = [];

      for (final dropletData in dropletsData) {
        final droplet = DropletInfo.fromJson(dropletData);

        // Check if this droplet is running a Minecraft server
        if (droplet.publicIp != null) {
          final minecraftInfo =
              await MinecraftServerService.checkMinecraftServer(
                  droplet.publicIp!);
          droplet.setMinecraftInfo(minecraftInfo);
        }

        droplets.add(droplet);
      }

      _droplets = droplets;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load droplets: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh the droplets data
  Future<void> refresh(BuildContext context) async {
    await loadDroplets(context);
  }
}

/// Data class representing a DigitalOcean droplet
class DropletInfo {
  final int id;
  final String name;
  final String status;
  final String? publicIp;
  final String? privateIp;
  final String region;
  final String size;
  final String image;
  final List<String> tags;
  final DateTime createdAt;

  MinecraftServerInfo? _minecraftInfo;
  bool get isMinecraftServer => _minecraftInfo != null;
  MinecraftServerInfo? get minecraftInfo => _minecraftInfo;

  DropletInfo({
    required this.id,
    required this.name,
    required this.status,
    this.publicIp,
    this.privateIp,
    required this.region,
    required this.size,
    required this.image,
    required this.tags,
    required this.createdAt,
  });

  void setMinecraftInfo(MinecraftServerInfo? info) {
    _minecraftInfo = info;
  }

  factory DropletInfo.fromJson(Map<String, dynamic> json) {
    final networks = json['networks'] as Map<String, dynamic>?;
    final v4Networks = networks?['v4'] as List<dynamic>? ?? [];

    String? publicIp;
    String? privateIp;

    for (final network in v4Networks) {
      final networkData = network as Map<String, dynamic>;
      if (networkData['type'] == 'public') {
        publicIp = networkData['ip_address'];
      } else if (networkData['type'] == 'private') {
        privateIp = networkData['ip_address'];
      }
    }

    return DropletInfo(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      publicIp: publicIp,
      privateIp: privateIp,
      region: json['region']?['name'] ?? 'Unknown',
      size: json['size']?['slug'] ?? 'Unknown',
      image: json['image']?['name'] ?? 'Unknown',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
