import 'package:flutter_test/flutter_test.dart';
import '../lib/models/storage_multiplier.dart';
import '../lib/models/cpu_category.dart';
import '../lib/models/cpu_option.dart';

void main() {
  group('StorageMultiplier', () {
    test('should have correct values and display names', () {
      expect(StorageMultiplier.x1.value, equals('1x'));
      expect(StorageMultiplier.x1.displayName, equals('1x SSD'));
      expect(StorageMultiplier.x1.description, equals('Standard storage'));

      expect(StorageMultiplier.x2.value, equals('2x'));
      expect(StorageMultiplier.x2.displayName, equals('2x SSD'));
      expect(
          StorageMultiplier.x2.description, equals('Double storage capacity'));

      expect(StorageMultiplier.x3.value, equals('3x'));
      expect(StorageMultiplier.x3.displayName, equals('3x SSD'));
      expect(
          StorageMultiplier.x3.description, equals('Triple storage capacity'));

      expect(StorageMultiplier.x6.value, equals('6x'));
      expect(StorageMultiplier.x6.displayName, equals('6x SSD'));
      expect(StorageMultiplier.x6.description,
          equals('Six times storage capacity'));
    });

    test('should have all expected values', () {
      expect(StorageMultiplier.values.length, equals(4));
      expect(StorageMultiplier.values, contains(StorageMultiplier.x1));
      expect(StorageMultiplier.values, contains(StorageMultiplier.x2));
      expect(StorageMultiplier.values, contains(StorageMultiplier.x3));
      expect(StorageMultiplier.values, contains(StorageMultiplier.x6));
    });

    group('isAvailableFor', () {
      test('should return true for all multipliers with basic category', () {
        expect(
            StorageMultiplier.x1
                .isAvailableFor(CpuCategory.basic, CpuOption.regular),
            isTrue);
        expect(
            StorageMultiplier.x2
                .isAvailableFor(CpuCategory.basic, CpuOption.regular),
            isTrue);
        expect(
            StorageMultiplier.x3
                .isAvailableFor(CpuCategory.basic, CpuOption.regular),
            isTrue);
        expect(
            StorageMultiplier.x6
                .isAvailableFor(CpuCategory.basic, CpuOption.regular),
            isTrue);
      });

      test('should return true for 1x and 2x with general purpose category',
          () {
        expect(
            StorageMultiplier.x1
                .isAvailableFor(CpuCategory.generalPurpose, CpuOption.regular),
            isTrue);
        expect(
            StorageMultiplier.x2
                .isAvailableFor(CpuCategory.generalPurpose, CpuOption.regular),
            isTrue);
        expect(
            StorageMultiplier.x3
                .isAvailableFor(CpuCategory.generalPurpose, CpuOption.regular),
            isFalse);
        expect(
            StorageMultiplier.x6
                .isAvailableFor(CpuCategory.generalPurpose, CpuOption.regular),
            isFalse);
      });

      test('should return true for 1x and 2x with cpu optimized category', () {
        expect(
            StorageMultiplier.x1
                .isAvailableFor(CpuCategory.cpuOptimized, CpuOption.regular),
            isTrue);
        expect(
            StorageMultiplier.x2
                .isAvailableFor(CpuCategory.cpuOptimized, CpuOption.regular),
            isTrue);
        expect(
            StorageMultiplier.x3
                .isAvailableFor(CpuCategory.cpuOptimized, CpuOption.regular),
            isFalse);
        expect(
            StorageMultiplier.x6
                .isAvailableFor(CpuCategory.cpuOptimized, CpuOption.regular),
            isFalse);
      });

      test(
          'should return true for 1x, 3x, and 6x with memory optimized category',
          () {
        expect(
            StorageMultiplier.x1
                .isAvailableFor(CpuCategory.memoryOptimized, CpuOption.regular),
            isTrue);
        expect(
            StorageMultiplier.x2
                .isAvailableFor(CpuCategory.memoryOptimized, CpuOption.regular),
            isFalse);
        expect(
            StorageMultiplier.x3
                .isAvailableFor(CpuCategory.memoryOptimized, CpuOption.regular),
            isTrue);
        expect(
            StorageMultiplier.x6
                .isAvailableFor(CpuCategory.memoryOptimized, CpuOption.regular),
            isTrue);
      });

      test('should return true for 1x and 2x with storage optimized category',
          () {
        expect(
            StorageMultiplier.x1.isAvailableFor(
                CpuCategory.storageOptimized, CpuOption.regular),
            isTrue);
        expect(
            StorageMultiplier.x2.isAvailableFor(
                CpuCategory.storageOptimized, CpuOption.regular),
            isTrue);
        expect(
            StorageMultiplier.x3.isAvailableFor(
                CpuCategory.storageOptimized, CpuOption.regular),
            isFalse);
        expect(
            StorageMultiplier.x6.isAvailableFor(
                CpuCategory.storageOptimized, CpuOption.regular),
            isFalse);
      });

      test('should return true only for 1x with gpu category', () {
        expect(
            StorageMultiplier.x1
                .isAvailableFor(CpuCategory.gpu, CpuOption.regular),
            isTrue);
        expect(
            StorageMultiplier.x2
                .isAvailableFor(CpuCategory.gpu, CpuOption.regular),
            isFalse);
        expect(
            StorageMultiplier.x3
                .isAvailableFor(CpuCategory.gpu, CpuOption.regular),
            isFalse);
        expect(
            StorageMultiplier.x6
                .isAvailableFor(CpuCategory.gpu, CpuOption.regular),
            isFalse);
      });
    });
  });
}
