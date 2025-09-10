/// Enum representing CPU architecture types
enum CpuArchitecture {
  shared('shared', 'Shared CPU'),
  dedicated('dedicated', 'Dedicated CPU');

  const CpuArchitecture(this.value, this.displayName);
  final String value;
  final String displayName;
}
