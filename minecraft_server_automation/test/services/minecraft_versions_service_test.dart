import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:minecraft_server_automation/services/minecraft_versions_service.dart';
import 'package:minecraft_server_automation/models/minecraft_version.dart';

import 'minecraft_versions_service_test.mocks.dart';

// Generate mocks for HTTP client
@GenerateMocks([http.Client, http.Response])
void main() {
  group('MinecraftVersionsService', () {
    late MockClient mockClient;
    late MockResponse mockResponse;

    setUp(() {
      mockClient = MockClient();
      mockResponse = MockResponse();

      // Reset the static client for each test
      MinecraftVersionsService.setClient(mockClient);
    });

    tearDown(() {
      // Reset the static client after each test
      MinecraftVersionsService.setClient(http.Client());
    });

    group('getMinecraftVersions', () {
      test('should return sorted versions when API call succeeds', () async {
        // Mock successful response
        final mockJsonResponse = {
          'versions': [
            {
              'id': '1.20.1',
              'type': 'release',
              'url':
                  'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json',
              'time': '2023-06-12T10:00:00+00:00',
              'releaseTime': '2023-06-12T10:00:00+00:00',
            },
            {
              'id': '23w16a',
              'type': 'snapshot',
              'url':
                  'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json',
              'time': '2023-04-19T10:00:00+00:00',
              'releaseTime': '2023-04-19T10:00:00+00:00',
            },
            {
              'id': '1.19.4',
              'type': 'release',
              'url':
                  'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json',
              'time': '2023-03-14T10:00:00+00:00',
              'releaseTime': '2023-03-14T10:00:00+00:00',
            },
          ]
        };

        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.body).thenReturn(json.encode(mockJsonResponse));
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        final result = await MinecraftVersionsService.getMinecraftVersions();

        expect(result, isA<List<MinecraftVersion>>());
        expect(result.length, equals(3));

        // Check that versions are sorted by release time (newest first)
        expect(result[0].id, equals('1.20.1'));
        expect(result[1].id, equals('23w16a'));
        expect(result[2].id, equals('1.19.4'));

        // Check that only release and snapshot types are included
        expect(result.every((v) => v.type == 'release' || v.type == 'snapshot'),
            isTrue);

        verify(mockClient.get(
          Uri.parse(
              'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json'),
          headers: {'Content-Type': 'application/json'},
        )).called(1);
      });

      test('should throw exception when API returns non-200 status', () async {
        when(mockResponse.statusCode).thenReturn(404);
        when(mockResponse.body).thenReturn('Not Found');
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        expect(
          () => MinecraftVersionsService.getMinecraftVersions(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to fetch Minecraft versions: 404'),
          )),
        );

        verify(mockClient.get(
          Uri.parse(
              'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json'),
          headers: {'Content-Type': 'application/json'},
        )).called(1);
      });

      test('should throw exception when network request fails', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Network error'));

        expect(
          () => MinecraftVersionsService.getMinecraftVersions(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Network error'),
          )),
        );
      });

      test('should throw exception when JSON parsing fails', () async {
        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.body).thenReturn('invalid json');
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        expect(
          () => MinecraftVersionsService.getMinecraftVersions(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Error fetching Minecraft versions'),
          )),
        );
      });

      test('should filter out non-release and non-snapshot versions', () async {
        final mockJsonResponse = {
          'versions': [
            {
              'id': '1.20.1',
              'type': 'release',
              'url':
                  'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json',
              'time': '2023-06-12T10:00:00+00:00',
              'releaseTime': '2023-06-12T10:00:00+00:00',
            },
            {
              'id': '23w16a',
              'type': 'snapshot',
              'url':
                  'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json',
              'time': '2023-04-19T10:00:00+00:00',
              'releaseTime': '2023-04-19T10:00:00+00:00',
            },
            {
              'id': 'old_beta',
              'type': 'old_beta',
              'url':
                  'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json',
              'time': '2010-12-20T10:00:00+00:00',
              'releaseTime': '2010-12-20T10:00:00+00:00',
            },
            {
              'id': 'old_alpha',
              'type': 'old_alpha',
              'url':
                  'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json',
              'time': '2010-06-30T10:00:00+00:00',
              'releaseTime': '2010-06-30T10:00:00+00:00',
            },
          ]
        };

        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.body).thenReturn(json.encode(mockJsonResponse));
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        final result = await MinecraftVersionsService.getMinecraftVersions();

        expect(result.length, equals(2));
        expect(result.any((v) => v.id == '1.20.1'), isTrue);
        expect(result.any((v) => v.id == '23w16a'), isTrue);
        expect(result.any((v) => v.id == 'old_beta'), isFalse);
        expect(result.any((v) => v.id == 'old_alpha'), isFalse);
      });
    });

    group('getReleaseVersions', () {
      test('should return only release versions', () async {
        final mockJsonResponse = {
          'versions': [
            {
              'id': '1.20.1',
              'type': 'release',
              'url':
                  'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json',
              'time': '2023-06-12T10:00:00+00:00',
              'releaseTime': '2023-06-12T10:00:00+00:00',
            },
            {
              'id': '23w16a',
              'type': 'snapshot',
              'url':
                  'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json',
              'time': '2023-04-19T10:00:00+00:00',
              'releaseTime': '2023-04-19T10:00:00+00:00',
            },
            {
              'id': '1.19.4',
              'type': 'release',
              'url':
                  'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json',
              'time': '2023-03-14T10:00:00+00:00',
              'releaseTime': '2023-03-14T10:00:00+00:00',
            },
          ]
        };

        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.body).thenReturn(json.encode(mockJsonResponse));
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        final result = await MinecraftVersionsService.getReleaseVersions();

        expect(result, isA<List<MinecraftVersion>>());
        expect(result.length, equals(2));
        expect(result.every((v) => v.type == 'release'), isTrue);
        expect(result.any((v) => v.id == '1.20.1'), isTrue);
        expect(result.any((v) => v.id == '1.19.4'), isTrue);
        expect(result.any((v) => v.id == '23w16a'), isFalse);
      });

      test('should throw exception when getMinecraftVersions fails', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Network error'));

        expect(
          () => MinecraftVersionsService.getReleaseVersions(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Network error'),
          )),
        );
      });
    });

    group('getSnapshotVersions', () {
      test('should return only snapshot versions', () async {
        final mockJsonResponse = {
          'versions': [
            {
              'id': '1.20.1',
              'type': 'release',
              'url':
                  'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json',
              'time': '2023-06-12T10:00:00+00:00',
              'releaseTime': '2023-06-12T10:00:00+00:00',
            },
            {
              'id': '23w16a',
              'type': 'snapshot',
              'url':
                  'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json',
              'time': '2023-04-19T10:00:00+00:00',
              'releaseTime': '2023-04-19T10:00:00+00:00',
            },
            {
              'id': '23w15a',
              'type': 'snapshot',
              'url':
                  'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json',
              'time': '2023-04-12T10:00:00+00:00',
              'releaseTime': '2023-04-12T10:00:00+00:00',
            },
          ]
        };

        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.body).thenReturn(json.encode(mockJsonResponse));
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        final result = await MinecraftVersionsService.getSnapshotVersions();

        expect(result, isA<List<MinecraftVersion>>());
        expect(result.length, equals(2));
        expect(result.every((v) => v.type == 'snapshot'), isTrue);
        expect(result.any((v) => v.id == '23w16a'), isTrue);
        expect(result.any((v) => v.id == '23w15a'), isTrue);
        expect(result.any((v) => v.id == '1.20.1'), isFalse);
      });

      test('should throw exception when getMinecraftVersions fails', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Network error'));

        expect(
          () => MinecraftVersionsService.getSnapshotVersions(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Network error'),
          )),
        );
      });
    });

    group('getServerJarUrlForVersion', () {
      test('should return server JAR URL for valid version', () async {
        // Mock the version manifest response
        final versionManifestResponse = {
          'versions': [
            {
              'id': '1.20.1',
              'type': 'release',
              'url':
                  'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json',
              'time': '2023-06-12T10:00:00+00:00',
              'releaseTime': '2023-06-12T10:00:00+00:00',
            },
          ]
        };

        final versionDetailsResponse = {
          'downloads': {
            'server': {
              'url':
                  'https://launcher.mojang.com/v1/objects/103874b7986691c6c6d582c0ba42be4df21e38d2/server.jar',
              'sha1': '103874b7986691c6c6d582c0ba42be4df21e38d2',
              'size': 12345678,
            }
          }
        };

        // Mock the calls in sequence using a counter
        var callCount = 0;
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((invocation) async {
          final response = MockResponse();
          callCount++;

          if (callCount == 1) {
            // First call - version manifest
            when(response.statusCode).thenReturn(200);
            when(response.body)
                .thenReturn(json.encode(versionManifestResponse));
          } else {
            // Second call - version details
            when(response.statusCode).thenReturn(200);
            when(response.body).thenReturn(json.encode(versionDetailsResponse));
          }

          return response;
        });

        final result =
            await MinecraftVersionsService.getServerJarUrlForVersion('1.20.1');

        expect(
            result,
            equals(
                'https://launcher.mojang.com/v1/objects/103874b7986691c6c6d582c0ba42be4df21e38d2/server.jar'));

        verify(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).called(2);
      });

      test('should throw exception when version not found', () async {
        final versionManifestResponse = {
          'versions': [
            {
              'id': '1.20.1',
              'type': 'release',
              'url':
                  'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json',
              'time': '2023-06-12T10:00:00+00:00',
              'releaseTime': '2023-06-12T10:00:00+00:00',
            },
          ]
        };

        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.body)
            .thenReturn(json.encode(versionManifestResponse));
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        expect(
          () =>
              MinecraftVersionsService.getServerJarUrlForVersion('nonexistent'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Version nonexistent not found'),
          )),
        );
      });

      test('should throw exception when getMinecraftVersions fails', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Network error'));

        expect(
          () => MinecraftVersionsService.getServerJarUrlForVersion('1.20.1'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Network error'),
          )),
        );
      });
    });

    group('setClient', () {
      test('should allow setting custom HTTP client', () {
        final customClient = MockClient();
        MinecraftVersionsService.setClient(customClient);

        // This test verifies that setClient doesn't throw
        expect(customClient, isNotNull);
      });
    });
  });
}
