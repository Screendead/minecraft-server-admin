import 'package:flutter_test/flutter_test.dart';
import '../lib/models/cpu_architecture.dart';

void main() {
  group('CpuArchitecture', () {
    test('should have correct values and display names', () {
      expect(CpuArchitecture.shared.value, equals('shared'));
      expect(CpuArchitecture.shared.displayName, equals('Shared CPU'));
      expect(CpuArchitecture.dedicated.value, equals('dedicated'));
      expect(CpuArchitecture.dedicated.displayName, equals('Dedicated CPU'));
    });

    test('should have all expected values', () {
      expect(CpuArchitecture.values.length, equals(2));
      expect(CpuArchitecture.values, contains(CpuArchitecture.shared));
      expect(CpuArchitecture.values, contains(CpuArchitecture.dedicated));
    });
  });
}
