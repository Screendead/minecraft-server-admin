import 'package:minecraft_server_automation/models/droplet_creation_request.dart';
import 'package:minecraft_server_automation/models/droplet_size.dart';
import 'package:minecraft_server_automation/models/region.dart';

/// Abstract interface for DigitalOcean API services
/// This allows for easy mocking in tests
abstract class DigitalOceanApiServiceInterface {
  /// Set a custom HTTP client for testing
  void setClient(dynamic client);

  /// Validates a DigitalOcean API key by making a basic API call
  /// Returns true if the key is valid, false otherwise
  Future<bool> validateApiKey(String apiKey);

  /// Gets the account information for a valid API key
  /// Throws an exception if the key is invalid
  Future<Map<String, dynamic>> getAccountInfo(String apiKey);

  /// Gets all droplets for the authenticated user
  /// Throws an exception if the API key is invalid or request fails
  Future<List<Map<String, dynamic>>> getDroplets(String apiKey);

  /// Gets all available droplet sizes
  /// Throws an exception if the API key is invalid or request fails
  Future<List<DropletSize>> getDropletSizes(String apiKey);

  /// Gets all available regions
  /// Throws an exception if the API key is invalid or request fails
  Future<List<Region>> getRegions(String apiKey);

  /// Gets all available images
  /// Throws an exception if the API key is invalid or request fails
  Future<List<Map<String, dynamic>>> fetchImages(String apiKey);

  /// Creates a new droplet using the DigitalOcean API
  /// Throws an exception if the API key is invalid or request fails
  Future<Map<String, dynamic>> createDroplet(
    String apiKey,
    DropletCreationRequest request,
  );
}
