/// Data class representing Minecraft server information
class MinecraftServerInfo {
  final String hostname;
  final String ip;
  final int port;
  final String version;
  final String protocol;
  final int playersOnline;
  final int playersMax;
  final String? motd;
  final String? favicon;
  final List<String>? players;
  final String? software;
  final String? map;
  final String? gamemode;
  final int? ping;

  const MinecraftServerInfo({
    required this.hostname,
    required this.ip,
    required this.port,
    required this.version,
    required this.protocol,
    required this.playersOnline,
    required this.playersMax,
    this.motd,
    this.favicon,
    this.players,
    this.software,
    this.map,
    this.gamemode,
    this.ping,
  });

  factory MinecraftServerInfo.fromJson(Map<String, dynamic> json) {
    return MinecraftServerInfo(
      hostname:
          json['hostname'] as String? ?? json['ip'] as String? ?? 'Unknown',
      ip: json['ip'] as String? ?? 'Unknown',
      port: json['port'] as int? ?? 25565,
      version: json['version'] as String? ?? 'Unknown',
      protocol: json['protocol']?.toString() ?? 'Unknown',
      playersOnline: json['players']?['online'] as int? ?? 0,
      playersMax: json['players']?['max'] as int? ?? 0,
      motd: _parseMotd(json['motd']),
      favicon: json['favicon'] as String?,
      players: json['players']?['list'] != null
          ? List<String>.from(json['players']['list'])
          : null,
      software: json['software'] as String?,
      map: json['map'] as String?,
      gamemode: json['gamemode'] as String?,
      ping: json['ping'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hostname': hostname,
      'ip': ip,
      'port': port,
      'version': version,
      'protocol': protocol,
      'players': {
        'online': playersOnline,
        'max': playersMax,
        if (players != null) 'list': players,
      },
      if (motd != null) 'motd': {'clean': motd},
      if (favicon != null) 'favicon': favicon,
      if (software != null) 'software': software,
      if (map != null) 'map': map,
      if (gamemode != null) 'gamemode': gamemode,
      if (ping != null) 'ping': ping,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MinecraftServerInfo &&
        other.hostname == hostname &&
        other.ip == ip &&
        other.port == port &&
        other.version == version &&
        other.protocol == protocol &&
        other.playersOnline == playersOnline &&
        other.playersMax == playersMax &&
        other.motd == motd &&
        other.favicon == favicon &&
        other.players == players &&
        other.software == software &&
        other.map == map &&
        other.gamemode == gamemode &&
        other.ping == ping;
  }

  @override
  int get hashCode {
    return Object.hash(
      hostname,
      ip,
      port,
      version,
      protocol,
      playersOnline,
      playersMax,
      motd,
      favicon,
      players,
      software,
      map,
      gamemode,
      ping,
    );
  }

  @override
  String toString() {
    return 'MinecraftServerInfo(hostname: $hostname, ip: $ip, port: $port, version: $version, playersOnline: $playersOnline, playersMax: $playersMax)';
  }

  static String? _parseMotd(dynamic motd) {
    if (motd == null) return null;

    // Try clean first
    if (motd['clean'] != null) {
      if (motd['clean'] is List) {
        final cleanList = motd['clean'] as List;
        if (cleanList.isNotEmpty) {
          return cleanList.join(' ');
        }
      } else if (motd['clean'] is String) {
        return motd['clean'] as String;
      }
    }

    // Fallback to raw
    if (motd['raw'] != null) {
      if (motd['raw'] is List) {
        final rawList = motd['raw'] as List;
        if (rawList.isNotEmpty) {
          return rawList.join(' ');
        }
      } else if (motd['raw'] is String) {
        return motd['raw'] as String;
      }
    }

    return null;
  }
}
