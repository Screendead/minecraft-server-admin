import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/models/log_entry.dart';

void main() {
  group('LogLevel', () {
    test('should have correct display names', () {
      expect(LogLevel.debug.displayName, equals('Debug'));
      expect(LogLevel.info.displayName, equals('Info'));
      expect(LogLevel.warning.displayName, equals('Warning'));
      expect(LogLevel.error.displayName, equals('Error'));
      expect(LogLevel.fatal.displayName, equals('Fatal'));
    });

    test('should have correct icon names', () {
      expect(LogLevel.debug.iconName, equals('bug_report'));
      expect(LogLevel.info.iconName, equals('info'));
      expect(LogLevel.warning.iconName, equals('warning'));
      expect(LogLevel.error.iconName, equals('error'));
      expect(LogLevel.fatal.iconName, equals('dangerous'));
    });

    test('should have all expected values', () {
      expect(LogLevel.values.length, equals(5));
      expect(LogLevel.values, contains(LogLevel.debug));
      expect(LogLevel.values, contains(LogLevel.info));
      expect(LogLevel.values, contains(LogLevel.warning));
      expect(LogLevel.values, contains(LogLevel.error));
      expect(LogLevel.values, contains(LogLevel.fatal));
    });
  });

  group('LogLevelExtension', () {
    test('should return correct icons', () {
      expect(LogLevel.debug.icon, equals(Icons.bug_report));
      expect(LogLevel.info.icon, equals(Icons.info));
      expect(LogLevel.warning.icon, equals(Icons.warning));
      expect(LogLevel.error.icon, equals(Icons.error));
      expect(LogLevel.fatal.icon, equals(Icons.dangerous));
    });

    test('should return correct colors', () {
      expect(LogLevel.debug.color, equals(Colors.blue));
      expect(LogLevel.info.color, equals(Colors.green));
      expect(LogLevel.warning.color, equals(Colors.orange));
      expect(LogLevel.error.color, equals(Colors.red));
      expect(LogLevel.fatal.color, equals(Colors.purple));
    });
  });

  group('LogCategory', () {
    test('should have correct display names', () {
      expect(LogCategory.userInteraction.displayName, equals('User Interaction'));
      expect(LogCategory.apiCall.displayName, equals('API Call'));
      expect(LogCategory.authentication.displayName, equals('Authentication'));
      expect(LogCategory.dropletManagement.displayName, equals('Droplet Management'));
      expect(LogCategory.serverManagement.displayName, equals('Server Management'));
      expect(LogCategory.error.displayName, equals('Error'));
      expect(LogCategory.system.displayName, equals('System'));
      expect(LogCategory.security.displayName, equals('Security'));
    });

    test('should have all expected values', () {
      expect(LogCategory.values.length, equals(8));
      expect(LogCategory.values, contains(LogCategory.userInteraction));
      expect(LogCategory.values, contains(LogCategory.apiCall));
      expect(LogCategory.values, contains(LogCategory.authentication));
      expect(LogCategory.values, contains(LogCategory.dropletManagement));
      expect(LogCategory.values, contains(LogCategory.serverManagement));
      expect(LogCategory.values, contains(LogCategory.error));
      expect(LogCategory.values, contains(LogCategory.system));
      expect(LogCategory.values, contains(LogCategory.security));
    });
  });

  group('LogEntry', () {
    late DateTime testTimestamp;
    late LogEntry testEntry;

    setUp(() {
      testTimestamp = DateTime(2023, 1, 1, 12, 0, 0);
      testEntry = LogEntry(
        id: 'test-id',
        timestamp: testTimestamp,
        level: LogLevel.info,
        category: LogCategory.system,
        message: 'Test message',
        details: 'Test details',
        metadata: {'key': 'value'},
        userId: 'user-123',
        sessionId: 'session-456',
      );
    });

    test('should create LogEntry with all properties', () {
      expect(testEntry.id, equals('test-id'));
      expect(testEntry.timestamp, equals(testTimestamp));
      expect(testEntry.level, equals(LogLevel.info));
      expect(testEntry.category, equals(LogCategory.system));
      expect(testEntry.message, equals('Test message'));
      expect(testEntry.details, equals('Test details'));
      expect(testEntry.metadata, equals({'key': 'value'}));
      expect(testEntry.userId, equals('user-123'));
      expect(testEntry.sessionId, equals('session-456'));
    });

    test('should create LogEntry with minimal properties', () {
      final minimalEntry = LogEntry(
        id: 'minimal-id',
        timestamp: testTimestamp,
        level: LogLevel.debug,
        category: LogCategory.userInteraction,
        message: 'Minimal message',
      );

      expect(minimalEntry.id, equals('minimal-id'));
      expect(minimalEntry.timestamp, equals(testTimestamp));
      expect(minimalEntry.level, equals(LogLevel.debug));
      expect(minimalEntry.category, equals(LogCategory.userInteraction));
      expect(minimalEntry.message, equals('Minimal message'));
      expect(minimalEntry.details, isNull);
      expect(minimalEntry.metadata, isNull);
      expect(minimalEntry.userId, isNull);
      expect(minimalEntry.sessionId, isNull);
    });

    group('fromJson', () {
      test('should create LogEntry from valid JSON', () {
        final json = {
          'id': 'json-id',
          'timestamp': '2023-01-01T12:00:00.000Z',
          'level': 'warning',
          'category': 'apiCall',
          'message': 'JSON message',
          'details': 'JSON details',
          'metadata': {'jsonKey': 'jsonValue'},
          'userId': 'json-user',
          'sessionId': 'json-session',
        };

        final entry = LogEntry.fromJson(json);

        expect(entry.id, equals('json-id'));
        expect(entry.timestamp, equals(DateTime.parse('2023-01-01T12:00:00.000Z')));
        expect(entry.level, equals(LogLevel.warning));
        expect(entry.category, equals(LogCategory.apiCall));
        expect(entry.message, equals('JSON message'));
        expect(entry.details, equals('JSON details'));
        expect(entry.metadata, equals({'jsonKey': 'jsonValue'}));
        expect(entry.userId, equals('json-user'));
        expect(entry.sessionId, equals('json-session'));
      });

      test('should handle invalid level with fallback', () {
        final json = {
          'id': 'test-id',
          'timestamp': '2023-01-01T12:00:00.000Z',
          'level': 'invalid_level',
          'category': 'system',
          'message': 'Test message',
        };

        final entry = LogEntry.fromJson(json);
        expect(entry.level, equals(LogLevel.info));
      });

      test('should handle invalid category with fallback', () {
        final json = {
          'id': 'test-id',
          'timestamp': '2023-01-01T12:00:00.000Z',
          'level': 'info',
          'category': 'invalid_category',
          'message': 'Test message',
        };

        final entry = LogEntry.fromJson(json);
        expect(entry.category, equals(LogCategory.system));
      });

      test('should handle null optional fields', () {
        final json = {
          'id': 'test-id',
          'timestamp': '2023-01-01T12:00:00.000Z',
          'level': 'info',
          'category': 'system',
          'message': 'Test message',
        };

        final entry = LogEntry.fromJson(json);
        expect(entry.details, isNull);
        expect(entry.metadata, isNull);
        expect(entry.userId, isNull);
        expect(entry.sessionId, isNull);
      });
    });

    group('toJson', () {
      test('should convert LogEntry to JSON', () {
        final json = testEntry.toJson();

        expect(json['id'], equals('test-id'));
        expect(json['timestamp'], equals(testTimestamp.toIso8601String()));
        expect(json['level'], equals('info'));
        expect(json['category'], equals('system'));
        expect(json['message'], equals('Test message'));
        expect(json['details'], equals('Test details'));
        expect(json['metadata'], equals({'key': 'value'}));
        expect(json['userId'], equals('user-123'));
        expect(json['sessionId'], equals('session-456'));
      });

      test('should handle null optional fields in JSON', () {
        final minimalEntry = LogEntry(
          id: 'minimal-id',
          timestamp: testTimestamp,
          level: LogLevel.debug,
          category: LogCategory.userInteraction,
          message: 'Minimal message',
        );

        final json = minimalEntry.toJson();

        expect(json['details'], isNull);
        expect(json['metadata'], isNull);
        expect(json['userId'], isNull);
        expect(json['sessionId'], isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final updatedEntry = testEntry.copyWith(
          level: LogLevel.error,
          message: 'Updated message',
          userId: 'updated-user',
        );

        expect(updatedEntry.id, equals('test-id'));
        expect(updatedEntry.timestamp, equals(testTimestamp));
        expect(updatedEntry.level, equals(LogLevel.error));
        expect(updatedEntry.category, equals(LogCategory.system));
        expect(updatedEntry.message, equals('Updated message'));
        expect(updatedEntry.details, equals('Test details'));
        expect(updatedEntry.metadata, equals({'key': 'value'}));
        expect(updatedEntry.userId, equals('updated-user'));
        expect(updatedEntry.sessionId, equals('session-456'));
      });

      test('should create copy with all fields updated', () {
        final newTimestamp = DateTime(2023, 2, 1, 12, 0, 0);
        final updatedEntry = testEntry.copyWith(
          id: 'new-id',
          timestamp: newTimestamp,
          level: LogLevel.fatal,
          category: LogCategory.error,
          message: 'New message',
          details: 'New details',
          metadata: {'newKey': 'newValue'},
          userId: 'new-user',
          sessionId: 'new-session',
        );

        expect(updatedEntry.id, equals('new-id'));
        expect(updatedEntry.timestamp, equals(newTimestamp));
        expect(updatedEntry.level, equals(LogLevel.fatal));
        expect(updatedEntry.category, equals(LogCategory.error));
        expect(updatedEntry.message, equals('New message'));
        expect(updatedEntry.details, equals('New details'));
        expect(updatedEntry.metadata, equals({'newKey': 'newValue'}));
        expect(updatedEntry.userId, equals('new-user'));
        expect(updatedEntry.sessionId, equals('new-session'));
      });

      test('should create copy with no changes when no parameters provided', () {
        final copiedEntry = testEntry.copyWith();

        expect(copiedEntry.id, equals(testEntry.id));
        expect(copiedEntry.timestamp, equals(testEntry.timestamp));
        expect(copiedEntry.level, equals(testEntry.level));
        expect(copiedEntry.category, equals(testEntry.category));
        expect(copiedEntry.message, equals(testEntry.message));
        expect(copiedEntry.details, equals(testEntry.details));
        expect(copiedEntry.metadata, equals(testEntry.metadata));
        expect(copiedEntry.userId, equals(testEntry.userId));
        expect(copiedEntry.sessionId, equals(testEntry.sessionId));
      });
    });

    group('equality', () {
      test('should be equal when IDs are the same', () {
        final entry1 = LogEntry(
          id: 'same-id',
          timestamp: testTimestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Message 1',
        );

        final entry2 = LogEntry(
          id: 'same-id',
          timestamp: DateTime(2023, 2, 1, 12, 0, 0),
          level: LogLevel.error,
          category: LogCategory.error,
          message: 'Message 2',
        );

        expect(entry1, equals(entry2));
        expect(entry1.hashCode, equals(entry2.hashCode));
      });

      test('should not be equal when IDs are different', () {
        final entry1 = LogEntry(
          id: 'id-1',
          timestamp: testTimestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Message',
        );

        final entry2 = LogEntry(
          id: 'id-2',
          timestamp: testTimestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Message',
        );

        expect(entry1, isNot(equals(entry2)));
        expect(entry1.hashCode, isNot(equals(entry2.hashCode)));
      });

      test('should be equal to itself', () {
        expect(testEntry, equals(testEntry));
        expect(testEntry.hashCode, equals(testEntry.hashCode));
      });
    });

    group('toString', () {
      test('should return string representation', () {
        final string = testEntry.toString();
        expect(string, contains('LogEntry'));
        expect(string, contains('test-id'));
        expect(string, contains('Test message'));
        expect(string, contains('info'));
        expect(string, contains('system'));
      });
    });
  });

  group('LogFilter', () {
    late LogEntry testEntry;

    setUp(() {
      testEntry = LogEntry(
        id: 'test-id',
        timestamp: DateTime(2023, 1, 15, 12, 0, 0),
        level: LogLevel.info,
        category: LogCategory.system,
        message: 'Test message with search term',
        details: 'Test details',
        userId: 'user-123',
        sessionId: 'session-456',
      );
    });

    test('should create LogFilter with all properties', () {
      final filter = LogFilter(
        levels: [LogLevel.info, LogLevel.warning],
        categories: [LogCategory.system, LogCategory.error],
        startDate: DateTime(2023, 1, 1),
        endDate: DateTime(2023, 1, 31),
        searchQuery: 'test',
        userId: 'user-123',
        sessionId: 'session-456',
      );

      expect(filter.levels, equals([LogLevel.info, LogLevel.warning]));
      expect(filter.categories, equals([LogCategory.system, LogCategory.error]));
      expect(filter.startDate, equals(DateTime(2023, 1, 1)));
      expect(filter.endDate, equals(DateTime(2023, 1, 31)));
      expect(filter.searchQuery, equals('test'));
      expect(filter.userId, equals('user-123'));
      expect(filter.sessionId, equals('session-456'));
    });

    test('should create LogFilter with minimal properties', () {
      final filter = LogFilter();

      expect(filter.levels, isNull);
      expect(filter.categories, isNull);
      expect(filter.startDate, isNull);
      expect(filter.endDate, isNull);
      expect(filter.searchQuery, isNull);
      expect(filter.userId, isNull);
      expect(filter.sessionId, isNull);
    });

    group('matches', () {
      test('should match entry when no filters are set', () {
        final filter = LogFilter();
        expect(filter.matches(testEntry), isTrue);
      });

      test('should match entry when level is in filter', () {
        final filter = LogFilter(levels: [LogLevel.info, LogLevel.warning]);
        expect(filter.matches(testEntry), isTrue);
      });

      test('should not match entry when level is not in filter', () {
        final filter = LogFilter(levels: [LogLevel.error, LogLevel.fatal]);
        expect(filter.matches(testEntry), isFalse);
      });

      test('should match entry when category is in filter', () {
        final filter = LogFilter(categories: [LogCategory.system, LogCategory.error]);
        expect(filter.matches(testEntry), isTrue);
      });

      test('should not match entry when category is not in filter', () {
        final filter = LogFilter(categories: [LogCategory.apiCall, LogCategory.error]);
        expect(filter.matches(testEntry), isFalse);
      });

      test('should match entry when timestamp is after start date', () {
        final filter = LogFilter(startDate: DateTime(2023, 1, 1));
        expect(filter.matches(testEntry), isTrue);
      });

      test('should not match entry when timestamp is before start date', () {
        final filter = LogFilter(startDate: DateTime(2023, 1, 20));
        expect(filter.matches(testEntry), isFalse);
      });

      test('should match entry when timestamp is before end date', () {
        final filter = LogFilter(endDate: DateTime(2023, 1, 31));
        expect(filter.matches(testEntry), isTrue);
      });

      test('should not match entry when timestamp is after end date', () {
        final filter = LogFilter(endDate: DateTime(2023, 1, 10));
        expect(filter.matches(testEntry), isFalse);
      });

      test('should match entry when search query is found in message', () {
        final filter = LogFilter(searchQuery: 'search term');
        expect(filter.matches(testEntry), isTrue);
      });

      test('should match entry when search query is found in details', () {
        final filter = LogFilter(searchQuery: 'details');
        expect(filter.matches(testEntry), isTrue);
      });

      test('should not match entry when search query is not found', () {
        final filter = LogFilter(searchQuery: 'not found');
        expect(filter.matches(testEntry), isFalse);
      });

      test('should match entry when search query is empty', () {
        final filter = LogFilter(searchQuery: '');
        expect(filter.matches(testEntry), isTrue);
      });

      test('should be case insensitive for search query', () {
        final filter = LogFilter(searchQuery: 'SEARCH TERM');
        expect(filter.matches(testEntry), isTrue);
      });

      test('should match entry when userId matches', () {
        final filter = LogFilter(userId: 'user-123');
        expect(filter.matches(testEntry), isTrue);
      });

      test('should not match entry when userId does not match', () {
        final filter = LogFilter(userId: 'user-456');
        expect(filter.matches(testEntry), isFalse);
      });

      test('should match entry when sessionId matches', () {
        final filter = LogFilter(sessionId: 'session-456');
        expect(filter.matches(testEntry), isTrue);
      });

      test('should not match entry when sessionId does not match', () {
        final filter = LogFilter(sessionId: 'session-789');
        expect(filter.matches(testEntry), isFalse);
      });

      test('should match entry when all filters match', () {
        final filter = LogFilter(
          levels: [LogLevel.info],
          categories: [LogCategory.system],
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 1, 31),
          searchQuery: 'test',
          userId: 'user-123',
          sessionId: 'session-456',
        );
        expect(filter.matches(testEntry), isTrue);
      });

      test('should not match entry when any filter does not match', () {
        final filter = LogFilter(
          levels: [LogLevel.info],
          categories: [LogCategory.system],
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 1, 31),
          searchQuery: 'test',
          userId: 'user-123',
          sessionId: 'session-789', // This doesn't match
        );
        expect(filter.matches(testEntry), isFalse);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final originalFilter = LogFilter(
          levels: [LogLevel.info],
          categories: [LogCategory.system],
          searchQuery: 'test',
        );

        final updatedFilter = originalFilter.copyWith(
          levels: [LogLevel.error, LogLevel.fatal],
          searchQuery: 'updated',
        );

        expect(updatedFilter.levels, equals([LogLevel.error, LogLevel.fatal]));
        expect(updatedFilter.categories, equals([LogCategory.system]));
        expect(updatedFilter.searchQuery, equals('updated'));
        expect(updatedFilter.startDate, isNull);
        expect(updatedFilter.endDate, isNull);
        expect(updatedFilter.userId, isNull);
        expect(updatedFilter.sessionId, isNull);
      });

      test('should create copy with all fields updated', () {
        final originalFilter = LogFilter(
          levels: [LogLevel.info],
          categories: [LogCategory.system],
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 1, 31),
          searchQuery: 'test',
          userId: 'user-123',
          sessionId: 'session-456',
        );

        final updatedFilter = originalFilter.copyWith(
          levels: [LogLevel.error],
          categories: [LogCategory.error],
          startDate: DateTime(2023, 2, 1),
          endDate: DateTime(2023, 2, 28),
          searchQuery: 'updated',
          userId: 'user-456',
          sessionId: 'session-789',
        );

        expect(updatedFilter.levels, equals([LogLevel.error]));
        expect(updatedFilter.categories, equals([LogCategory.error]));
        expect(updatedFilter.startDate, equals(DateTime(2023, 2, 1)));
        expect(updatedFilter.endDate, equals(DateTime(2023, 2, 28)));
        expect(updatedFilter.searchQuery, equals('updated'));
        expect(updatedFilter.userId, equals('user-456'));
        expect(updatedFilter.sessionId, equals('session-789'));
      });

      test('should create copy with no changes when no parameters provided', () {
        final originalFilter = LogFilter(
          levels: [LogLevel.info],
          categories: [LogCategory.system],
          searchQuery: 'test',
        );

        final copiedFilter = originalFilter.copyWith();

        expect(copiedFilter.levels, equals(originalFilter.levels));
        expect(copiedFilter.categories, equals(originalFilter.categories));
        expect(copiedFilter.startDate, equals(originalFilter.startDate));
        expect(copiedFilter.endDate, equals(originalFilter.endDate));
        expect(copiedFilter.searchQuery, equals(originalFilter.searchQuery));
        expect(copiedFilter.userId, equals(originalFilter.userId));
        expect(copiedFilter.sessionId, equals(originalFilter.sessionId));
      });
    });
  });
}
