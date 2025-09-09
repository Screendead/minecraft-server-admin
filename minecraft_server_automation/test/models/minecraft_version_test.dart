import 'package:flutter_test/flutter_test.dart';
import 'package:minecraft_server_automation/models/minecraft_version.dart';

void main() {
  group('MinecraftVersion', () {
    test('should create instance with all parameters', () {
      final time = DateTime.now();
      final releaseTime = DateTime.now().add(Duration(days: 1));
      
      final minecraftVersion = MinecraftVersion(
        id: '1.20.1',
        type: 'release',
        url: 'https://launchermeta.mojang.com/mc/game/version_manifest.json',
        time: time,
        releaseTime: releaseTime,
        sha1: 'abc123def456',
        complianceLevel: 1,
      );

      expect(minecraftVersion.id, equals('1.20.1'));
      expect(minecraftVersion.type, equals('release'));
      expect(minecraftVersion.url, equals('https://launchermeta.mojang.com/mc/game/version_manifest.json'));
      expect(minecraftVersion.time, equals(time));
      expect(minecraftVersion.releaseTime, equals(releaseTime));
      expect(minecraftVersion.sha1, equals('abc123def456'));
      expect(minecraftVersion.complianceLevel, equals(1));
    });

    group('fromJson factory', () {
      test('should create instance from valid JSON', () {
        final time = DateTime.now();
        final releaseTime = DateTime.now().add(Duration(days: 1));
        final json = {
          'id': '1.20.1',
          'type': 'release',
          'url': 'https://launchermeta.mojang.com/mc/game/version_manifest.json',
          'time': time.toIso8601String(),
          'releaseTime': releaseTime.toIso8601String(),
          'sha1': 'abc123def456',
          'complianceLevel': 1,
        };

        final version = MinecraftVersion.fromJson(json);

        expect(version.id, equals('1.20.1'));
        expect(version.type, equals('release'));
        expect(version.url, equals('https://launchermeta.mojang.com/mc/game/version_manifest.json'));
        expect(version.time, equals(time));
        expect(version.releaseTime, equals(releaseTime));
        expect(version.sha1, equals('abc123def456'));
        expect(version.complianceLevel, equals(1));
      });

      test('should handle missing fields with defaults', () {
        final json = <String, dynamic>{};

        final version = MinecraftVersion.fromJson(json);

        expect(version.id, equals(''));
        expect(version.type, equals(''));
        expect(version.url, equals(''));
        expect(version.time, isA<DateTime>());
        expect(version.releaseTime, isA<DateTime>());
        expect(version.sha1, equals(''));
        expect(version.complianceLevel, equals(0));
      });

      test('should handle null values with defaults', () {
        final json = {
          'id': null,
          'type': null,
          'url': null,
          'time': null,
          'releaseTime': null,
          'sha1': null,
          'complianceLevel': null,
        };

        final version = MinecraftVersion.fromJson(json);

        expect(version.id, equals(''));
        expect(version.type, equals(''));
        expect(version.url, equals(''));
        expect(version.time, isA<DateTime>());
        expect(version.releaseTime, isA<DateTime>());
        expect(version.sha1, equals(''));
        expect(version.complianceLevel, equals(0));
      });
    });

    group('isRelease', () {
      test('should return true for release type', () {
        final time = DateTime.now();
        final releaseTime = DateTime.now().add(Duration(days: 1));
        
        final version = MinecraftVersion(
          id: '1.20.1',
          type: 'release',
          url: 'https://example.com',
          time: time,
          releaseTime: releaseTime,
          sha1: 'abc123',
          complianceLevel: 1,
        );

        expect(version.isRelease, isTrue);
      });

      test('should return false for non-release type', () {
        final time = DateTime.now();
        final releaseTime = DateTime.now().add(Duration(days: 1));
        
        final version = MinecraftVersion(
          id: '1.20.1',
          type: 'snapshot',
          url: 'https://example.com',
          time: time,
          releaseTime: releaseTime,
          sha1: 'abc123',
          complianceLevel: 1,
        );

        expect(version.isRelease, isFalse);
      });
    });

    group('isSnapshot', () {
      test('should return true for snapshot type', () {
        final time = DateTime.now();
        final releaseTime = DateTime.now().add(Duration(days: 1));
        
        final version = MinecraftVersion(
          id: '1.20.1',
          type: 'snapshot',
          url: 'https://example.com',
          time: time,
          releaseTime: releaseTime,
          sha1: 'abc123',
          complianceLevel: 1,
        );

        expect(version.isSnapshot, isTrue);
      });

      test('should return false for non-snapshot type', () {
        final time = DateTime.now();
        final releaseTime = DateTime.now().add(Duration(days: 1));
        
        final version = MinecraftVersion(
          id: '1.20.1',
          type: 'release',
          url: 'https://example.com',
          time: time,
          releaseTime: releaseTime,
          sha1: 'abc123',
          complianceLevel: 1,
        );

        expect(version.isSnapshot, isFalse);
      });
    });

    group('displayName', () {
      test('should return id for release version', () {
        final time = DateTime.now();
        final releaseTime = DateTime.now().add(Duration(days: 1));
        
        final version = MinecraftVersion(
          id: '1.20.1',
          type: 'release',
          url: 'https://example.com',
          time: time,
          releaseTime: releaseTime,
          sha1: 'abc123',
          complianceLevel: 1,
        );

        expect(version.displayName, equals('1.20.1'));
      });

      test('should return id with snapshot suffix for snapshot version', () {
        final time = DateTime.now();
        final releaseTime = DateTime.now().add(Duration(days: 1));
        
        final version = MinecraftVersion(
          id: '23w45a',
          type: 'snapshot',
          url: 'https://example.com',
          time: time,
          releaseTime: releaseTime,
          sha1: 'abc123',
          complianceLevel: 1,
        );

        expect(version.displayName, equals('23w45a (Snapshot)'));
      });

      test('should return id with snapshot suffix for other non-release types', () {
        final time = DateTime.now();
        final releaseTime = DateTime.now().add(Duration(days: 1));
        
        final version = MinecraftVersion(
          id: '1.20.1-pre1',
          type: 'old_beta',
          url: 'https://example.com',
          time: time,
          releaseTime: releaseTime,
          sha1: 'abc123',
          complianceLevel: 1,
        );

        expect(version.displayName, equals('1.20.1-pre1 (Snapshot)'));
      });
    });
  });
}
