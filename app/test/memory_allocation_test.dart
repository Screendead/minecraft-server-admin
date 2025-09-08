import 'package:flutter_test/flutter_test.dart';
import 'package:app/utils/memory_calculator.dart';

void main() {
  group('Memory Allocation Logic', () {
    group('OS RAM Usage Calculation', () {
      test('should calculate correct OS RAM for 512MB droplet', () {
        final osRam = MemoryCalculator.calculateOSRamUsage(512);
        expect(osRam, 200);
      });

      test('should calculate correct OS RAM for 1GB droplet', () {
        final osRam = MemoryCalculator.calculateOSRamUsage(1024);
        expect(osRam, 300);
      });

      test('should calculate correct OS RAM for 2GB droplet', () {
        final osRam = MemoryCalculator.calculateOSRamUsage(2048);
        expect(osRam, 400);
      });

      test('should calculate correct OS RAM for 4GB+ droplet', () {
        final osRam = MemoryCalculator.calculateOSRamUsage(4096);
        expect(osRam, 500);
      });

      test('should calculate correct OS RAM for 8GB droplet', () {
        final osRam = MemoryCalculator.calculateOSRamUsage(8192);
        expect(osRam, 500);
      });
    });

    group('JVM RAM Allocation Calculation', () {
      test('should calculate correct JVM RAM for 512MB total (312MB available)', () {
        final jvmRam = MemoryCalculator.calculateJvmRamAllocation(312);
        expect(jvmRam, 256); // 312 * 0.8 = 249.6, but clamped to minimum 256
      });

      test('should calculate correct JVM RAM for 1GB total (724MB available)', () {
        final jvmRam = MemoryCalculator.calculateJvmRamAllocation(724);
        expect(jvmRam, 579); // 724 * 0.8 = 579.2, rounded to 579
      });

      test('should calculate correct JVM RAM for 2GB total (1648MB available)', () {
        final jvmRam = MemoryCalculator.calculateJvmRamAllocation(1648);
        expect(jvmRam, 1318); // 1648 * 0.8 = 1318.4, rounded to 1318
      });

      test('should calculate correct JVM RAM for 4GB total (3596MB available)', () {
        final jvmRam = MemoryCalculator.calculateJvmRamAllocation(3596);
        expect(jvmRam, 2877); // 3596 * 0.8 = 2876.8, rounded to 2877
      });

      test('should calculate correct JVM RAM for 8GB total (7596MB available)', () {
        final jvmRam = MemoryCalculator.calculateJvmRamAllocation(7596);
        expect(jvmRam, 6077); // 7596 * 0.8 = 6076.8, rounded to 6077
      });

      test('should enforce minimum 256MB JVM RAM', () {
        final jvmRam = MemoryCalculator.calculateJvmRamAllocation(100);
        expect(jvmRam, 256); // Should be clamped to minimum 256
      });

      test('should not enforce maximum JVM RAM limit', () {
        final jvmRam = MemoryCalculator.calculateJvmRamAllocation(10000);
        expect(jvmRam, 8000); // 10000 * 0.8 = 8000, no maximum limit
      });
    });

    group('View Distance Calculation', () {
      test('should calculate correct view distance for 256MB JVM', () {
        final viewDistance = MemoryCalculator.calculateViewDistance(256);
        expect(viewDistance, 6);
      });

      test('should calculate correct view distance for 512MB JVM', () {
        final viewDistance = MemoryCalculator.calculateViewDistance(512);
        expect(viewDistance, 8);
      });

      test('should calculate correct view distance for 768MB JVM', () {
        final viewDistance = MemoryCalculator.calculateViewDistance(768);
        expect(viewDistance, 8);
      });

      test('should calculate correct view distance for 1GB JVM', () {
        final viewDistance = MemoryCalculator.calculateViewDistance(1024);
        expect(viewDistance, 10);
      });

      test('should calculate correct view distance for 1.5GB JVM', () {
        final viewDistance = MemoryCalculator.calculateViewDistance(1536);
        expect(viewDistance, 10);
      });

      test('should calculate correct view distance for 2GB JVM', () {
        final viewDistance = MemoryCalculator.calculateViewDistance(2048);
        expect(viewDistance, 12);
      });

      test('should calculate correct view distance for 3GB JVM', () {
        final viewDistance = MemoryCalculator.calculateViewDistance(3072);
        expect(viewDistance, 12);
      });

      test('should calculate correct view distance for 4GB JVM', () {
        final viewDistance = MemoryCalculator.calculateViewDistance(4096);
        expect(viewDistance, 16);
      });

      test('should calculate correct view distance for 8GB JVM', () {
        final viewDistance = MemoryCalculator.calculateViewDistance(8192);
        expect(viewDistance, 16);
      });
    });

    group('Simulation Distance Calculation', () {
      test('should calculate correct simulation distance for 256MB JVM', () {
        final simulationDistance = MemoryCalculator.calculateSimulationDistance(256);
        expect(simulationDistance, 4);
      });

      test('should calculate correct simulation distance for 512MB JVM', () {
        final simulationDistance = MemoryCalculator.calculateSimulationDistance(512);
        expect(simulationDistance, 6);
      });

      test('should calculate correct simulation distance for 768MB JVM', () {
        final simulationDistance = MemoryCalculator.calculateSimulationDistance(768);
        expect(simulationDistance, 6);
      });

      test('should calculate correct simulation distance for 1GB JVM', () {
        final simulationDistance = MemoryCalculator.calculateSimulationDistance(1024);
        expect(simulationDistance, 8);
      });

      test('should calculate correct simulation distance for 1.5GB JVM', () {
        final simulationDistance = MemoryCalculator.calculateSimulationDistance(1536);
        expect(simulationDistance, 8);
      });

      test('should calculate correct simulation distance for 2GB JVM', () {
        final simulationDistance = MemoryCalculator.calculateSimulationDistance(2048);
        expect(simulationDistance, 10);
      });

      test('should calculate correct simulation distance for 3GB JVM', () {
        final simulationDistance = MemoryCalculator.calculateSimulationDistance(3072);
        expect(simulationDistance, 10);
      });

      test('should calculate correct simulation distance for 4GB JVM', () {
        final simulationDistance = MemoryCalculator.calculateSimulationDistance(4096);
        expect(simulationDistance, 12);
      });

      test('should calculate correct simulation distance for 8GB JVM', () {
        final simulationDistance = MemoryCalculator.calculateSimulationDistance(8192);
        expect(simulationDistance, 12);
      });
    });

    group('End-to-End Memory Calculation', () {
      test('should calculate correct values for 512MB droplet', () {
        final totalRamMB = 512;
        final osRamMB = MemoryCalculator.calculateOSRamUsage(totalRamMB);
        final availableRamMB = totalRamMB - osRamMB;
        final jvmRamMB = MemoryCalculator.calculateJvmRamAllocation(availableRamMB);
        final viewDistance = MemoryCalculator.calculateViewDistance(jvmRamMB);
        final simulationDistance = MemoryCalculator.calculateSimulationDistance(jvmRamMB);

        expect(osRamMB, 200);
        expect(availableRamMB, 312);
        expect(jvmRamMB, 256);
        expect(viewDistance, 6);
        expect(simulationDistance, 4);
      });

      test('should calculate correct values for 1GB droplet', () {
        final totalRamMB = 1024;
        final osRamMB = MemoryCalculator.calculateOSRamUsage(totalRamMB);
        final availableRamMB = totalRamMB - osRamMB;
        final jvmRamMB = MemoryCalculator.calculateJvmRamAllocation(availableRamMB);
        final viewDistance = MemoryCalculator.calculateViewDistance(jvmRamMB);
        final simulationDistance = MemoryCalculator.calculateSimulationDistance(jvmRamMB);

        expect(osRamMB, 300);
        expect(availableRamMB, 724);
        expect(jvmRamMB, 579);
        expect(viewDistance, 8);
        expect(simulationDistance, 6);
      });

      test('should calculate correct values for 2GB droplet', () {
        final totalRamMB = 2048;
        final osRamMB = MemoryCalculator.calculateOSRamUsage(totalRamMB);
        final availableRamMB = totalRamMB - osRamMB;
        final jvmRamMB = MemoryCalculator.calculateJvmRamAllocation(availableRamMB);
        final viewDistance = MemoryCalculator.calculateViewDistance(jvmRamMB);
        final simulationDistance = MemoryCalculator.calculateSimulationDistance(jvmRamMB);

        expect(osRamMB, 400);
        expect(availableRamMB, 1648);
        expect(jvmRamMB, 1318);
        expect(viewDistance, 10);
        expect(simulationDistance, 8);
      });

      test('should calculate correct values for 4GB droplet', () {
        final totalRamMB = 4096;
        final osRamMB = MemoryCalculator.calculateOSRamUsage(totalRamMB);
        final availableRamMB = totalRamMB - osRamMB;
        final jvmRamMB = MemoryCalculator.calculateJvmRamAllocation(availableRamMB);
        final viewDistance = MemoryCalculator.calculateViewDistance(jvmRamMB);
        final simulationDistance = MemoryCalculator.calculateSimulationDistance(jvmRamMB);

        expect(osRamMB, 500);
        expect(availableRamMB, 3596);
        expect(jvmRamMB, 2877);
        expect(viewDistance, 12);
        expect(simulationDistance, 10);
      });

      test('should calculate correct values for 8GB droplet', () {
        final totalRamMB = 8192;
        final osRamMB = MemoryCalculator.calculateOSRamUsage(totalRamMB);
        final availableRamMB = totalRamMB - osRamMB;
        final jvmRamMB = MemoryCalculator.calculateJvmRamAllocation(availableRamMB);
        final viewDistance = MemoryCalculator.calculateViewDistance(jvmRamMB);
        final simulationDistance = MemoryCalculator.calculateSimulationDistance(jvmRamMB);

        expect(osRamMB, 500);
        expect(availableRamMB, 7692);
        expect(jvmRamMB, 6154);
        expect(viewDistance, 16);
        expect(simulationDistance, 12);
      });
    });
  });
}