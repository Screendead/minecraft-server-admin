import 'package:flutter_test/flutter_test.dart';
import 'package:minecraft_server_automation/models/cpu_category.dart';
import 'package:minecraft_server_automation/models/cpu_option.dart';

void main() {
  group('CpuOption', () {
    test('should have correct values, display names, and descriptions', () {
      expect(CpuOption.regular.value, equals('regular'));
      expect(CpuOption.regular.displayName, equals('Regular'));
      expect(CpuOption.regular.description, equals('Disk type: SSD / Network: Up to 2 Gbps'));
      
      expect(CpuOption.premiumIntel.value, equals('premium_intel'));
      expect(CpuOption.premiumIntel.displayName, equals('Premium Intel'));
      expect(CpuOption.premiumIntel.description, equals('Disk: NVMe SSD / Network: Up to 10 Gbps'));
      
      expect(CpuOption.premiumAmd.value, equals('premium_amd'));
      expect(CpuOption.premiumAmd.displayName, equals('Premium AMD'));
      expect(CpuOption.premiumAmd.description, equals('Disk: NVMe SSD / Network: Up to 10 Gbps'));
    });

    test('should have all expected enum values', () {
      expect(CpuOption.values.length, equals(3));
      expect(CpuOption.values, contains(CpuOption.regular));
      expect(CpuOption.values, contains(CpuOption.premiumIntel));
      expect(CpuOption.values, contains(CpuOption.premiumAmd));
    });

    test('should support equality comparison', () {
      expect(CpuOption.regular, equals(CpuOption.regular));
      expect(CpuOption.premiumIntel, equals(CpuOption.premiumIntel));
      expect(CpuOption.premiumAmd, equals(CpuOption.premiumAmd));
      expect(CpuOption.regular, isNot(equals(CpuOption.premiumIntel)));
      expect(CpuOption.premiumIntel, isNot(equals(CpuOption.premiumAmd)));
    });

    test('should support string conversion', () {
      expect(CpuOption.regular.toString(), contains('CpuOption.regular'));
      expect(CpuOption.premiumIntel.toString(), contains('CpuOption.premiumIntel'));
      expect(CpuOption.premiumAmd.toString(), contains('CpuOption.premiumAmd'));
    });

    group('diskType', () {
      test('should return correct disk type for regular option', () {
        expect(CpuOption.regular.diskType, equals('SSD'));
      });

      test('should return correct disk type for premium options', () {
        expect(CpuOption.premiumIntel.diskType, equals('NVMe SSD'));
        expect(CpuOption.premiumAmd.diskType, equals('NVMe SSD'));
      });
    });

    group('networkSpeed', () {
      test('should return correct network speed for regular option', () {
        expect(CpuOption.regular.networkSpeed, equals('Up to 2 Gbps'));
      });

      test('should return correct network speed for premium options', () {
        expect(CpuOption.premiumIntel.networkSpeed, equals('Up to 10 Gbps'));
        expect(CpuOption.premiumAmd.networkSpeed, equals('Up to 10 Gbps'));
      });
    });

    group('isAvailableFor', () {
      test('should return true for all options with basic category', () {
        expect(CpuOption.regular.isAvailableFor(CpuCategory.basic), isTrue);
        expect(CpuOption.premiumIntel.isAvailableFor(CpuCategory.basic), isTrue);
        expect(CpuOption.premiumAmd.isAvailableFor(CpuCategory.basic), isTrue);
      });

      test('should return true for regular and premium intel with general purpose category', () {
        expect(CpuOption.regular.isAvailableFor(CpuCategory.generalPurpose), isTrue);
        expect(CpuOption.premiumIntel.isAvailableFor(CpuCategory.generalPurpose), isTrue);
        expect(CpuOption.premiumAmd.isAvailableFor(CpuCategory.generalPurpose), isFalse);
      });

      test('should return true for regular and premium intel with cpu optimized category', () {
        expect(CpuOption.regular.isAvailableFor(CpuCategory.cpuOptimized), isTrue);
        expect(CpuOption.premiumIntel.isAvailableFor(CpuCategory.cpuOptimized), isTrue);
        expect(CpuOption.premiumAmd.isAvailableFor(CpuCategory.cpuOptimized), isFalse);
      });

      test('should return true for regular and premium intel with memory optimized category', () {
        expect(CpuOption.regular.isAvailableFor(CpuCategory.memoryOptimized), isTrue);
        expect(CpuOption.premiumIntel.isAvailableFor(CpuCategory.memoryOptimized), isTrue);
        expect(CpuOption.premiumAmd.isAvailableFor(CpuCategory.memoryOptimized), isFalse);
      });

      test('should return true for regular and premium intel with storage optimized category', () {
        expect(CpuOption.regular.isAvailableFor(CpuCategory.storageOptimized), isTrue);
        expect(CpuOption.premiumIntel.isAvailableFor(CpuCategory.storageOptimized), isTrue);
        expect(CpuOption.premiumAmd.isAvailableFor(CpuCategory.storageOptimized), isFalse);
      });

      test('should return true for regular and premium intel with gpu category', () {
        expect(CpuOption.regular.isAvailableFor(CpuCategory.gpu), isTrue);
        expect(CpuOption.premiumIntel.isAvailableFor(CpuCategory.gpu), isTrue);
        expect(CpuOption.premiumAmd.isAvailableFor(CpuCategory.gpu), isFalse);
      });
    });

    test('should be immutable', () {
      const regular = CpuOption.regular;
      expect(regular.value, equals('regular'));
      expect(regular.displayName, equals('Regular'));
      expect(regular.description, equals('Disk type: SSD / Network: Up to 2 Gbps'));
      
      // Verify that the enum values are constants
      expect(regular.value, isA<String>());
      expect(regular.displayName, isA<String>());
      expect(regular.description, isA<String>());
    });
  });
}
