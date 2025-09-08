import 'package:flutter_test/flutter_test.dart';
import '../lib/models/cpu_option.dart';
import '../lib/models/cpu_category.dart';

void main() {
  group('CpuOption Availability', () {
    test('should allow all options for basic category', () {
      expect(CpuOption.regular.isAvailableFor(CpuCategory.basic), isTrue);
      expect(CpuOption.premiumIntel.isAvailableFor(CpuCategory.basic), isTrue);
      expect(CpuOption.premiumAmd.isAvailableFor(CpuCategory.basic), isTrue);
    });

    test('should allow regular and premium Intel for dedicated categories', () {
      final dedicatedCategories = [
        CpuCategory.generalPurpose,
        CpuCategory.cpuOptimized,
        CpuCategory.memoryOptimized,
        CpuCategory.storageOptimized,
        CpuCategory.gpu,
      ];

      for (final category in dedicatedCategories) {
        expect(CpuOption.regular.isAvailableFor(category), isTrue,
            reason: 'Regular option should be available for $category');
        expect(CpuOption.premiumIntel.isAvailableFor(category), isTrue,
            reason: 'Premium Intel option should be available for $category');
        expect(CpuOption.premiumAmd.isAvailableFor(category), isFalse,
            reason: 'Premium AMD option should NOT be available for $category');
      }
    });

    test('should have correct display names and descriptions', () {
      expect(CpuOption.regular.displayName, equals('Regular'));
      expect(CpuOption.premiumIntel.displayName, equals('Premium Intel'));
      expect(CpuOption.premiumAmd.displayName, equals('Premium AMD'));

      expect(CpuOption.regular.description, equals('Disk type: SSD / Network: Up to 2 Gbps'));
      expect(CpuOption.premiumIntel.description, equals('Disk: NVMe SSD / Network: Up to 10 Gbps'));
      expect(CpuOption.premiumAmd.description, equals('Disk: NVMe SSD / Network: Up to 10 Gbps'));
    });

    test('should have correct disk types', () {
      expect(CpuOption.regular.diskType, equals('SSD'));
      expect(CpuOption.premiumIntel.diskType, equals('NVMe SSD'));
      expect(CpuOption.premiumAmd.diskType, equals('NVMe SSD'));
    });

    test('should have correct network speeds', () {
      expect(CpuOption.regular.networkSpeed, equals('Up to 2 Gbps'));
      expect(CpuOption.premiumIntel.networkSpeed, equals('Up to 10 Gbps'));
      expect(CpuOption.premiumAmd.networkSpeed, equals('Up to 10 Gbps'));
    });
  });
}
