import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:minecraft_server_automation/models/droplet_creation_request.dart';
import 'package:minecraft_server_automation/models/region.dart';
import 'package:minecraft_server_automation/models/droplet_size.dart';
import 'package:minecraft_server_automation/common/di/service_locator.dart';
import 'package:minecraft_server_automation/models/log_entry.dart';
import 'package:minecraft_server_automation/common/interfaces/digitalocean_api_service.dart';

/// Service for interacting with DigitalOcean API
class DigitalOceanApiService implements DigitalOceanApiServiceInterface {
  static const String _baseUrl = 'https://api.digitalocean.com/v2';
  http.Client? _client;
  final ServiceLocator _serviceLocator = ServiceLocator();

  /// Set a custom HTTP client for testing
  @override
  void setClient(dynamic client) {
    _client = client as http.Client?;
  }

  /// Get the HTTP client (for testing or default)
  http.Client get _httpClient => _client ?? http.Client();

  /// Validates a DigitalOcean API key by making a basic API call
  /// Returns true if the key is valid, false otherwise
  @override
  Future<bool> validateApiKey(String apiKey) async {
    final stopwatch = Stopwatch()..start();

    try {
      await _serviceLocator.loggingService.logApiCall(
        '/account',
        'GET',
        metadata: {'operation': 'validate_api_key'},
      );

      final response = await _httpClient
          .get(
            Uri.parse('$_baseUrl/account'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      stopwatch.stop();

      // API key is valid if we get a 200 response
      final isValid = response.statusCode == 200;

      await _serviceLocator.loggingService.logApiCall(
        '/account',
        'GET',
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
        metadata: {'operation': 'validate_api_key', 'isValid': isValid},
      );

      return isValid;
    } catch (e) {
      stopwatch.stop();

      await _serviceLocator.loggingService.logError(
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
  @override
  Future<Map<String, dynamic>> getAccountInfo(String apiKey) async {
    final stopwatch = Stopwatch()..start();

    try {
      await _serviceLocator.loggingService.logApiCall(
        '/account',
        'GET',
        metadata: {'operation': 'get_account_info'},
      );

      final response = await _httpClient
          .get(
            Uri.parse('$_baseUrl/account'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      stopwatch.stop();

      if (response.statusCode != 200) {
        await _serviceLocator.loggingService.logError(
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

      await _serviceLocator.loggingService.logApiCall(
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

      await _serviceLocator.loggingService.logError(
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
  @override
  Future<List<Map<String, dynamic>>> getDroplets(String apiKey) async {
    final stopwatch = Stopwatch()..start();

    try {
      await _serviceLocator.loggingService.logApiCall(
        '/droplets',
        'GET',
        metadata: {'operation': 'get_droplets'},
      );

      final response = await _httpClient
          .get(
            Uri.parse('$_baseUrl/droplets'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      stopwatch.stop();

      if (response.statusCode != 200) {
        await _serviceLocator.loggingService.logError(
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

      await _serviceLocator.loggingService.logApiCall(
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

      await _serviceLocator.loggingService.logError(
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
  @override
  Future<List<DropletSize>> getDropletSizes(String apiKey) async {
    final response = await _httpClient
        .get(
          Uri.parse('$_baseUrl/sizes?per_page=200'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch droplet sizes: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final sizes = data['sizes'] as List<dynamic>;
    return sizes.map((size) => DropletSize.fromJson(size)).toList();
  }

  /// Gets all available regions
  /// Throws an exception if the API key is invalid or request fails
  @override
  Future<List<Region>> getRegions(String apiKey) async {
    final response = await _httpClient
        .get(
          Uri.parse('$_baseUrl/regions'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch regions: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final regions = data['regions'] as List<dynamic>;
    return regions.map((region) => Region.fromJson(region)).toList();
  }

  /// Gets all available images
  /// Throws an exception if the API key is invalid or request fails
  @override
  Future<List<Map<String, dynamic>>> fetchImages(String apiKey) async {
    final stopwatch = Stopwatch()..start();

    try {
      await _serviceLocator.loggingService.logApiCall(
        '/images',
        'GET',
        metadata: {'operation': 'fetch_images'},
      );

      final response = await _httpClient
          .get(
            Uri.parse('$_baseUrl/images?per_page=200'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      stopwatch.stop();

      if (response.statusCode != 200) {
        await _serviceLocator.loggingService.logError(
          'Failed to fetch images',
          category: LogCategory.apiCall,
          details: 'Status: ${response.statusCode}, Response: ${response.body}',
          metadata: {
            'endpoint': '/images',
            'method': 'GET',
            'operation': 'fetch_images',
            'statusCode': response.statusCode,
          },
        );

        throw Exception('Failed to fetch images: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final images = data['images'] as List<dynamic>?;

      if (images == null) {
        await _serviceLocator.loggingService.logError(
          'Images response missing images array',
          category: LogCategory.apiCall,
          details: 'Response: ${response.body}',
          metadata: {
            'endpoint': '/images',
            'method': 'GET',
            'operation': 'fetch_images',
            'statusCode': response.statusCode,
          },
        );
        throw Exception('Invalid response: missing images array');
      }

      final imageList = images.cast<Map<String, dynamic>>();

      await _serviceLocator.loggingService.logApiCall(
        '/images',
        'GET',
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
        metadata: {'operation': 'fetch_images', 'imageCount': imageList.length},
      );

      return imageList;
    } catch (e) {
      stopwatch.stop();

      await _serviceLocator.loggingService.logError(
        'Images request failed',
        category: LogCategory.apiCall,
        details: 'Endpoint: /images, Error: $e',
        metadata: {
          'endpoint': '/images',
          'method': 'GET',
          'operation': 'fetch_images',
        },
        error: e,
      );

      rethrow;
    }
  }

  /// Creates a new droplet using the DigitalOcean API
  /// Throws an exception if the API key is invalid or request fails
  @override
  Future<Map<String, dynamic>> createDroplet(
    String apiKey,
    DropletCreationRequest request,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      await _serviceLocator.loggingService.logApiCall(
        '/droplets',
        'POST',
        metadata: {
          'operation': 'create_droplet',
          'droplet_name': request.name,
          'region': request.region,
          'size': request.size,
        },
      );

      final response = await _httpClient
          .post(
            Uri.parse('$_baseUrl/droplets'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: json.encode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      stopwatch.stop();

      if (response.statusCode != 202) {
        await _serviceLocator.loggingService.logError(
          'Failed to create droplet',
          category: LogCategory.apiCall,
          details: 'Status: ${response.statusCode}, Response: ${response.body}',
          metadata: {
            'endpoint': '/droplets',
            'method': 'POST',
            'operation': 'create_droplet',
            'statusCode': response.statusCode,
            'droplet_name': request.name,
            'region': request.region,
            'size': request.size,
          },
        );

        throw Exception(
          'Failed to create droplet: ${response.statusCode} - ${response.body}',
        );
      }

      final data = json.decode(response.body);
      final droplet = data['droplet'] as Map<String, dynamic>?;

      if (droplet == null) {
        await _serviceLocator.loggingService.logError(
          'Droplet creation response missing droplet data',
          category: LogCategory.apiCall,
          details: 'Response: ${response.body}',
          metadata: {
            'endpoint': '/droplets',
            'method': 'POST',
            'operation': 'create_droplet',
            'statusCode': response.statusCode,
          },
        );
        throw Exception('Invalid response: missing droplet data');
      }

      await _serviceLocator.loggingService.logApiCall(
        '/droplets',
        'POST',
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
        metadata: {
          'operation': 'create_droplet',
          'droplet_id': droplet['id']?.toString(),
          'droplet_name': request.name,
          'region': request.region,
          'size': request.size,
        },
      );

      return droplet;
    } catch (e) {
      stopwatch.stop();

      await _serviceLocator.loggingService.logError(
        'Droplet creation request failed',
        category: LogCategory.apiCall,
        details: 'Endpoint: /droplets, Error: $e',
        metadata: {
          'endpoint': '/droplets',
          'method': 'POST',
          'operation': 'create_droplet',
          'droplet_name': request.name,
          'region': request.region,
          'size': request.size,
        },
        error: e,
      );

      rethrow;
    }
  }
}

/// Data class representing a DigitalOcean droplet size

/// Data class representing a DigitalOcean region
