import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:app/services/digitalocean_api_service.dart';
import 'package:app/services/logging_service.dart';
import 'package:app/models/log_entry.dart';

import 'digitalocean_api_service_fetch_images_test.mocks.dart';

@GenerateMocks([http.Client, LoggingService])
void main() {
  group('DigitalOceanApiService.fetchImages', () {
    late MockClient mockClient;
    late MockLoggingService mockLoggingService;

    setUp(() {
      mockClient = MockClient();
      mockLoggingService = MockLoggingService();
      
      // Set the mock client
      DigitalOceanApiService.setClient(mockClient);
    });

    tearDown(() {
      DigitalOceanApiService.setClient(http.Client());
    });

    test('should fetch images successfully', () async {
      // Arrange
      const apiKey = 'test-api-key';
      final responseBody = {
        'images': [
          {
            'id': 12345,
            'name': 'Ubuntu 22.04 (LTS) x64',
            'distribution': 'Ubuntu',
            'slug': 'ubuntu-22-04-x64',
            'public': true,
            'regions': ['nyc1', 'nyc2', 'nyc3'],
            'created_at': '2022-04-21T00:00:00Z',
            'min_disk_size': 20,
            'type': 'snapshot',
            'size_gigabytes': 2.34,
            'description': 'Ubuntu 22.04 LTS x64',
            'tags': ['ubuntu', '22.04', 'lts'],
            'status': 'available',
            'error_message': null,
          },
          {
            'id': 12346,
            'name': 'Ubuntu 20.04 (LTS) x64',
            'distribution': 'Ubuntu',
            'slug': 'ubuntu-20-04-x64',
            'public': true,
            'regions': ['nyc1', 'nyc2', 'nyc3'],
            'created_at': '2020-04-23T00:00:00Z',
            'min_disk_size': 20,
            'type': 'snapshot',
            'size_gigabytes': 2.34,
            'description': 'Ubuntu 20.04 LTS x64',
            'tags': ['ubuntu', '20.04', 'lts'],
            'status': 'available',
            'error_message': null,
          },
          {
            'id': 12347,
            'name': 'CentOS 8 x64',
            'distribution': 'CentOS',
            'slug': 'centos-8-x64',
            'public': true,
            'regions': ['nyc1', 'nyc2', 'nyc3'],
            'created_at': '2019-09-24T00:00:00Z',
            'min_disk_size': 20,
            'type': 'snapshot',
            'size_gigabytes': 2.34,
            'description': 'CentOS 8 x64',
            'tags': ['centos', '8'],
            'status': 'available',
            'error_message': null,
          },
        ]
      };

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
        json.encode(responseBody),
        200,
        headers: {'content-type': 'application/json'},
      ));

      // Act
      final result = await DigitalOceanApiService.fetchImages(apiKey);

      // Assert
      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.length, 3);
      expect(result[0]['name'], 'Ubuntu 22.04 (LTS) x64');
      expect(result[0]['distribution'], 'Ubuntu');
      expect(result[0]['slug'], 'ubuntu-22-04-x64');
      expect(result[1]['name'], 'Ubuntu 20.04 (LTS) x64');
      expect(result[2]['name'], 'CentOS 8 x64');

      // Verify the request was made correctly
      verify(mockClient.get(
        Uri.parse('https://api.digitalocean.com/v2/images?per_page=200'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      )).called(1);
    });

    test('should throw exception on API error', () async {
      // Arrange
      const apiKey = 'test-api-key';
      final errorResponse = {
        'id': 'unauthorized',
        'message': 'Unable to authenticate you',
        'request_id': 'test-request-id',
      };

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
        json.encode(errorResponse),
        401,
        headers: {'content-type': 'application/json'},
      ));

      // Act & Assert
      try {
        await DigitalOceanApiService.fetchImages(apiKey);
        fail('Expected exception to be thrown');
      } catch (e) {
        expect(e, isA<Exception>());
      }

      // Verify the request was made
      verify(mockClient.get(
        Uri.parse('https://api.digitalocean.com/v2/images?per_page=200'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      )).called(1);
    });

    test('should throw exception on network error', () async {
      // Arrange
      const apiKey = 'test-api-key';

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => DigitalOceanApiService.fetchImages(apiKey),
        throwsA(isA<Exception>()),
      );
    });


    test('should handle invalid JSON response', () async {
      // Arrange
      const apiKey = 'test-api-key';

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
        'invalid json',
        200,
        headers: {'content-type': 'application/json'},
      ));

      // Act & Assert
      expect(
        () => DigitalOceanApiService.fetchImages(apiKey),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle missing images array in response', () async {
      // Arrange
      const apiKey = 'test-api-key';
      final responseBody = {
        'message': 'Images fetched successfully',
        // Missing 'images' key
      };

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
        json.encode(responseBody),
        200,
        headers: {'content-type': 'application/json'},
      ));

      // Act & Assert
      try {
        await DigitalOceanApiService.fetchImages(apiKey);
        fail('Expected exception to be thrown for missing images array');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('should handle empty images array', () async {
      // Arrange
      const apiKey = 'test-api-key';
      final responseBody = {
        'images': [],
      };

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
        json.encode(responseBody),
        200,
        headers: {'content-type': 'application/json'},
      ));

      // Act
      final result = await DigitalOceanApiService.fetchImages(apiKey);

      // Assert
      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.length, 0);
    });

    test('should handle different HTTP status codes', () async {
      // Arrange
      const apiKey = 'test-api-key';
      final testCases = [
        (400, 'Bad Request'),
        (403, 'Forbidden'),
        (404, 'Not Found'),
        (429, 'Too Many Requests'),
        (500, 'Internal Server Error'),
      ];

      for (final (statusCode, description) in testCases) {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          '{"error": "$description"}',
          statusCode,
          headers: {'content-type': 'application/json'},
        ));

        // Act & Assert
        expect(
          () => DigitalOceanApiService.fetchImages(apiKey),
          throwsA(isA<Exception>()),
          reason: 'Should throw for status code $statusCode',
        );
      }
    });
  });
}
