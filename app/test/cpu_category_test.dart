import 'package:flutter_test/flutter_test.dart';
import '../lib/models/cpu_category.dart';
import '../lib/models/cpu_architecture.dart';

void main() {
  group('CpuCategory', () {
    test('should have correct values and display names', () {
      expect(CpuCategory.basic.value, equals('basic'));
      expect(CpuCategory.basic.displayName, equals('Basic'));
      expect(CpuCategory.generalPurpose.value, equals('general_purpose'));
      expect(CpuCategory.generalPurpose.displayName, equals('General Purpose'));
      expect(CpuCategory.cpuOptimized.value, equals('cpu_optimized'));
      expect(CpuCategory.cpuOptimized.displayName, equals('CPU Optimized'));
      expect(CpuCategory.memoryOptimized.value, equals('memory_optimized'));
      expect(
          CpuCategory.memoryOptimized.displayName, equals('Memory Optimized'));
      expect(CpuCategory.storageOptimized.value, equals('storage_optimized'));
      expect(CpuCategory.storageOptimized.displayName,
          equals('Storage Optimized'));
      expect(CpuCategory.gpu.value, equals('gpu'));
      expect(CpuCategory.gpu.displayName, equals('GPU'));
    });

    test('should have all expected values', () {
      expect(CpuCategory.values.length, equals(6));
      expect(CpuCategory.values, contains(CpuCategory.basic));
      expect(CpuCategory.values, contains(CpuCategory.generalPurpose));
      expect(CpuCategory.values, contains(CpuCategory.cpuOptimized));
      expect(CpuCategory.values, contains(CpuCategory.memoryOptimized));
      expect(CpuCategory.values, contains(CpuCategory.storageOptimized));
      expect(CpuCategory.values, contains(CpuCategory.gpu));
    });

    group('isAvailableFor', () {
      test('should return true for basic category with shared architecture',
          () {
        expect(
            CpuCategory.basic.isAvailableFor(CpuArchitecture.shared), isTrue);
      });

      test('should return false for basic category with dedicated architecture',
          () {
        expect(CpuCategory.basic.isAvailableFor(CpuArchitecture.dedicated),
            isFalse);
      });

      test(
          'should return false for dedicated categories with shared architecture',
          () {
        expect(
            CpuCategory.generalPurpose.isAvailableFor(CpuArchitecture.shared),
            isFalse);
        expect(CpuCategory.cpuOptimized.isAvailableFor(CpuArchitecture.shared),
            isFalse);
        expect(
            CpuCategory.memoryOptimized.isAvailableFor(CpuArchitecture.shared),
            isFalse);
        expect(
            CpuCategory.storageOptimized.isAvailableFor(CpuArchitecture.shared),
            isFalse);
        expect(CpuCategory.gpu.isAvailableFor(CpuArchitecture.shared), isFalse);
      });

      test(
          'should return true for dedicated categories with dedicated architecture',
          () {
        expect(
            CpuCategory.generalPurpose
                .isAvailableFor(CpuArchitecture.dedicated),
            isTrue);
        expect(
            CpuCategory.cpuOptimized.isAvailableFor(CpuArchitecture.dedicated),
            isTrue);
        expect(
            CpuCategory.memoryOptimized
                .isAvailableFor(CpuArchitecture.dedicated),
            isTrue);
        expect(
            CpuCategory.storageOptimized
                .isAvailableFor(CpuArchitecture.dedicated),
            isTrue);
        expect(
            CpuCategory.gpu.isAvailableFor(CpuArchitecture.dedicated), isTrue);
      });
    });
  });
}
