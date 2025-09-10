import 'package:flutter/foundation.dart';
import 'package:minecraft_server_automation/common/interfaces/logging_service.dart';
import 'package:minecraft_server_automation/services/logging_service.dart' as impl;
import 'package:minecraft_server_automation/models/log_entry.dart';

/// Adapter to make LoggingService conform to LoggingServiceInterface
/// This allows the service to be used with dependency injection
class LoggingServiceAdapter implements LoggingServiceInterface {
  final impl.LoggingService _loggingService;

  LoggingServiceAdapter(this._loggingService);

  @override
  Future<void> initialize() async {
    await _loggingService.initialize();
  }

  @override
  void setUserId(String? userId) {
    _loggingService.setUserId(userId);
  }

  @override
  String? get currentSessionId => _loggingService.currentSessionId;

  @override
  String? get currentUserId => _loggingService.currentUserId;

  @override
  bool get isInitialized => _loggingService.isInitialized;

  @override
  void addListener(VoidCallback listener) {
    _loggingService.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _loggingService.removeListener(listener);
  }

  @override
  Future<void> logDebug(
    String message, {
    LogCategory category = LogCategory.system,
    String? details,
    Map<String, dynamic>? metadata,
  }) async {
    await _loggingService.logDebug(
      message,
      category: category,
      details: details,
      metadata: metadata,
    );
  }

  @override
  Future<void> logInfo(
    String message, {
    LogCategory category = LogCategory.system,
    String? details,
    Map<String, dynamic>? metadata,
  }) async {
    await _loggingService.logInfo(
      message,
      category: category,
      details: details,
      metadata: metadata,
    );
  }

  @override
  Future<void> logWarning(
    String message, {
    LogCategory category = LogCategory.system,
    String? details,
    Map<String, dynamic>? metadata,
  }) async {
    await _loggingService.logWarning(
      message,
      category: category,
      details: details,
      metadata: metadata,
    );
  }

  @override
  Future<void> logError(
    String message, {
    LogCategory category = LogCategory.error,
    String? details,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    await _loggingService.logError(
      message,
      category: category,
      details: details,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  Future<void> logFatal(
    String message, {
    LogCategory category = LogCategory.error,
    String? details,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    await _loggingService.logFatal(
      message,
      category: category,
      details: details,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  Future<void> logApiCall(
    String endpoint,
    String method, {
    int? statusCode,
    Duration? duration,
    String? details,
    Map<String, dynamic>? metadata,
  }) async {
    await _loggingService.logApiCall(
      endpoint,
      method,
      statusCode: statusCode,
      duration: duration,
      details: details,
      metadata: metadata,
    );
  }

  @override
  List<LogEntry> getLogs() {
    return _loggingService.getLogs();
  }

  @override
  List<LogEntry> getLogsByCategory(LogCategory category) {
    return _loggingService.getLogsByCategory(category);
  }

  @override
  List<LogEntry> getLogsByLevel(LogLevel level) {
    return _loggingService.getLogsByLevel(level);
  }

  @override
  Future<void> clearLogs() async {
    await _loggingService.clearLogs();
  }

  @override
  Future<void> clearOldLogs(int days) async {
    await _loggingService.clearOldLogs(days);
  }

  @override
  Future<String> exportLogsToJson({LogFilter? filter}) async {
    return await _loggingService.exportLogsToJson(filter: filter);
  }

  @override
  Future<String> exportLogsToCsv({LogFilter? filter}) async {
    return await _loggingService.exportLogsToCsv(filter: filter);
  }

  @override
  Future<String> exportLogsToText({LogFilter? filter}) async {
    return await _loggingService.exportLogsToText(filter: filter);
  }

  @override
  List<LogEntry> getFilteredLogs(LogFilter filter) {
    return _loggingService.getFilteredLogs(filter);
  }

  @override
  List<LogEntry> getRecentLogs(int count) {
    return _loggingService.getRecentLogs(count);
  }
}
