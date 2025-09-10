class Region {
  final String name;
  final String slug;
  final List<String> features;
  final bool available;

  const Region({
    required this.name,
    required this.slug,
    required this.features,
    required this.available,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      features: (json['features'] as List<dynamic>?)?.cast<String>() ?? [],
      available: json['available'] ?? false,
    );
  }
}
