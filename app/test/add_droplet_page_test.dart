import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/services/digitalocean_api_service.dart';
import '../lib/services/minecraft_versions_service.dart';
import '../lib/providers/droplet_config_provider.dart';

void main() {
  group('DropletSize', () {
    test('correctly identifies shared CPU droplets', () {
      const sharedSize = DropletSize(
        slug: 's-1vcpu-1gb',
        memory: 1024,
        vcpus: 1,
        disk: 25,
        transfer: 1000,
        priceMonthly: 6.0,
        priceHourly: 0.009,
        regions: ['nyc1'],
        available: true,
        description: 'Basic shared CPU droplet',
      );

      expect(sharedSize.isSharedCpu, true);
      expect(sharedSize.isDedicatedCpu, false);
    });

    test('correctly identifies dedicated CPU droplets', () {
      const dedicatedSize = DropletSize(
        slug: 'c-2',
        memory: 4096,
        vcpus: 2,
        disk: 50,
        transfer: 2000,
        priceMonthly: 36.0,
        priceHourly: 0.054,
        regions: ['nyc1'],
        available: true,
        description: 'Dedicated CPU droplet',
      );

      expect(dedicatedSize.isSharedCpu, false);
      expect(dedicatedSize.isDedicatedCpu, true);
    });

    test('formats display name correctly', () {
      const size = DropletSize(
        slug: 's-1vcpu-1gb',
        memory: 1024,
        vcpus: 1,
        disk: 25,
        transfer: 1000,
        priceMonthly: 6.0,
        priceHourly: 0.009,
        regions: ['nyc1'],
        available: true,
        description: 'Basic shared CPU droplet',
      );

      expect(size.displayName, 's-1vcpu-1gb - 1GB RAM, 1 vCPU, 25GB SSD');
    });
  });

  group('Region', () {
    test('creates region with correct properties', () {
      const region = Region(
        name: 'New York 1',
        slug: 'nyc1',
        features: ['virtio', 'private_networking'],
        available: true,
      );

      expect(region.name, 'New York 1');
      expect(region.slug, 'nyc1');
      expect(region.features, ['virtio', 'private_networking']);
      expect(region.available, true);
    });
  });

  group('MinecraftVersion', () {
    test('correctly identifies release versions', () {
      final version = MinecraftVersion(
        id: '1.20.1',
        type: 'release',
        url: 'https://example.com',
        time: DateTime.now(),
        releaseTime: DateTime.now(),
        sha1: 'test',
        complianceLevel: 1,
      );

      expect(version.isRelease, true);
      expect(version.isSnapshot, false);
      expect(version.displayName, '1.20.1');
    });

    test('correctly identifies snapshot versions', () {
      final version = MinecraftVersion(
        id: '23w45a',
        type: 'snapshot',
        url: 'https://example.com',
        time: DateTime.now(),
        releaseTime: DateTime.now(),
        sha1: 'test',
        complianceLevel: 1,
      );

      expect(version.isRelease, false);
      expect(version.isSnapshot, true);
      expect(version.displayName, '23w45a (Snapshot)');
    });

    test('creates version from JSON correctly', () {
      final json = {
        'id': '1.20.1',
        'type': 'release',
        'url': 'https://example.com',
        'time': '2023-06-12T12:00:00+00:00',
        'releaseTime': '2023-06-12T12:00:00+00:00',
        'sha1': 'test-sha1',
        'complianceLevel': 1,
      };

      final version = MinecraftVersion.fromJson(json);

      expect(version.id, '1.20.1');
      expect(version.type, 'release');
      expect(version.url, 'https://example.com');
      expect(version.sha1, 'test-sha1');
      expect(version.complianceLevel, 1);
    });
  });

  group('DropletConfigProvider', () {
    test('initializes with empty data', () {
      final provider = DropletConfigProvider();

      expect(provider.dropletSizes, isEmpty);
      expect(provider.regions, isEmpty);
      expect(provider.minecraftVersions, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('organizes droplet sizes by CPU type correctly', () {
      const sharedSize = DropletSize(
        slug: 's-1vcpu-1gb',
        memory: 1024,
        vcpus: 1,
        disk: 25,
        transfer: 1000,
        priceMonthly: 6.0,
        priceHourly: 0.009,
        regions: ['nyc1'],
        available: true,
        description: 'Basic shared CPU droplet',
      );

      const dedicatedSize = DropletSize(
        slug: 'c-2',
        memory: 4096,
        vcpus: 2,
        disk: 50,
        transfer: 2000,
        priceMonthly: 36.0,
        priceHourly: 0.054,
        regions: ['nyc1'],
        available: true,
        description: 'Dedicated CPU droplet',
      );

      expect(sharedSize.isSharedCpu, true);
      expect(sharedSize.isDedicatedCpu, false);
      expect(dedicatedSize.isSharedCpu, false);
      expect(dedicatedSize.isDedicatedCpu, true);
    });
  });
}
