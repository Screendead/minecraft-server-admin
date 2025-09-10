import 'package:flutter_test/flutter_test.dart';
import 'package:minecraft_server_automation/models/cpu_architecture.dart';
import 'package:minecraft_server_automation/models/cpu_category.dart';
import 'package:minecraft_server_automation/models/cpu_option.dart';
import 'package:minecraft_server_automation/models/droplet_size.dart';
import 'package:minecraft_server_automation/models/storage_multiplier.dart';

void main() {
  group('DropletSize', () {
    test('should create instance with all parameters', () {
      const dropletSize = DropletSize(
        slug: 's-1vcpu-1gb',
        memory: 1024,
        vcpus: 1,
        disk: 25,
        transfer: 1.0,
        priceMonthly: 5.0,
        priceHourly: 0.007,
        regions: ['nyc1', 'nyc2', 'nyc3'],
        available: true,
        description: 'Basic shared CPU droplet',
      );

      expect(dropletSize.slug, equals('s-1vcpu-1gb'));
      expect(dropletSize.memory, equals(1024));
      expect(dropletSize.vcpus, equals(1));
      expect(dropletSize.disk, equals(25));
      expect(dropletSize.transfer, equals(1.0));
      expect(dropletSize.priceMonthly, equals(5.0));
      expect(dropletSize.priceHourly, equals(0.007));
      expect(dropletSize.regions, equals(['nyc1', 'nyc2', 'nyc3']));
      expect(dropletSize.available, isTrue);
      expect(dropletSize.description, equals('Basic shared CPU droplet'));
    });

    group('fromJson factory', () {
      test('should create instance from valid JSON', () {
        final json = {
          'slug': 's-1vcpu-1gb',
          'memory': 1024,
          'vcpus': 1,
          'disk': 25,
          'transfer': 1.0,
          'price_monthly': 5.0,
          'price_hourly': 0.007,
          'regions': ['nyc1', 'nyc2', 'nyc3'],
          'available': true,
          'description': 'Basic shared CPU droplet',
        };

        final dropletSize = DropletSize.fromJson(json);

        expect(dropletSize.slug, equals('s-1vcpu-1gb'));
        expect(dropletSize.memory, equals(1024));
        expect(dropletSize.vcpus, equals(1));
        expect(dropletSize.disk, equals(25));
        expect(dropletSize.transfer, equals(1.0));
        expect(dropletSize.priceMonthly, equals(5.0));
        expect(dropletSize.priceHourly, equals(0.007));
        expect(dropletSize.regions, equals(['nyc1', 'nyc2', 'nyc3']));
        expect(dropletSize.available, isTrue);
        expect(dropletSize.description, equals('Basic shared CPU droplet'));
      });

      test('should handle missing fields with defaults', () {
        final json = <String, dynamic>{};

        final dropletSize = DropletSize.fromJson(json);

        expect(dropletSize.slug, equals(''));
        expect(dropletSize.memory, equals(0));
        expect(dropletSize.vcpus, equals(0));
        expect(dropletSize.disk, equals(0));
        expect(dropletSize.transfer, equals(0.0));
        expect(dropletSize.priceMonthly, equals(0.0));
        expect(dropletSize.priceHourly, equals(0.0));
        expect(dropletSize.regions, equals([]));
        expect(dropletSize.available, isFalse);
        expect(dropletSize.description, equals(''));
      });

      test('should handle null values with defaults', () {
        final json = {
          'slug': null,
          'memory': null,
          'vcpus': null,
          'disk': null,
          'transfer': null,
          'price_monthly': null,
          'price_hourly': null,
          'regions': null,
          'available': null,
          'description': null,
        };

        final dropletSize = DropletSize.fromJson(json);

        expect(dropletSize.slug, equals(''));
        expect(dropletSize.memory, equals(0));
        expect(dropletSize.vcpus, equals(0));
        expect(dropletSize.disk, equals(0));
        expect(dropletSize.transfer, equals(0.0));
        expect(dropletSize.priceMonthly, equals(0.0));
        expect(dropletSize.priceHourly, equals(0.0));
        expect(dropletSize.regions, equals([]));
        expect(dropletSize.available, isFalse);
        expect(dropletSize.description, equals(''));
      });
    });

    group('isSharedCpu', () {
      test('should return true for shared CPU droplets', () {
        const dropletSize = DropletSize(
          slug: 's-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'Basic shared CPU droplet',
        );

        expect(dropletSize.isSharedCpu, isTrue);
      });

      test('should return false for dedicated CPU droplets', () {
        const dropletSize = DropletSize(
          slug: 'c-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'Basic dedicated CPU droplet',
        );

        expect(dropletSize.isSharedCpu, isFalse);
      });
    });

    group('isDedicatedCpu', () {
      test('should return true for c- prefixed droplets', () {
        const dropletSize = DropletSize(
          slug: 'c-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'Basic dedicated CPU droplet',
        );

        expect(dropletSize.isDedicatedCpu, isTrue);
      });

      test('should return true for g- prefixed droplets', () {
        const dropletSize = DropletSize(
          slug: 'g-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'General purpose droplet',
        );

        expect(dropletSize.isDedicatedCpu, isTrue);
      });

      test('should return true for m- prefixed droplets', () {
        const dropletSize = DropletSize(
          slug: 'm-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'Memory optimized droplet',
        );

        expect(dropletSize.isDedicatedCpu, isTrue);
      });

      test('should return true for so- prefixed droplets', () {
        const dropletSize = DropletSize(
          slug: 'so-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'Storage optimized droplet',
        );

        expect(dropletSize.isDedicatedCpu, isTrue);
      });

      test('should return true for gpu- prefixed droplets', () {
        const dropletSize = DropletSize(
          slug: 'gpu-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'GPU droplet',
        );

        expect(dropletSize.isDedicatedCpu, isTrue);
      });

      test('should return false for s- prefixed droplets', () {
        const dropletSize = DropletSize(
          slug: 's-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'Shared CPU droplet',
        );

        expect(dropletSize.isDedicatedCpu, isFalse);
      });
    });

    group('cpuArchitecture', () {
      test('should return shared for shared CPU droplets', () {
        const dropletSize = DropletSize(
          slug: 's-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'Shared CPU droplet',
        );

        expect(dropletSize.cpuArchitecture, equals(CpuArchitecture.shared));
      });

      test('should return dedicated for dedicated CPU droplets', () {
        const dropletSize = DropletSize(
          slug: 'c-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'Dedicated CPU droplet',
        );

        expect(dropletSize.cpuArchitecture, equals(CpuArchitecture.dedicated));
      });
    });

    group('cpuCategory', () {
      test('should return basic for shared CPU droplets', () {
        const dropletSize = DropletSize(
          slug: 's-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'Shared CPU droplet',
        );

        expect(dropletSize.cpuCategory, equals(CpuCategory.basic));
      });

      test('should return generalPurpose for g- prefixed droplets', () {
        const dropletSize = DropletSize(
          slug: 'g-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'General purpose droplet',
        );

        expect(dropletSize.cpuCategory, equals(CpuCategory.generalPurpose));
      });

      test('should return generalPurpose for gd- prefixed droplets', () {
        const dropletSize = DropletSize(
          slug: 'gd-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'General purpose droplet',
        );

        expect(dropletSize.cpuCategory, equals(CpuCategory.generalPurpose));
      });

      test('should return cpuOptimized for c- prefixed droplets', () {
        const dropletSize = DropletSize(
          slug: 'c-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'CPU optimized droplet',
        );

        expect(dropletSize.cpuCategory, equals(CpuCategory.cpuOptimized));
      });

      test('should return cpuOptimized for c2- prefixed droplets', () {
        const dropletSize = DropletSize(
          slug: 'c2-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'CPU optimized droplet',
        );

        expect(dropletSize.cpuCategory, equals(CpuCategory.cpuOptimized));
      });

      test('should return memoryOptimized for m- prefixed droplets', () {
        const dropletSize = DropletSize(
          slug: 'm-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'Memory optimized droplet',
        );

        expect(dropletSize.cpuCategory, equals(CpuCategory.memoryOptimized));
      });

      test('should return memoryOptimized for m3- prefixed droplets', () {
        const dropletSize = DropletSize(
          slug: 'm3-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'Memory optimized droplet',
        );

        expect(dropletSize.cpuCategory, equals(CpuCategory.memoryOptimized));
      });

      test('should return memoryOptimized for m6- prefixed droplets', () {
        const dropletSize = DropletSize(
          slug: 'm6-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'Memory optimized droplet',
        );

        expect(dropletSize.cpuCategory, equals(CpuCategory.memoryOptimized));
      });

      test('should return storageOptimized for so- prefixed droplets', () {
        const dropletSize = DropletSize(
          slug: 'so-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'Storage optimized droplet',
        );

        expect(dropletSize.cpuCategory, equals(CpuCategory.storageOptimized));
      });

      test('should return gpu for gpu- prefixed droplets', () {
        const dropletSize = DropletSize(
          slug: 'gpu-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'GPU droplet',
        );

        expect(dropletSize.cpuCategory, equals(CpuCategory.gpu));
      });

      test('should return generalPurpose as default fallback', () {
        const dropletSize = DropletSize(
          slug: 'unknown-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'Unknown droplet type',
        );

        expect(dropletSize.cpuCategory, equals(CpuCategory.generalPurpose));
      });
    });

    group('cpuOption', () {
      test('should return regular for basic shared CPU droplets', () {
        const dropletSize = DropletSize(
          slug: 's-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'Basic shared CPU droplet',
        );

        expect(dropletSize.cpuOption, equals(CpuOption.regular));
      });

      test('should return premiumIntel for shared CPU droplets with intel', () {
        const dropletSize = DropletSize(
          slug: 's-1vcpu-1gb-intel',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'Intel shared CPU droplet',
        );

        expect(dropletSize.cpuOption, equals(CpuOption.premiumIntel));
      });

      test('should return premiumAmd for shared CPU droplets with amd', () {
        const dropletSize = DropletSize(
          slug: 's-1vcpu-1gb-amd',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'AMD shared CPU droplet',
        );

        expect(dropletSize.cpuOption, equals(CpuOption.premiumAmd));
      });

      test('should return regular for dedicated CPU droplets without intel',
          () {
        const dropletSize = DropletSize(
          slug: 'c-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'Dedicated CPU droplet',
        );

        expect(dropletSize.cpuOption, equals(CpuOption.regular));
      });

      test('should return premiumIntel for dedicated CPU droplets with intel',
          () {
        const dropletSize = DropletSize(
          slug: 'c-1vcpu-1gb-intel',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'Intel dedicated CPU droplet',
        );

        expect(dropletSize.cpuOption, equals(CpuOption.premiumIntel));
      });
    });

    group('storageMultiplier', () {
      test('should return x1 for regular droplets', () {
        const dropletSize = DropletSize(
          slug: 's-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'Basic droplet',
        );

        expect(dropletSize.storageMultiplier, equals(StorageMultiplier.x1));
      });

      test('should return x2 for gd- prefixed droplets', () {
        const dropletSize = DropletSize(
          slug: 'gd-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'General purpose droplet',
        );

        expect(dropletSize.storageMultiplier, equals(StorageMultiplier.x2));
      });

      test('should return x2 for c2- prefixed droplets', () {
        const dropletSize = DropletSize(
          slug: 'c2-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'CPU optimized droplet',
        );

        expect(dropletSize.storageMultiplier, equals(StorageMultiplier.x2));
      });

      test('should return x3 for m3- prefixed droplets', () {
        const dropletSize = DropletSize(
          slug: 'm3-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'Memory optimized droplet',
        );

        expect(dropletSize.storageMultiplier, equals(StorageMultiplier.x3));
      });

      test('should return x6 for m6- prefixed droplets', () {
        const dropletSize = DropletSize(
          slug: 'm6-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'Memory optimized droplet',
        );

        expect(dropletSize.storageMultiplier, equals(StorageMultiplier.x6));
      });
    });

    group('dedicatedCpuCategory', () {
      test('should return null for shared CPU droplets', () {
        const dropletSize = DropletSize(
          slug: 's-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'Shared CPU droplet',
        );

        expect(dropletSize.dedicatedCpuCategory, isNull);
      });

      test('should return category value for dedicated CPU droplets', () {
        const dropletSize = DropletSize(
          slug: 'c-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'Dedicated CPU droplet',
        );

        expect(dropletSize.dedicatedCpuCategory, equals('cpu_optimized'));
      });
    });

    group('isAvailableInRegion', () {
      test('should return true when region is in regions list', () {
        const dropletSize = DropletSize(
          slug: 's-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1', 'nyc2', 'nyc3'],
          available: true,
          description: 'Basic droplet',
        );

        expect(dropletSize.isAvailableInRegion('nyc1'), isTrue);
        expect(dropletSize.isAvailableInRegion('nyc2'), isTrue);
        expect(dropletSize.isAvailableInRegion('nyc3'), isTrue);
      });

      test('should return false when region is not in regions list', () {
        const dropletSize = DropletSize(
          slug: 's-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1', 'nyc2', 'nyc3'],
          available: true,
          description: 'Basic droplet',
        );

        expect(dropletSize.isAvailableInRegion('sfo1'), isFalse);
        expect(dropletSize.isAvailableInRegion('lon1'), isFalse);
      });
    });

    group('displayName', () {
      test('should return formatted display name', () {
        const dropletSize = DropletSize(
          slug: 's-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1.0,
          priceMonthly: 5.0,
          priceHourly: 0.007,
          regions: ['nyc1'],
          available: true,
          description: 'Basic droplet',
        );

        final displayName = dropletSize.displayName;

        expect(displayName, contains('s-1vcpu-1gb'));
        expect(displayName, contains('1GB RAM'));
        expect(displayName, contains('1 vCPU'));
        expect(displayName, contains('25GB SSD'));
      });
    });
  });
}
