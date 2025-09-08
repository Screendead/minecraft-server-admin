/// Represents different log levels
enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal;

  String get displayName {
    switch (this) {
      case LogLevel.debug:
        return 'Debug';
      case LogLevel.info:
        return 'Info';
      case LogLevel.warning:
        return 'Warning';
      case LogLevel.error:
        return 'Error';
      case LogLevel.fatal:
        return 'Fatal';
    }
  }

  String get iconName {
    switch (this) {
      case LogLevel.debug:
        return 'bug_report';
      case LogLevel.info:
        return 'info';
      case LogLevel.warning:
        return 'warning';
      case LogLevel.error:
        return 'error';
      case LogLevel.fatal:
        return 'dangerous';
    }
  }
}

/// Represents different log categories for better organization
enum LogCategory {
  userInteraction,
  apiCall,
  authentication,
  dropletManagement,
  serverManagement,
  error,
  system,
  security;

  String get displayName {
    switch (this) {
      case LogCategory.userInteraction:
        return 'User Interaction';
      case LogCategory.apiCall:
        return 'API Call';
      case LogCategory.authentication:
        return 'Authentication';
      case LogCategory.dropletManagement:
        return 'Droplet Management';
      case LogCategory.serverManagement:
        return 'Server Management';
      case LogCategory.error:
        return 'Error';
      case LogCategory.system:
        return 'System';
      case LogCategory.security:
        return 'Security';
    }
  }
}

/// Represents a single log entry
class LogEntry {
  final String id;
  final DateTime timestamp;
  final LogLevel level;
  final LogCategory category;
  final String message;
  final String? details;
  final Map<String, dynamic>? metadata;
  final String? userId;
  final String? sessionId;

  const LogEntry({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.category,
    required this.message,
    this.details,
    this.metadata,
    this.userId,
    this.sessionId,
  });

  /// Create a LogEntry from JSON
  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      level: LogLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => LogLevel.info,
      ),
      category: LogCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => LogCategory.system,
      ),
      message: json['message'] as String,
      details: json['details'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      userId: json['userId'] as String?,
      sessionId: json['sessionId'] as String?,
    );
  }

  /// Convert LogEntry to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'category': category.name,
      'message': message,
      'details': details,
      'metadata': metadata,
      'userId': userId,
      'sessionId': sessionId,
    };
  }

  /// Create a copy of this LogEntry with updated fields
  LogEntry copyWith({
    String? id,
    DateTime? timestamp,
    LogLevel? level,
    LogCategory? category,
    String? message,
    String? details,
    Map<String, dynamic>? metadata,
    String? userId,
    String? sessionId,
  }) {
    return LogEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      level: level ?? this.level,
      category: category ?? this.category,
      message: message ?? this.message,
      details: details ?? this.details,
      metadata: metadata ?? this.metadata,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LogEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'LogEntry(id: $id, timestamp: $timestamp, level: $level, category: $category, message: $message)';
  }
}

/// Filter criteria for log entries
class LogFilter {
  final List<LogLevel>? levels;
  final List<LogCategory>? categories;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;
  final String? userId;
  final String? sessionId;

  const LogFilter({
    this.levels,
    this.categories,
    this.startDate,
    this.endDate,
    this.searchQuery,
    this.userId,
    this.sessionId,
  });

  /// Check if a log entry matches this filter
  bool matches(LogEntry entry) {
    if (levels != null && !levels!.contains(entry.level)) {
      return false;
    }

    if (categories != null && !categories!.contains(entry.category)) {
      return false;
    }

    if (startDate != null && entry.timestamp.isBefore(startDate!)) {
      return false;
    }

    if (endDate != null && entry.timestamp.isAfter(endDate!)) {
      return false;
    }

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      if (!entry.message.toLowerCase().contains(query) &&
          (entry.details?.toLowerCase().contains(query) != true)) {
        return false;
      }
    }

    if (userId != null && entry.userId != userId) {
      return false;
    }

    if (sessionId != null && entry.sessionId != sessionId) {
      return false;
    }

    return true;
  }

  /// Create a copy of this filter with updated fields
  LogFilter copyWith({
    List<LogLevel>? levels,
    List<LogCategory>? categories,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    String? userId,
    String? sessionId,
  }) {
    return LogFilter(
      levels: levels ?? this.levels,
      categories: categories ?? this.categories,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}
