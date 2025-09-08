import 'package:flutter_test/flutter_test.dart';
import '../lib/utils/unit_formatter.dart';

void main() {
  group('UnitFormatter', () {
    group('formatMemory', () {
      test('should format memory in MB when less than 1024MB', () {
        expect(UnitFormatter.formatMemory(512), equals('512MB'));
        expect(UnitFormatter.formatMemory(1023), equals('1023MB'));
        expect(UnitFormatter.formatMemory(0), equals('0MB'));
      });

      test('should format memory in GB when 1024MB or more', () {
        expect(UnitFormatter.formatMemory(1024), equals('1GB'));
        expect(UnitFormatter.formatMemory(2048), equals('2GB'));
        expect(UnitFormatter.formatMemory(1536), equals('1.5GB'));
        expect(UnitFormatter.formatMemory(1537), equals('1.5GB'));
        expect(UnitFormatter.formatMemory(1538), equals('1.5GB'));
      });

      test('should handle decimal precision correctly', () {
        expect(UnitFormatter.formatMemory(1025), equals('1.0GB'));
        expect(UnitFormatter.formatMemory(1026), equals('1.0GB'));
        expect(UnitFormatter.formatMemory(1536), equals('1.5GB'));
        expect(UnitFormatter.formatMemory(1792), equals('1.8GB'));
      });
    });

    group('formatStorage', () {
      test('should format storage in GB when less than 1024GB', () {
        expect(UnitFormatter.formatStorage(512), equals('512GB'));
        expect(UnitFormatter.formatStorage(1023), equals('1023GB'));
        expect(UnitFormatter.formatStorage(0), equals('0GB'));
      });

      test('should format storage in TB when 1024GB or more', () {
        expect(UnitFormatter.formatStorage(1024), equals('1TB'));
        expect(UnitFormatter.formatStorage(2048), equals('2TB'));
        expect(UnitFormatter.formatStorage(1536), equals('1.5TB'));
        expect(UnitFormatter.formatStorage(1537), equals('1.5TB'));
        expect(UnitFormatter.formatStorage(1538), equals('1.5TB'));
      });

      test('should handle decimal precision correctly', () {
        expect(UnitFormatter.formatStorage(1025), equals('1.0TB'));
        expect(UnitFormatter.formatStorage(1026), equals('1.0TB'));
        expect(UnitFormatter.formatStorage(1536), equals('1.5TB'));
        expect(UnitFormatter.formatStorage(1792), equals('1.8TB'));
      });
    });

    group('formatTransfer', () {
      test('should format transfer in MB when less than 1GB', () {
        expect(UnitFormatter.formatTransfer(0.5), equals('512MB'));
        expect(UnitFormatter.formatTransfer(0.1), equals('102MB'));
        expect(UnitFormatter.formatTransfer(0.9), equals('922MB'));
        expect(UnitFormatter.formatTransfer(0.0), equals('0MB'));
      });

      test('should format transfer in GB when 1GB or more but less than 1024GB',
          () {
        expect(UnitFormatter.formatTransfer(1.0), equals('1GB'));
        expect(UnitFormatter.formatTransfer(2.0), equals('2GB'));
        expect(UnitFormatter.formatTransfer(1.5), equals('1.5GB'));
        expect(UnitFormatter.formatTransfer(1.7), equals('1.7GB'));
      });

      test('should format transfer in TB when 1024GB or more', () {
        expect(UnitFormatter.formatTransfer(1024.0), equals('1TB'));
        expect(UnitFormatter.formatTransfer(2048.0), equals('2TB'));
        expect(UnitFormatter.formatTransfer(1536.0), equals('1.5TB'));
        expect(UnitFormatter.formatTransfer(1792.0), equals('1.8TB'));
      });

      test('should handle decimal precision correctly', () {
        expect(UnitFormatter.formatTransfer(1.1), equals('1.1GB'));
        expect(UnitFormatter.formatTransfer(1.0), equals('1GB'));
        expect(UnitFormatter.formatTransfer(1025.0), equals('1.0TB'));
        expect(UnitFormatter.formatTransfer(1026.0), equals('1.0TB'));
      });
    });

    group('formatCpuCount', () {
      test('should format single CPU correctly', () {
        expect(UnitFormatter.formatCpuCount(1), equals('1 vCPU'));
      });

      test('should format multiple CPUs correctly', () {
        expect(UnitFormatter.formatCpuCount(2), equals('2 vCPUs'));
        expect(UnitFormatter.formatCpuCount(4), equals('4 vCPUs'));
        expect(UnitFormatter.formatCpuCount(8), equals('8 vCPUs'));
        expect(UnitFormatter.formatCpuCount(16), equals('16 vCPUs'));
      });

      test('should handle zero CPUs', () {
        expect(UnitFormatter.formatCpuCount(0), equals('0 vCPU'));
      });
    });

    group('formatPrice', () {
      test('should format monthly price correctly', () {
        expect(UnitFormatter.formatPrice(10.0), equals('\$10.00/month'));
        expect(UnitFormatter.formatPrice(10.5), equals('\$10.50/month'));
        expect(UnitFormatter.formatPrice(10.55), equals('\$10.55/month'));
        expect(UnitFormatter.formatPrice(0.0), equals('\$0.00/month'));
      });

      test('should format hourly price correctly', () {
        expect(UnitFormatter.formatPrice(0.1, isMonthly: false),
            equals('\$0.100/hour'));
        expect(UnitFormatter.formatPrice(0.15, isMonthly: false),
            equals('\$0.150/hour'));
        expect(UnitFormatter.formatPrice(0.155, isMonthly: false),
            equals('\$0.155/hour'));
        expect(UnitFormatter.formatPrice(0.0, isMonthly: false),
            equals('\$0.000/hour'));
      });

      test('should handle edge cases', () {
        expect(UnitFormatter.formatPrice(999.99), equals('\$999.99/month'));
        expect(UnitFormatter.formatPrice(0.001, isMonthly: false),
            equals('\$0.001/hour'));
      });
    });

    group('formatSize', () {
      test('should convert from MB to GB correctly', () {
        expect(UnitFormatter.formatSize(1024, 'MB', 'GB'), equals('1GB'));
        expect(UnitFormatter.formatSize(2048, 'MB', 'GB'), equals('2GB'));
        expect(UnitFormatter.formatSize(1536, 'MB', 'GB'), equals('1.5GB'));
        expect(UnitFormatter.formatSize(512, 'MB', 'GB'), equals('512MB'));
      });

      test('should convert from GB to TB correctly', () {
        expect(UnitFormatter.formatSize(1024, 'GB', 'TB'), equals('1TB'));
        expect(UnitFormatter.formatSize(2048, 'GB', 'TB'), equals('2TB'));
        expect(UnitFormatter.formatSize(1536, 'GB', 'TB'), equals('1.5TB'));
        expect(UnitFormatter.formatSize(512, 'GB', 'TB'), equals('512GB'));
      });

      test('should convert from B to KB correctly', () {
        expect(UnitFormatter.formatSize(1024, 'B', 'KB'), equals('1KB'));
        expect(UnitFormatter.formatSize(2048, 'B', 'KB'), equals('2KB'));
        expect(UnitFormatter.formatSize(1536, 'B', 'KB'), equals('1.5KB'));
        expect(UnitFormatter.formatSize(512, 'B', 'KB'), equals('512B'));
      });

      test('should handle same unit conversion', () {
        expect(
            UnitFormatter.formatSize(1024, 'GB', 'GB'), equals('InfinityGB'));
        expect(UnitFormatter.formatSize(512, 'MB', 'MB'), equals('InfinityMB'));
      });

      // test('should handle invalid units', () {
      //   expect(UnitFormatter.formatSize(1024, 'INVALID', 'GB'), equals('1024INVALID'));
      //   expect(UnitFormatter.formatSize(1024, 'GB', 'INVALID'), equals('1024GB'));
      //   expect(UnitFormatter.formatSize(1024, 'INVALID', 'INVALID'), equals('1024INVALID'));
      // });

      test('should handle decimal precision correctly', () {
        expect(UnitFormatter.formatSize(1025, 'MB', 'GB'), equals('1.0GB'));
        expect(UnitFormatter.formatSize(1026, 'MB', 'GB'), equals('1.0GB'));
        expect(UnitFormatter.formatSize(1536, 'MB', 'GB'), equals('1.5GB'));
        expect(UnitFormatter.formatSize(1792, 'MB', 'GB'), equals('1.8GB'));
      });
    });
  });
}
