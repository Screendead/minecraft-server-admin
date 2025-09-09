import 'package:flutter/foundation.dart';
import 'package:minecraft_server_automation/models/log_entry.dart';
import 'package:minecraft_server_automation/services/logging_service.dart';

/// Provider for managing log state and operations
class LogsProvider extends ChangeNotifier {
  final LoggingService _loggingService = LoggingService();

  List<LogEntry> _logs = [];
  LogFilter _currentFilter = const LogFilter();
  bool _isLoading = false;
  String? _error;

  /// Get all logs
  List<LogEntry> get logs => _logs;

  /// Get current filter
  LogFilter get currentFilter => _currentFilter;

  /// Get loading state
  bool get isLoading => _isLoading;

  /// Get error state
  String? get error => _error;

  /// Initialize the provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // LoggingService is already initialized in main.dart
      // Just add listener and refresh logs
      _loggingService.addListener(_onLogsUpdated);
      await refreshLogs();
    } catch (e) {
      _setError('Failed to initialize logging: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set user ID for logging context
  void setUserId(String? userId) {
    _loggingService.setUserId(userId);
  }

  /// Refresh logs from the service
  Future<void> refreshLogs() async {
    try {
      _logs = _loggingService.getLogs();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to refresh logs: $e');
    }
  }

  /// Apply filter to logs
  void applyFilter(LogFilter filter) {
    _currentFilter = filter;
    _logs = _loggingService.getFilteredLogs(filter);
    _clearError();
    notifyListeners();
  }

  /// Clear current filter
  void clearFilter() {
    _currentFilter = const LogFilter();
    _logs = _loggingService.getLogs();
    _clearError();
    notifyListeners();
  }

  /// Get logs by level
  List<LogEntry> getLogsByLevel(LogLevel level) {
    return _loggingService.getLogsByLevel(level);
  }

  /// Get logs by category
  List<LogEntry> getLogsByCategory(LogCategory category) {
    return _loggingService.getLogsByCategory(category);
  }

  /// Get recent logs
  List<LogEntry> getRecentLogs(int count) {
    return _loggingService.getRecentLogs(count);
  }

  /// Get log statistics
  Map<String, int> getLogStatistics() {
    final stats = <String, int>{};

    // Count by level
    for (final level in LogLevel.values) {
      stats['${level.name}_count'] =
          _logs.where((log) => log.level == level).length;
    }

    // Count by category
    for (final category in LogCategory.values) {
      stats['${category.name}_count'] =
          _logs.where((log) => log.category == category).length;
    }

    // Total count
    stats['total_count'] = _logs.length;

    return stats;
  }

  /// Clear all logs
  Future<void> clearAllLogs() async {
    _setLoading(true);
    try {
      await _loggingService.clearLogs();
      // Refresh logs from service instead of clearing the unmodifiable list
      await refreshLogs();
    } catch (e) {
      _setError('Failed to clear logs: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Clear old logs
  Future<void> clearOldLogs(int days) async {
    _setLoading(true);
    try {
      await _loggingService.clearOldLogs(days);
      await refreshLogs();
    } catch (e) {
      _setError('Failed to clear old logs: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Export logs to JSON
  Future<String> exportToJson({LogFilter? filter}) async {
    try {
      return await _loggingService.exportLogsToJson(filter: filter);
    } catch (e) {
      _setError('Failed to export logs to JSON: $e');
      rethrow;
    }
  }

  /// Export logs to CSV
  Future<String> exportToCsv({LogFilter? filter}) async {
    try {
      return await _loggingService.exportLogsToCsv(filter: filter);
    } catch (e) {
      _setError('Failed to export logs to CSV: $e');
      rethrow;
    }
  }

  /// Export logs to text
  Future<String> exportToText({LogFilter? filter}) async {
    try {
      return await _loggingService.exportLogsToText(filter: filter);
    } catch (e) {
      _setError('Failed to export logs to text: $e');
      rethrow;
    }
  }

  /// Search logs (sorted by timestamp, most recent first)
  List<LogEntry> searchLogs(String query) {
    if (query.isEmpty) return _logs;

    final searchQuery = query.toLowerCase();
    final results = _logs.where((log) {
      return log.message.toLowerCase().contains(searchQuery) ||
          (log.details?.toLowerCase().contains(searchQuery) ?? false);
    }).toList();

    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return results;
  }

  /// Get logs for a specific time range (sorted by timestamp, most recent first)
  List<LogEntry> getLogsInTimeRange(DateTime start, DateTime end) {
    final results = _logs.where((log) {
      return log.timestamp.isAfter(start) && log.timestamp.isBefore(end);
    }).toList();

    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return results;
  }

  /// Get error logs only (sorted by timestamp, most recent first)
  List<LogEntry> getErrorLogs() {
    final results = _logs
        .where(
            (log) => log.level == LogLevel.error || log.level == LogLevel.fatal)
        .toList();

    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return results;
  }

  /// Get warning logs only (sorted by timestamp, most recent first)
  List<LogEntry> getWarningLogs() {
    final results =
        _logs.where((log) => log.level == LogLevel.warning).toList();
    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return results;
  }

  /// Get user interaction logs (sorted by timestamp, most recent first)
  List<LogEntry> getUserInteractionLogs() {
    final results = _logs
        .where((log) => log.category == LogCategory.userInteraction)
        .toList();

    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return results;
  }

  /// Get API call logs (sorted by timestamp, most recent first)
  List<LogEntry> getApiCallLogs() {
    final results =
        _logs.where((log) => log.category == LogCategory.apiCall).toList();
    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return results;
  }

  /// Callback when logs are updated
  void _onLogsUpdated() {
    if (_currentFilter.levels != null ||
        _currentFilter.categories != null ||
        _currentFilter.startDate != null ||
        _currentFilter.endDate != null ||
        _currentFilter.searchQuery != null ||
        _currentFilter.userId != null ||
        _currentFilter.sessionId != null) {
      // Reapply current filter
      _logs = _loggingService.getFilteredLogs(_currentFilter);
    } else {
      // No filter applied, get all logs
      _logs = _loggingService.getLogs();
    }
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error state
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error state
  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    _loggingService.removeListener(_onLogsUpdated);
    super.dispose();
  }
}
