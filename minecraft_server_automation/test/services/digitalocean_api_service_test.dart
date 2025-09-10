import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:minecraft_server_automation/services/digitalocean_api_service.dart';
import 'package:minecraft_server_automation/services/logging_service.dart';
import 'package:minecraft_server_automation/models/droplet_creation_request.dart';
import 'package:minecraft_server_automation/models/droplet_size.dart';
import 'package:minecraft_server_automation/models/region.dart';
import 'package:minecraft_server_automation/models/log_entry.dart';
import 'digitalocean_api_service_test.mocks.dart';

// Generate mocks for external dependencies
@GenerateMocks([http.Client, LoggingService])
void main() {
  group('DigitalOceanApiService Tests', () {
    late MockClient mockHttpClient;
    late MockLoggingService mockLoggingService;
    const String testApiKey = 'test-api-key-123';

    setUp(() {
      mockHttpClient = MockClient();
      mockLoggingService = MockLoggingService();
      
      // Set the mock client for testing
      DigitalOceanApiService.setClient(mockHttpClient);
      
      // Mock the LoggingService static instance
      // Note: This is a challenge with static services, but we'll work around it
    });

    tearDown(() {
      // Reset the client after each test
      DigitalOceanApiService.setClient(http.Client());
    });

    group('validateApiKey', () {
      test('should return true for valid API key', () async {
        // Arrange
        final mockResponse = http.Response(
          json.encode({
            'account': {
              'email': 'test@example.com',
              'uuid': 'test-uuid',
              'status': 'active'
            }
          }),
          200,
        );
        
        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await DigitalOceanApiService.validateApiKey(testApiKey);

        // Assert
        expect(result, isTrue);
        verify(mockHttpClient.get(
          Uri.parse('https://api.digitalocean.com/v2/account'),
          headers: {
            'Authorization': 'Bearer $testApiKey',
            'Content-Type': 'application/json',
          },
        )).called(1);
      });

      test('should return false for invalid API key', () async {
        // Arrange
        final mockResponse = http.Response(
          json.encode({'error': 'Unauthorized'}),
          401,
        );
        
        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await DigitalOceanApiService.validateApiKey(testApiKey);

        // Assert
        expect(result, isFalse);
        verify(mockHttpClient.get(
          Uri.parse('https://api.digitalocean.com/v2/account'),
          headers: {
            'Authorization': 'Bearer $testApiKey',
            'Content-Type': 'application/json',
          },
        )).called(1);
      });

      test('should return false when request times out', () async {
        // Arrange
        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Timeout'));

        // Act
        final result = await DigitalOceanApiService.validateApiKey(testApiKey);

        // Assert
        expect(result, isFalse);
      });

      test('should return false when network error occurs', () async {
        // Arrange
        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Network error'));

        // Act
        final result = await DigitalOceanApiService.validateApiKey(testApiKey);

        // Assert
        expect(result, isFalse);
      });
    });

    group('getAccountInfo', () {
      test('should return account info for valid API key', () async {
        // Arrange
        final accountData = {
          'email': 'test@example.com',
          'uuid': 'test-uuid',
          'status': 'active',
          'droplet_limit': 10,
          'floating_ip_limit': 3
        };
        
        final mockResponse = http.Response(
          json.encode({'account': accountData}),
          200,
        );
        
        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await DigitalOceanApiService.getAccountInfo(testApiKey);

        // Assert
        expect(result, equals(accountData));
        verify(mockHttpClient.get(
          Uri.parse('https://api.digitalocean.com/v2/account'),
          headers: {
            'Authorization': 'Bearer $testApiKey',
            'Content-Type': 'application/json',
          },
        )).called(1);
      });

      test('should throw exception for invalid API key', () async {
        // Arrange
        final mockResponse = http.Response(
          json.encode({'error': 'Unauthorized'}),
          401,
        );
        
        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => DigitalOceanApiService.getAccountInfo(testApiKey),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when request fails', () async {
        // Arrange
        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => DigitalOceanApiService.getAccountInfo(testApiKey),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getDroplets', () {
      test('should return list of droplets for valid API key', () async {
        // Arrange
        final dropletsData = [
          {
            'id': 12345,
            'name': 'test-droplet-1',
            'status': 'active',
            'region': {'slug': 'nyc1'},
            'size': {'slug': 's-1vcpu-1gb'},
            'image': {'slug': 'ubuntu-20-04-x64'}
          },
          {
            'id': 12346,
            'name': 'test-droplet-2',
            'status': 'active',
            'region': {'slug': 'lon1'},
            'size': {'slug': 's-2vcpu-2gb'},
            'image': {'slug': 'ubuntu-22-04-x64'}
          }
        ];
        
        final mockResponse = http.Response(
          json.encode({'droplets': dropletsData}),
          200,
        );
        
        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await DigitalOceanApiService.getDroplets(testApiKey);

        // Assert
        expect(result, equals(dropletsData));
        expect(result.length, equals(2));
        verify(mockHttpClient.get(
          Uri.parse('https://api.digitalocean.com/v2/droplets'),
          headers: {
            'Authorization': 'Bearer $testApiKey',
            'Content-Type': 'application/json',
          },
        )).called(1);
      });

      test('should throw exception for invalid API key', () async {
        // Arrange
        final mockResponse = http.Response(
          json.encode({'error': 'Unauthorized'}),
          401,
        );
        
        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => DigitalOceanApiService.getDroplets(testApiKey),
          throwsA(isA<Exception>()),
        );
      });

      test('should return empty list when no droplets exist', () async {
        // Arrange
        final mockResponse = http.Response(
          json.encode({'droplets': []}),
          200,
        );
        
        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await DigitalOceanApiService.getDroplets(testApiKey);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getDropletSizes', () {
      test('should return list of droplet sizes', () async {
        // Arrange
        final sizesData = [
          {
            'slug': 's-1vcpu-1gb',
            'memory': 1024,
            'vcpus': 1,
            'disk': 25,
            'transfer': 1.0,
            'price_monthly': 5.0,
            'price_hourly': 0.007,
            'regions': ['nyc1', 'lon1'],
            'available': true,
            'description': 'Basic Droplet'
          },
          {
            'slug': 's-2vcpu-2gb',
            'memory': 2048,
            'vcpus': 2,
            'disk': 50,
            'transfer': 2.0,
            'price_monthly': 10.0,
            'price_hourly': 0.014,
            'regions': ['nyc1', 'lon1', 'sfo1'],
            'available': true,
            'description': 'Standard Droplet'
          }
        ];
        
        final mockResponse = http.Response(
          json.encode({'sizes': sizesData}),
          200,
        );
        
        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await DigitalOceanApiService.getDropletSizes(testApiKey);

        // Assert
        expect(result, isA<List<DropletSize>>());
        expect(result.length, equals(2));
        expect(result.first.slug, equals('s-1vcpu-1gb'));
        expect(result.first.memory, equals(1024));
        expect(result.first.vcpus, equals(1));
        expect(result.first.priceMonthly, equals(5.0));
        expect(result.first.available, isTrue);
        
        verify(mockHttpClient.get(
          Uri.parse('https://api.digitalocean.com/v2/sizes?per_page=200'),
          headers: {
            'Authorization': 'Bearer $testApiKey',
            'Content-Type': 'application/json',
          },
        )).called(1);
      });

      test('should throw exception for invalid API key', () async {
        // Arrange
        final mockResponse = http.Response(
          json.encode({'error': 'Unauthorized'}),
          401,
        );
        
        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => DigitalOceanApiService.getDropletSizes(testApiKey),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getRegions', () {
      test('should return list of regions', () async {
        // Arrange
        final regionsData = [
          {
            'name': 'New York 1',
            'slug': 'nyc1',
            'features': ['virtio', 'private_networking', 'backups', 'ipv6', 'metadata'],
            'available': true
          },
          {
            'name': 'London 1',
            'slug': 'lon1',
            'features': ['virtio', 'private_networking', 'backups', 'ipv6', 'metadata'],
            'available': true
          }
        ];
        
        final mockResponse = http.Response(
          json.encode({'regions': regionsData}),
          200,
        );
        
        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await DigitalOceanApiService.getRegions(testApiKey);

        // Assert
        expect(result, isA<List<Region>>());
        expect(result.length, equals(2));
        expect(result.first.name, equals('New York 1'));
        expect(result.first.slug, equals('nyc1'));
        expect(result.first.available, isTrue);
        expect(result.first.features, contains('virtio'));
        
        verify(mockHttpClient.get(
          Uri.parse('https://api.digitalocean.com/v2/regions'),
          headers: {
            'Authorization': 'Bearer $testApiKey',
            'Content-Type': 'application/json',
          },
        )).called(1);
      });

      test('should throw exception for invalid API key', () async {
        // Arrange
        final mockResponse = http.Response(
          json.encode({'error': 'Unauthorized'}),
          401,
        );
        
        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => DigitalOceanApiService.getRegions(testApiKey),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('fetchImages', () {
      test('should return list of images', () async {
        // Arrange
        final imagesData = [
          {
            'id': 12345,
            'name': 'Ubuntu 20.04 (LTS) x64',
            'slug': 'ubuntu-20-04-x64',
            'distribution': 'Ubuntu',
            'version': '20.04',
            'type': 'snapshot',
            'min_disk_size': 20,
            'created_at': '2020-04-23T00:00:00Z',
            'status': 'available'
          },
          {
            'id': 12346,
            'name': 'Ubuntu 22.04 (LTS) x64',
            'slug': 'ubuntu-22-04-x64',
            'distribution': 'Ubuntu',
            'version': '22.04',
            'type': 'snapshot',
            'min_disk_size': 20,
            'created_at': '2022-04-21T00:00:00Z',
            'status': 'available'
          }
        ];
        
        final mockResponse = http.Response(
          json.encode({'images': imagesData}),
          200,
        );
        
        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await DigitalOceanApiService.fetchImages(testApiKey);

        // Assert
        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, equals(2));
        expect(result.first['name'], equals('Ubuntu 20.04 (LTS) x64'));
        expect(result.first['slug'], equals('ubuntu-20-04-x64'));
        expect(result.first['status'], equals('available'));
        
        verify(mockHttpClient.get(
          Uri.parse('https://api.digitalocean.com/v2/images?per_page=200'),
          headers: {
            'Authorization': 'Bearer $testApiKey',
            'Content-Type': 'application/json',
          },
        )).called(1);
      });

      test('should throw exception for invalid API key', () async {
        // Arrange
        final mockResponse = http.Response(
          json.encode({'error': 'Unauthorized'}),
          401,
        );
        
        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => DigitalOceanApiService.fetchImages(testApiKey),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when images array is missing', () async {
        // Arrange
        final mockResponse = http.Response(
          json.encode({'data': 'invalid'}),
          200,
        );
        
        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => DigitalOceanApiService.fetchImages(testApiKey),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('createDroplet', () {
      test('should create droplet successfully', () async {
        // Arrange
        final request = DropletCreationRequest(
          name: 'test-droplet',
          region: 'nyc1',
          size: 's-1vcpu-1gb',
          image: 'ubuntu-20-04-x64',
          sshKeys: ['ssh-key-1'],
          backups: true,
          ipv6: true,
          monitoring: true,
          tags: ['test', 'minecraft'],
          userData: '#!/bin/bash\necho "Hello World"',
        );
        
        final dropletData = {
          'id': 12345,
          'name': 'test-droplet',
          'status': 'new',
          'region': {'slug': 'nyc1'},
          'size': {'slug': 's-1vcpu-1gb'},
          'image': {'slug': 'ubuntu-20-04-x64'},
          'created_at': '2023-01-01T00:00:00Z'
        };
        
        final mockResponse = http.Response(
          json.encode({'droplet': dropletData}),
          202,
        );
        
        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await DigitalOceanApiService.createDroplet(testApiKey, request);

        // Assert
        expect(result, equals(dropletData));
        expect(result['id'], equals(12345));
        expect(result['name'], equals('test-droplet'));
        expect(result['status'], equals('new'));
        
        verify(mockHttpClient.post(
          Uri.parse('https://api.digitalocean.com/v2/droplets'),
          headers: {
            'Authorization': 'Bearer $testApiKey',
            'Content-Type': 'application/json',
          },
          body: json.encode(request.toJson()),
        )).called(1);
      });

      test('should throw exception for invalid API key', () async {
        // Arrange
        final request = DropletCreationRequest(
          name: 'test-droplet',
          region: 'nyc1',
          size: 's-1vcpu-1gb',
          image: 'ubuntu-20-04-x64',
        );
        
        final mockResponse = http.Response(
          json.encode({'error': 'Unauthorized'}),
          401,
        );
        
        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => DigitalOceanApiService.createDroplet(testApiKey, request),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when droplet data is missing from response', () async {
        // Arrange
        final request = DropletCreationRequest(
          name: 'test-droplet',
          region: 'nyc1',
          size: 's-1vcpu-1gb',
          image: 'ubuntu-20-04-x64',
        );
        
        final mockResponse = http.Response(
          json.encode({'data': 'invalid'}),
          202,
        );
        
        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => DigitalOceanApiService.createDroplet(testApiKey, request),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle request with minimal required fields', () async {
        // Arrange
        final request = DropletCreationRequest(
          name: 'minimal-droplet',
          region: 'nyc1',
          size: 's-1vcpu-1gb',
          image: 'ubuntu-20-04-x64',
        );
        
        final dropletData = {
          'id': 12346,
          'name': 'minimal-droplet',
          'status': 'new',
          'region': {'slug': 'nyc1'},
          'size': {'slug': 's-1vcpu-1gb'},
          'image': {'slug': 'ubuntu-20-04-x64'},
        };
        
        final mockResponse = http.Response(
          json.encode({'droplet': dropletData}),
          202,
        );
        
        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await DigitalOceanApiService.createDroplet(testApiKey, request);

        // Assert
        expect(result, equals(dropletData));
        
        // Verify the JSON body contains only required fields
        final capturedBody = verify(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: captureAnyNamed('body'),
        )).captured.first as String;
        
        final bodyJson = json.decode(capturedBody);
        expect(bodyJson['name'], equals('minimal-droplet'));
        expect(bodyJson['region'], equals('nyc1'));
        expect(bodyJson['size'], equals('s-1vcpu-1gb'));
        expect(bodyJson['image'], equals('ubuntu-20-04-x64'));
        expect(bodyJson['backups'], equals(false));
        expect(bodyJson['ipv6'], equals(true));
        expect(bodyJson['monitoring'], equals(true));
        expect(bodyJson.containsKey('ssh_keys'), isFalse);
        expect(bodyJson.containsKey('tags'), isFalse);
        expect(bodyJson.containsKey('user_data'), isFalse);
        expect(bodyJson.containsKey('vpc_uuid'), isFalse);
      });
    });

    group('HTTP Client Management', () {
      test('should use custom client when set', () async {
        // Arrange
        final customClient = MockClient();
        DigitalOceanApiService.setClient(customClient);
        
        final mockResponse = http.Response(
          json.encode({'account': {'email': 'test@example.com'}}),
          200,
        );
        
        when(customClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        await DigitalOceanApiService.validateApiKey(testApiKey);

        // Assert
        verify(customClient.get(any, headers: anyNamed('headers'))).called(1);
        verifyNever(mockHttpClient.get(any, headers: anyNamed('headers')));
      });

      test('should reset to default client when new client is set', () async {
        // Arrange
        final firstClient = MockClient();
        final secondClient = MockClient();
        
        DigitalOceanApiService.setClient(firstClient);
        DigitalOceanApiService.setClient(secondClient);
        
        final mockResponse = http.Response(
          json.encode({'account': {'email': 'test@example.com'}}),
          200,
        );
        
        when(secondClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        await DigitalOceanApiService.validateApiKey(testApiKey);

        // Assert
        verify(secondClient.get(any, headers: anyNamed('headers'))).called(1);
        verifyNever(firstClient.get(any, headers: anyNamed('headers')));
      });
    });

    group('Error Handling', () {
      test('should handle JSON decode errors gracefully', () async {
        // Arrange
        final mockResponse = http.Response('invalid json', 200);
        
        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => DigitalOceanApiService.getAccountInfo(testApiKey),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle timeout errors', () async {
        // Arrange
        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Timeout'));

        // Act & Assert
        expect(
          () => DigitalOceanApiService.getAccountInfo(testApiKey),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle network errors', () async {
        // Arrange
        when(mockHttpClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Network unreachable'));

        // Act & Assert
        expect(
          () => DigitalOceanApiService.getAccountInfo(testApiKey),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
