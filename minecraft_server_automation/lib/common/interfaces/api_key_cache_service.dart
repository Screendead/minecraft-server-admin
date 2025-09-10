/// Abstract interface for API key cache services
/// This allows for easy mocking in tests
abstract class ApiKeyCacheServiceInterface {
  /// Get the cached API key if available and not expired
  String? getCachedApiKey();

  /// Cache an API key in memory
  void cacheApiKey(String apiKey);

  /// Clear the cached API key
  void clearCache();

  /// Check if there's a valid cached API key
  bool hasCachedApiKey();

  /// Get cache status information
  Map<String, dynamic> getCacheStatus();

  /// Handle app paused event (clear cache for security)
  void onAppPaused();

  /// Handle app resumed event
  void onAppResumed();

  /// Dispose of resources
  void dispose();
}
