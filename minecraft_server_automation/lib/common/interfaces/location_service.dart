/// Abstract interface for location services
/// This allows for easy mocking in tests
abstract class LocationService {
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
  Future<LocationData?> getCurrentLocation();
  Future<bool> isLocationServiceEnabled();
}

/// Location permission status
enum LocationPermission {
  denied,
  deniedForever,
  whileInUse,
  always,
  unableToDetermine,
}

/// Location data
class LocationData {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final double? heading;
  final DateTime timestamp;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    required this.timestamp,
  });
}
