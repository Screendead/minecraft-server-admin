import 'cpu_architecture.dart';

/// Enum representing CPU categories
enum CpuCategory {
  basic('basic', 'Basic'),
  generalPurpose('general_purpose', 'General Purpose'),
  cpuOptimized('cpu_optimized', 'CPU Optimized'),
  memoryOptimized('memory_optimized', 'Memory Optimized'),
  storageOptimized('storage_optimized', 'Storage Optimized'),
  gpu('gpu', 'GPU');

  const CpuCategory(this.value, this.displayName);
  final String value;
  final String displayName;

  /// Returns true if this category is available for the given architecture
  bool isAvailableFor(CpuArchitecture architecture) {
    switch (architecture) {
      case CpuArchitecture.shared:
        return this == CpuCategory.basic;
      case CpuArchitecture.dedicated:
        return this != CpuCategory.basic;
    }
  }
}
