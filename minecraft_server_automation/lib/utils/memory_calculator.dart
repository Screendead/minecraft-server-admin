/// Utility class for calculating memory allocation for Minecraft servers
class MemoryCalculator {
  /// Calculates OS RAM usage based on total system RAM
  static int calculateOSRamUsage(int totalRamMB) {
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

  /// Calculates appropriate JVM memory allocation
  static int calculateJvmRamAllocation(int availableRamMB) {
    // Reserve some memory for JVM overhead and other processes
    // Use 80% of available RAM, with minimum 256MB (no maximum limit)
    final jvmRam = (availableRamMB * 0.8).round();
    return jvmRam < 256 ? 256 : jvmRam; // Only enforce minimum, no maximum
  }

  /// Calculates view distance based on available RAM
  static int calculateViewDistance(int jvmRamMB) {
    if (jvmRamMB < 512) {
      return 6; // Very limited RAM - minimal settings
    } else if (jvmRamMB < 1024) {
      return 8; // Limited RAM - conservative settings
    } else if (jvmRamMB < 2048) {
      return 10; // Moderate RAM - balanced settings
    } else if (jvmRamMB < 4096) {
      return 12; // Good RAM - comfortable settings
    } else {
      return 16; // Plenty of RAM - high settings
    }
  }

  /// Calculates simulation distance based on available RAM
  static int calculateSimulationDistance(int jvmRamMB) {
    if (jvmRamMB < 512) {
      return 4; // Very limited RAM - minimal settings
    } else if (jvmRamMB < 1024) {
      return 6; // Limited RAM - conservative settings
    } else if (jvmRamMB < 2048) {
      return 8; // Moderate RAM - balanced settings
    } else if (jvmRamMB < 4096) {
      return 10; // Good RAM - comfortable settings
    } else {
      return 12; // Plenty of RAM - high settings
    }
  }
}
