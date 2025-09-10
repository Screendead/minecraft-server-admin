import 'package:flutter/foundation.dart';
import 'package:minecraft_server_automation/models/log_entry.dart';

/// Interface for logging services
/// This allows for easy mocking and testing
abstract class LoggingServiceInterface {
  /// Initialize the logging service
  Future<void> initialize();

  /// Set the current user ID for logging context
  void setUserId(String? userId);

  /// Get the current session ID
  String? get currentSessionId;

  /// Get the current user ID
  String? get currentUserId;

  /// Check if the logging service is initialized
  bool get isInitialized;

  /// Add a listener for log updates
  void addListener(VoidCallback listener);

  /// Remove a listener
  void removeListener(VoidCallback listener);

  /// Log a debug message
  Future<void> logDebug(
    String message, {
    LogCategory category = LogCategory.system,
    String? details,
    Map<String, dynamic>? metadata,
  });

  /// Log an info message
  Future<void> logInfo(
    String message, {
    LogCategory category = LogCategory.system,
    String? details,
    Map<String, dynamic>? metadata,
  });

  /// Log a warning message
  Future<void> logWarning(
    String message, {
    LogCategory category = LogCategory.system,
    String? details,
    Map<String, dynamic>? metadata,
  });

  /// Log an error message
  Future<void> logError(
    String message, {
    LogCategory category = LogCategory.error,
    String? details,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  });

  /// Log a fatal error message
  Future<void> logFatal(
    String message, {
    LogCategory category = LogCategory.error,
    String? details,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  });

  /// Log API call
  Future<void> logApiCall(
    String endpoint,
    String method, {
    int? statusCode,
    Duration? duration,
    String? details,
    Map<String, dynamic>? metadata,
  });

  /// Get all logs
  List<LogEntry> getLogs();

  /// Get logs by category
  List<LogEntry> getLogsByCategory(LogCategory category);

  /// Get logs by level
  List<LogEntry> getLogsByLevel(LogLevel level);

  /// Clear all logs
  Future<void> clearLogs();

  /// Clear old logs
  Future<void> clearOldLogs(int days);

  /// Export logs to JSON
  Future<String> exportLogsToJson({LogFilter? filter});

  /// Export logs to CSV
  Future<String> exportLogsToCsv({LogFilter? filter});

  /// Export logs to text
  Future<String> exportLogsToText({LogFilter? filter});

  /// Get filtered logs
  List<LogEntry> getFilteredLogs(LogFilter filter);

  /// Get recent logs
  List<LogEntry> getRecentLogs(int count);
}
