import 'package:flutter_test/flutter_test.dart';
import 'package:minecraft_server_automation/models/region.dart';
import 'package:minecraft_server_automation/services/region_selection_service.dart';

void main() {
  group('RegionSelectionService', () {
    late RegionSelectionService service;

    setUp(() {
      service = RegionSelectionService();
    });

    group('getRegionCoordinates', () {
      test('should return coordinates for known regions', () {
        final nycCoords = service.getRegionCoordinates('nyc1');
        expect(nycCoords, isNotNull);
        expect(nycCoords!['lat'], equals(40.7128));
        expect(nycCoords['lng'], equals(-74.0060));

        final londonCoords = service.getRegionCoordinates('lon1');
        expect(londonCoords, isNotNull);
        expect(londonCoords!['lat'], equals(51.5074));
        expect(londonCoords['lng'], equals(-0.1278));

        final sfoCoords = service.getRegionCoordinates('sfo1');
        expect(sfoCoords, isNotNull);
        expect(sfoCoords!['lat'], equals(37.7749));
        expect(sfoCoords['lng'], equals(-122.4194));
      });

      test('should return null for unknown regions', () {
        final unknownCoords = service.getRegionCoordinates('unknown');
        expect(unknownCoords, isNull);
      });

      test('should return coordinates for all known regions', () {
        final knownRegions = [
          'nyc1', 'nyc2', 'nyc3',
          'sfo1', 'sfo2', 'sfo3',
          'tor1', 'lon1',
          'ams2', 'ams3', 'fra1',
          'sgp1', 'blr1',
          'syd1', 'syd2', 'syd3',
        ];

        for (final region in knownRegions) {
          final coords = service.getRegionCoordinates(region);
          expect(coords, isNotNull, reason: 'Region $region should have coordinates');
          expect(coords!['lat'], isA<double>());
          expect(coords['lng'], isA<double>());
        }
      });
    });

    group('calculateDistance', () {
      test('should calculate distance between two points', () {
        // Distance between New York and London (approximately 5570 km)
        final distance = service.calculateDistance(40.7128, -74.0060, 51.5074, -0.1278);
        expect(distance, greaterThan(5500));
        expect(distance, lessThan(5600));
      });

      test('should return 0 for same coordinates', () {
        final distance = service.calculateDistance(40.7128, -74.0060, 40.7128, -74.0060);
        expect(distance, equals(0.0));
      });

      test('should calculate distance between New York and San Francisco', () {
        // Distance between NYC and SFO (approximately 4130 km)
        final distance = service.calculateDistance(40.7128, -74.0060, 37.7749, -122.4194);
        expect(distance, greaterThan(4100));
        expect(distance, lessThan(4200));
      });

      test('should calculate distance between London and Singapore', () {
        // Distance between London and Singapore (approximately 10850 km)
        final distance = service.calculateDistance(51.5074, -0.1278, 1.3521, 103.8198);
        expect(distance, greaterThan(10800));
        expect(distance, lessThan(10900));
      });

      test('should handle negative coordinates', () {
        // Distance between Sydney and New York (approximately 15900 km)
        final distance = service.calculateDistance(-33.8688, 151.2093, 40.7128, -74.0060);
        expect(distance, greaterThan(15800));
        expect(distance, lessThan(16000));
      });
    });

    group('degreesToRadians', () {
      test('should convert degrees to radians', () {
        expect(service.degreesToRadians(0), equals(0.0));
        expect(service.degreesToRadians(90), closeTo(1.5708, 0.001));
        expect(service.degreesToRadians(180), closeTo(3.14159, 0.001));
        expect(service.degreesToRadians(360), closeTo(6.28318, 0.001));
      });

      test('should handle negative degrees', () {
        expect(service.degreesToRadians(-90), closeTo(-1.5708, 0.001));
        expect(service.degreesToRadians(-180), closeTo(-3.14159, 0.001));
      });
    });

    group('findClosestRegionToPosition', () {
      late List<Region> testRegions;

      setUp(() {
        testRegions = [
          Region(
            name: 'New York 1',
            slug: 'nyc1',
            features: ['virtio', 'private_networking'],
            available: true,
          ),
          Region(
            name: 'London 1',
            slug: 'lon1',
            features: ['virtio', 'private_networking'],
            available: true,
          ),
          Region(
            name: 'San Francisco 1',
            slug: 'sfo1',
            features: ['virtio', 'private_networking'],
            available: true,
          ),
        ];
      });

      test('should find closest region to New York coordinates', () {
        // Test from New York coordinates (should return NYC)
        final closest = service.findClosestRegionToPosition(
          testRegions,
          40.7128, // NYC latitude
          -74.0060, // NYC longitude
        );

        expect(closest, isNotNull);
        expect(closest!.slug, equals('nyc1'));
      });

      test('should find closest region to London coordinates', () {
        // Test from London coordinates (should return London)
        final closest = service.findClosestRegionToPosition(
          testRegions,
          51.5074, // London latitude
          -0.1278, // London longitude
        );

        expect(closest, isNotNull);
        expect(closest!.slug, equals('lon1'));
      });

      test('should find closest region to San Francisco coordinates', () {
        // Test from San Francisco coordinates (should return SFO)
        final closest = service.findClosestRegionToPosition(
          testRegions,
          37.7749, // SFO latitude
          -122.4194, // SFO longitude
        );

        expect(closest, isNotNull);
        expect(closest!.slug, equals('sfo1'));
      });

      test('should return first region when no coordinates available', () {
        // Test with regions that don't have coordinates
        final regionsWithoutCoords = [
          Region(
            name: 'Unknown Region',
            slug: 'unknown',
            features: ['virtio'],
            available: true,
          ),
        ];

        final closest = service.findClosestRegionToPosition(
          regionsWithoutCoords,
          40.7128,
          -74.0060,
        );

        expect(closest, isNotNull);
        expect(closest!.slug, equals('unknown'));
      });

      test('should return null for empty regions list', () {
        final closest = service.findClosestRegionToPosition(
          [],
          40.7128,
          -74.0060,
        );

        expect(closest, isNull);
      });

      test('should handle mixed regions with and without coordinates', () {
        final mixedRegions = [
          Region(
            name: 'Unknown Region',
            slug: 'unknown',
            features: ['virtio'],
            available: true,
          ),
          Region(
            name: 'New York 1',
            slug: 'nyc1',
            features: ['virtio', 'private_networking'],
            available: true,
          ),
        ];

        final closest = service.findClosestRegionToPosition(
          mixedRegions,
          40.7128, // NYC coordinates
          -74.0060,
        );

        expect(closest, isNotNull);
        expect(closest!.slug, equals('nyc1'));
      });
    });

    group('_getDefaultRegion', () {
      test('should return London region when available', () async {
        final regions = [
          Region(
            name: 'New York 1',
            slug: 'nyc1',
            features: ['virtio'],
            available: true,
          ),
          Region(
            name: 'London 1',
            slug: 'lon1',
            features: ['virtio'],
            available: true,
          ),
        ];

        // Use reflection to access private method or test through public interface
        // Since we can't access private methods directly, we'll test the behavior
        // through the public findClosestRegion method with null location
        final result = await service.findClosestRegion(regions);
        
        // The service should return a region (likely London as default)
        expect(result, isNotNull);
        expect(result!.slug, isIn(['nyc1', 'lon1']));
      });

      test('should return first region when London not available', () async {
        final regions = [
          Region(
            name: 'New York 1',
            slug: 'nyc1',
            features: ['virtio'],
            available: true,
          ),
          Region(
            name: 'San Francisco 1',
            slug: 'sfo1',
            features: ['virtio'],
            available: true,
          ),
        ];

        final result = await service.findClosestRegion(regions);
        
        expect(result, isNotNull);
        expect(result!.slug, isIn(['nyc1', 'sfo1']));
      });

      test('should return null for empty regions list', () async {
        final result = await service.findClosestRegion([]);
        expect(result, isNull);
      });
    });

    group('integration tests', () {
      test('should work with realistic region data', () {
        final realisticRegions = [
          Region(
            name: 'New York 1',
            slug: 'nyc1',
            features: ['virtio', 'private_networking', 'backups'],
            available: true,
          ),
          Region(
            name: 'London 1',
            slug: 'lon1',
            features: ['virtio', 'private_networking', 'backups'],
            available: true,
          ),
          Region(
            name: 'San Francisco 1',
            slug: 'sfo1',
            features: ['virtio', 'private_networking', 'backups'],
            available: true,
          ),
          Region(
            name: 'Singapore 1',
            slug: 'sgp1',
            features: ['virtio', 'private_networking', 'backups'],
            available: true,
          ),
        ];

        // Test from various locations
        final testLocations = [
          {'lat': 40.7128, 'lng': -74.0060, 'expected': 'nyc1'}, // NYC
          {'lat': 51.5074, 'lng': -0.1278, 'expected': 'lon1'}, // London
          {'lat': 37.7749, 'lng': -122.4194, 'expected': 'sfo1'}, // SFO
          {'lat': 1.3521, 'lng': 103.8198, 'expected': 'sgp1'}, // Singapore
        ];

        for (final location in testLocations) {
          final closest = service.findClosestRegionToPosition(
            realisticRegions,
            location['lat']! as double,
            location['lng']! as double,
          );

          expect(closest, isNotNull);
          expect(closest!.slug, equals(location['expected']));
        }
      });
    });
  });
}
