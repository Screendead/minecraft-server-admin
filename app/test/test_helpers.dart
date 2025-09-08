import 'package:app/services/api_key_cache_service.dart';
import 'package:flutter/foundation.dart';

/// Test helper functions to ensure proper test isolation
class TestHelpers {
  /// Reset all singleton instances before running tests
  static void resetSingletons() {
    ApiKeyCacheService.resetInstance();
  }
  
  /// Check if running on iOS platform
  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;
}
