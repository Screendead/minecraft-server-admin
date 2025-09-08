import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:app/services/minecraft_versions_service.dart';

import 'minecraft_versions_service_get_server_jar_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('MinecraftVersionsService.getServerJarUrlForVersion', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      MinecraftVersionsService.setClient(mockClient);
    });

    tearDown(() {
      MinecraftVersionsService.setClient(http.Client());
    });

    test('should fetch server JAR URL for valid version', () async {
      // Arrange
      const versionId = '1.20.1';
      const manifestUrl = 'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json';
      const versionManifestUrl = 'https://piston-meta.mojang.com/v1/packages/abc123/1.20.1.json';
      const serverJarUrl = 'https://piston-data.mojang.com/v1/objects/def456/server.jar';

      // Mock version manifest response
      final versionManifestResponse = {
        'versions': [
          {
            'id': versionId,
            'type': 'release',
            'url': versionManifestUrl,
            'time': '2023-06-12T10:00:00+00:00',
            'releaseTime': '2023-06-12T10:00:00+00:00',
            'sha1': 'abc123',
            'complianceLevel': 0,
          }
        ]
      };

      // Mock version-specific manifest response
      final versionSpecificResponse = {
        'downloads': {
          'server': {
            'url': serverJarUrl,
            'sha1': 'def456',
            'size': 12345678,
          }
        }
      };

      when(mockClient.get(
        Uri.parse(manifestUrl),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
        json.encode(versionManifestResponse),
        200,
        headers: {'content-type': 'application/json'},
      ));

      when(mockClient.get(
        Uri.parse(versionManifestUrl),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
        json.encode(versionSpecificResponse),
        200,
        headers: {'content-type': 'application/json'},
      ));

      // Act
      final result = await MinecraftVersionsService.getServerJarUrlForVersion(versionId);

      // Assert
      expect(result, serverJarUrl);

      // Verify both requests were made
      verify(mockClient.get(
        Uri.parse(manifestUrl),
        headers: {'Content-Type': 'application/json'},
      )).called(1);

      verify(mockClient.get(
        Uri.parse(versionManifestUrl),
        headers: {'Content-Type': 'application/json'},
      )).called(1);
    });

    test('should throw exception for non-existent version', () async {
      // Arrange
      const versionId = 'non-existent-version';
      const manifestUrl = 'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json';

      final versionManifestResponse = {
        'versions': [
          {
            'id': '1.20.1',
            'type': 'release',
            'url': 'https://example.com/version.json',
            'time': '2023-06-12T10:00:00+00:00',
            'releaseTime': '2023-06-12T10:00:00+00:00',
            'sha1': 'abc123',
            'complianceLevel': 0,
          }
        ]
      };

      when(mockClient.get(
        Uri.parse(manifestUrl),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
        json.encode(versionManifestResponse),
        200,
        headers: {'content-type': 'application/json'},
      ));

      // Act & Assert
      expect(
        () => MinecraftVersionsService.getServerJarUrlForVersion(versionId),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw exception when version manifest fetch fails', () async {
      // Arrange
      const versionId = '1.20.1';
      const manifestUrl = 'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json';

      when(mockClient.get(
        Uri.parse(manifestUrl),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
        'Server Error',
        500,
        headers: {'content-type': 'application/json'},
      ));

      // Act & Assert
      expect(
        () => MinecraftVersionsService.getServerJarUrlForVersion(versionId),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw exception when version-specific manifest fetch fails', () async {
      // Arrange
      const versionId = '1.20.1';
      const manifestUrl = 'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json';
      const versionManifestUrl = 'https://piston-meta.mojang.com/v1/packages/abc123/1.20.1.json';

      final versionManifestResponse = {
        'versions': [
          {
            'id': versionId,
            'type': 'release',
            'url': versionManifestUrl,
            'time': '2023-06-12T10:00:00+00:00',
            'releaseTime': '2023-06-12T10:00:00+00:00',
            'sha1': 'abc123',
            'complianceLevel': 0,
          }
        ]
      };

      when(mockClient.get(
        Uri.parse(manifestUrl),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
        json.encode(versionManifestResponse),
        200,
        headers: {'content-type': 'application/json'},
      ));

      when(mockClient.get(
        Uri.parse(versionManifestUrl),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
        'Not Found',
        404,
        headers: {'content-type': 'application/json'},
      ));

      // Act & Assert
      expect(
        () => MinecraftVersionsService.getServerJarUrlForVersion(versionId),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw exception when downloads section is missing', () async {
      // Arrange
      const versionId = '1.20.1';
      const manifestUrl = 'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json';
      const versionManifestUrl = 'https://piston-meta.mojang.com/v1/packages/abc123/1.20.1.json';

      final versionManifestResponse = {
        'versions': [
          {
            'id': versionId,
            'type': 'release',
            'url': versionManifestUrl,
            'time': '2023-06-12T10:00:00+00:00',
            'releaseTime': '2023-06-12T10:00:00+00:00',
            'sha1': 'abc123',
            'complianceLevel': 0,
          }
        ]
      };

      final versionSpecificResponse = {
        // Missing 'downloads' section
        'id': versionId,
        'type': 'release',
      };

      when(mockClient.get(
        Uri.parse(manifestUrl),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
        json.encode(versionManifestResponse),
        200,
        headers: {'content-type': 'application/json'},
      ));

      when(mockClient.get(
        Uri.parse(versionManifestUrl),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
        json.encode(versionSpecificResponse),
        200,
        headers: {'content-type': 'application/json'},
      ));

      // Act & Assert
      expect(
        () => MinecraftVersionsService.getServerJarUrlForVersion(versionId),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw exception when server download is missing', () async {
      // Arrange
      const versionId = '1.20.1';
      const manifestUrl = 'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json';
      const versionManifestUrl = 'https://piston-meta.mojang.com/v1/packages/abc123/1.20.1.json';

      final versionManifestResponse = {
        'versions': [
          {
            'id': versionId,
            'type': 'release',
            'url': versionManifestUrl,
            'time': '2023-06-12T10:00:00+00:00',
            'releaseTime': '2023-06-12T10:00:00+00:00',
            'sha1': 'abc123',
            'complianceLevel': 0,
          }
        ]
      };

      final versionSpecificResponse = {
        'downloads': {
          // Missing 'server' section
          'client': {
            'url': 'https://example.com/client.jar',
            'sha1': 'abc123',
            'size': 12345678,
          }
        }
      };

      when(mockClient.get(
        Uri.parse(manifestUrl),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
        json.encode(versionManifestResponse),
        200,
        headers: {'content-type': 'application/json'},
      ));

      when(mockClient.get(
        Uri.parse(versionManifestUrl),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
        json.encode(versionSpecificResponse),
        200,
        headers: {'content-type': 'application/json'},
      ));

      // Act & Assert
      expect(
        () => MinecraftVersionsService.getServerJarUrlForVersion(versionId),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw exception when server URL is empty', () async {
      // Arrange
      const versionId = '1.20.1';
      const manifestUrl = 'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json';
      const versionManifestUrl = 'https://piston-meta.mojang.com/v1/packages/abc123/1.20.1.json';

      final versionManifestResponse = {
        'versions': [
          {
            'id': versionId,
            'type': 'release',
            'url': versionManifestUrl,
            'time': '2023-06-12T10:00:00+00:00',
            'releaseTime': '2023-06-12T10:00:00+00:00',
            'sha1': 'abc123',
            'complianceLevel': 0,
          }
        ]
      };

      final versionSpecificResponse = {
        'downloads': {
          'server': {
            'url': '', // Empty URL
            'sha1': 'def456',
            'size': 12345678,
          }
        }
      };

      when(mockClient.get(
        Uri.parse(manifestUrl),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
        json.encode(versionManifestResponse),
        200,
        headers: {'content-type': 'application/json'},
      ));

      when(mockClient.get(
        Uri.parse(versionManifestUrl),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
        json.encode(versionSpecificResponse),
        200,
        headers: {'content-type': 'application/json'},
      ));

      // Act & Assert
      expect(
        () => MinecraftVersionsService.getServerJarUrlForVersion(versionId),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle network timeout', () async {
      // Arrange
      const versionId = '1.20.1';
      const manifestUrl = 'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json';

      when(mockClient.get(
        Uri.parse(manifestUrl),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 15));
        return http.Response('{}', 200);
      });

      // Act & Assert
      expect(
        () => MinecraftVersionsService.getServerJarUrlForVersion(versionId),
        throwsA(isA<Exception>()),
      );
    });
  });
}
