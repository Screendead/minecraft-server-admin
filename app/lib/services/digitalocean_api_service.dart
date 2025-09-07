import 'dart:convert';
import 'package:http/http.dart' as http;

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
}
