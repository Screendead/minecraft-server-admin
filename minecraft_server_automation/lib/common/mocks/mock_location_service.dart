import 'package:minecraft_server_automation/common/interfaces/location_service.dart';

/// Mock implementation of LocationService for testing
class MockLocationService implements LocationService {
  // Test control properties
  LocationPermission _permission = LocationPermission.whileInUse;
  LocationData? _mockLocation;
  bool _isLocationServiceEnabled = true;
  bool _shouldThrow = false;
  String? _throwMessage;
  List<LocationOperation> _operations = [];

  @override
  Future<LocationPermission> checkPermission() async {
    _operations
        .add(LocationOperation(type: LocationOperationType.checkPermission));

    if (_shouldThrow) {
      throw Exception(_throwMessage ?? 'Mock location error');
    }

    return _permission;
  }

  @override
  Future<LocationPermission> requestPermission() async {
    _operations
        .add(LocationOperation(type: LocationOperationType.requestPermission));

    if (_shouldThrow) {
      throw Exception(_throwMessage ?? 'Mock location error');
    }

    return _permission;
  }

  @override
  Future<LocationData?> getCurrentLocation() async {
    _operations
        .add(LocationOperation(type: LocationOperationType.getCurrentLocation));

    if (_shouldThrow) {
      throw Exception(_throwMessage ?? 'Mock location error');
    }

    if (_permission == LocationPermission.denied ||
        _permission == LocationPermission.deniedForever) {
      return null;
    }

    return _mockLocation;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    _operations.add(LocationOperation(
        type: LocationOperationType.isLocationServiceEnabled));

    if (_shouldThrow) {
      throw Exception(_throwMessage ?? 'Mock location error');
    }

    return _isLocationServiceEnabled;
  }

  // Test helper methods
  void setPermission(LocationPermission permission) => _permission = permission;
  void setMockLocation(LocationData? location) => _mockLocation = location;
  void setLocationServiceEnabled(bool enabled) =>
      _isLocationServiceEnabled = enabled;
  void setShouldThrow(bool shouldThrow, [String? message]) {
    _shouldThrow = shouldThrow;
    _throwMessage = message;
  }

  List<LocationOperation> get operations => List.unmodifiable(_operations);
  void clearOperations() => _operations.clear();

  void reset() {
    _permission = LocationPermission.whileInUse;
    _mockLocation = null;
    _isLocationServiceEnabled = true;
    _shouldThrow = false;
    _throwMessage = null;
    _operations.clear();
  }
}

/// Record of location operations
class LocationOperation {
  final LocationOperationType type;
  final DateTime timestamp;

  LocationOperation({
    required this.type,
  }) : timestamp = DateTime.now();
}

enum LocationOperationType {
  checkPermission,
  requestPermission,
  getCurrentLocation,
  isLocationServiceEnabled,
}
