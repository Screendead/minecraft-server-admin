import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../lib/services/logging_service.dart';
import '../lib/models/log_entry.dart';

// Generate mocks
@GenerateMocks([Uuid])
void main() {
  group('LoggingService', () {
    late LoggingService loggingService;

    setUp(() {
      loggingService = LoggingService();
      // Clear any existing logs before each test
      loggingService.clearLogs();
    });

    test('should create log entry with correct properties', () async {
      // Arrange
      const message = 'Test log message';
      const category = LogCategory.system;
      const level = LogLevel.info;

      // Act
      await loggingService.logInfo(message, category: category);

      // Assert
      final logs = loggingService.getLogs();
      expect(logs.length, equals(1));
      expect(logs.first.message, equals(message));
      expect(logs.first.category, equals(category));
      expect(logs.first.level, equals(level));
      expect(logs.first.timestamp, isA<DateTime>());
      expect(logs.first.id, isNotEmpty);
    });

    test('should log different levels correctly', () async {
      // Act
      await loggingService.logDebug('Debug message');
      await loggingService.logInfo('Info message');
      await loggingService.logWarning('Warning message');
      await loggingService.logError('Error message');
      await loggingService.logFatal('Fatal message');

      // Assert
      final logs = loggingService.getLogs();
      expect(logs.length, equals(5));
      expect(logs.any((log) => log.level == LogLevel.debug), isTrue);
      expect(logs.any((log) => log.level == LogLevel.info), isTrue);
      expect(logs.any((log) => log.level == LogLevel.warning), isTrue);
      expect(logs.any((log) => log.level == LogLevel.error), isTrue);
      expect(logs.any((log) => log.level == LogLevel.fatal), isTrue);
    });

    test('should log user interactions correctly', () async {
      // Act
      await loggingService.logUserInteraction(
        'Button clicked',
        details: 'User clicked the submit button',
        metadata: {'buttonId': 'submit'},
      );

      // Assert
      final logs = loggingService.getLogs();
      expect(logs.length, equals(1));
      expect(logs.first.category, equals(LogCategory.userInteraction));
      expect(logs.first.message, equals('User interaction: Button clicked'));
      expect(logs.first.details, equals('User clicked the submit button'));
      expect(logs.first.metadata, equals({'buttonId': 'submit'}));
    });

    test('should log API calls correctly', () async {
      // Act
      await loggingService.logApiCall(
        '/test-endpoint',
        'POST',
        statusCode: 200,
        duration: const Duration(milliseconds: 150),
        metadata: {'operation': 'test'},
      );

      // Assert
      final logs = loggingService.getLogs();
      expect(logs.length, equals(1));
      expect(logs.first.category, equals(LogCategory.apiCall));
      expect(logs.first.message, equals('API Call: POST /test-endpoint'));
      expect(logs.first.metadata?['statusCode'], equals(200));
      expect(logs.first.metadata?['durationMs'], equals(150));
      expect(logs.first.metadata?['operation'], equals('test'));
    });

    test('should filter logs correctly', () async {
      // Arrange
      await loggingService.logInfo('Info message',
          category: LogCategory.system);
      await loggingService.logError('Error message',
          category: LogCategory.error);
      await loggingService.logWarning('Warning message',
          category: LogCategory.system);

      // Act
      final errorLogs = loggingService.getLogsByLevel(LogLevel.error);
      final systemLogs = loggingService.getLogsByCategory(LogCategory.system);

      // Assert
      expect(errorLogs.length, equals(1));
      expect(errorLogs.first.message, equals('Error message'));
      expect(systemLogs.length, equals(2));
    });

    test('should apply custom filter correctly', () async {
      // Arrange
      await loggingService.logInfo('Info message',
          category: LogCategory.system);
      await loggingService.logError('Error message',
          category: LogCategory.error);
      await loggingService.logWarning('Warning message',
          category: LogCategory.system);

      final filter = LogFilter(
        levels: [LogLevel.error],
        categories: [LogCategory.error],
      );

      // Act
      final filteredLogs = loggingService.getFilteredLogs(filter);

      // Assert
      expect(filteredLogs.length, equals(1));
      expect(filteredLogs.first.level, equals(LogLevel.error));
      expect(filteredLogs.first.category, equals(LogCategory.error));
    });

    test('should clear logs correctly', () async {
      // Arrange
      await loggingService.logInfo('Test message');
      expect(loggingService.getLogs().length, equals(1));

      // Act
      await loggingService.clearLogs();

      // Assert
      expect(loggingService.getLogs().length, equals(0));
    });

    test('should export logs to JSON correctly', () async {
      // Arrange
      await loggingService.logInfo('Test message',
          category: LogCategory.system);

      // Act
      final jsonString = await loggingService.exportLogsToJson();

      // Assert
      expect(jsonString, isNotEmpty);
      expect(jsonString, contains('Test message'));
      expect(jsonString, contains('system'));
    });

    test('should export logs to CSV correctly', () async {
      // Arrange
      await loggingService.logInfo('Test message',
          category: LogCategory.system);

      // Act
      final csvString = await loggingService.exportLogsToCsv();

      // Assert
      expect(csvString, isNotEmpty);
      expect(csvString, contains('Test message'));
      expect(csvString, contains('system'));
    });

    test('should export logs to text correctly', () async {
      // Arrange
      await loggingService.logInfo('Test message',
          category: LogCategory.system);

      // Act
      final textString = await loggingService.exportLogsToText();

      // Assert
      expect(textString, isNotEmpty);
      expect(textString, contains('Test message'));
      expect(textString, contains('System'));
    });

    test('should set user ID correctly', () {
      // Act
      loggingService.setUserId('test-user-123');

      // Assert
      expect(loggingService.currentUserId, equals('test-user-123'));
    });

    test('should track initialization state', () {
      // Check that service starts uninitialized
      expect(loggingService.isInitialized, isFalse);
      expect(loggingService.currentSessionId, isNull);
    });
  });
}
