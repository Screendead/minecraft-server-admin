import 'package:geolocator/geolocator.dart' hide LocationPermission;
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:minecraft_server_automation/common/interfaces/location_service.dart';

/// Implementation of LocationService using geolocator package
class LocationServiceAdapter implements LocationService {
  @override
  Future<LocationPermission> checkPermission() async {
    final permission = await Geolocator.checkPermission();
    return _convertPermission(permission);
  }

  @override
  Future<LocationPermission> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return _convertPermission(permission);
  }

  @override
  Future<LocationData?> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        heading: position.heading,
        timestamp: position.timestamp,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  LocationPermission _convertPermission(
      geolocator.LocationPermission permission) {
    switch (permission) {
      case geolocator.LocationPermission.denied:
        return LocationPermission.denied;
      case geolocator.LocationPermission.deniedForever:
        return LocationPermission.deniedForever;
      case geolocator.LocationPermission.whileInUse:
        return LocationPermission.whileInUse;
      case geolocator.LocationPermission.always:
        return LocationPermission.always;
      case geolocator.LocationPermission.unableToDetermine:
        return LocationPermission.unableToDetermine;
    }
  }
}
