class MinecraftVersion {
  final String id;
  final String type;
  final String url;
  final DateTime time;
  final DateTime releaseTime;
  final String sha1;
  final int complianceLevel;

  const MinecraftVersion({
    required this.id,
    required this.type,
    required this.url,
    required this.time,
    required this.releaseTime,
    required this.sha1,
    required this.complianceLevel,
  });

  factory MinecraftVersion.fromJson(Map<String, dynamic> json) {
    return MinecraftVersion(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      url: json['url'] ?? '',
      time: DateTime.parse(json['time'] ?? DateTime.now().toIso8601String()),
      releaseTime: DateTime.parse(
          json['releaseTime'] ?? DateTime.now().toIso8601String()),
      sha1: json['sha1'] ?? '',
      complianceLevel: (json['complianceLevel'] ?? 0).toInt(),
    );
  }

  /// Returns true if this is a release version
  bool get isRelease => type == 'release';

  /// Returns true if this is a snapshot version
  bool get isSnapshot => type == 'snapshot';

  /// Returns a formatted display name
  String get displayName {
    if (isRelease) {
      return id;
    } else {
      return '$id (Snapshot)';
    }
  }
}
