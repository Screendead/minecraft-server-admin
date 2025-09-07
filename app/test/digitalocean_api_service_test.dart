import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
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

    group('validateApiKey', () {
      test('returns true for valid API key (200 response)', () async {
        // Arrange
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('{"account": {}}', 200));

        // Act
        final result = await DigitalOceanApiService.validateApiKey('valid-key');

        // Assert
        expect(result, true);
      });

      test('returns false for invalid API key (401 response)', () async {
        // Arrange
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer(
            (_) async => http.Response('{"id": "unauthorized"}', 401));

        // Act
        final result =
            await DigitalOceanApiService.validateApiKey('invalid-key');

        // Assert
        expect(result, false);
      });

      test('returns false for network error', () async {
        // Arrange
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Network error'));

        // Act
        final result = await DigitalOceanApiService.validateApiKey('any-key');

        // Assert
        expect(result, false);
      });

      test('returns false for timeout', () async {
        // Arrange
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => Future.delayed(
              const Duration(seconds: 15),
              () => http.Response('{"account": {}}', 200),
            ));

        // Act
        final result = await DigitalOceanApiService.validateApiKey('any-key');

        // Assert
        expect(result, false);
      });
    });

    group('getAccountInfo', () {
      test('returns account info for valid API key', () async {
        // Arrange
        final expectedAccount = {
          'uuid': 'test-uuid',
          'email': 'test@example.com',
          'status': 'active',
        };
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
              '{"account": {"uuid": "test-uuid", "email": "test@example.com", "status": "active"}}',
              200,
            ));

        // Act
        final result = await DigitalOceanApiService.getAccountInfo('valid-key');

        // Assert
        expect(result, expectedAccount);
      });

      test('throws exception for invalid API key', () async {
        // Arrange
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer(
            (_) async => http.Response('{"id": "unauthorized"}', 401));

        // Act & Assert
        expect(
          () => DigitalOceanApiService.getAccountInfo('invalid-key'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
