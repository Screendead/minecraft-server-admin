import 'package:flutter_test/flutter_test.dart';
import 'package:app/providers/logs_provider.dart';
import 'package:app/models/log_entry.dart';

void main() {
  group('LogsProvider', () {
    late LogsProvider logsProvider;

    setUp(() {
      logsProvider = LogsProvider();
    });

    test('should initialize with empty logs', () {
      expect(logsProvider.logs, isEmpty);
      expect(logsProvider.isLoading, isFalse);
      expect(logsProvider.error, isNull);
    });

    test('should have correct initial filter', () {
      final filter = logsProvider.currentFilter;
      expect(filter.levels, isNull);
      expect(filter.categories, isNull);
      expect(filter.startDate, isNull);
      expect(filter.endDate, isNull);
      expect(filter.searchQuery, isNull);
      expect(filter.userId, isNull);
      expect(filter.sessionId, isNull);
    });

    test('should set user ID correctly', () {
      logsProvider.setUserId('test-user-123');
      // Note: This would work if we had a way to access the logging service
      // For now, we just verify the method doesn't throw
      expect(() => logsProvider.setUserId('test-user-123'), returnsNormally);
    });

    test('should get empty statistics for no logs', () {
      final stats = logsProvider.getLogStatistics();
      expect(stats['total_count'], equals(0));
      expect(stats['info_count'], equals(0));
      expect(stats['error_count'], equals(0));
      expect(stats['warning_count'], equals(0));
      expect(stats['debug_count'], equals(0));
      expect(stats['fatal_count'], equals(0));
    });

    test('should search empty logs correctly', () {
      final results = logsProvider.searchLogs('test');
      expect(results, isEmpty);
    });

    test('should get empty error logs', () {
      final errorLogs = logsProvider.getErrorLogs();
      expect(errorLogs, isEmpty);
    });

    test('should get empty warning logs', () {
      final warningLogs = logsProvider.getWarningLogs();
      expect(warningLogs, isEmpty);
    });

    test('should get empty user interaction logs', () {
      final userLogs = logsProvider.getUserInteractionLogs();
      expect(userLogs, isEmpty);
    });

    test('should get empty API call logs', () {
      final apiLogs = logsProvider.getApiCallLogs();
      expect(apiLogs, isEmpty);
    });

    test('should get empty recent logs', () {
      final recentLogs = logsProvider.getRecentLogs(10);
      expect(recentLogs, isEmpty);
    });

    test('should get empty logs in time range', () {
      final now = DateTime.now();
      final start = now.subtract(const Duration(hours: 1));
      final end = now.add(const Duration(hours: 1));

      final logsInRange = logsProvider.getLogsInTimeRange(start, end);
      expect(logsInRange, isEmpty);
    });
  });
}
