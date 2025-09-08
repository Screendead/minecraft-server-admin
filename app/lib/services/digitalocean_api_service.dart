import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/unit_formatter.dart';
import '../models/cpu_architecture.dart';
import '../models/cpu_category.dart';
import '../models/cpu_option.dart';
import '../models/storage_multiplier.dart';
import 'logging_service.dart';
import '../models/log_entry.dart';

/// Service for interacting with DigitalOcean API
class DigitalOceanApiService {
  static const String _baseUrl = 'https://api.digitalocean.com/v2';
  static http.Client? _client;
  static final LoggingService _loggingService = LoggingService();

  /// Set a custom HTTP client for testing
  static void setClient(http.Client client) {
    _client = client;
  }

  /// Get the HTTP client (for testing or default)
  static http.Client get _httpClient => _client ?? http.Client();

  /// Validates a DigitalOcean API key by making a basic API call
  /// Returns true if the key is valid, false otherwise
  static Future<bool> validateApiKey(String apiKey) async {
    final stopwatch = Stopwatch()..start();

    try {
      await _loggingService.logApiCall(
        '/account',
        'GET',
        metadata: {'operation': 'validate_api_key'},
      );

      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/account'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      stopwatch.stop();

      // API key is valid if we get a 200 response
      final isValid = response.statusCode == 200;

      await _loggingService.logApiCall(
        '/account',
        'GET',
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
        metadata: {
          'operation': 'validate_api_key',
          'isValid': isValid,
        },
      );

      return isValid;
    } catch (e) {
      stopwatch.stop();

      await _loggingService.logError(
        'API key validation failed',
        category: LogCategory.apiCall,
        details: 'Endpoint: /account, Error: $e',
        metadata: {
          'endpoint': '/account',
          'method': 'GET',
          'operation': 'validate_api_key',
        },
        error: e,
      );

      return false;
    }
  }

  /// Gets the account information for a valid API key
  /// Throws an exception if the key is invalid
  static Future<Map<String, dynamic>> getAccountInfo(String apiKey) async {
    final stopwatch = Stopwatch()..start();

    try {
      await _loggingService.logApiCall(
        '/account',
        'GET',
        metadata: {'operation': 'get_account_info'},
      );

      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/account'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      stopwatch.stop();

      if (response.statusCode != 200) {
        await _loggingService.logError(
          'Failed to get account info - invalid API key',
          category: LogCategory.apiCall,
          details: 'Status: ${response.statusCode}, Response: ${response.body}',
          metadata: {
            'endpoint': '/account',
            'method': 'GET',
            'operation': 'get_account_info',
            'statusCode': response.statusCode,
          },
        );

        throw Exception('Invalid API key: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final accountInfo = data['account'] as Map<String, dynamic>;

      await _loggingService.logApiCall(
        '/account',
        'GET',
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
        metadata: {
          'operation': 'get_account_info',
          'accountEmail': accountInfo['email']?.toString(),
        },
      );

      return accountInfo;
    } catch (e) {
      stopwatch.stop();

      await _loggingService.logError(
        'Account info request failed',
        category: LogCategory.apiCall,
        details: 'Endpoint: /account, Error: $e',
        metadata: {
          'endpoint': '/account',
          'method': 'GET',
          'operation': 'get_account_info',
        },
        error: e,
      );

      rethrow;
    }
  }

  /// Gets all droplets for the authenticated user
  /// Throws an exception if the API key is invalid or request fails
  static Future<List<Map<String, dynamic>>> getDroplets(String apiKey) async {
    final stopwatch = Stopwatch()..start();

    try {
      await _loggingService.logApiCall(
        '/droplets',
        'GET',
        metadata: {'operation': 'get_droplets'},
      );

      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/droplets'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      stopwatch.stop();

      if (response.statusCode != 200) {
        await _loggingService.logError(
          'Failed to fetch droplets',
          category: LogCategory.apiCall,
          details: 'Status: ${response.statusCode}, Response: ${response.body}',
          metadata: {
            'endpoint': '/droplets',
            'method': 'GET',
            'operation': 'get_droplets',
            'statusCode': response.statusCode,
          },
        );

        throw Exception('Failed to fetch droplets: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final droplets = data['droplets'] as List<dynamic>;
      final dropletList = droplets.cast<Map<String, dynamic>>();

      await _loggingService.logApiCall(
        '/droplets',
        'GET',
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
        metadata: {
          'operation': 'get_droplets',
          'dropletCount': dropletList.length,
        },
      );

      return dropletList;
    } catch (e) {
      stopwatch.stop();

      await _loggingService.logError(
        'Droplets request failed',
        category: LogCategory.apiCall,
        details: 'Endpoint: /droplets, Error: $e',
        metadata: {
          'endpoint': '/droplets',
          'method': 'GET',
          'operation': 'get_droplets',
        },
        error: e,
      );

      rethrow;
    }
  }

  /// Gets all available droplet sizes
  /// Throws an exception if the API key is invalid or request fails
  static Future<List<DropletSize>> getDropletSizes(String apiKey) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/sizes?per_page=200'),
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
  bool get isDedicatedCpu =>
      slug.startsWith('c-') ||
      slug.startsWith('g-') ||
      slug.startsWith('m-') ||
      slug.startsWith('so-') ||
      slug.startsWith('gpu-');

  /// Returns the CPU architecture for this droplet
  CpuArchitecture get cpuArchitecture {
    if (isSharedCpu) return CpuArchitecture.shared;
    return CpuArchitecture.dedicated;
  }

  /// Returns the CPU category for this droplet
  CpuCategory get cpuCategory {
    if (isSharedCpu) return CpuCategory.basic;

    if (slug.startsWith('g-') || slug.startsWith('gd-')) {
      return CpuCategory.generalPurpose;
    } else if (slug.startsWith('c-') || slug.startsWith('c2-')) {
      return CpuCategory.cpuOptimized;
    } else if (slug.startsWith('m-') ||
        slug.startsWith('m3-') ||
        slug.startsWith('m6-')) {
      return CpuCategory.memoryOptimized;
    } else if (slug.startsWith('so-')) {
      return CpuCategory.storageOptimized;
    } else if (slug.startsWith('gpu-')) {
      return CpuCategory.gpu;
    }

    return CpuCategory.generalPurpose; // Default fallback
  }

  /// Returns the CPU option for this droplet
  CpuOption get cpuOption {
    if (isSharedCpu) {
      if (slug.contains('-intel')) return CpuOption.premiumIntel;
      if (slug.contains('-amd')) return CpuOption.premiumAmd;
      return CpuOption.regular;
    }

    // Handle dedicated CPU Intel variants
    if (slug.contains('-intel')) return CpuOption.premiumIntel;
    return CpuOption.regular;
  }

  /// Returns the storage multiplier for this droplet
  StorageMultiplier get storageMultiplier {
    if (slug.startsWith('gd-') || slug.startsWith('c2-')) {
      return StorageMultiplier.x2;
    } else if (slug.startsWith('m3-')) {
      return StorageMultiplier.x3;
    } else if (slug.startsWith('m6-')) {
      return StorageMultiplier.x6;
    }
    return StorageMultiplier.x1; // Default to 1x
  }

  /// Returns the dedicated CPU category (legacy method for backward compatibility)
  String? get dedicatedCpuCategory {
    if (!isDedicatedCpu) return null;
    return cpuCategory.value;
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
