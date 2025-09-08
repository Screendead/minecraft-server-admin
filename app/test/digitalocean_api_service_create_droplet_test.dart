import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:app/services/digitalocean_api_service.dart';
import 'package:app/models/droplet_creation_request.dart';
import 'package:app/services/logging_service.dart';
import 'package:app/models/log_entry.dart';

import 'digitalocean_api_service_create_droplet_test.mocks.dart';

@GenerateMocks([http.Client, LoggingService])
void main() {
  group('DigitalOceanApiService.createDroplet', () {
    late MockClient mockClient;
    late MockLoggingService mockLoggingService;
    late DropletCreationRequest testRequest;

    setUp(() {
      mockClient = MockClient();
      mockLoggingService = MockLoggingService();

      // Set the mock client
      DigitalOceanApiService.setClient(mockClient);

      // Create test request
      testRequest = DropletCreationRequest(
        name: 'test-droplet',
        region: 'nyc3',
        size: 's-1vcpu-1gb',
        image: 'ubuntu-22-04-x64',
        tags: ['minecraft-server'],
      );
    });

    tearDown(() {
      DigitalOceanApiService.setClient(http.Client());
    });

    test('should create droplet successfully', () async {
      // Arrange
      const apiKey = 'test-api-key';
      final responseBody = {
        'droplet': {
          'id': 12345,
          'name': 'test-droplet',
          'region': {'slug': 'nyc3'},
          'size': {'slug': 's-1vcpu-1gb'},
          'image': {'slug': 'ubuntu-22-04-x64'},
          'status': 'new',
        }
      };

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
            json.encode(responseBody),
            202,
            headers: {'content-type': 'application/json'},
          ));

      // Act
      final result =
          await DigitalOceanApiService.createDroplet(apiKey, testRequest);

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['id'], 12345);
      expect(result['name'], 'test-droplet');
      expect(result['status'], 'new');

      // Verify the request was made correctly
      verify(mockClient.post(
        Uri.parse('https://api.digitalocean.com/v2/droplets'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(testRequest.toJson()),
      )).called(1);
    });

    test('should throw exception on API error', () async {
      // Arrange
      const apiKey = 'test-api-key';
      final errorResponse = {
        'id': 'unprocessable_entity',
        'message': 'The request was not valid',
        'request_id': 'test-request-id',
      };

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
            json.encode(errorResponse),
            422,
            headers: {'content-type': 'application/json'},
          ));

      // Act & Assert
      try {
        await DigitalOceanApiService.createDroplet(apiKey, testRequest);
        fail('Expected exception to be thrown');
      } catch (e) {
        expect(e, isA<Exception>());
      }

      // Verify the request was made
      verify(mockClient.post(
        Uri.parse('https://api.digitalocean.com/v2/droplets'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(testRequest.toJson()),
      )).called(1);
    });

    test('should throw exception on network error', () async {
      // Arrange
      const apiKey = 'test-api-key';

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => DigitalOceanApiService.createDroplet(apiKey, testRequest),
        throwsA(isA<Exception>()),
      );
    });


    test('should handle invalid JSON response', () async {
      // Arrange
      const apiKey = 'test-api-key';

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
            'invalid json',
            202,
            headers: {'content-type': 'application/json'},
          ));

      // Act & Assert
      expect(
        () => DigitalOceanApiService.createDroplet(apiKey, testRequest),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle missing droplet in response', () async {
      // Arrange
      const apiKey = 'test-api-key';
      final responseBody = {
        'message': 'Droplet created',
        // Missing 'droplet' key
      };

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
            json.encode(responseBody),
            202,
            headers: {'content-type': 'application/json'},
          ));

      // Act & Assert
      try {
        await DigitalOceanApiService.createDroplet(apiKey, testRequest);
        fail('Expected exception to be thrown for missing droplet');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('should create request with all optional parameters', () async {
      // Arrange
      const apiKey = 'test-api-key';
      final requestWithAllParams = DropletCreationRequest(
        name: 'test-droplet',
        region: 'nyc3',
        size: 's-1vcpu-1gb',
        image: 'ubuntu-22-04-x64',
        sshKeys: ['key1', 'key2'],
        backups: true,
        ipv6: false,
        monitoring: false,
        tags: ['tag1', 'tag2'],
        userData: 'test user data',
        vpcUuid: 'vpc-uuid',
      );

      final responseBody = {
        'droplet': {
          'id': 12345,
          'name': 'test-droplet',
          'status': 'new',
        }
      };

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
            json.encode(responseBody),
            202,
            headers: {'content-type': 'application/json'},
          ));

      // Act
      await DigitalOceanApiService.createDroplet(apiKey, requestWithAllParams);

      // Assert
      verify(mockClient.post(
        Uri.parse('https://api.digitalocean.com/v2/droplets'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestWithAllParams.toJson()),
      )).called(1);
    });

    test('should handle different HTTP status codes', () async {
      // Arrange
      const apiKey = 'test-api-key';
      final testCases = [
        (400, 'Bad Request'),
        (401, 'Unauthorized'),
        (403, 'Forbidden'),
        (404, 'Not Found'),
        (429, 'Too Many Requests'),
        (500, 'Internal Server Error'),
      ];

      for (final (statusCode, description) in testCases) {
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
              '{"error": "$description"}',
              statusCode,
              headers: {'content-type': 'application/json'},
            ));

        // Act & Assert
        expect(
          () => DigitalOceanApiService.createDroplet(apiKey, testRequest),
          throwsA(isA<Exception>()),
          reason: 'Should throw for status code $statusCode',
        );
      }
    });
  });
}
