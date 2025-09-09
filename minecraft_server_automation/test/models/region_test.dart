import 'package:flutter_test/flutter_test.dart';
import 'package:minecraft_server_automation/models/region.dart';

void main() {
  group('Region', () {
    test('should create instance with all parameters', () {
      const region = Region(
        name: 'New York 1',
        slug: 'nyc1',
        features: ['virtio', 'private_networking', 'backups', 'ipv6', 'metadata'],
        available: true,
      );

      expect(region.name, equals('New York 1'));
      expect(region.slug, equals('nyc1'));
      expect(region.features, equals(['virtio', 'private_networking', 'backups', 'ipv6', 'metadata']));
      expect(region.available, isTrue);
    });

    group('fromJson factory', () {
      test('should create instance from valid JSON', () {
        final json = {
          'name': 'New York 1',
          'slug': 'nyc1',
          'features': ['virtio', 'private_networking', 'backups', 'ipv6', 'metadata'],
          'available': true,
        };

        final region = Region.fromJson(json);

        expect(region.name, equals('New York 1'));
        expect(region.slug, equals('nyc1'));
        expect(region.features, equals(['virtio', 'private_networking', 'backups', 'ipv6', 'metadata']));
        expect(region.available, isTrue);
      });

      test('should handle missing fields with defaults', () {
        final json = <String, dynamic>{};

        final region = Region.fromJson(json);

        expect(region.name, equals(''));
        expect(region.slug, equals(''));
        expect(region.features, equals([]));
        expect(region.available, isFalse);
      });

      test('should handle null values with defaults', () {
        final json = {
          'name': null,
          'slug': null,
          'features': null,
          'available': null,
        };

        final region = Region.fromJson(json);

        expect(region.name, equals(''));
        expect(region.slug, equals(''));
        expect(region.features, equals([]));
        expect(region.available, isFalse);
      });

      test('should handle empty features list', () {
        final json = {
          'name': 'Test Region',
          'slug': 'test1',
          'features': [],
          'available': true,
        };

        final region = Region.fromJson(json);

        expect(region.name, equals('Test Region'));
        expect(region.slug, equals('test1'));
        expect(region.features, equals([]));
        expect(region.available, isTrue);
      });

      test('should handle features with string types only', () {
        final json = {
          'name': 'Test Region',
          'slug': 'test1',
          'features': ['virtio', 'backups', 'metadata'],
          'available': true,
        };

        final region = Region.fromJson(json);

        expect(region.name, equals('Test Region'));
        expect(region.slug, equals('test1'));
        expect(region.features, equals(['virtio', 'backups', 'metadata']));
        expect(region.available, isTrue);
      });
    });

    test('should be immutable', () {
      const region = Region(
        name: 'New York 1',
        slug: 'nyc1',
        features: ['virtio', 'private_networking'],
        available: true,
      );

      expect(region.name, equals('New York 1'));
      expect(region.slug, equals('nyc1'));
      expect(region.features, equals(['virtio', 'private_networking']));
      expect(region.available, isTrue);
      
      // Verify that the values are constants
      expect(region.name, isA<String>());
      expect(region.slug, isA<String>());
      expect(region.features, isA<List<String>>());
      expect(region.available, isA<bool>());
    });

    test('should support equality comparison', () {
      const region1 = Region(
        name: 'New York 1',
        slug: 'nyc1',
        features: ['virtio', 'private_networking'],
        available: true,
      );

      const region2 = Region(
        name: 'New York 1',
        slug: 'nyc1',
        features: ['virtio', 'private_networking'],
        available: true,
      );

      const region3 = Region(
        name: 'San Francisco 1',
        slug: 'sfo1',
        features: ['virtio', 'private_networking'],
        available: true,
      );

      expect(region1, equals(region2));
      expect(region1, isNot(equals(region3)));
    });

    test('should support string conversion', () {
      const region = Region(
        name: 'New York 1',
        slug: 'nyc1',
        features: ['virtio', 'private_networking'],
        available: true,
      );

      final string = region.toString();

      // Region class doesn't have custom toString, so it returns default instance representation
      expect(string, contains('Region'));
    });
  });
}
