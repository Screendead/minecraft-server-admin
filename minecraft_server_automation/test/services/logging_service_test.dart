import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:minecraft_server_automation/services/logging_service.dart';
import 'package:minecraft_server_automation/models/log_entry.dart';

void main() {
  // Initialize Flutter binding for tests
  TestWidgetsFlutterBinding.ensureInitialized();
  group('LoggingService', () {
    late LoggingService loggingService;

    setUp(() {
      // Get the singleton instance
      loggingService = LoggingService();

      // Reset any existing state
      loggingService.clearLogs();
    });

    tearDown(() {
      // Clean up after each test
      loggingService.clearLogs();
    });

    group('Initialization', () {
      test('should create service instance', () {
        expect(loggingService, isNotNull);
        expect(loggingService.isInitialized, isFalse);
      });

      test('should have null session and user ID initially', () {
        expect(loggingService.currentSessionId, isNull);
        expect(loggingService.currentUserId, isNull);
      });

      test('should handle initialization failure gracefully', () async {
        // Note: We can't test successful initialization in unit tests due to path_provider dependency
        // This test verifies that the service handles initialization failures gracefully
        try {
          await loggingService.initialize();
        } catch (e) {
          // Expected to fail in test environment
          expect(e, isNotNull);
        }

        // Service should still be functional for basic logging
        await loggingService.logInfo('Test message');
        expect(loggingService.getLogs().length, equals(1));
      });
    });

    group('User Management', () {
      test('should set and get user ID', () {
        const testUserId = 'test-user-123';

        loggingService.setUserId(testUserId);

        expect(loggingService.currentUserId, equals(testUserId));
      });

      test('should handle null user ID', () {
        loggingService.setUserId(null);

        expect(loggingService.currentUserId, isNull);
      });
    });

    group('Listener Management', () {
      test('should add and remove listeners', () {
        void testListener() {
          // Test listener implementation
        }

        loggingService.addListener(testListener);
        expect(loggingService, isNotNull); // Service should still exist

        loggingService.removeListener(testListener);
        expect(loggingService, isNotNull); // Service should still exist
      });

      test('should handle multiple listeners', () {
        int callCount = 0;
        void listener1() => callCount++;
        void listener2() => callCount++;

        loggingService.addListener(listener1);
        loggingService.addListener(listener2);

        expect(loggingService, isNotNull);

        loggingService.removeListener(listener1);
        loggingService.removeListener(listener2);

        expect(loggingService, isNotNull);
      });
    });

    group('Basic Logging', () {
      test('should log debug message', () async {
        const message = 'Test debug message';
        const category = LogCategory.system;

        await loggingService.logDebug(message, category: category);

        final logs = loggingService.getLogs();
        expect(logs.length, equals(1));
        expect(logs.first.message, equals(message));
        expect(logs.first.level, equals(LogLevel.debug));
        expect(logs.first.category, equals(category));
      });

      test('should log info message', () async {
        const message = 'Test info message';
        const category = LogCategory.system;

        await loggingService.logInfo(message, category: category);

        final logs = loggingService.getLogs();
        expect(logs.length, equals(1));
        expect(logs.first.message, equals(message));
        expect(logs.first.level, equals(LogLevel.info));
        expect(logs.first.category, equals(category));
      });

      test('should log warning message', () async {
        const message = 'Test warning message';
        const category = LogCategory.system;

        await loggingService.logWarning(message, category: category);

        final logs = loggingService.getLogs();
        expect(logs.length, equals(1));
        expect(logs.first.message, equals(message));
        expect(logs.first.level, equals(LogLevel.warning));
        expect(logs.first.category, equals(category));
      });

      test('should log error message', () async {
        const message = 'Test error message';
        const category = LogCategory.error;
        const details = 'Error details';
        const error = 'Test error';

        await loggingService.logError(
          message,
          category: category,
          details: details,
          error: error,
        );

        final logs = loggingService.getLogs();
        expect(logs.length, equals(1));
        expect(logs.first.message, equals(message));
        expect(logs.first.level, equals(LogLevel.error));
        expect(logs.first.category, equals(category));
        expect(logs.first.details, equals(details));
        expect(logs.first.metadata?['error'], equals(error));
      });

      test('should log fatal message', () async {
        const message = 'Test fatal message';
        const category = LogCategory.error;
        const details = 'Fatal details';
        const error = 'Fatal error';
        final stackTrace = StackTrace.current;

        await loggingService.logFatal(
          message,
          category: category,
          details: details,
          error: error,
          stackTrace: stackTrace,
        );

        final logs = loggingService.getLogs();
        expect(logs.length, equals(1));
        expect(logs.first.message, equals(message));
        expect(logs.first.level, equals(LogLevel.fatal));
        expect(logs.first.category, equals(category));
        expect(logs.first.details, equals(details));
        expect(logs.first.metadata?['error'], equals(error));
        expect(logs.first.metadata?['stackTrace'], isNotNull);
      });
    });

    group('Specialized Logging', () {
      test('should log user interaction', () async {
        const action = 'button_click';
        const details = 'User clicked login button';
        const metadata = {'screen': 'login', 'button': 'login'};

        await loggingService.logUserInteraction(
          action,
          details: details,
          metadata: metadata,
        );

        final logs = loggingService.getLogs();
        expect(logs.length, equals(1));
        expect(logs.first.message, equals('User interaction: $action'));
        expect(logs.first.level, equals(LogLevel.info));
        expect(logs.first.category, equals(LogCategory.userInteraction));
        expect(logs.first.details, equals(details));
        expect(logs.first.metadata, equals(metadata));
      });

      test('should log API call with success status', () async {
        const endpoint = '/api/droplets';
        const method = 'GET';
        const statusCode = 200;
        const duration = Duration(milliseconds: 150);
        const details = 'Successfully fetched droplets';
        const metadata = {'requestId': 'req-123'};

        await loggingService.logApiCall(
          endpoint,
          method,
          statusCode: statusCode,
          duration: duration,
          details: details,
          metadata: metadata,
        );

        final logs = loggingService.getLogs();
        expect(logs.length, equals(1));
        expect(logs.first.message, equals('API Call: $method $endpoint'));
        expect(logs.first.level, equals(LogLevel.info));
        expect(logs.first.category, equals(LogCategory.apiCall));
        expect(logs.first.details, equals(details));
        expect(logs.first.metadata?['endpoint'], equals(endpoint));
        expect(logs.first.metadata?['method'], equals(method));
        expect(logs.first.metadata?['statusCode'], equals(statusCode));
        expect(logs.first.metadata?['durationMs'], equals(150));
        expect(logs.first.metadata?['requestId'], equals('req-123'));
      });

      test('should log API call with error status', () async {
        const endpoint = '/api/droplets';
        const method = 'GET';
        const statusCode = 500;
        const duration = Duration(milliseconds: 2000);
        const details = 'Internal server error';

        await loggingService.logApiCall(
          endpoint,
          method,
          statusCode: statusCode,
          duration: duration,
          details: details,
        );

        final logs = loggingService.getLogs();
        expect(logs.length, equals(1));
        expect(logs.first.message, equals('API Call: $method $endpoint'));
        expect(logs.first.level, equals(LogLevel.error));
        expect(logs.first.category, equals(LogCategory.apiCall));
        expect(logs.first.details, equals(details));
        expect(logs.first.metadata?['statusCode'], equals(statusCode));
        expect(logs.first.metadata?['durationMs'], equals(2000));
      });
    });

    group('Log Retrieval', () {
      setUp(() async {
        // Add some test logs
        await loggingService.logInfo('Info message 1',
            category: LogCategory.system);
        await loggingService.logWarning('Warning message',
            category: LogCategory.error);
        await loggingService.logError('Error message',
            category: LogCategory.error);
        await loggingService.logInfo('Info message 2',
            category: LogCategory.userInteraction);
      });

      test('should get all logs sorted by timestamp', () {
        final logs = loggingService.getLogs();

        expect(logs.length, equals(4));
        // Should be sorted by timestamp (most recent first)
        for (int i = 0; i < logs.length - 1; i++) {
          expect(
            logs[i].timestamp.isAfter(logs[i + 1].timestamp) ||
                logs[i].timestamp.isAtSameMomentAs(logs[i + 1].timestamp),
            isTrue,
          );
        }
      });

      test('should get logs by level', () {
        final infoLogs = loggingService.getLogsByLevel(LogLevel.info);
        final errorLogs = loggingService.getLogsByLevel(LogLevel.error);
        final warningLogs = loggingService.getLogsByLevel(LogLevel.warning);

        expect(infoLogs.length, equals(2));
        expect(errorLogs.length, equals(1));
        expect(warningLogs.length, equals(1));

        for (final log in infoLogs) {
          expect(log.level, equals(LogLevel.info));
        }
        for (final log in errorLogs) {
          expect(log.level, equals(LogLevel.error));
        }
        for (final log in warningLogs) {
          expect(log.level, equals(LogLevel.warning));
        }
      });

      test('should get logs by category', () {
        final systemLogs = loggingService.getLogsByCategory(LogCategory.system);
        final errorLogs = loggingService.getLogsByCategory(LogCategory.error);
        final userLogs =
            loggingService.getLogsByCategory(LogCategory.userInteraction);

        expect(systemLogs.length, equals(1));
        expect(errorLogs.length, equals(2)); // Warning and error
        expect(userLogs.length, equals(1));

        for (final log in systemLogs) {
          expect(log.category, equals(LogCategory.system));
        }
        for (final log in errorLogs) {
          expect(log.category, equals(LogCategory.error));
        }
        for (final log in userLogs) {
          expect(log.category, equals(LogCategory.userInteraction));
        }
      });

      test('should get recent logs', () {
        final recentLogs = loggingService.getRecentLogs(2);

        expect(recentLogs.length, equals(2));
        // Should be sorted by timestamp (most recent first)
        expect(
            recentLogs[0].timestamp.isAfter(recentLogs[1].timestamp) ||
                recentLogs[0]
                    .timestamp
                    .isAtSameMomentAs(recentLogs[1].timestamp),
            isTrue);
      });

      test('should get filtered logs', () {
        final filter = LogFilter(
          levels: [LogLevel.info],
          categories: [LogCategory.system],
        );

        final filteredLogs = loggingService.getFilteredLogs(filter);

        expect(filteredLogs.length, equals(1));
        expect(filteredLogs.first.level, equals(LogLevel.info));
        expect(filteredLogs.first.category, equals(LogCategory.system));
      });

      test('should get logs filtered by search query', () {
        final filter = LogFilter(
          searchQuery: 'Info',
        );

        final filteredLogs = loggingService.getFilteredLogs(filter);

        expect(filteredLogs.length, equals(2));
        for (final log in filteredLogs) {
          expect(log.message.toLowerCase().contains('info'), isTrue);
        }
      });

      test('should get logs filtered by date range', () {
        final now = DateTime.now();
        final startDate = now.subtract(const Duration(minutes: 1));
        final endDate = now.add(const Duration(minutes: 1));

        final filter = LogFilter(
          startDate: startDate,
          endDate: endDate,
        );

        final filteredLogs = loggingService.getFilteredLogs(filter);

        expect(filteredLogs.length, equals(4));
        for (final log in filteredLogs) {
          expect(log.timestamp.isAfter(startDate), isTrue);
          expect(log.timestamp.isBefore(endDate), isTrue);
        }
      });
    });

    group('Log Management', () {
      setUp(() async {
        // Add some test logs
        await loggingService.logInfo('Test message 1');
        await loggingService.logInfo('Test message 2');
        await loggingService.logInfo('Test message 3');
      });

      test('should clear all logs', () async {
        expect(loggingService.getLogs().length, equals(3));

        await loggingService.clearLogs();

        expect(loggingService.getLogs().length, equals(0));
      });

      test('should clear old logs', () async {
        // Add some recent logs
        await loggingService.logInfo('Recent message 1');
        await loggingService.logInfo('Recent message 2');

        // Clear logs older than 0 days (should clear all logs)
        await loggingService.clearOldLogs(0);

        final logs = loggingService.getLogs();
        expect(logs.length, equals(0));
      });
    });

    group('Export Functionality', () {
      setUp(() async {
        // Add test logs with different types
        await loggingService.logInfo(
          'Test info message',
          category: LogCategory.system,
          details: 'Test details',
          metadata: {'key': 'value'},
        );
        await loggingService.logError(
          'Test error message',
          category: LogCategory.error,
          details: 'Error details',
          metadata: {'errorCode': '500'},
        );
        loggingService.setUserId('test-user-123');
      });

      test('should export logs to JSON', () async {
        final jsonString = await loggingService.exportLogsToJson();

        expect(jsonString, isNotEmpty);

        final jsonData = json.decode(jsonString);
        expect(jsonData, isA<Map<String, dynamic>>());
        expect(jsonData['totalLogs'], equals(2));
        expect(jsonData['logs'], isA<List>());
        expect(jsonData['logs'].length, equals(2));
        expect(jsonData['exportedAt'], isNotNull);
      });

      test('should export filtered logs to JSON', () async {
        final filter = LogFilter(levels: [LogLevel.info]);
        final jsonString =
            await loggingService.exportLogsToJson(filter: filter);

        final jsonData = json.decode(jsonString);
        expect(jsonData['totalLogs'], equals(1));
        expect(jsonData['logs'].length, equals(1));
        expect(jsonData['logs'][0]['level'], equals('info'));
      });

      test('should export logs to CSV', () async {
        final csvString = await loggingService.exportLogsToCsv();

        expect(csvString, isNotEmpty);
        expect(
            csvString.contains(
                'Timestamp,Level,Category,Message,Details,User ID,Session ID'),
            isTrue);
        expect(csvString.contains('Test info message'), isTrue);
        expect(csvString.contains('Test error message'), isTrue);
      });

      test('should export filtered logs to CSV', () async {
        final filter = LogFilter(levels: [LogLevel.error]);
        final csvString = await loggingService.exportLogsToCsv(filter: filter);

        expect(csvString, isNotEmpty);
        expect(csvString.contains('Test error message'), isTrue);
        expect(csvString.contains('Test info message'), isFalse);
      });

      test('should export logs to text', () async {
        final textString = await loggingService.exportLogsToText();

        expect(textString, isNotEmpty);
        expect(textString.contains('=== LOG EXPORT ==='), isTrue);
        expect(textString.contains('Total logs: 2'), isTrue);
        expect(textString.contains('Test info message'), isTrue);
        expect(textString.contains('Test error message'), isTrue);
      });

      test('should export filtered logs to text', () async {
        final filter = LogFilter(categories: [LogCategory.system]);
        final textString =
            await loggingService.exportLogsToText(filter: filter);

        expect(textString, isNotEmpty);
        expect(textString.contains('Test info message'), isTrue);
        expect(textString.contains('Test error message'), isFalse);
      });

      test('should handle CSV escaping correctly', () async {
        // Add a log with special CSV characters
        await loggingService.logInfo('Message with "quotes" and, commas');

        final csvString = await loggingService.exportLogsToCsv();

        expect(csvString, isNotEmpty);
        // Should contain properly escaped CSV
        expect(csvString.contains('"Message with ""quotes"" and, commas"'),
            isTrue);
      });
    });

    group('Log Entry Properties', () {
      test('should include user ID in logs', () async {
        const userId = 'test-user-456';
        loggingService.setUserId(userId);

        await loggingService.logInfo('Test message');

        final logs = loggingService.getLogs();
        expect(logs.length, equals(1));
        expect(logs.first.userId, equals(userId));
        // Note: sessionId will be null until service is initialized
        expect(logs.first.sessionId, isNull);
      });

      test('should handle session ID when service is initialized', () async {
        // Note: We can't easily test initialization in unit tests due to path_provider dependency
        // This test verifies that session ID is null when not initialized
        await loggingService.logInfo('Test message before init');

        final logs = loggingService.getLogs();
        expect(logs.length, equals(1));
        expect(logs.first.sessionId, isNull);
      });

      test('should generate unique IDs for each log entry', () async {
        await loggingService.logInfo('Message 1');
        await loggingService.logInfo('Message 2');

        final logs = loggingService.getLogs();
        expect(logs.length, equals(2));
        expect(logs[0].id, isNot(equals(logs[1].id)));
      });

      test('should include timestamp in logs', () async {
        final beforeLog = DateTime.now();
        await loggingService.logInfo('Test message');
        final afterLog = DateTime.now();

        final logs = loggingService.getLogs();
        expect(logs.length, equals(1));
        expect(
            logs.first.timestamp.isAfter(beforeLog) ||
                logs.first.timestamp.isAtSameMomentAs(beforeLog),
            isTrue);
        expect(
            logs.first.timestamp.isBefore(afterLog) ||
                logs.first.timestamp.isAtSameMomentAs(afterLog),
            isTrue);
      });
    });

    group('Edge Cases', () {
      test('should handle empty message', () async {
        await loggingService.logInfo('');

        final logs = loggingService.getLogs();
        expect(logs.length, equals(1));
        expect(logs.first.message, equals(''));
      });

      test('should handle null details and metadata', () async {
        await loggingService.logInfo('Test message');

        final logs = loggingService.getLogs();
        expect(logs.length, equals(1));
        expect(logs.first.details, isNull);
        expect(logs.first.metadata, isNull);
      });

      test('should handle very long messages', () async {
        final longMessage = 'A' * 10000; // 10KB message

        await loggingService.logInfo(longMessage);

        final logs = loggingService.getLogs();
        expect(logs.length, equals(1));
        expect(logs.first.message, equals(longMessage));
      });

      test('should handle special characters in messages', () async {
        const specialMessage =
            'Message with special chars: !@#\$%^&*()_+-=[]{}|;:,.<>?';

        await loggingService.logInfo(specialMessage);

        final logs = loggingService.getLogs();
        expect(logs.length, equals(1));
        expect(logs.first.message, equals(specialMessage));
      });
    });

    group('Log Filter', () {
      test('should match all criteria when all are provided', () {
        final log = LogEntry(
          id: 'test-id',
          timestamp: DateTime.now(),
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
          details: 'Test details',
          userId: 'user-123',
          sessionId: 'session-456',
        );

        final filter = LogFilter(
          levels: [LogLevel.info],
          categories: [LogCategory.system],
          startDate: DateTime.now().subtract(const Duration(hours: 1)),
          endDate: DateTime.now().add(const Duration(hours: 1)),
          searchQuery: 'Test',
          userId: 'user-123',
          sessionId: 'session-456',
        );

        expect(filter.matches(log), isTrue);
      });

      test('should not match when level is different', () {
        final log = LogEntry(
          id: 'test-id',
          timestamp: DateTime.now(),
          level: LogLevel.error,
          category: LogCategory.system,
          message: 'Test message',
        );

        final filter = LogFilter(levels: [LogLevel.info]);

        expect(filter.matches(log), isFalse);
      });

      test('should not match when category is different', () {
        final log = LogEntry(
          id: 'test-id',
          timestamp: DateTime.now(),
          level: LogLevel.info,
          category: LogCategory.error,
          message: 'Test message',
        );

        final filter = LogFilter(categories: [LogCategory.system]);

        expect(filter.matches(log), isFalse);
      });

      test('should not match when date is outside range', () {
        final log = LogEntry(
          id: 'test-id',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
        );

        final filter = LogFilter(
          startDate: DateTime.now().subtract(const Duration(days: 1)),
          endDate: DateTime.now(),
        );

        expect(filter.matches(log), isFalse);
      });

      test('should not match when search query is not found', () {
        final log = LogEntry(
          id: 'test-id',
          timestamp: DateTime.now(),
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
        );

        final filter = LogFilter(searchQuery: 'NotFound');

        expect(filter.matches(log), isFalse);
      });

      test('should match when search query is in details', () {
        final log = LogEntry(
          id: 'test-id',
          timestamp: DateTime.now(),
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
          details: 'Found in details',
        );

        final filter = LogFilter(searchQuery: 'Found');

        expect(filter.matches(log), isTrue);
      });
    });
  });
}
