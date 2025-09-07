/// Utility class for formatting various units in a consistent way
class UnitFormatter {
  /// Formats memory size from MB to appropriate unit (MB or GB)
  static String formatMemory(int memoryInMB) {
    if (memoryInMB < 1024) {
      return '${memoryInMB}MB';
    } else {
      final memoryGB = memoryInMB / 1024.0;
      return '${memoryGB.toStringAsFixed(memoryGB % 1 == 0 ? 0 : 1)}GB';
    }
  }

  /// Formats storage size from GB to appropriate unit (GB or TB)
  static String formatStorage(int storageInGB) {
    if (storageInGB < 1024) {
      return '${storageInGB}GB';
    } else {
      final storageTB = storageInGB / 1024.0;
      return '${storageTB.toStringAsFixed(storageTB % 1 == 0 ? 0 : 1)}TB';
    }
  }

  /// Formats transfer/bandwidth from GB to appropriate unit (GB or TB)
  static String formatTransfer(int transferInGB) {
    if (transferInGB < 1024) {
      return '${transferInGB}GB';
    } else {
      final transferTB = transferInGB / 1024.0;
      return '${transferTB.toStringAsFixed(transferTB % 1 == 0 ? 0 : 1)}TB';
    }
  }

  /// Formats CPU count with appropriate label
  static String formatCpuCount(int cpuCount) {
    return '$cpuCount vCPU${cpuCount > 1 ? 's' : ''}';
  }

  /// Formats price with appropriate precision
  static String formatPrice(double price, {bool isMonthly = true}) {
    if (isMonthly) {
      return '\$${price.toStringAsFixed(2)}/month';
    } else {
      return '\$${price.toStringAsFixed(3)}/hour';
    }
  }

  /// Formats a general size value with appropriate unit
  /// [value] is the numeric value
  /// [unit] is the base unit (e.g., 'MB', 'GB', 'TB')
  /// [targetUnit] is the preferred display unit (e.g., 'GB', 'TB')
  static String formatSize(double value, String unit, String targetUnit) {
    final conversionFactor = _getConversionFactor(unit, targetUnit);
    final convertedValue = value * conversionFactor;

    if (convertedValue < 1) {
      return '${value.toInt()}$unit';
    } else {
      return '${convertedValue.toStringAsFixed(convertedValue % 1 == 0 ? 0 : 1)}$targetUnit';
    }
  }

  /// Gets conversion factor between units
  static double _getConversionFactor(String fromUnit, String toUnit) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    final fromIndex = units.indexOf(fromUnit.toUpperCase());
    final toIndex = units.indexOf(toUnit.toUpperCase());

    if (fromIndex == -1 || toIndex == -1) return 1.0;

    return 1.0 / (1024 * (toIndex - fromIndex));
  }
}
