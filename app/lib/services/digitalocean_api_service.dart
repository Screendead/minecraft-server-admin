import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/unit_formatter.dart';

/// Service for interacting with DigitalOcean API
class DigitalOceanApiService {
  static const String _baseUrl = 'https://api.digitalocean.com/v2';
  static http.Client? _client;

  /// Set a custom HTTP client for testing
  static void setClient(http.Client client) {
    _client = client;
  }

  /// Get the HTTP client (for testing or default)
  static http.Client get _httpClient => _client ?? http.Client();

  /// Validates a DigitalOcean API key by making a basic API call
  /// Returns true if the key is valid, false otherwise
  static Future<bool> validateApiKey(String apiKey) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/account'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      // API key is valid if we get a 200 response
      return response.statusCode == 200;
    } catch (e) {
      // Any network error or timeout means the key is invalid
      return false;
    }
  }

  /// Gets the account information for a valid API key
  /// Throws an exception if the key is invalid
  static Future<Map<String, dynamic>> getAccountInfo(String apiKey) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/account'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Invalid API key: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    return data['account'] as Map<String, dynamic>;
  }

  /// Gets all droplets for the authenticated user
  /// Throws an exception if the API key is invalid or request fails
  static Future<List<Map<String, dynamic>>> getDroplets(String apiKey) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/droplets'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch droplets: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final droplets = data['droplets'] as List<dynamic>;
    return droplets.cast<Map<String, dynamic>>();
  }

  /// Gets all available droplet sizes
  /// Throws an exception if the API key is invalid or request fails
  static Future<List<DropletSize>> getDropletSizes(String apiKey) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/sizes'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch droplet sizes: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final sizes = data['sizes'] as List<dynamic>;
    return sizes.map((size) => DropletSize.fromJson(size)).toList();
  }

  /// Gets all available regions
  /// Throws an exception if the API key is invalid or request fails
  static Future<List<Region>> getRegions(String apiKey) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/regions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch regions: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final regions = data['regions'] as List<dynamic>;
    return regions.map((region) => Region.fromJson(region)).toList();
  }
}

/// Data class representing a DigitalOcean droplet size
class DropletSize {
  final String slug;
  final int memory;
  final int vcpus;
  final int disk;
  final double transfer;
  final double priceMonthly;
  final double priceHourly;
  final List<String> regions;
  final bool available;
  final String description;

  const DropletSize({
    required this.slug,
    required this.memory,
    required this.vcpus,
    required this.disk,
    required this.transfer,
    required this.priceMonthly,
    required this.priceHourly,
    required this.regions,
    required this.available,
    required this.description,
  });

  factory DropletSize.fromJson(Map<String, dynamic> json) {
    return DropletSize(
      slug: json['slug'] ?? '',
      memory: (json['memory'] ?? 0).toInt(),
      vcpus: (json['vcpus'] ?? 0).toInt(),
      disk: (json['disk'] ?? 0).toInt(),
      transfer: (json['transfer'] ?? 0).toDouble(),
      priceMonthly: (json['price_monthly'] ?? 0).toDouble(),
      priceHourly: (json['price_hourly'] ?? 0).toDouble(),
      regions: (json['regions'] as List<dynamic>?)?.cast<String>() ?? [],
      available: json['available'] ?? false,
      description: json['description'] ?? '',
    );
  }

  /// Returns true if this is a shared CPU droplet
  bool get isSharedCpu => slug.startsWith('s-');

  /// Returns true if this is a dedicated CPU droplet
  bool get isDedicatedCpu => slug.startsWith('c-');

  /// Returns the dedicated CPU category
  String? get dedicatedCpuCategory {
    if (!isDedicatedCpu) return null;

    if (slug.startsWith('c-2') ||
        slug.startsWith('c-4') ||
        slug.startsWith('c-8')) {
      return 'general_purpose';
    } else if (slug.startsWith('c-2-') ||
        slug.startsWith('c-4-') ||
        slug.startsWith('c-8-')) {
      return 'cpu_optimized';
    } else if (slug.startsWith('c-16') || slug.startsWith('c-32')) {
      return 'memory_optimized';
    } else if (slug.startsWith('c-2-') && disk > 100) {
      return 'storage_optimized';
    }
    return 'general_purpose';
  }

  /// Returns true if this droplet is available in the given region
  bool isAvailableInRegion(String regionSlug) {
    return regions.contains(regionSlug);
  }

  /// Returns a formatted string for display
  String get displayName {
    final memoryDisplay = UnitFormatter.formatMemory(memory);
    final cpuDisplay = UnitFormatter.formatCpuCount(vcpus);
    final storageDisplay = UnitFormatter.formatStorage(disk);
    return '$slug - $memoryDisplay RAM, $cpuDisplay, $storageDisplay SSD';
  }
}

/// Data class representing a DigitalOcean region
class Region {
  final String name;
  final String slug;
  final List<String> features;
  final bool available;

  const Region({
    required this.name,
    required this.slug,
    required this.features,
    required this.available,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      features: (json['features'] as List<dynamic>?)?.cast<String>() ?? [],
      available: json['available'] ?? false,
    );
  }
}
