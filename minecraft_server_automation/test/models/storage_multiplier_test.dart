import 'package:flutter_test/flutter_test.dart';
import 'package:minecraft_server_automation/models/cpu_category.dart';
import 'package:minecraft_server_automation/models/cpu_option.dart';
import 'package:minecraft_server_automation/models/storage_multiplier.dart';

void main() {
  group('StorageMultiplier', () {
    test('should have correct values, display names, and descriptions', () {
      expect(StorageMultiplier.x1.value, equals('1x'));
      expect(StorageMultiplier.x1.displayName, equals('1x SSD'));
      expect(StorageMultiplier.x1.description, equals('Standard storage'));
      
      expect(StorageMultiplier.x2.value, equals('2x'));
      expect(StorageMultiplier.x2.displayName, equals('2x SSD'));
      expect(StorageMultiplier.x2.description, equals('Double storage capacity'));
      
      expect(StorageMultiplier.x3.value, equals('3x'));
      expect(StorageMultiplier.x3.displayName, equals('3x SSD'));
      expect(StorageMultiplier.x3.description, equals('Triple storage capacity'));
      
      expect(StorageMultiplier.x6.value, equals('6x'));
      expect(StorageMultiplier.x6.displayName, equals('6x SSD'));
      expect(StorageMultiplier.x6.description, equals('Six times storage capacity'));
    });

    test('should have all expected enum values', () {
      expect(StorageMultiplier.values.length, equals(4));
      expect(StorageMultiplier.values, contains(StorageMultiplier.x1));
      expect(StorageMultiplier.values, contains(StorageMultiplier.x2));
      expect(StorageMultiplier.values, contains(StorageMultiplier.x3));
      expect(StorageMultiplier.values, contains(StorageMultiplier.x6));
    });

    test('should support equality comparison', () {
      expect(StorageMultiplier.x1, equals(StorageMultiplier.x1));
      expect(StorageMultiplier.x2, equals(StorageMultiplier.x2));
      expect(StorageMultiplier.x1, isNot(equals(StorageMultiplier.x2)));
    });

    test('should support string conversion', () {
      expect(StorageMultiplier.x1.toString(), contains('StorageMultiplier.x1'));
      expect(StorageMultiplier.x2.toString(), contains('StorageMultiplier.x2'));
    });

    group('isAvailableFor', () {
      test('should return true for all multipliers with basic category', () {
        expect(StorageMultiplier.x1.isAvailableFor(CpuCategory.basic, CpuOption.regular), isTrue);
        expect(StorageMultiplier.x2.isAvailableFor(CpuCategory.basic, CpuOption.regular), isTrue);
        expect(StorageMultiplier.x3.isAvailableFor(CpuCategory.basic, CpuOption.regular), isTrue);
        expect(StorageMultiplier.x6.isAvailableFor(CpuCategory.basic, CpuOption.regular), isTrue);
      });

      test('should return true for x1 and x2 with general purpose category', () {
        expect(StorageMultiplier.x1.isAvailableFor(CpuCategory.generalPurpose, CpuOption.regular), isTrue);
        expect(StorageMultiplier.x2.isAvailableFor(CpuCategory.generalPurpose, CpuOption.regular), isTrue);
        expect(StorageMultiplier.x3.isAvailableFor(CpuCategory.generalPurpose, CpuOption.regular), isFalse);
        expect(StorageMultiplier.x6.isAvailableFor(CpuCategory.generalPurpose, CpuOption.regular), isFalse);
      });

      test('should return true for x1 and x2 with cpu optimized category', () {
        expect(StorageMultiplier.x1.isAvailableFor(CpuCategory.cpuOptimized, CpuOption.regular), isTrue);
        expect(StorageMultiplier.x2.isAvailableFor(CpuCategory.cpuOptimized, CpuOption.regular), isTrue);
        expect(StorageMultiplier.x3.isAvailableFor(CpuCategory.cpuOptimized, CpuOption.regular), isFalse);
        expect(StorageMultiplier.x6.isAvailableFor(CpuCategory.cpuOptimized, CpuOption.regular), isFalse);
      });

      test('should return true for x1, x3, and x6 with memory optimized category', () {
        expect(StorageMultiplier.x1.isAvailableFor(CpuCategory.memoryOptimized, CpuOption.regular), isTrue);
        expect(StorageMultiplier.x2.isAvailableFor(CpuCategory.memoryOptimized, CpuOption.regular), isFalse);
        expect(StorageMultiplier.x3.isAvailableFor(CpuCategory.memoryOptimized, CpuOption.regular), isTrue);
        expect(StorageMultiplier.x6.isAvailableFor(CpuCategory.memoryOptimized, CpuOption.regular), isTrue);
      });

      test('should return true for x1 and x2 with storage optimized category', () {
        expect(StorageMultiplier.x1.isAvailableFor(CpuCategory.storageOptimized, CpuOption.regular), isTrue);
        expect(StorageMultiplier.x2.isAvailableFor(CpuCategory.storageOptimized, CpuOption.regular), isTrue);
        expect(StorageMultiplier.x3.isAvailableFor(CpuCategory.storageOptimized, CpuOption.regular), isFalse);
        expect(StorageMultiplier.x6.isAvailableFor(CpuCategory.storageOptimized, CpuOption.regular), isFalse);
      });

      test('should return true only for x1 with gpu category', () {
        expect(StorageMultiplier.x1.isAvailableFor(CpuCategory.gpu, CpuOption.regular), isTrue);
        expect(StorageMultiplier.x2.isAvailableFor(CpuCategory.gpu, CpuOption.regular), isFalse);
        expect(StorageMultiplier.x3.isAvailableFor(CpuCategory.gpu, CpuOption.regular), isFalse);
        expect(StorageMultiplier.x6.isAvailableFor(CpuCategory.gpu, CpuOption.regular), isFalse);
      });

      test('should work with different CPU options for same category', () {
        // Test that CPU option doesn't affect availability (only category matters)
        expect(StorageMultiplier.x1.isAvailableFor(CpuCategory.basic, CpuOption.regular), isTrue);
        expect(StorageMultiplier.x1.isAvailableFor(CpuCategory.basic, CpuOption.premiumIntel), isTrue);
        expect(StorageMultiplier.x1.isAvailableFor(CpuCategory.basic, CpuOption.premiumAmd), isTrue);
        
        expect(StorageMultiplier.x2.isAvailableFor(CpuCategory.generalPurpose, CpuOption.regular), isTrue);
        expect(StorageMultiplier.x2.isAvailableFor(CpuCategory.generalPurpose, CpuOption.premiumIntel), isTrue);
        expect(StorageMultiplier.x2.isAvailableFor(CpuCategory.generalPurpose, CpuOption.premiumAmd), isTrue);
      });
    });

    test('should be immutable', () {
      const x1 = StorageMultiplier.x1;
      expect(x1.value, equals('1x'));
      expect(x1.displayName, equals('1x SSD'));
      expect(x1.description, equals('Standard storage'));
      
      // Verify that the enum values are constants
      expect(x1.value, isA<String>());
      expect(x1.displayName, isA<String>());
      expect(x1.description, isA<String>());
    });
  });
}
