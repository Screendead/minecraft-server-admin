import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:geolocator/geolocator.dart';
import '../lib/services/region_selection_service.dart';
import '../lib/services/digitalocean_api_service.dart';

class MockPosition extends Mock implements Position {}

void main() {
  group('RegionSelectionService', () {
    test('findClosestRegionToPosition returns closest region', () {
      // Test data
      final regions = <Region>[
        Region(
          name: 'New York',
          slug: 'nyc1',
          available: true,
          features: [
            'virtio',
            'private_networking',
            'backups',
            'ipv6',
            'metadata'
          ],
        ),
        Region(
          name: 'San Francisco',
          slug: 'sfo1',
          available: true,
          features: [
            'virtio',
            'private_networking',
            'backups',
            'ipv6',
            'metadata'
          ],
        ),
        Region(
          name: 'London',
          slug: 'lon1',
          available: true,
          features: [
            'virtio',
            'private_networking',
            'backups',
            'ipv6',
            'metadata'
          ],
        ),
      ];

      // Test from New York (should return NYC region)
      final result = RegionSelectionService.findClosestRegionToPosition(
        regions,
        40.7128,
        -74.0060,
      );

      expect(result, isNotNull);
      expect(result!.slug, equals('nyc1'));
    });

    test('findClosestRegionToPosition returns first region when no coordinates',
        () {
      final regions = <Region>[
        Region(
          name: 'Test Region',
          slug: 'test1',
          available: true,
          features: ['virtio'],
        ),
      ];

      // Test with unknown region slug
      final result = RegionSelectionService.findClosestRegionToPosition(
        regions,
        0.0,
        0.0,
      );

      expect(result, isNotNull);
      expect(result!.slug, equals('test1'));
    });

    test('findClosestRegionToPosition returns null for empty regions', () {
      final result = RegionSelectionService.findClosestRegionToPosition(
        [],
        40.7128,
        -74.0060,
      );

      expect(result, isNull);
    });

    test('getRegionCoordinates returns correct coordinates for known regions',
        () {
      final coords = RegionSelectionService.getRegionCoordinates('nyc1');
      expect(coords, isNotNull);
      expect(coords!['lat'], equals(40.7128));
      expect(coords['lng'], equals(-74.0060));
    });

    test('getRegionCoordinates returns null for unknown region', () {
      final coords = RegionSelectionService.getRegionCoordinates('unknown');
      expect(coords, isNull);
    });

    test('calculateDistance calculates correct distance between two points',
        () {
      // Distance between New York and San Francisco (approximately 2560 miles)
      final distance = RegionSelectionService.calculateDistance(
        40.7128, -74.0060, // New York
        37.7749, -122.4194, // San Francisco
      );

      // Should be approximately 4000 km (allowing for some variance)
      expect(distance, greaterThan(3900));
      expect(distance, lessThan(4200));
    });

    test('calculateDistance returns 0 for same coordinates', () {
      final distance = RegionSelectionService.calculateDistance(
        40.7128,
        -74.0060,
        40.7128,
        -74.0060,
      );

      expect(distance, equals(0.0));
    });

    test('calculateDistance from Folkestone UK to London vs Amsterdam', () {
      // Folkestone, UK coordinates
      const folkestoneLat = 51.0813;
      const folkestoneLng = 1.1674;

      // London coordinates
      const londonLat = 51.5074;
      const londonLng = -0.1278;

      // Amsterdam coordinates
      const amsterdamLat = 52.3676;
      const amsterdamLng = 4.9041;

      final distanceToLondon = RegionSelectionService.calculateDistance(
        folkestoneLat,
        folkestoneLng,
        londonLat,
        londonLng,
      );

      final distanceToAmsterdam = RegionSelectionService.calculateDistance(
        folkestoneLat,
        folkestoneLng,
        amsterdamLat,
        amsterdamLng,
      );

      print('Folkestone to London: ${distanceToLondon.toStringAsFixed(1)} km');
      print(
          'Folkestone to Amsterdam: ${distanceToAmsterdam.toStringAsFixed(1)} km');

      // London should be closer than Amsterdam
      expect(distanceToLondon, lessThan(distanceToAmsterdam));
      expect(distanceToLondon,
          lessThan(110)); // Should be less than 110km (101.8km actual)
      expect(
          distanceToAmsterdam, greaterThan(150)); // Should be more than 150km
    });
  });
}
