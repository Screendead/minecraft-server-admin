import 'cpu_category.dart';

/// Enum representing CPU options
enum CpuOption {
  regular('regular', 'Regular', 'Disk type: SSD / Network: Up to 2 Gbps'),
  premiumIntel('premium_intel', 'Premium Intel',
      'Disk: NVMe SSD / Network: Up to 10 Gbps'),
  premiumAmd(
      'premium_amd', 'Premium AMD', 'Disk: NVMe SSD / Network: Up to 10 Gbps');

  const CpuOption(this.value, this.displayName, this.description);
  final String value;
  final String displayName;
  final String description;

  /// Returns the disk type for display
  String get diskType {
    switch (this) {
      case CpuOption.regular:
        return 'SSD';
      case CpuOption.premiumIntel:
      case CpuOption.premiumAmd:
        return 'NVMe SSD';
    }
  }

  /// Returns the network speed for display
  String get networkSpeed {
    switch (this) {
      case CpuOption.regular:
        return 'Up to 2 Gbps';
      case CpuOption.premiumIntel:
      case CpuOption.premiumAmd:
        return 'Up to 10 Gbps';
    }
  }

  /// Returns true if this option is available for the given category
  bool isAvailableFor(CpuCategory category) {
    switch (category) {
      case CpuCategory.basic:
        return true; // All options available for Basic
      case CpuCategory.generalPurpose:
      case CpuCategory.cpuOptimized:
      case CpuCategory.memoryOptimized:
      case CpuCategory.storageOptimized:
      case CpuCategory.gpu:
        return this == CpuOption.regular || this == CpuOption.premiumIntel;
    }
  }
}
