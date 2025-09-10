import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:minecraft_server_automation/services/minecraft_server_service.dart';
import 'minecraft_server_service_test.mocks.dart';

// Generate mocks for external dependencies
@GenerateMocks([http.Client])
void main() {
  group('MinecraftServerService', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      MinecraftServerService.setClient(mockClient);
    });

    tearDown(() {
      MinecraftServerService.setClient(http.Client());
    });

    group('checkMinecraftServer', () {
      test('should return server info when server is online', () async {
        // Arrange
        const ipAddress = '192.168.1.100';
        const responseBody = '''
        {
          "online": true,
          "ip": "192.168.1.100",
          "port": 25565,
          "hostname": "Test Server",
          "version": "1.20.1",
          "protocol": 763,
          "players": {
            "online": 5,
            "max": 20,
            "list": ["Player1", "Player2", "Player3"]
          },
          "motd": {
            "clean": ["A Minecraft Server"],
            "raw": ["§6A Minecraft Server"]
          },
          "software": "Paper"
        }
        ''';

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        // Assert
        expect(result, isNotNull);
        expect(result!.hostname, equals('Test Server'));
        expect(result.ip, equals('192.168.1.100'));
        expect(result.port, equals(25565));
        expect(result.version, equals('1.20.1'));
        expect(result.protocol, equals('763'));
        expect(result.playersOnline, equals(5));
        expect(result.playersMax, equals(20));
        expect(result.motd, equals('A Minecraft Server'));
        expect(result.software, equals('Paper'));
        expect(result.players, equals(['Player1', 'Player2', 'Player3']));

        // Verify the correct URL was called
        verify(mockClient.get(
          Uri.parse('https://api.mcsrvstat.us/2/192.168.1.100'),
          headers: {'Content-Type': 'application/json'},
        )).called(1);
      });

      test('should return null when server is offline', () async {
        // Arrange
        const ipAddress = '192.168.1.100';
        const responseBody = '''
        {
          "online": false,
          "ip": "192.168.1.100",
          "port": 25565
        }
        ''';

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        // Assert
        expect(result, isNull);
      });

      test('should return null when API returns non-200 status', () async {
        // Arrange
        const ipAddress = '192.168.1.100';
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('Not Found', 404));

        // Act
        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        // Assert
        expect(result, isNull);
      });

      test('should return null when API returns 500 error', () async {
        // Arrange
        const ipAddress = '192.168.1.100';
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('Internal Server Error', 500));

        // Act
        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        // Assert
        expect(result, isNull);
      });

      test('should return null when network error occurs', () async {
        // Arrange
        const ipAddress = '192.168.1.100';
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Network error'));

        // Act
        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        // Assert
        expect(result, isNull);
      });

      test('should handle server with minimal data', () async {
        // Arrange
        const ipAddress = '192.168.1.100';
        const responseBody = '''
        {
          "online": true,
          "ip": "192.168.1.100",
          "port": 25565
        }
        ''';

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        // Assert
        expect(result, isNotNull);
        expect(
            result!.hostname, equals('192.168.1.100')); // Should fallback to IP
        expect(result.ip, equals('192.168.1.100'));
        expect(result.port, equals(25565));
        expect(result.version, equals('Unknown'));
        expect(result.protocol, equals('Unknown'));
        expect(result.playersOnline, equals(0));
        expect(result.playersMax, equals(0));
        expect(result.motd, isNull);
        expect(result.software, isNull);
        expect(result.players, isNull);
      });

      test('should handle server with custom port', () async {
        // Arrange
        const ipAddress = '192.168.1.100:25566';
        const responseBody = '''
        {
          "online": true,
          "ip": "192.168.1.100",
          "port": 25566,
          "hostname": "Custom Port Server",
          "version": "1.19.4"
        }
        ''';

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        // Assert
        expect(result, isNotNull);
        expect(result!.hostname, equals('Custom Port Server'));
        expect(result.port, equals(25566));
        expect(result.version, equals('1.19.4'));
      });

      test('should handle server with complex MOTD', () async {
        // Arrange
        const ipAddress = '192.168.1.100';
        const responseBody = '''
        {
          "online": true,
          "ip": "192.168.1.100",
          "port": 25565,
          "motd": {
            "clean": ["Welcome to", "My Server!"],
            "raw": ["§6Welcome to", "§aMy Server!"]
          }
        }
        ''';

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        // Assert
        expect(result, isNotNull);
        expect(result!.motd, equals('Welcome to My Server!'));
      });

      test('should handle server with only raw MOTD', () async {
        // Arrange
        const ipAddress = '192.168.1.100';
        const responseBody = '''
        {
          "online": true,
          "ip": "192.168.1.100",
          "port": 25565,
          "motd": {
            "raw": ["§6Raw MOTD", "§aOnly"]
          }
        }
        ''';

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        // Assert
        expect(result, isNotNull);
        expect(result!.motd, equals('§6Raw MOTD §aOnly'));
      });

      test('should handle server with empty MOTD', () async {
        // Arrange
        const ipAddress = '192.168.1.100';
        const responseBody = '''
        {
          "online": true,
          "ip": "192.168.1.100",
          "port": 25565,
          "motd": {
            "clean": [],
            "raw": []
          }
        }
        ''';

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        // Assert
        expect(result, isNotNull);
        expect(result!.motd, isNull);
      });

      test('should handle server with players list', () async {
        // Arrange
        const ipAddress = '192.168.1.100';
        const responseBody = '''
        {
          "online": true,
          "ip": "192.168.1.100",
          "port": 25565,
          "players": {
            "online": 3,
            "max": 10,
            "list": ["Alice", "Bob", "Charlie"]
          }
        }
        ''';

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        // Assert
        expect(result, isNotNull);
        expect(result!.playersOnline, equals(3));
        expect(result.playersMax, equals(10));
        expect(result.players, equals(['Alice', 'Bob', 'Charlie']));
      });

      test('should handle server without players list', () async {
        // Arrange
        const ipAddress = '192.168.1.100';
        const responseBody = '''
        {
          "online": true,
          "ip": "192.168.1.100",
          "port": 25565,
          "players": {
            "online": 5,
            "max": 20
          }
        }
        ''';

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        // Assert
        expect(result, isNotNull);
        expect(result!.playersOnline, equals(5));
        expect(result.playersMax, equals(20));
        expect(result.players, isNull);
      });

      test('should handle malformed JSON response', () async {
        // Arrange
        const ipAddress = '192.168.1.100';
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('invalid json', 200));

        // Act
        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        // Assert
        expect(result, isNull);
      });

      test('should handle empty response body', () async {
        // Arrange
        const ipAddress = '192.168.1.100';
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('', 200));

        // Act
        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        // Assert
        expect(result, isNull);
      });

      test('should handle null values in response', () async {
        // Arrange
        const ipAddress = '192.168.1.100';
        const responseBody = '''
        {
          "online": true,
          "ip": null,
          "port": null,
          "hostname": null,
          "version": null,
          "protocol": null,
          "players": null,
          "motd": null,
          "software": null
        }
        ''';

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        // Assert
        expect(result, isNotNull);
        expect(result!.hostname, equals('Unknown'));
        expect(result.ip, equals('Unknown'));
        expect(result.port, equals(25565)); // Default port
        expect(result.version, equals('Unknown'));
        expect(result.protocol, equals('Unknown'));
        expect(result.playersOnline, equals(0));
        expect(result.playersMax, equals(0));
        expect(result.motd, isNull);
        expect(result.software, isNull);
        expect(result.players, isNull);
      });
    });

    group('MinecraftServerInfo', () {
      test('should create instance with all properties', () {
        // Arrange
        const serverInfo = MinecraftServerInfo(
          hostname: 'Test Server',
          ip: '192.168.1.100',
          port: 25565,
          version: '1.20.1',
          protocol: '763',
          playersOnline: 5,
          playersMax: 20,
          motd: 'Welcome to Test Server',
          software: 'Paper',
          players: ['Player1', 'Player2'],
        );

        // Assert
        expect(serverInfo.hostname, equals('Test Server'));
        expect(serverInfo.ip, equals('192.168.1.100'));
        expect(serverInfo.port, equals(25565));
        expect(serverInfo.version, equals('1.20.1'));
        expect(serverInfo.protocol, equals('763'));
        expect(serverInfo.playersOnline, equals(5));
        expect(serverInfo.playersMax, equals(20));
        expect(serverInfo.motd, equals('Welcome to Test Server'));
        expect(serverInfo.software, equals('Paper'));
        expect(serverInfo.players, equals(['Player1', 'Player2']));
      });

      test('should create instance with minimal properties', () {
        // Arrange
        const serverInfo = MinecraftServerInfo(
          hostname: 'Minimal Server',
          ip: '192.168.1.100',
          port: 25565,
          version: '1.20.1',
          protocol: '763',
          playersOnline: 0,
          playersMax: 0,
        );

        // Assert
        expect(serverInfo.hostname, equals('Minimal Server'));
        expect(serverInfo.ip, equals('192.168.1.100'));
        expect(serverInfo.port, equals(25565));
        expect(serverInfo.version, equals('1.20.1'));
        expect(serverInfo.protocol, equals('763'));
        expect(serverInfo.playersOnline, equals(0));
        expect(serverInfo.playersMax, equals(0));
        expect(serverInfo.motd, isNull);
        expect(serverInfo.software, isNull);
        expect(serverInfo.players, isNull);
      });

      test('should parse JSON correctly', () {
        // Arrange
        const json = {
          'hostname': 'JSON Server',
          'ip': '192.168.1.100',
          'port': 25565,
          'version': '1.20.1',
          'protocol': 763,
          'players': {
            'online': 3,
            'max': 10,
            'list': ['Alice', 'Bob']
          },
          'motd': {
            'clean': ['Welcome to JSON Server'],
            'raw': ['§6Welcome to JSON Server']
          },
          'software': 'Vanilla'
        };

        // Act
        final serverInfo = MinecraftServerInfo.fromJson(json);

        // Assert
        expect(serverInfo.hostname, equals('JSON Server'));
        expect(serverInfo.ip, equals('192.168.1.100'));
        expect(serverInfo.port, equals(25565));
        expect(serverInfo.version, equals('1.20.1'));
        expect(serverInfo.protocol, equals('763'));
        expect(serverInfo.playersOnline, equals(3));
        expect(serverInfo.playersMax, equals(10));
        expect(serverInfo.motd, equals('Welcome to JSON Server'));
        expect(serverInfo.software, equals('Vanilla'));
        expect(serverInfo.players, equals(['Alice', 'Bob']));
      });

      test('should handle missing fields in JSON', () {
        // Arrange
        const json = <String, dynamic>{};

        // Act
        final serverInfo = MinecraftServerInfo.fromJson(json);

        // Assert
        expect(serverInfo.hostname, equals('Unknown'));
        expect(serverInfo.ip, equals('Unknown'));
        expect(serverInfo.port, equals(25565));
        expect(serverInfo.version, equals('Unknown'));
        expect(serverInfo.protocol, equals('Unknown'));
        expect(serverInfo.playersOnline, equals(0));
        expect(serverInfo.playersMax, equals(0));
        expect(serverInfo.motd, isNull);
        expect(serverInfo.software, isNull);
        expect(serverInfo.players, isNull);
      });

      test('should handle null values in JSON', () {
        // Arrange
        const json = {
          'hostname': null,
          'ip': null,
          'port': null,
          'version': null,
          'protocol': null,
          'players': null,
          'motd': null,
          'software': null,
        };

        // Act
        final serverInfo = MinecraftServerInfo.fromJson(json);

        // Assert
        expect(serverInfo.hostname, equals('Unknown'));
        expect(serverInfo.ip, equals('Unknown'));
        expect(serverInfo.port, equals(25565));
        expect(serverInfo.version, equals('Unknown'));
        expect(serverInfo.protocol, equals('Unknown'));
        expect(serverInfo.playersOnline, equals(0));
        expect(serverInfo.playersMax, equals(0));
        expect(serverInfo.motd, isNull);
        expect(serverInfo.software, isNull);
        expect(serverInfo.players, isNull);
      });
    });

    group('error handling', () {
      test('should handle timeout gracefully', () async {
        // Arrange
        const ipAddress = '192.168.1.100';
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Timeout'));

        // Act
        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        // Assert
        expect(result, isNull);
      });

      test('should handle invalid IP address format', () async {
        // Arrange
        const ipAddress = 'invalid-ip-address';
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('{"online": false}', 200));

        // Act
        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        // Assert
        expect(result, isNull);
      });

      test('should handle empty IP address', () async {
        // Arrange
        const ipAddress = '';
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('{"online": false}', 200));

        // Act
        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        // Assert
        expect(result, isNull);
      });
    });
  });
}
