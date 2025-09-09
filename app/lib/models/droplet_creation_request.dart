/// Model representing a request to create a DigitalOcean droplet
class DropletCreationRequest {
  final String name;
  final String region;
  final String size;
  final String image;
  final List<String>? sshKeys;
  final bool backups;
  final bool ipv6;
  final bool monitoring;
  final List<String>? tags;
  final String? userData;
  final String? vpcUuid;

  const DropletCreationRequest({
    required this.name,
    required this.region,
    required this.size,
    required this.image,
    this.sshKeys,
    this.backups = false,
    this.ipv6 = true,
    this.monitoring = true,
    this.tags,
    this.userData,
    this.vpcUuid,
  });

  /// Creates a DropletCreationRequest from the form data
  factory DropletCreationRequest.fromFormData({
    required String name,
    required String region,
    required String size,
    required String image,
    List<String>? sshKeys,
    bool backups = false,
    bool ipv6 = true,
    bool monitoring = true,
    List<String>? tags,
    String? userData,
    String? vpcUuid,
  }) {
    return DropletCreationRequest(
      name: name,
      region: region,
      size: size,
      image: image,
      sshKeys: sshKeys,
      backups: backups,
      ipv6: ipv6,
      monitoring: monitoring,
      tags: tags,
      userData: userData,
      vpcUuid: vpcUuid,
    );
  }

  /// Converts the request to JSON for the DigitalOcean API
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
      'region': region,
      'size': size,
      'image': image,
      'backups': backups,
      'ipv6': ipv6,
      'monitoring': monitoring,
    };

    if (sshKeys != null && sshKeys!.isNotEmpty) {
      json['ssh_keys'] = sshKeys;
    }

    if (tags != null && tags!.isNotEmpty) {
      json['tags'] = tags;
    }

    if (userData != null && userData!.isNotEmpty) {
      json['user_data'] = userData;
    }

    if (vpcUuid != null && vpcUuid!.isNotEmpty) {
      json['vpc_uuid'] = vpcUuid;
    }

    return json;
  }

  @override
  String toString() {
    return 'DropletCreationRequest(name: $name, region: $region, size: $size, image: $image)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DropletCreationRequest &&
        other.name == name &&
        other.region == region &&
        other.size == size &&
        other.image == image &&
        other.backups == backups &&
        other.ipv6 == ipv6 &&
        other.monitoring == monitoring;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      region,
      size,
      image,
      backups,
      ipv6,
      monitoring,
    );
  }
}
