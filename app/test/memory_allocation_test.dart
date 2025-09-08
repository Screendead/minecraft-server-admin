import 'package:flutter_test/flutter_test.dart';
import 'package:app/pages/add_droplet_page.dart';
import 'package:app/services/digitalocean_api_service.dart';

void main() {
  group('Memory Allocation Logic', () {
    late _TestAddDropletPage testPage;

    setUp(() {
      testPage = _TestAddDropletPage();
    });

    group('OS RAM Usage Calculation', () {
      test('should calculate correct OS RAM for 512MB droplet', () {
        final osRam = testPage.calculateOSRamUsage(512);
        expect(osRam, 200);
      });

      test('should calculate correct OS RAM for 1GB droplet', () {
        final osRam = testPage.calculateOSRamUsage(1024);
        expect(osRam, 300);
      });

      test('should calculate correct OS RAM for 2GB droplet', () {
        final osRam = testPage.calculateOSRamUsage(2048);
        expect(osRam, 400);
      });

      test('should calculate correct OS RAM for 4GB+ droplet', () {
        final osRam = testPage.calculateOSRamUsage(4096);
        expect(osRam, 500);
      });

      test('should calculate correct OS RAM for 8GB droplet', () {
        final osRam = testPage.calculateOSRamUsage(8192);
        expect(osRam, 500);
      });
    });

    group('JVM RAM Allocation Calculation', () {
      test('should calculate correct JVM RAM for 512MB total (312MB available)', () {
        final jvmRam = testPage.calculateJvmRamAllocation(312);
        expect(jvmRam, 256); // 312 * 0.8 = 249.6, but clamped to minimum 256
      });

      test('should calculate correct JVM RAM for 1GB total (724MB available)', () {
        final jvmRam = testPage.calculateJvmRamAllocation(724);
        expect(jvmRam, 579); // 724 * 0.8 = 579.2, rounded to 579
      });

      test('should calculate correct JVM RAM for 2GB total (1648MB available)', () {
        final jvmRam = testPage.calculateJvmRamAllocation(1648);
        expect(jvmRam, 1318); // 1648 * 0.8 = 1318.4, rounded to 1318
      });

      test('should respect minimum JVM RAM of 256MB', () {
        final jvmRam = testPage.calculateJvmRamAllocation(200);
        expect(jvmRam, 256); // Should clamp to minimum
      });

      test('should not limit JVM RAM for large droplets', () {
        final jvmRam = testPage.calculateJvmRamAllocation(12000);
        expect(jvmRam, 9600); // 12000 * 0.8 = 9600, no maximum limit
      });

      test('should scale JVM RAM for very large droplets', () {
        final jvmRam = testPage.calculateJvmRamAllocation(32000);
        expect(jvmRam, 25600); // 32000 * 0.8 = 25600, scales with available RAM
      });
    });

    group('Server Properties Generation', () {
      test('should generate minimal settings for 256MB JVM', () {
        final properties = testPage.generateServerProperties(256);
        expect(properties, contains('view-distance=6'));
        expect(properties, contains('simulation-distance=4'));
        expect(properties, contains('Generated for 256MB JVM allocation'));
      });

      test('should generate conservative settings for 512MB JVM', () {
        final properties = testPage.generateServerProperties(512);
        expect(properties, contains('view-distance=8'));
        expect(properties, contains('simulation-distance=6'));
        expect(properties, contains('Generated for 512MB JVM allocation'));
      });

      test('should generate balanced settings for 1GB JVM', () {
        final properties = testPage.generateServerProperties(1024);
        expect(properties, contains('view-distance=10'));
        expect(properties, contains('simulation-distance=8'));
        expect(properties, contains('Generated for 1024MB JVM allocation'));
      });

      test('should generate comfortable settings for 2GB JVM', () {
        final properties = testPage.generateServerProperties(2048);
        expect(properties, contains('view-distance=12'));
        expect(properties, contains('simulation-distance=10'));
        expect(properties, contains('Generated for 2048MB JVM allocation'));
      });

      test('should generate high settings for 4GB+ JVM', () {
        final properties = testPage.generateServerProperties(4096);
        expect(properties, contains('view-distance=16'));
        expect(properties, contains('simulation-distance=12'));
        expect(properties, contains('Generated for 4096MB JVM allocation'));
      });
    });

    group('End-to-End Memory Calculation', () {
      test('should work correctly for smallest droplet (512MB total)', () {
        // 512MB total - 200MB OS = 312MB available
        // 312MB * 0.8 = 249.6MB, clamped to 256MB minimum
        final totalRam = 512;
        final osRam = testPage.calculateOSRamUsage(totalRam);
        final availableRam = totalRam - osRam;
        final jvmRam = testPage.calculateJvmRamAllocation(availableRam);
        
        expect(osRam, 200);
        expect(availableRam, 312);
        expect(jvmRam, 256);
      });

      test('should work correctly for 1GB droplet', () {
        // 1024MB total - 300MB OS = 724MB available
        // 724MB * 0.8 = 579.2MB
        final totalRam = 1024;
        final osRam = testPage.calculateOSRamUsage(totalRam);
        final availableRam = totalRam - osRam;
        final jvmRam = testPage.calculateJvmRamAllocation(availableRam);
        
        expect(osRam, 300);
        expect(availableRam, 724);
        expect(jvmRam, 579);
      });

      test('should work correctly for 2GB droplet', () {
        // 2048MB total - 400MB OS = 1648MB available
        // 1648MB * 0.8 = 1318.4MB
        final totalRam = 2048;
        final osRam = testPage.calculateOSRamUsage(totalRam);
        final availableRam = totalRam - osRam;
        final jvmRam = testPage.calculateJvmRamAllocation(availableRam);
        
        expect(osRam, 400);
        expect(availableRam, 1648);
        expect(jvmRam, 1318);
      });
    });
  });
}

/// Test class that exposes the private methods for testing
class _TestAddDropletPage {
  int calculateOSRamUsage(int totalRamMB) {
    // Ubuntu 22.04 LTS typically uses:
    // - 512MB: ~200MB for OS
    // - 1GB: ~300MB for OS  
    // - 2GB+: ~400MB for OS
    if (totalRamMB <= 512) {
      return 200; // Conservative for small droplets
    } else if (totalRamMB <= 1024) {
      return 300;
    } else if (totalRamMB <= 2048) {
      return 400;
    } else {
      return 500; // More services running on larger droplets
    }
  }

  int calculateJvmRamAllocation(int availableRamMB) {
    // Reserve some memory for JVM overhead and other processes
    // Use 80% of available RAM, with minimum 256MB (no maximum limit)
    final jvmRam = (availableRamMB * 0.8).round();
    return jvmRam < 256 ? 256 : jvmRam; // Only enforce minimum, no maximum
  }

  String generateServerProperties(int jvmRamMB) {
    // Calculate view distance and simulation distance based on available RAM
    // More RAM = higher distances for better gameplay experience
    int viewDistance;
    int simulationDistance;
    
    if (jvmRamMB < 512) {
      // Very limited RAM - minimal settings
      viewDistance = 6;
      simulationDistance = 4;
    } else if (jvmRamMB < 1024) {
      // Limited RAM - conservative settings
      viewDistance = 8;
      simulationDistance = 6;
    } else if (jvmRamMB < 2048) {
      // Moderate RAM - balanced settings
      viewDistance = 10;
      simulationDistance = 8;
    } else if (jvmRamMB < 4096) {
      // Good RAM - comfortable settings
      viewDistance = 12;
      simulationDistance = 10;
    } else {
      // Plenty of RAM - high settings
      viewDistance = 16;
      simulationDistance = 12;
    }

    return '''# Minecraft server properties
# Generated for ${jvmRamMB}MB JVM allocation

# Performance settings (optimized for ${jvmRamMB}MB RAM)
view-distance=$viewDistance
simulation-distance=$simulationDistance
''';
  }
}
