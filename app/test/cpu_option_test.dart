import 'package:flutter_test/flutter_test.dart';
import '../lib/models/cpu_option.dart';
import '../lib/models/cpu_category.dart';

void main() {
  group('CpuOption', () {
    test('should have correct values and display names', () {
      expect(CpuOption.regular.value, equals('regular'));
      expect(CpuOption.regular.displayName, equals('Regular'));
      expect(CpuOption.regular.description,
          equals('Disk type: SSD / Network: Up to 2 Gbps'));

      expect(CpuOption.premiumIntel.value, equals('premium_intel'));
      expect(CpuOption.premiumIntel.displayName, equals('Premium Intel'));
      expect(CpuOption.premiumIntel.description,
          equals('Disk: NVMe SSD / Network: Up to 10 Gbps'));

      expect(CpuOption.premiumAmd.value, equals('premium_amd'));
      expect(CpuOption.premiumAmd.displayName, equals('Premium AMD'));
      expect(CpuOption.premiumAmd.description,
          equals('Disk: NVMe SSD / Network: Up to 10 Gbps'));
    });

    test('should have all expected values', () {
      expect(CpuOption.values.length, equals(3));
      expect(CpuOption.values, contains(CpuOption.regular));
      expect(CpuOption.values, contains(CpuOption.premiumIntel));
      expect(CpuOption.values, contains(CpuOption.premiumAmd));
    });

    group('diskType', () {
      test('should return correct disk types', () {
        expect(CpuOption.regular.diskType, equals('SSD'));
        expect(CpuOption.premiumIntel.diskType, equals('NVMe SSD'));
        expect(CpuOption.premiumAmd.diskType, equals('NVMe SSD'));
      });
    });

    group('networkSpeed', () {
      test('should return correct network speeds', () {
        expect(CpuOption.regular.networkSpeed, equals('Up to 2 Gbps'));
        expect(CpuOption.premiumIntel.networkSpeed, equals('Up to 10 Gbps'));
        expect(CpuOption.premiumAmd.networkSpeed, equals('Up to 10 Gbps'));
      });
    });

    group('isAvailableFor', () {
      test('should return true for all options with basic category', () {
        expect(CpuOption.regular.isAvailableFor(CpuCategory.basic), isTrue);
        expect(
            CpuOption.premiumIntel.isAvailableFor(CpuCategory.basic), isTrue);
        expect(CpuOption.premiumAmd.isAvailableFor(CpuCategory.basic), isTrue);
      });

      test(
          'should return true for both regular and premium Intel options with dedicated categories',
          () {
        expect(CpuOption.regular.isAvailableFor(CpuCategory.generalPurpose),
            isTrue);
        expect(
            CpuOption.premiumIntel.isAvailableFor(CpuCategory.generalPurpose),
            isTrue);
        expect(CpuOption.premiumAmd.isAvailableFor(CpuCategory.generalPurpose),
            isFalse);

        expect(
            CpuOption.regular.isAvailableFor(CpuCategory.cpuOptimized), isTrue);
        expect(CpuOption.premiumIntel.isAvailableFor(CpuCategory.cpuOptimized),
            isTrue);
        expect(CpuOption.premiumAmd.isAvailableFor(CpuCategory.cpuOptimized),
            isFalse);

        expect(CpuOption.regular.isAvailableFor(CpuCategory.memoryOptimized),
            isTrue);
        expect(
            CpuOption.premiumIntel.isAvailableFor(CpuCategory.memoryOptimized),
            isTrue);
        expect(CpuOption.premiumAmd.isAvailableFor(CpuCategory.memoryOptimized),
            isFalse);

        expect(CpuOption.regular.isAvailableFor(CpuCategory.storageOptimized),
            isTrue);
        expect(
            CpuOption.premiumIntel.isAvailableFor(CpuCategory.storageOptimized),
            isTrue);
        expect(
            CpuOption.premiumAmd.isAvailableFor(CpuCategory.storageOptimized),
            isFalse);

        expect(CpuOption.regular.isAvailableFor(CpuCategory.gpu), isTrue);
        expect(CpuOption.premiumIntel.isAvailableFor(CpuCategory.gpu), isTrue);
        expect(CpuOption.premiumAmd.isAvailableFor(CpuCategory.gpu), isFalse);
      });
    });
  });
}
