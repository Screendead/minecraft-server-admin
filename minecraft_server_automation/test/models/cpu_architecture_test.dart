import 'package:flutter_test/flutter_test.dart';
import 'package:minecraft_server_automation/models/cpu_architecture.dart';

void main() {
  group('CpuArchitecture', () {
    test('should have correct values and display names', () {
      expect(CpuArchitecture.shared.value, equals('shared'));
      expect(CpuArchitecture.shared.displayName, equals('Shared CPU'));
      
      expect(CpuArchitecture.dedicated.value, equals('dedicated'));
      expect(CpuArchitecture.dedicated.displayName, equals('Dedicated CPU'));
    });

    test('should have all expected enum values', () {
      expect(CpuArchitecture.values.length, equals(2));
      expect(CpuArchitecture.values, contains(CpuArchitecture.shared));
      expect(CpuArchitecture.values, contains(CpuArchitecture.dedicated));
    });

    test('should support equality comparison', () {
      expect(CpuArchitecture.shared, equals(CpuArchitecture.shared));
      expect(CpuArchitecture.dedicated, equals(CpuArchitecture.dedicated));
      expect(CpuArchitecture.shared, isNot(equals(CpuArchitecture.dedicated)));
    });

    test('should support string conversion', () {
      expect(CpuArchitecture.shared.toString(), contains('CpuArchitecture.shared'));
      expect(CpuArchitecture.dedicated.toString(), contains('CpuArchitecture.dedicated'));
    });

    test('should be immutable', () {
      const shared = CpuArchitecture.shared;
      expect(shared.value, equals('shared'));
      expect(shared.displayName, equals('Shared CPU'));
      
      // Verify that the enum values are constants
      expect(shared.value, isA<String>());
      expect(shared.displayName, isA<String>());
    });
  });
}
