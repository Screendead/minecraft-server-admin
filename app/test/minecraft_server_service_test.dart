import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
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

    test(
        'checkMinecraftServer returns MinecraftServerInfo when server is online',
        () async {
      // Arrange
      const ipAddress = '192.168.1.100';
      final mockResponse = http.Response('''
        {
          "online": true,
          "ip": "$ipAddress",
          "port": 25565,
          "hostname": "Test Server",
          "version": "1.20.1",
          "protocol": 763,
          "players": {
            "online": 5,
            "max": 20,
            "list": ["Player1", "Player2"]
          },
          "motd": {
            "clean": ["A Minecraft Server"],
            "raw": ["§bA Minecraft Server"]
          },
          "software": "Paper"
        }
      ''', 200);

      when(mockClient.get(
        Uri.parse('https://api.mcsrvstat.us/2/$ipAddress'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result =
          await MinecraftServerService.checkMinecraftServer(ipAddress);

      // Assert
      expect(result, isNotNull);
      expect(result!.ip, equals(ipAddress));
      expect(result.port, equals(25565));
      expect(result.hostname, equals('Test Server'));
      expect(result.version, equals('1.20.1'));
      expect(result.protocol, equals('763'));
      expect(result.playersOnline, equals(5));
      expect(result.playersMax, equals(20));
      expect(result.software, equals('Paper'));
      expect(result.motd, equals('A Minecraft Server'));
      expect(result.players, equals(['Player1', 'Player2']));
    });

    test('checkMinecraftServer returns null when server is offline', () async {
      // Arrange
      const ipAddress = '192.168.1.100';
      final mockResponse = http.Response('''
        {
          "online": false
        }
      ''', 200);

      when(mockClient.get(
        Uri.parse('https://api.mcsrvstat.us/2/$ipAddress'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result =
          await MinecraftServerService.checkMinecraftServer(ipAddress);

      // Assert
      expect(result, isNull);
    });

    test('checkMinecraftServer returns null when API returns error status',
        () async {
      // Arrange
      const ipAddress = '192.168.1.100';
      final mockResponse = http.Response('Not Found', 404);

      when(mockClient.get(
        Uri.parse('https://api.mcsrvstat.us/2/$ipAddress'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result =
          await MinecraftServerService.checkMinecraftServer(ipAddress);

      // Assert
      expect(result, isNull);
    });

    test('checkMinecraftServer returns null when network error occurs',
        () async {
      // Arrange
      const ipAddress = '192.168.1.100';

      when(mockClient.get(
        Uri.parse('https://api.mcsrvstat.us/2/$ipAddress'),
        headers: anyNamed('headers'),
      )).thenThrow(Exception('Network error'));

      // Act
      final result =
          await MinecraftServerService.checkMinecraftServer(ipAddress);

      // Assert
      expect(result, isNull);
    });

    test('checkMinecraftServer handles missing optional fields', () async {
      // Arrange
      const ipAddress = '192.168.1.100';
      final mockResponse = http.Response('''
        {
          "online": true,
          "ip": "$ipAddress",
          "port": 25565,
          "hostname": "Test Server",
          "version": "1.20.1",
          "protocol": 763,
          "players": {
            "online": 0,
            "max": 0
          }
        }
      ''', 200);

      when(mockClient.get(
        Uri.parse('https://api.mcsrvstat.us/2/$ipAddress'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result =
          await MinecraftServerService.checkMinecraftServer(ipAddress);

      // Assert
      expect(result, isNotNull);
      expect(result!.ip, equals(ipAddress));
      expect(result.port, equals(25565));
      expect(result.hostname, equals('Test Server'));
      expect(result.version, equals('1.20.1'));
      expect(result.protocol, equals('763'));
      expect(result.playersOnline, equals(0));
      expect(result.playersMax, equals(0));
      expect(result.software, isNull);
      expect(result.motd, isNull);
      expect(result.players, isNull);
    });
  });

  group('MinecraftServerInfo', () {
    test('fromJson creates instance with all fields', () {
      // Arrange
      final json = {
        'ip': '192.168.1.100',
        'port': 25565,
        'hostname': 'Test Server',
        'version': '1.20.1',
        'protocol': 763,
        'players': {
          'online': 5,
          'max': 20,
          'list': ['Player1', 'Player2']
        },
        'motd': {
          'clean': ['A Minecraft Server'],
          'raw': ['§bA Minecraft Server']
        },
        'software': 'Paper'
      };

      // Act
      final result = MinecraftServerInfo.fromJson(json);

      // Assert
      expect(result.ip, equals('192.168.1.100'));
      expect(result.port, equals(25565));
      expect(result.hostname, equals('Test Server'));
      expect(result.version, equals('1.20.1'));
      expect(result.protocol, equals('763'));
      expect(result.playersOnline, equals(5));
      expect(result.playersMax, equals(20));
      expect(result.software, equals('Paper'));
      expect(result.motd, equals('A Minecraft Server'));
      expect(result.players, equals(['Player1', 'Player2']));
    });

    test('fromJson handles missing fields with defaults', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final result = MinecraftServerInfo.fromJson(json);

      // Assert
      expect(result.ip, equals('Unknown'));
      expect(result.port, equals(25565));
      expect(result.hostname, equals('Unknown'));
      expect(result.version, equals('Unknown'));
      expect(result.protocol, equals('Unknown'));
      expect(result.playersOnline, equals(0));
      expect(result.playersMax, equals(0));
      expect(result.software, isNull);
      expect(result.motd, isNull);
      expect(result.players, isNull);
    });
  });
}
