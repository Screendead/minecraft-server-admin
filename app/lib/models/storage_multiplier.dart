import 'cpu_category.dart';
import 'cpu_option.dart';

/// Enum representing storage multipliers
enum StorageMultiplier {
  x1('1x', '1x SSD', 'Standard storage'),
  x2('2x', '2x SSD', 'Double storage capacity'),
  x3('3x', '3x SSD', 'Triple storage capacity'),
  x6('6x', '6x SSD', 'Six times storage capacity');

  const StorageMultiplier(this.value, this.displayName, this.description);
  final String value;
  final String displayName;
  final String description;

  /// Returns true if this multiplier is available for the given category and option
  bool isAvailableFor(CpuCategory category, CpuOption option) {
    switch (category) {
      case CpuCategory.basic:
        return true; // All multipliers available for Basic
      case CpuCategory.generalPurpose:
        return this == StorageMultiplier.x1 || this == StorageMultiplier.x2;
      case CpuCategory.cpuOptimized:
        return this == StorageMultiplier.x1 || this == StorageMultiplier.x2;
      case CpuCategory.memoryOptimized:
        return this == StorageMultiplier.x1 ||
            this == StorageMultiplier.x3 ||
            this == StorageMultiplier.x6;
      case CpuCategory.storageOptimized:
        return this == StorageMultiplier.x1 || this == StorageMultiplier.x2;
      case CpuCategory.gpu:
        return this == StorageMultiplier.x1; // Only 1x for GPU
    }
  }
}
