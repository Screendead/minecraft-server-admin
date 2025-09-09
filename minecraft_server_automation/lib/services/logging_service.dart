import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:minecraft_server_automation/models/log_entry.dart';

/// Service for managing application logs
class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  static const String _logFileName = 'app_logs.json';
  static const int _maxLogEntries =
      10000; // Maximum number of log entries to keep
  static const int _maxFileSize = 10 * 1024 * 1024; // 10MB max file size

  final List<LogEntry> _logs = [];
  final List<VoidCallback> _listeners = [];
  String? _currentSessionId;
  String? _currentUserId;
  File? _logFile;
  bool _isInitialized = false;

  /// Initialize the logging service
  Future<void> initialize() async {
    // Prevent multiple initializations
    if (_isInitialized) {
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      _logFile = File('${directory.path}/$_logFileName');

      // Load existing logs
      await _loadLogs();

      // Generate session ID
      _currentSessionId = const Uuid().v4();

      // Mark as initialized
      _isInitialized = true;

      // Log initialization
      await logInfo(
        'Logging service initialized',
        category: LogCategory.system,
        metadata: {
          'sessionId': _currentSessionId,
          'maxLogEntries': _maxLogEntries,
          'maxFileSize': _maxFileSize,
        },
      );
    } catch (e) {
      debugPrint('Failed to initialize logging service: $e');
    }
  }

  /// Set the current user ID for logging context
  void setUserId(String? userId) {
    _currentUserId = userId;
  }

  /// Get the current session ID
  String? get currentSessionId => _currentSessionId;

  /// Get the current user ID
  String? get currentUserId => _currentUserId;

  /// Check if the logging service is initialized
  bool get isInitialized => _isInitialized;

  /// Add a listener for log updates
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Remove a listener
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners of log updates
  void _notifyListeners() {
    for (final listener in _listeners) {
      try {
        listener();
      } catch (e) {
        debugPrint('Error notifying log listener: $e');
      }
    }
  }

  /// Log a debug message
  Future<void> logDebug(
    String message, {
    LogCategory category = LogCategory.system,
    String? details,
    Map<String, dynamic>? metadata,
  }) async {
    await _log(LogLevel.debug, message, category, details, metadata);
  }

  /// Log an info message
  Future<void> logInfo(
    String message, {
    LogCategory category = LogCategory.system,
    String? details,
    Map<String, dynamic>? metadata,
  }) async {
    await _log(LogLevel.info, message, category, details, metadata);
  }

  /// Log a warning message
  Future<void> logWarning(
    String message, {
    LogCategory category = LogCategory.system,
    String? details,
    Map<String, dynamic>? metadata,
  }) async {
    await _log(LogLevel.warning, message, category, details, metadata);
  }

  /// Log an error message
  Future<void> logError(
    String message, {
    LogCategory category = LogCategory.error,
    String? details,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    final errorDetails = details ?? '';
    final errorMetadata = <String, dynamic>{
      ...?metadata,
      if (error != null) 'error': error.toString(),
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
    };

    await _log(LogLevel.error, message, category, errorDetails, errorMetadata);
  }

  /// Log a fatal error message
  Future<void> logFatal(
    String message, {
    LogCategory category = LogCategory.error,
    String? details,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    final errorDetails = details ?? '';
    final errorMetadata = <String, dynamic>{
      ...?metadata,
      if (error != null) 'error': error.toString(),
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
    };

    await _log(LogLevel.fatal, message, category, errorDetails, errorMetadata);
  }

  /// Log user interaction
  Future<void> logUserInteraction(
    String action, {
    String? details,
    Map<String, dynamic>? metadata,
  }) async {
    await _log(
      LogLevel.info,
      'User interaction: $action',
      LogCategory.userInteraction,
      details,
      metadata,
    );
  }

  /// Log API call
  Future<void> logApiCall(
    String endpoint,
    String method, {
    int? statusCode,
    Duration? duration,
    String? details,
    Map<String, dynamic>? metadata,
  }) async {
    final apiMetadata = <String, dynamic>{
      'endpoint': endpoint,
      'method': method,
      if (statusCode != null) 'statusCode': statusCode,
      if (duration != null) 'durationMs': duration.inMilliseconds,
      ...?metadata,
    };

    final level = statusCode != null && statusCode >= 400
        ? LogLevel.error
        : LogLevel.info;

    await _log(
      level,
      'API Call: $method $endpoint',
      LogCategory.apiCall,
      details,
      apiMetadata,
    );
  }

  /// Internal method to create and store log entries
  Future<void> _log(
    LogLevel level,
    String message,
    LogCategory category,
    String? details,
    Map<String, dynamic>? metadata,
  ) async {
    // Don't log if service is not initialized (except for initialization message itself)
    // In debug mode, allow logging even if not initialized to support testing
    if (!_isInitialized &&
        message != 'Logging service initialized' &&
        kReleaseMode) {
      debugPrint('LoggingService not initialized, skipping log: $message');
      return;
    }

    try {
      final logEntry = LogEntry(
        id: const Uuid().v4(),
        timestamp: DateTime.now(),
        level: level,
        category: category,
        message: message,
        details: details,
        metadata: metadata,
        userId: _currentUserId,
        sessionId: _currentSessionId,
      );

      _logs.add(logEntry);

      // Keep only the most recent logs
      if (_logs.length > _maxLogEntries) {
        _logs.removeRange(0, _logs.length - _maxLogEntries);
      }

      // Save to file
      await _saveLogs();

      // Notify listeners
      _notifyListeners();
    } catch (e) {
      debugPrint('Failed to log message: $e');
    }
  }

  /// Get all logs (sorted by timestamp, most recent first)
  List<LogEntry> getLogs() {
    final sortedLogs = List<LogEntry>.from(_logs);
    sortedLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return List.unmodifiable(sortedLogs);
  }

  /// Get filtered logs (sorted by timestamp, most recent first)
  List<LogEntry> getFilteredLogs(LogFilter filter) {
    final filteredLogs = _logs.where(filter.matches).toList();
    filteredLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return filteredLogs;
  }

  /// Get logs by level (sorted by timestamp, most recent first)
  List<LogEntry> getLogsByLevel(LogLevel level) {
    final levelLogs = _logs.where((log) => log.level == level).toList();
    levelLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return levelLogs;
  }

  /// Get logs by category (sorted by timestamp, most recent first)
  List<LogEntry> getLogsByCategory(LogCategory category) {
    final categoryLogs =
        _logs.where((log) => log.category == category).toList();
    categoryLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return categoryLogs;
  }

  /// Get recent logs (last N entries, sorted by timestamp, most recent first)
  List<LogEntry> getRecentLogs(int count) {
    final sortedLogs = List<LogEntry>.from(_logs);
    sortedLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedLogs.take(count).toList();
  }

  /// Clear all logs
  Future<void> clearLogs() async {
    _logs.clear();
    await _saveLogs();
    _notifyListeners();
  }

  /// Clear logs older than specified days
  Future<void> clearOldLogs(int days) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    _logs.removeWhere((log) => log.timestamp.isBefore(cutoffDate));
    await _saveLogs();
    _notifyListeners();
  }

  /// Export logs to JSON
  Future<String> exportLogsToJson({LogFilter? filter}) async {
    final logsToExport = filter != null ? getFilteredLogs(filter) : _logs;
    final jsonData = {
      'exportedAt': DateTime.now().toIso8601String(),
      'totalLogs': logsToExport.length,
      'logs': logsToExport.map((log) => log.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(jsonData);
  }

  /// Export logs to CSV
  Future<String> exportLogsToCsv({LogFilter? filter}) async {
    final logsToExport = filter != null ? getFilteredLogs(filter) : _logs;

    final buffer = StringBuffer();
    buffer
        .writeln('Timestamp,Level,Category,Message,Details,User ID,Session ID');

    for (final log in logsToExport) {
      final timestamp = log.timestamp.toIso8601String();
      final level = log.level.name;
      final category = log.category.name;
      final message = _escapeCsv(log.message);
      final details = _escapeCsv(log.details ?? '');
      final userId = log.userId ?? '';
      final sessionId = log.sessionId ?? '';

      buffer.writeln(
          '$timestamp,$level,$category,$message,$details,$userId,$sessionId');
    }

    return buffer.toString();
  }

  /// Export logs to plain text
  Future<String> exportLogsToText({LogFilter? filter}) async {
    final logsToExport = filter != null ? getFilteredLogs(filter) : _logs;

    final buffer = StringBuffer();
    buffer.writeln('=== LOG EXPORT ===');
    buffer.writeln('Exported at: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Total logs: ${logsToExport.length}');
    buffer.writeln('');

    for (final log in logsToExport) {
      buffer.writeln(
          '${log.timestamp.toIso8601String()} [${log.level.displayName}] ${log.category.displayName}');
      buffer.writeln('  ${log.message}');
      if (log.details != null && log.details!.isNotEmpty) {
        buffer.writeln('  Details: ${log.details}');
      }
      if (log.metadata != null && log.metadata!.isNotEmpty) {
        buffer.writeln('  Metadata: ${log.metadata}');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }

  /// Load logs from file
  Future<void> _loadLogs() async {
    if (_logFile == null || !await _logFile!.exists()) {
      return;
    }

    try {
      final content = await _logFile!.readAsString();
      if (content.isEmpty) return;

      final jsonData = json.decode(content);
      if (jsonData is List) {
        _logs.clear();
        for (final item in jsonData) {
          if (item is Map<String, dynamic>) {
            _logs.add(LogEntry.fromJson(item));
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to load logs: $e');
    }
  }

  /// Save logs to file
  Future<void> _saveLogs() async {
    if (_logFile == null) return;

    try {
      final jsonData = _logs.map((log) => log.toJson()).toList();
      final content = const JsonEncoder.withIndent('  ').convert(jsonData);

      await _logFile!.writeAsString(content);

      // Check file size and rotate if necessary
      final fileSize = await _logFile!.length();
      if (fileSize > _maxFileSize) {
        await _rotateLogFile();
      }
    } catch (e) {
      debugPrint('Failed to save logs: $e');
    }
  }

  /// Rotate log file when it gets too large
  Future<void> _rotateLogFile() async {
    if (_logFile == null) return;

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final rotatedFileName = '${_logFile!.path}.$timestamp';

      await _logFile!.copy(rotatedFileName);

      // Keep only the most recent logs
      final keepCount = _maxLogEntries ~/ 2;
      if (_logs.length > keepCount) {
        _logs.removeRange(0, _logs.length - keepCount);
      }

      await _logFile!.writeAsString(const JsonEncoder.withIndent('  ').convert(
        _logs.map((log) => log.toJson()).toList(),
      ));
    } catch (e) {
      debugPrint('Failed to rotate log file: $e');
    }
  }

  /// Escape CSV field
  String _escapeCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
