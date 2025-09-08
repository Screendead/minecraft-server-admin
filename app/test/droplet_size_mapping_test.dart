import 'package:flutter_test/flutter_test.dart';
import '../lib/services/digitalocean_api_service.dart';
import '../lib/models/cpu_architecture.dart';
import '../lib/models/cpu_category.dart';
import '../lib/models/cpu_option.dart';
import '../lib/models/storage_multiplier.dart';

void main() {
  group('DropletSize Mapping', () {
    test('should map shared CPU droplets correctly', () {
      final size = DropletSize(
        slug: 's-1vcpu-1gb',
        memory: 1024,
        vcpus: 1,
        disk: 25,
        transfer: 1000,
        priceMonthly: 5.0,
        priceHourly: 0.007,
        regions: ['nyc1'],
        available: true,
        description: 'Basic Droplet',
      );

      expect(size.cpuArchitecture, equals(CpuArchitecture.shared));
      expect(size.cpuCategory, equals(CpuCategory.basic));
      expect(size.cpuOption, equals(CpuOption.regular));
      expect(size.storageMultiplier, equals(StorageMultiplier.x1));
    });

    test('should map shared CPU Intel droplets correctly', () {
      final size = DropletSize(
        slug: 's-1vcpu-1gb-intel',
        memory: 1024,
        vcpus: 1,
        disk: 25,
        transfer: 1000,
        priceMonthly: 5.0,
        priceHourly: 0.007,
        regions: ['nyc1'],
        available: true,
        description: 'Basic Intel Droplet',
      );

      expect(size.cpuArchitecture, equals(CpuArchitecture.shared));
      expect(size.cpuCategory, equals(CpuCategory.basic));
      expect(size.cpuOption, equals(CpuOption.premiumIntel));
      expect(size.storageMultiplier, equals(StorageMultiplier.x1));
    });

    test('should map shared CPU AMD droplets correctly', () {
      final size = DropletSize(
        slug: 's-1vcpu-1gb-amd',
        memory: 1024,
        vcpus: 1,
        disk: 25,
        transfer: 1000,
        priceMonthly: 5.0,
        priceHourly: 0.007,
        regions: ['nyc1'],
        available: true,
        description: 'Basic AMD Droplet',
      );

      expect(size.cpuArchitecture, equals(CpuArchitecture.shared));
      expect(size.cpuCategory, equals(CpuCategory.basic));
      expect(size.cpuOption, equals(CpuOption.premiumAmd));
      expect(size.storageMultiplier, equals(StorageMultiplier.x1));
    });

    test('should map general purpose droplets correctly', () {
      final size = DropletSize(
        slug: 'g-1vcpu-1gb',
        memory: 1024,
        vcpus: 1,
        disk: 25,
        transfer: 1000,
        priceMonthly: 5.0,
        priceHourly: 0.007,
        regions: ['nyc1'],
        available: true,
        description: 'General Purpose Droplet',
      );

      expect(size.cpuArchitecture, equals(CpuArchitecture.dedicated));
      expect(size.cpuCategory, equals(CpuCategory.generalPurpose));
      expect(size.cpuOption, equals(CpuOption.regular));
      expect(size.storageMultiplier, equals(StorageMultiplier.x1));
    });

    test('should map general purpose 2x SSD droplets correctly', () {
      final size = DropletSize(
        slug: 'gd-1vcpu-1gb',
        memory: 1024,
        vcpus: 1,
        disk: 50,
        transfer: 1000,
        priceMonthly: 5.0,
        priceHourly: 0.007,
        regions: ['nyc1'],
        available: true,
        description: 'General Purpose 2x SSD Droplet',
      );

      expect(size.cpuArchitecture, equals(CpuArchitecture.dedicated));
      expect(size.cpuCategory, equals(CpuCategory.generalPurpose));
      expect(size.cpuOption, equals(CpuOption.regular));
      expect(size.storageMultiplier, equals(StorageMultiplier.x2));
    });

    test('should map CPU optimized droplets correctly', () {
      final size = DropletSize(
        slug: 'c-2',
        memory: 2048,
        vcpus: 2,
        disk: 25,
        transfer: 1000,
        priceMonthly: 10.0,
        priceHourly: 0.014,
        regions: ['nyc1'],
        available: true,
        description: 'CPU Optimized Droplet',
      );

      expect(size.cpuArchitecture, equals(CpuArchitecture.dedicated));
      expect(size.cpuCategory, equals(CpuCategory.cpuOptimized));
      expect(size.cpuOption, equals(CpuOption.regular));
      expect(size.storageMultiplier, equals(StorageMultiplier.x1));
    });

    test('should map CPU optimized 2x SSD droplets correctly', () {
      final size = DropletSize(
        slug: 'c2-2',
        memory: 2048,
        vcpus: 2,
        disk: 50,
        transfer: 1000,
        priceMonthly: 10.0,
        priceHourly: 0.014,
        regions: ['nyc1'],
        available: true,
        description: 'CPU Optimized 2x SSD Droplet',
      );

      expect(size.cpuArchitecture, equals(CpuArchitecture.dedicated));
      expect(size.cpuCategory, equals(CpuCategory.cpuOptimized));
      expect(size.cpuOption, equals(CpuOption.regular));
      expect(size.storageMultiplier, equals(StorageMultiplier.x2));
    });

    test('should map memory optimized droplets correctly', () {
      final size = DropletSize(
        slug: 'm-2vcpu-16gb',
        memory: 16384,
        vcpus: 2,
        disk: 50,
        transfer: 1000,
        priceMonthly: 20.0,
        priceHourly: 0.028,
        regions: ['nyc1'],
        available: true,
        description: 'Memory Optimized Droplet',
      );

      expect(size.cpuArchitecture, equals(CpuArchitecture.dedicated));
      expect(size.cpuCategory, equals(CpuCategory.memoryOptimized));
      expect(size.cpuOption, equals(CpuOption.regular));
      expect(size.storageMultiplier, equals(StorageMultiplier.x1));
    });

    test('should map memory optimized 3x SSD droplets correctly', () {
      final size = DropletSize(
        slug: 'm3-2vcpu-16gb',
        memory: 16384,
        vcpus: 2,
        disk: 150,
        transfer: 1000,
        priceMonthly: 20.0,
        priceHourly: 0.028,
        regions: ['nyc1'],
        available: true,
        description: 'Memory Optimized 3x SSD Droplet',
      );

      expect(size.cpuArchitecture, equals(CpuArchitecture.dedicated));
      expect(size.cpuCategory, equals(CpuCategory.memoryOptimized));
      expect(size.cpuOption, equals(CpuOption.regular));
      expect(size.storageMultiplier, equals(StorageMultiplier.x3));
    });

    test('should map memory optimized 6x SSD droplets correctly', () {
      final size = DropletSize(
        slug: 'm6-2vcpu-16gb',
        memory: 16384,
        vcpus: 2,
        disk: 300,
        transfer: 1000,
        priceMonthly: 20.0,
        priceHourly: 0.028,
        regions: ['nyc1'],
        available: true,
        description: 'Memory Optimized 6x SSD Droplet',
      );

      expect(size.cpuArchitecture, equals(CpuArchitecture.dedicated));
      expect(size.cpuCategory, equals(CpuCategory.memoryOptimized));
      expect(size.cpuOption, equals(CpuOption.regular));
      expect(size.storageMultiplier, equals(StorageMultiplier.x6));
    });

    test('should map storage optimized droplets correctly', () {
      final size = DropletSize(
        slug: 'so-1vcpu-1gb',
        memory: 1024,
        vcpus: 1,
        disk: 25,
        transfer: 1000,
        priceMonthly: 5.0,
        priceHourly: 0.007,
        regions: ['nyc1'],
        available: true,
        description: 'Storage Optimized Droplet',
      );

      expect(size.cpuArchitecture, equals(CpuArchitecture.dedicated));
      expect(size.cpuCategory, equals(CpuCategory.storageOptimized));
      expect(size.cpuOption, equals(CpuOption.regular));
      expect(size.storageMultiplier, equals(StorageMultiplier.x1));
    });

    test('should map GPU droplets correctly', () {
      final size = DropletSize(
        slug: 'gpu-1vcpu-1gb',
        memory: 1024,
        vcpus: 1,
        disk: 25,
        transfer: 1000,
        priceMonthly: 5.0,
        priceHourly: 0.007,
        regions: ['nyc1'],
        available: true,
        description: 'GPU Droplet',
      );

      expect(size.cpuArchitecture, equals(CpuArchitecture.dedicated));
      expect(size.cpuCategory, equals(CpuCategory.gpu));
      expect(size.cpuOption, equals(CpuOption.regular));
      expect(size.storageMultiplier, equals(StorageMultiplier.x1));
    });

    test(
        'should maintain backward compatibility with isSharedCpu and isDedicatedCpu',
        () {
      final sharedSize = DropletSize(
        slug: 's-1vcpu-1gb',
        memory: 1024,
        vcpus: 1,
        disk: 25,
        transfer: 1000,
        priceMonthly: 5.0,
        priceHourly: 0.007,
        regions: ['nyc1'],
        available: true,
        description: 'Basic Droplet',
      );

      final dedicatedSize = DropletSize(
        slug: 'g-1vcpu-1gb',
        memory: 1024,
        vcpus: 1,
        disk: 25,
        transfer: 1000,
        priceMonthly: 5.0,
        priceHourly: 0.007,
        regions: ['nyc1'],
        available: true,
        description: 'General Purpose Droplet',
      );

      expect(sharedSize.isSharedCpu, isTrue);
      expect(sharedSize.isDedicatedCpu, isFalse);
      expect(dedicatedSize.isSharedCpu, isFalse);
      expect(dedicatedSize.isDedicatedCpu, isTrue);
    });
  });
}
