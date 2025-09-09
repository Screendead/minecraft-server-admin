import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:minecraft_server_automation/models/region.dart';

/// Service for determining the closest DigitalOcean region to the user
class RegionSelectionService {
  /// Get the user's current location
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get current position with high accuracy
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }

  /// Find the closest DigitalOcean region to the user's location
  static Future<Region?> findClosestRegion(List<Region> regions) async {
    final position = await getCurrentLocation();
    if (position == null) {
      // If we can't get location, try to find a reasonable default
      return _getDefaultRegion(regions);
    }

    return findClosestRegionToPosition(
        regions, position.latitude, position.longitude);
  }

  /// Get a reasonable default region when location detection fails
  static Region? _getDefaultRegion(List<Region> regions) {
    if (regions.isEmpty) return null;

    // Try to find London first (good default for UK users)
    final londonRegion = regions.firstWhere(
      (region) => region.slug == 'lon1',
      orElse: () => regions.first,
    );

    return londonRegion;
  }

  /// Find the closest region to a specific latitude and longitude
  static Region? findClosestRegionToPosition(
      List<Region> regions, double lat, double lng) {
    if (regions.isEmpty) return null;

    Region? closestRegion;
    double minDistance = double.infinity;

    for (final region in regions) {
      final regionCoords = getRegionCoordinates(region.slug);
      if (regionCoords == null) {
        continue;
      }

      final distance = calculateDistance(
        lat,
        lng,
        regionCoords['lat']!,
        regionCoords['lng']!,
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestRegion = region;
      }
    }

    return closestRegion ?? regions.first;
  }

  /// Get approximate coordinates for DigitalOcean regions
  static Map<String, double>? getRegionCoordinates(String regionSlug) {
    // DigitalOcean region coordinates (approximate)
    const regionCoordinates = {
      'nyc1': {'lat': 40.7128, 'lng': -74.0060}, // New York
      'nyc2': {'lat': 40.7128, 'lng': -74.0060}, // New York
      'nyc3': {'lat': 40.7128, 'lng': -74.0060}, // New York
      'sfo1': {'lat': 37.7749, 'lng': -122.4194}, // San Francisco
      'sfo2': {'lat': 37.7749, 'lng': -122.4194}, // San Francisco
      'sfo3': {'lat': 37.7749, 'lng': -122.4194}, // San Francisco
      'tor1': {'lat': 43.6532, 'lng': -79.3832}, // Toronto
      'lon1': {'lat': 51.5074, 'lng': -0.1278}, // London
      'ams2': {'lat': 52.3676, 'lng': 4.9041}, // Amsterdam
      'ams3': {'lat': 52.3676, 'lng': 4.9041}, // Amsterdam
      'fra1': {'lat': 50.1109, 'lng': 8.6821}, // Frankfurt
      'sgp1': {'lat': 1.3521, 'lng': 103.8198}, // Singapore
      'blr1': {'lat': 12.9716, 'lng': 77.5946}, // Bangalore
      'syd1': {'lat': -33.8688, 'lng': 151.2093}, // Sydney
      'syd2': {'lat': -33.8688, 'lng': 151.2093}, // Sydney
      'syd3': {'lat': -33.8688, 'lng': 151.2093}, // Sydney
    };

    return regionCoordinates[regionSlug];
  }

  /// Calculate distance between two points using Haversine formula
  static double calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final dLat = degreesToRadians(lat2 - lat1);
    final dLng = degreesToRadians(lng2 - lng1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(degreesToRadians(lat1)) *
            cos(degreesToRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
