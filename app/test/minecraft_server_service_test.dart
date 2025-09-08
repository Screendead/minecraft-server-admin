import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:app/services/minecraft_server_service.dart';

import 'minecraft_server_service_test.mocks.dart';

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
      test('should return server info for online server', () async {
        const ipAddress = '192.168.1.100';
        final mockResponse = http.Response('''
        {
          "online": true,
          "hostname": "test.server.com",
          "ip": "192.168.1.100",
          "port": 25565,
          "version": "1.20.1",
          "protocol": 763,
          "players": {
            "online": 5,
            "max": 20,
            "list": ["Player1", "Player2"]
          },
          "motd": {
            "clean": ["Welcome to our server!"],
            "raw": ["§aWelcome to our server!"]
          },
          "software": "Paper"
        }
        ''', 200);

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        expect(result, isNotNull);
        expect(result!.hostname, equals('test.server.com'));
        expect(result.ip, equals('192.168.1.100'));
        expect(result.port, equals(25565));
        expect(result.version, equals('1.20.1'));
        expect(result.protocol, equals('763'));
        expect(result.playersOnline, equals(5));
        expect(result.playersMax, equals(20));
        expect(result.motd, equals('Welcome to our server!'));
        expect(result.software, equals('Paper'));
        expect(result.players, equals(['Player1', 'Player2']));
      });

      test('should return null for offline server', () async {
        const ipAddress = '192.168.1.100';
        final mockResponse = http.Response('''
        {
          "online": false
        }
        ''', 200);

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        expect(result, isNull);
      });

      test('should return null for non-200 status code', () async {
        const ipAddress = '192.168.1.100';
        final mockResponse = http.Response('Not Found', 404);

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        expect(result, isNull);
      });

      test('should return null for network error', () async {
        const ipAddress = '192.168.1.100';

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Network error'));

        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        expect(result, isNull);
      });

      test('should handle malformed JSON', () async {
        const ipAddress = '192.168.1.100';
        final mockResponse = http.Response('invalid json', 200);

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        expect(result, isNull);
      });

      test('should handle missing fields in JSON', () async {
        const ipAddress = '192.168.1.100';
        final mockResponse = http.Response('''
        {
          "online": true
        }
        ''', 200);

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        expect(result, isNotNull);
        expect(result!.hostname, equals('Unknown'));
        expect(result.ip, equals('Unknown'));
        expect(result.port, equals(25565));
        expect(result.version, equals('Unknown'));
        expect(result.protocol, equals('Unknown'));
        expect(result.playersOnline, equals(0));
        expect(result.playersMax, equals(0));
        expect(result.motd, isNull);
        expect(result.software, isNull);
        expect(result.players, isNull);
      });

      test('should handle partial player data', () async {
        const ipAddress = '192.168.1.100';
        final mockResponse = http.Response('''
        {
          "online": true,
          "hostname": "test.server.com",
          "ip": "192.168.1.100",
          "port": 25565,
          "version": "1.20.1",
          "protocol": 763,
          "players": {
            "online": 3,
            "max": 20
          }
        }
        ''', 200);

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        expect(result, isNotNull);
        expect(result!.playersOnline, equals(3));
        expect(result.playersMax, equals(20));
        expect(result.players, isNull);
      });

      test('should handle motd with clean text', () async {
        const ipAddress = '192.168.1.100';
        final mockResponse = http.Response('''
        {
          "online": true,
          "hostname": "test.server.com",
          "ip": "192.168.1.100",
          "port": 25565,
          "version": "1.20.1",
          "protocol": 763,
          "players": {
            "online": 0,
            "max": 20
          },
          "motd": {
            "clean": ["Welcome to our server!", "Have fun!"]
          }
        }
        ''', 200);

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        expect(result, isNotNull);
        expect(result!.motd, equals('Welcome to our server! Have fun!'));
      });

      test('should handle motd with raw text when clean is empty', () async {
        const ipAddress = '192.168.1.100';
        final mockResponse = http.Response('''
        {
          "online": true,
          "hostname": "test.server.com",
          "ip": "192.168.1.100",
          "port": 25565,
          "version": "1.20.1",
          "protocol": 763,
          "players": {
            "online": 0,
            "max": 20
          },
          "motd": {
            "clean": [],
            "raw": ["§aWelcome to our server!", "§bHave fun!"]
          }
        }
        ''', 200);

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        expect(result, isNotNull);
        expect(result!.motd, equals('§aWelcome to our server! §bHave fun!'));
      });

      test('should handle empty motd', () async {
        const ipAddress = '192.168.1.100';
        final mockResponse = http.Response('''
        {
          "online": true,
          "hostname": "test.server.com",
          "ip": "192.168.1.100",
          "port": 25565,
          "version": "1.20.1",
          "protocol": 763,
          "players": {
            "online": 0,
            "max": 20
          },
          "motd": {
            "clean": [],
            "raw": []
          }
        }
        ''', 200);

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        expect(result, isNotNull);
        expect(result!.motd, isNull);
      });

      test('should handle null motd', () async {
        const ipAddress = '192.168.1.100';
        final mockResponse = http.Response('''
        {
          "online": true,
          "hostname": "test.server.com",
          "ip": "192.168.1.100",
          "port": 25565,
          "version": "1.20.1",
          "protocol": 763,
          "players": {
            "online": 0,
            "max": 20
          }
        }
        ''', 200);

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        expect(result, isNotNull);
        expect(result!.motd, isNull);
      });

      test('should use correct URL and headers', () async {
        const ipAddress = '192.168.1.100';
        final mockResponse = http.Response('{"online": false}', 200);

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        await MinecraftServerService.checkMinecraftServer(ipAddress);

        verify(mockClient.get(
          Uri.parse('https://api.mcsrvstat.us/2/192.168.1.100'),
          headers: {'Content-Type': 'application/json'},
        )).called(1);
      });
    });

    group('MinecraftServerInfo', () {
      test('should create instance with all fields', () {
        const info = MinecraftServerInfo(
          hostname: 'test.server.com',
          ip: '192.168.1.100',
          port: 25565,
          version: '1.20.1',
          protocol: '763',
          playersOnline: 5,
          playersMax: 20,
          motd: 'Welcome!',
          software: 'Paper',
          players: ['Player1', 'Player2'],
        );

        expect(info.hostname, equals('test.server.com'));
        expect(info.ip, equals('192.168.1.100'));
        expect(info.port, equals(25565));
        expect(info.version, equals('1.20.1'));
        expect(info.protocol, equals('763'));
        expect(info.playersOnline, equals(5));
        expect(info.playersMax, equals(20));
        expect(info.motd, equals('Welcome!'));
        expect(info.software, equals('Paper'));
        expect(info.players, equals(['Player1', 'Player2']));
      });

      test('should create instance with minimal fields', () {
        const info = MinecraftServerInfo(
          hostname: 'test.server.com',
          ip: '192.168.1.100',
          port: 25565,
          version: '1.20.1',
          protocol: '763',
          playersOnline: 0,
          playersMax: 20,
        );

        expect(info.hostname, equals('test.server.com'));
        expect(info.ip, equals('192.168.1.100'));
        expect(info.port, equals(25565));
        expect(info.version, equals('1.20.1'));
        expect(info.protocol, equals('763'));
        expect(info.playersOnline, equals(0));
        expect(info.playersMax, equals(20));
        expect(info.motd, isNull);
        expect(info.software, isNull);
        expect(info.players, isNull);
      });

      test('should parse from JSON with all fields', () {
        final json = {
          'hostname': 'test.server.com',
          'ip': '192.168.1.100',
          'port': 25565,
          'version': '1.20.1',
          'protocol': 763,
          'players': {
            'online': 5,
            'max': 20,
            'list': ['Player1', 'Player2']
          },
          'motd': {
            'clean': ['Welcome to our server!']
          },
          'software': 'Paper'
        };

        final info = MinecraftServerInfo.fromJson(json);

        expect(info.hostname, equals('test.server.com'));
        expect(info.ip, equals('192.168.1.100'));
        expect(info.port, equals(25565));
        expect(info.version, equals('1.20.1'));
        expect(info.protocol, equals('763'));
        expect(info.playersOnline, equals(5));
        expect(info.playersMax, equals(20));
        expect(info.motd, equals('Welcome to our server!'));
        expect(info.software, equals('Paper'));
        expect(info.players, equals(['Player1', 'Player2']));
      });

      test('should parse from JSON with missing fields', () {
        final json = {'online': true};

        final info = MinecraftServerInfo.fromJson(json);

        expect(info.hostname, equals('Unknown'));
        expect(info.ip, equals('Unknown'));
        expect(info.port, equals(25565));
        expect(info.version, equals('Unknown'));
        expect(info.protocol, equals('Unknown'));
        expect(info.playersOnline, equals(0));
        expect(info.playersMax, equals(0));
        expect(info.motd, isNull);
        expect(info.software, isNull);
        expect(info.players, isNull);
      });

      test('should handle null values in JSON', () {
        final json = {
          'hostname': null,
          'ip': null,
          'port': null,
          'version': null,
          'protocol': null,
          'players': null,
          'motd': null,
          'software': null,
        };

        final info = MinecraftServerInfo.fromJson(json);

        expect(info.hostname, equals('Unknown'));
        expect(info.ip, equals('Unknown'));
        expect(info.port, equals(25565));
        expect(info.version, equals('Unknown'));
        expect(info.protocol, equals('Unknown'));
        expect(info.playersOnline, equals(0));
        expect(info.playersMax, equals(0));
        expect(info.motd, isNull);
        expect(info.software, isNull);
        expect(info.players, isNull);
      });

      test('should handle empty motd arrays', () {
        final json = {
          'hostname': 'test.server.com',
          'ip': '192.168.1.100',
          'port': 25565,
          'version': '1.20.1',
          'protocol': 763,
          'players': {'online': 0, 'max': 20},
          'motd': {'clean': [], 'raw': []}
        };

        final info = MinecraftServerInfo.fromJson(json);

        expect(info.motd, isNull);
      });

      test('should handle motd with only raw text', () {
        final json = {
          'hostname': 'test.server.com',
          'ip': '192.168.1.100',
          'port': 25565,
          'version': '1.20.1',
          'protocol': 763,
          'players': {'online': 0, 'max': 20},
          'motd': {
            'raw': ['§aWelcome!', '§bHave fun!']
          }
        };

        final info = MinecraftServerInfo.fromJson(json);

        expect(info.motd, equals('§aWelcome! §bHave fun!'));
      });
    });

    group('Edge cases', () {
      test('should handle empty IP address', () async {
        final mockResponse = http.Response('{"online": false}', 200);

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        final result = await MinecraftServerService.checkMinecraftServer('');

        expect(result, isNull);
      });

      test('should handle IP address with port', () async {
        const ipAddress = '192.168.1.100:25565';
        final mockResponse = http.Response('{"online": false}', 200);

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        expect(result, isNull);
        verify(mockClient.get(
          Uri.parse('https://api.mcsrvstat.us/2/192.168.1.100:25565'),
          headers: anyNamed('headers'),
        )).called(1);
      });

      test('should handle domain names', () async {
        const ipAddress = 'minecraft.example.com';
        final mockResponse = http.Response('{"online": false}', 200);

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        final result =
            await MinecraftServerService.checkMinecraftServer(ipAddress);

        expect(result, isNull);
        verify(mockClient.get(
          Uri.parse('https://api.mcsrvstat.us/2/minecraft.example.com'),
          headers: anyNamed('headers'),
        )).called(1);
      });
    });
  });
}
