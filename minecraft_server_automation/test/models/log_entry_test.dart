import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minecraft_server_automation/models/log_entry.dart';

void main() {
  group('LogLevel', () {
    test('should have all expected enum values', () {
      expect(LogLevel.values.length, equals(5));
      expect(LogLevel.values, contains(LogLevel.debug));
      expect(LogLevel.values, contains(LogLevel.info));
      expect(LogLevel.values, contains(LogLevel.warning));
      expect(LogLevel.values, contains(LogLevel.error));
      expect(LogLevel.values, contains(LogLevel.fatal));
    });

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

    group('LogLevelExtension', () {
      test('should have correct icons', () {
        expect(LogLevel.debug.icon, equals(Icons.bug_report));
        expect(LogLevel.info.icon, equals(Icons.info));
        expect(LogLevel.warning.icon, equals(Icons.warning));
        expect(LogLevel.error.icon, equals(Icons.error));
        expect(LogLevel.fatal.icon, equals(Icons.dangerous));
      });

      test('should have correct colors', () {
        expect(LogLevel.debug.color, equals(Colors.blue));
        expect(LogLevel.info.color, equals(Colors.green));
        expect(LogLevel.warning.color, equals(Colors.orange));
        expect(LogLevel.error.color, equals(Colors.red));
        expect(LogLevel.fatal.color, equals(Colors.purple));
      });
    });
  });

  group('LogCategory', () {
    test('should have all expected enum values', () {
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
  });

  group('LogEntry', () {
    test('should create instance with required parameters', () {
      final timestamp = DateTime.now();
      final entry = LogEntry(
        id: 'test-id',
        timestamp: timestamp,
        level: LogLevel.info,
        category: LogCategory.system,
        message: 'Test message',
      );

      expect(entry.id, equals('test-id'));
      expect(entry.timestamp, equals(timestamp));
      expect(entry.level, equals(LogLevel.info));
      expect(entry.category, equals(LogCategory.system));
      expect(entry.message, equals('Test message'));
      expect(entry.details, isNull);
      expect(entry.metadata, isNull);
      expect(entry.userId, isNull);
      expect(entry.sessionId, isNull);
    });

    test('should create instance with all parameters', () {
      final timestamp = DateTime.now();
      const metadata = {'key': 'value'};
      
      final entry = LogEntry(
        id: 'test-id',
        timestamp: timestamp,
        level: LogLevel.error,
        category: LogCategory.authentication,
        message: 'Test message',
        details: 'Test details',
        metadata: metadata,
        userId: 'user-123',
        sessionId: 'session-456',
      );

      expect(entry.id, equals('test-id'));
      expect(entry.timestamp, equals(timestamp));
      expect(entry.level, equals(LogLevel.error));
      expect(entry.category, equals(LogCategory.authentication));
      expect(entry.message, equals('Test message'));
      expect(entry.details, equals('Test details'));
      expect(entry.metadata, equals(metadata));
      expect(entry.userId, equals('user-123'));
      expect(entry.sessionId, equals('session-456'));
    });

    group('fromJson factory', () {
      test('should create instance from valid JSON', () {
        final timestamp = DateTime.now();
        final json = {
          'id': 'test-id',
          'timestamp': timestamp.toIso8601String(),
          'level': 'info',
          'category': 'system',
          'message': 'Test message',
          'details': 'Test details',
          'metadata': {'key': 'value'},
          'userId': 'user-123',
          'sessionId': 'session-456',
        };

        final entry = LogEntry.fromJson(json);

        expect(entry.id, equals('test-id'));
        expect(entry.timestamp, equals(timestamp));
        expect(entry.level, equals(LogLevel.info));
        expect(entry.category, equals(LogCategory.system));
        expect(entry.message, equals('Test message'));
        expect(entry.details, equals('Test details'));
        expect(entry.metadata, equals({'key': 'value'}));
        expect(entry.userId, equals('user-123'));
        expect(entry.sessionId, equals('session-456'));
      });

      test('should handle invalid level with default fallback', () {
        final timestamp = DateTime.now();
        final json = {
          'id': 'test-id',
          'timestamp': timestamp.toIso8601String(),
          'level': 'invalid_level',
          'category': 'system',
          'message': 'Test message',
        };

        final entry = LogEntry.fromJson(json);

        expect(entry.level, equals(LogLevel.info));
      });

      test('should handle invalid category with default fallback', () {
        final timestamp = DateTime.now();
        final json = {
          'id': 'test-id',
          'timestamp': timestamp.toIso8601String(),
          'level': 'info',
          'category': 'invalid_category',
          'message': 'Test message',
        };

        final entry = LogEntry.fromJson(json);

        expect(entry.category, equals(LogCategory.system));
      });

      test('should handle null optional fields', () {
        final timestamp = DateTime.now();
        final json = {
          'id': 'test-id',
          'timestamp': timestamp.toIso8601String(),
          'level': 'info',
          'category': 'system',
          'message': 'Test message',
          'details': null,
          'metadata': null,
          'userId': null,
          'sessionId': null,
        };

        final entry = LogEntry.fromJson(json);

        expect(entry.details, isNull);
        expect(entry.metadata, isNull);
        expect(entry.userId, isNull);
        expect(entry.sessionId, isNull);
      });
    });

    group('toJson', () {
      test('should convert to JSON with all fields', () {
        final timestamp = DateTime.now();
        const metadata = {'key': 'value'};
        
        final entry = LogEntry(
          id: 'test-id',
          timestamp: timestamp,
          level: LogLevel.error,
          category: LogCategory.authentication,
          message: 'Test message',
          details: 'Test details',
          metadata: metadata,
          userId: 'user-123',
          sessionId: 'session-456',
        );

        final json = entry.toJson();

        expect(json['id'], equals('test-id'));
        expect(json['timestamp'], equals(timestamp.toIso8601String()));
        expect(json['level'], equals('error'));
        expect(json['category'], equals('authentication'));
        expect(json['message'], equals('Test message'));
        expect(json['details'], equals('Test details'));
        expect(json['metadata'], equals(metadata));
        expect(json['userId'], equals('user-123'));
        expect(json['sessionId'], equals('session-456'));
      });

      test('should convert to JSON with null optional fields', () {
        final timestamp = DateTime.now();
        
        final entry = LogEntry(
          id: 'test-id',
          timestamp: timestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
        );

        final json = entry.toJson();

        expect(json['id'], equals('test-id'));
        expect(json['timestamp'], equals(timestamp.toIso8601String()));
        expect(json['level'], equals('info'));
        expect(json['category'], equals('system'));
        expect(json['message'], equals('Test message'));
        expect(json['details'], isNull);
        expect(json['metadata'], isNull);
        expect(json['userId'], isNull);
        expect(json['sessionId'], isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final timestamp = DateTime.now();
        final newTimestamp = DateTime.now().add(Duration(hours: 1));
        
        final original = LogEntry(
          id: 'test-id',
          timestamp: timestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
          details: 'Test details',
          metadata: {'key': 'value'},
          userId: 'user-123',
          sessionId: 'session-456',
        );

        final updated = original.copyWith(
          timestamp: newTimestamp,
          level: LogLevel.error,
          message: 'Updated message',
          details: 'Updated details',
        );

        expect(updated.id, equals('test-id'));
        expect(updated.timestamp, equals(newTimestamp));
        expect(updated.level, equals(LogLevel.error));
        expect(updated.category, equals(LogCategory.system));
        expect(updated.message, equals('Updated message'));
        expect(updated.details, equals('Updated details'));
        expect(updated.metadata, equals({'key': 'value'}));
        expect(updated.userId, equals('user-123'));
        expect(updated.sessionId, equals('session-456'));
      });

      test('should create copy with null fields (preserves original values)', () {
        final timestamp = DateTime.now();
        
        final original = LogEntry(
          id: 'test-id',
          timestamp: timestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
          details: 'Test details',
          metadata: {'key': 'value'},
          userId: 'user-123',
          sessionId: 'session-456',
        );

        final updated = original.copyWith(
          details: null,
          metadata: null,
          userId: null,
          sessionId: null,
        );

        // copyWith with null values preserves original values
        expect(updated.details, equals('Test details'));
        expect(updated.metadata, equals({'key': 'value'}));
        expect(updated.userId, equals('user-123'));
        expect(updated.sessionId, equals('session-456'));
      });
    });

    group('equality', () {
      test('should be equal to identical instance', () {
        final timestamp = DateTime.now();
        
        final entry1 = LogEntry(
          id: 'test-id',
          timestamp: timestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
        );

        final entry2 = LogEntry(
          id: 'test-id',
          timestamp: timestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
        );

        expect(entry1, equals(entry2));
        expect(entry1.hashCode, equals(entry2.hashCode));
      });

      test('should not be equal to different instance', () {
        final timestamp = DateTime.now();
        
        final entry1 = LogEntry(
          id: 'test-id-1',
          timestamp: timestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
        );

        final entry2 = LogEntry(
          id: 'test-id-2',
          timestamp: timestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
        );

        expect(entry1, isNot(equals(entry2)));
        expect(entry1.hashCode, isNot(equals(entry2.hashCode)));
      });

      test('should be equal to itself', () {
        final timestamp = DateTime.now();
        
        final entry = LogEntry(
          id: 'test-id',
          timestamp: timestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
        );

        expect(entry, equals(entry));
      });
    });

    group('toString', () {
      test('should return string representation', () {
        final timestamp = DateTime.now();
        
        final entry = LogEntry(
          id: 'test-id',
          timestamp: timestamp,
          level: LogLevel.error,
          category: LogCategory.authentication,
          message: 'Test message',
        );

        final string = entry.toString();

        expect(string, contains('LogEntry'));
        expect(string, contains('id: test-id'));
        expect(string, contains('level: LogLevel.error'));
        expect(string, contains('category: LogCategory.authentication'));
        expect(string, contains('message: Test message'));
      });
    });
  });

  group('LogFilter', () {
    test('should create instance with all parameters', () {
      final startDate = DateTime.now().subtract(Duration(days: 1));
      final endDate = DateTime.now();
      
      final logFilter = LogFilter(
        levels: [LogLevel.error, LogLevel.fatal],
        categories: [LogCategory.authentication, LogCategory.security],
        startDate: startDate,
        endDate: endDate,
        searchQuery: 'test query',
        userId: 'user-123',
        sessionId: 'session-456',
      );

      expect(logFilter.levels, equals([LogLevel.error, LogLevel.fatal]));
      expect(logFilter.categories, equals([LogCategory.authentication, LogCategory.security]));
      expect(logFilter.startDate, equals(startDate));
      expect(logFilter.endDate, equals(endDate));
      expect(logFilter.searchQuery, equals('test query'));
      expect(logFilter.userId, equals('user-123'));
      expect(logFilter.sessionId, equals('session-456'));
    });

    test('should create instance with null parameters', () {
      const filter = LogFilter();

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
        const filter = LogFilter();
        final timestamp = DateTime.now();
        
        final entry = LogEntry(
          id: 'test-id',
          timestamp: timestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
        );

        expect(filter.matches(entry), isTrue);
      });

      test('should match entry when level filter matches', () {
        const filter = LogFilter(levels: [LogLevel.info, LogLevel.warning]);
        final timestamp = DateTime.now();
        
        final entry = LogEntry(
          id: 'test-id',
          timestamp: timestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
        );

        expect(filter.matches(entry), isTrue);
      });

      test('should not match entry when level filter does not match', () {
        const filter = LogFilter(levels: [LogLevel.error, LogLevel.fatal]);
        final timestamp = DateTime.now();
        
        final entry = LogEntry(
          id: 'test-id',
          timestamp: timestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
        );

        expect(filter.matches(entry), isFalse);
      });

      test('should match entry when category filter matches', () {
        const filter = LogFilter(categories: [LogCategory.system, LogCategory.error]);
        final timestamp = DateTime.now();
        
        final entry = LogEntry(
          id: 'test-id',
          timestamp: timestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
        );

        expect(filter.matches(entry), isTrue);
      });

      test('should not match entry when category filter does not match', () {
        const filter = LogFilter(categories: [LogCategory.authentication, LogCategory.security]);
        final timestamp = DateTime.now();
        
        final entry = LogEntry(
          id: 'test-id',
          timestamp: timestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
        );

        expect(filter.matches(entry), isFalse);
      });

      test('should match entry when timestamp is within date range', () {
        final startDate = DateTime.now().subtract(Duration(hours: 1));
        final endDate = DateTime.now().add(Duration(hours: 1));
        final filter = LogFilter(startDate: startDate, endDate: endDate);
        final timestamp = DateTime.now();
        
        final entry = LogEntry(
          id: 'test-id',
          timestamp: timestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
        );

        expect(filter.matches(entry), isTrue);
      });

      test('should not match entry when timestamp is before start date', () {
        final startDate = DateTime.now().add(Duration(hours: 1));
        final endDate = DateTime.now().add(Duration(hours: 2));
        final filter = LogFilter(startDate: startDate, endDate: endDate);
        final timestamp = DateTime.now();
        
        final entry = LogEntry(
          id: 'test-id',
          timestamp: timestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
        );

        expect(filter.matches(entry), isFalse);
      });

      test('should not match entry when timestamp is after end date', () {
        final startDate = DateTime.now().subtract(Duration(hours: 2));
        final endDate = DateTime.now().subtract(Duration(hours: 1));
        final filter = LogFilter(startDate: startDate, endDate: endDate);
        final timestamp = DateTime.now();
        
        final entry = LogEntry(
          id: 'test-id',
          timestamp: timestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
        );

        expect(filter.matches(entry), isFalse);
      });

      test('should match entry when search query matches message', () {
        const filter = LogFilter(searchQuery: 'test');
        final timestamp = DateTime.now();
        
        final entry = LogEntry(
          id: 'test-id',
          timestamp: timestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
        );

        expect(filter.matches(entry), isTrue);
      });

      test('should match entry when search query matches details', () {
        const filter = LogFilter(searchQuery: 'details');
        final timestamp = DateTime.now();
        
        final entry = LogEntry(
          id: 'test-id',
          timestamp: timestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
          details: 'Test details',
        );

        expect(filter.matches(entry), isTrue);
      });

      test('should not match entry when search query does not match', () {
        const filter = LogFilter(searchQuery: 'notfound');
        final timestamp = DateTime.now();
        
        final entry = LogEntry(
          id: 'test-id',
          timestamp: timestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
        );

        expect(filter.matches(entry), isFalse);
      });

      test('should match entry when search query is empty', () {
        const filter = LogFilter(searchQuery: '');
        final timestamp = DateTime.now();
        
        final entry = LogEntry(
          id: 'test-id',
          timestamp: timestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
        );

        expect(filter.matches(entry), isTrue);
      });

      test('should match entry when userId matches', () {
        const filter = LogFilter(userId: 'user-123');
        final timestamp = DateTime.now();
        
        final entry = LogEntry(
          id: 'test-id',
          timestamp: timestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
          userId: 'user-123',
        );

        expect(filter.matches(entry), isTrue);
      });

      test('should not match entry when userId does not match', () {
        const filter = LogFilter(userId: 'user-456');
        final timestamp = DateTime.now();
        
        final entry = LogEntry(
          id: 'test-id',
          timestamp: timestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
          userId: 'user-123',
        );

        expect(filter.matches(entry), isFalse);
      });

      test('should match entry when sessionId matches', () {
        const filter = LogFilter(sessionId: 'session-123');
        final timestamp = DateTime.now();
        
        final entry = LogEntry(
          id: 'test-id',
          timestamp: timestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
          sessionId: 'session-123',
        );

        expect(filter.matches(entry), isTrue);
      });

      test('should not match entry when sessionId does not match', () {
        const filter = LogFilter(sessionId: 'session-456');
        final timestamp = DateTime.now();
        
        final entry = LogEntry(
          id: 'test-id',
          timestamp: timestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
          sessionId: 'session-123',
        );

        expect(filter.matches(entry), isFalse);
      });

      test('should match entry when all filters match', () {
        final startDate = DateTime.now().subtract(Duration(hours: 1));
        final endDate = DateTime.now().add(Duration(hours: 1));
        final filter = LogFilter(
          levels: [LogLevel.info],
          categories: [LogCategory.system],
          startDate: startDate,
          endDate: endDate,
          searchQuery: 'test',
          userId: 'user-123',
          sessionId: 'session-123',
        );
        final timestamp = DateTime.now();
        
        final entry = LogEntry(
          id: 'test-id',
          timestamp: timestamp,
          level: LogLevel.info,
          category: LogCategory.system,
          message: 'Test message',
          userId: 'user-123',
          sessionId: 'session-123',
        );

        expect(filter.matches(entry), isTrue);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final startDate = DateTime.now().subtract(Duration(days: 1));
        final endDate = DateTime.now();
        final newStartDate = DateTime.now().subtract(Duration(days: 2));
        
        final original = LogFilter(
          levels: [LogLevel.error],
          categories: [LogCategory.authentication],
          startDate: startDate,
          endDate: endDate,
          searchQuery: 'original query',
          userId: 'user-123',
          sessionId: 'session-456',
        );

        final updated = original.copyWith(
          startDate: newStartDate,
          searchQuery: 'updated query',
          userId: 'user-789',
        );

        expect(updated.levels, equals([LogLevel.error]));
        expect(updated.categories, equals([LogCategory.authentication]));
        expect(updated.startDate, equals(newStartDate));
        expect(updated.endDate, equals(endDate));
        expect(updated.searchQuery, equals('updated query'));
        expect(updated.userId, equals('user-789'));
        expect(updated.sessionId, equals('session-456'));
      });

      test('should create copy with null fields (preserves original values)', () {
        final startDate = DateTime.now().subtract(Duration(days: 1));
        final endDate = DateTime.now();
        
        final original = LogFilter(
          levels: [LogLevel.error],
          categories: [LogCategory.authentication],
          startDate: startDate,
          endDate: endDate,
          searchQuery: 'original query',
          userId: 'user-123',
          sessionId: 'session-456',
        );

        final updated = original.copyWith(
          levels: null,
          categories: null,
          searchQuery: null,
          userId: null,
          sessionId: null,
        );

        // copyWith with null values preserves original values
        expect(updated.levels, equals([LogLevel.error]));
        expect(updated.categories, equals([LogCategory.authentication]));
        expect(updated.startDate, equals(startDate));
        expect(updated.endDate, equals(endDate));
        expect(updated.searchQuery, equals('original query'));
        expect(updated.userId, equals('user-123'));
        expect(updated.sessionId, equals('session-456'));
      });
    });
  });
}
