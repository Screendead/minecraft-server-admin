import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:app/services/digitalocean_api_service.dart';

import 'digitalocean_api_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('DigitalOceanApiService', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      DigitalOceanApiService.setClient(mockClient);
    });

    tearDown(() {
      DigitalOceanApiService.setClient(http.Client());
    });

    group('validateApiKey', () {
      test('should return true for valid API key', () async {
        const apiKey = 'valid-api-key';
        final mockResponse = http.Response('''
        {
          "account": {
            "droplet_limit": 10,
            "floating_ip_limit": 3,
            "email": "test@example.com",
            "uuid": "12345678-1234-1234-1234-123456789012",
            "email_verified": true,
            "status": "active"
          }
        }
        ''', 200);

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        final result = await DigitalOceanApiService.validateApiKey(apiKey);

        expect(result, isTrue);
        verify(mockClient.get(
          Uri.parse('https://api.digitalocean.com/v2/account'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        )).called(1);
      });

      test('should return false for invalid API key', () async {
        const apiKey = 'invalid-api-key';
        final mockResponse = http.Response('''
        {
          "id": "unauthorized",
          "message": "Unable to authenticate you"
        }
        ''', 401);

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        final result = await DigitalOceanApiService.validateApiKey(apiKey);

        expect(result, isFalse);
      });

      test('should return false for network error', () async {
        const apiKey = 'test-api-key';

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Network error'));

        final result = await DigitalOceanApiService.validateApiKey(apiKey);

        expect(result, isFalse);
      });
    });

    group('getAccountInfo', () {
      test('should return account info for valid API key', () async {
        const apiKey = 'valid-api-key';
        final mockResponse = http.Response('''
        {
          "account": {
            "droplet_limit": 10,
            "floating_ip_limit": 3,
            "email": "test@example.com",
            "uuid": "12345678-1234-1234-1234-123456789012",
            "email_verified": true,
            "status": "active"
          }
        }
        ''', 200);

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        final result = await DigitalOceanApiService.getAccountInfo(apiKey);

        expect(result, isA<Map<String, dynamic>>());
        expect(result, isNotEmpty);
      });

      test('should throw exception for invalid API key', () async {
        const apiKey = 'invalid-api-key';
        final mockResponse = http.Response('''
        {
          "id": "unauthorized",
          "message": "Unable to authenticate you"
        }
        ''', 401);

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        expect(() => DigitalOceanApiService.getAccountInfo(apiKey),
            throwsException);
      });

      test('should throw exception for network error', () async {
        const apiKey = 'test-api-key';

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Network error'));

        expect(() => DigitalOceanApiService.getAccountInfo(apiKey),
            throwsException);
      });
    });

    group('getDroplets', () {
      test('should return droplets for valid API key', () async {
        const apiKey = 'valid-api-key';
        final mockResponse = http.Response('''
        {
          "droplets": [
            {
              "id": 12345678,
              "name": "test-droplet",
              "memory": 1024,
              "vcpus": 1,
              "disk": 25,
              "locked": false,
              "status": "active",
              "size_slug": "s-1vcpu-1gb"
            }
          ],
          "links": {},
          "meta": {
            "total": 1
          }
        }
        ''', 200);

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        final result = await DigitalOceanApiService.getDroplets(apiKey);

        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, equals(1));
        expect(result[0]['id'], equals(12345678));
        expect(result[0]['name'], equals('test-droplet'));
        expect(result[0]['status'], equals('active'));
      });

      test('should throw exception for invalid API key', () async {
        const apiKey = 'invalid-api-key';
        final mockResponse = http.Response('''
        {
          "id": "unauthorized",
          "message": "Unable to authenticate you"
        }
        ''', 401);

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        expect(
            () => DigitalOceanApiService.getDroplets(apiKey), throwsException);
      });

      test('should throw exception for network error', () async {
        const apiKey = 'test-api-key';

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Network error'));

        expect(
            () => DigitalOceanApiService.getDroplets(apiKey), throwsException);
      });
    });

    group('getDropletSizes', () {
      test('should return droplet sizes for valid API key', () async {
        const apiKey = 'valid-api-key';
        final mockResponse = http.Response('''
        {
          "sizes": [
            {
              "slug": "s-1vcpu-1gb",
              "memory": 1024,
              "vcpus": 1,
              "disk": 25,
              "transfer": 1000,
              "price_monthly": 5.0,
              "price_hourly": 0.00744,
              "regions": ["nyc1", "sfo1"],
              "available": true
            }
          ],
          "links": {},
          "meta": {
            "total": 1
          }
        }
        ''', 200);

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        final result = await DigitalOceanApiService.getDropletSizes(apiKey);

        expect(result, isA<List<DropletSize>>());
        expect(result.length, equals(1));
        expect(result[0].slug, equals('s-1vcpu-1gb'));
        expect(result[0].memory, equals(1024));
        expect(result[0].vcpus, equals(1));
        expect(result[0].priceMonthly, equals(5.0));
      });

      test('should throw exception for invalid API key', () async {
        const apiKey = 'invalid-api-key';
        final mockResponse = http.Response('''
        {
          "id": "unauthorized",
          "message": "Unable to authenticate you"
        }
        ''', 401);

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        expect(() => DigitalOceanApiService.getDropletSizes(apiKey),
            throwsException);
      });
    });

    group('getRegions', () {
      test('should return regions for valid API key', () async {
        const apiKey = 'valid-api-key';
        final mockResponse = http.Response('''
        {
          "regions": [
            {
              "name": "New York 1",
              "slug": "nyc1",
              "sizes": ["s-1vcpu-1gb", "s-2vcpu-2gb"],
              "features": ["virtio", "private_networking", "backups", "ipv6", "metadata"],
              "available": true
            }
          ],
          "links": {},
          "meta": {
            "total": 1
          }
        }
        ''', 200);

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        final result = await DigitalOceanApiService.getRegions(apiKey);

        expect(result, isA<List<Region>>());
        expect(result.length, equals(1));
        expect(result[0].name, equals('New York 1'));
        expect(result[0].slug, equals('nyc1'));
        expect(result[0].available, isTrue);
      });

      test('should throw exception for invalid API key', () async {
        const apiKey = 'invalid-api-key';
        final mockResponse = http.Response('''
        {
          "id": "unauthorized",
          "message": "Unable to authenticate you"
        }
        ''', 401);

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        expect(
            () => DigitalOceanApiService.getRegions(apiKey), throwsException);
      });
    });

    group('Data Classes', () {
      test('DropletSize should create instance correctly', () {
        final size = DropletSize(
          slug: 's-1vcpu-1gb',
          memory: 1024,
          vcpus: 1,
          disk: 25,
          transfer: 1000,
          priceMonthly: 5.0,
          priceHourly: 0.00744,
          regions: ['nyc1', 'sfo1'],
          available: true,
          description: '1 vCPU, 1GB RAM, 25GB SSD',
        );

        expect(size.slug, equals('s-1vcpu-1gb'));
        expect(size.memory, equals(1024));
        expect(size.vcpus, equals(1));
        expect(size.disk, equals(25));
        expect(size.transfer, equals(1000));
        expect(size.priceMonthly, equals(5.0));
        expect(size.priceHourly, equals(0.00744));
        expect(size.regions, equals(['nyc1', 'sfo1']));
        expect(size.available, isTrue);
        expect(size.description, equals('1 vCPU, 1GB RAM, 25GB SSD'));
      });

      test('Region should create instance correctly', () {
        final region = Region(
          name: 'New York 1',
          slug: 'nyc1',
          features: ['virtio', 'private_networking', 'backups'],
          available: true,
        );

        expect(region.name, equals('New York 1'));
        expect(region.slug, equals('nyc1'));
        expect(region.features,
            equals(['virtio', 'private_networking', 'backups']));
        expect(region.available, isTrue);
      });
    });
  });
}
