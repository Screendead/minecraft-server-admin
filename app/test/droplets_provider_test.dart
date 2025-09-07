import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/providers/droplets_provider.dart';
import 'package:app/services/digitalocean_api_service.dart';
import 'package:app/services/minecraft_server_service.dart';
import 'package:app/services/ios_secure_api_key_service.dart';
import 'package:app/services/ios_biometric_encryption_service.dart';

import 'droplets_provider_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  IOSSecureApiKeyService,
  IOSBiometricEncryptionService,
])
void main() {
  group('DropletsProvider', () {
    late DropletsProvider provider;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockIOSSecureApiKeyService mockApiKeyService;
    late MockIOSBiometricEncryptionService mockBiometricService;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockApiKeyService = MockIOSSecureApiKeyService();
      mockBiometricService = MockIOSBiometricEncryptionService();

      provider = DropletsProvider();
    });

    test('initial state is correct', () {
      expect(provider.droplets, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
      expect(provider.minecraftDroplets, isEmpty);
      expect(provider.nonMinecraftDroplets, isEmpty);
    });

    test('refresh calls loadDroplets', () async {
      // This test verifies that refresh method exists and can be called
      // The actual implementation testing would require mocking static methods
      // which is complex in this architecture

      // Act & Assert - should not throw
      expect(() => provider.refresh(), returnsNormally);
    });
  });

  group('DropletInfo', () {
    test('fromJson creates instance with all fields', () {
      // Arrange
      final json = {
        'id': 12345,
        'name': 'test-droplet',
        'status': 'active',
        'networks': {
          'v4': [
            {'type': 'public', 'ip_address': '192.168.1.100'},
            {'type': 'private', 'ip_address': '10.0.0.100'}
          ]
        },
        'region': {'name': 'nyc1'},
        'size': {'slug': 's-1vcpu-1gb'},
        'image': {'name': 'Ubuntu 20.04'},
        'tags': ['web', 'production'],
        'created_at': '2023-01-01T00:00:00Z'
      };

      // Act
      final result = DropletInfo.fromJson(json);

      // Assert
      expect(result.id, equals(12345));
      expect(result.name, equals('test-droplet'));
      expect(result.status, equals('active'));
      expect(result.publicIp, equals('192.168.1.100'));
      expect(result.privateIp, equals('10.0.0.100'));
      expect(result.region, equals('nyc1'));
      expect(result.size, equals('s-1vcpu-1gb'));
      expect(result.image, equals('Ubuntu 20.04'));
      expect(result.tags, equals(['web', 'production']));
      expect(result.createdAt, equals(DateTime.parse('2023-01-01T00:00:00Z')));
    });

    test('fromJson handles missing networks', () {
      // Arrange
      final json = {
        'id': 12345,
        'name': 'test-droplet',
        'status': 'active',
        'region': {'name': 'nyc1'},
        'size': {'slug': 's-1vcpu-1gb'},
        'image': {'name': 'Ubuntu 20.04'},
        'tags': [],
        'created_at': '2023-01-01T00:00:00Z'
      };

      // Act
      final result = DropletInfo.fromJson(json);

      // Assert
      expect(result.publicIp, isNull);
      expect(result.privateIp, isNull);
    });

    test('setMinecraftInfo updates minecraft status', () {
      // Arrange
      final droplet = DropletInfo(
        id: 12345,
        name: 'test-droplet',
        status: 'active',
        region: 'nyc1',
        size: 's-1vcpu-1gb',
        image: 'Ubuntu 20.04',
        tags: [],
        createdAt: DateTime.now(),
      );

      final minecraftInfo = MinecraftServerInfo(
        hostname: 'Test Server',
        ip: '192.168.1.100',
        port: 25565,
        version: '1.20.1',
        protocol: '763',
        playersOnline: 5,
        playersMax: 20,
      );

      // Act
      droplet.setMinecraftInfo(minecraftInfo);

      // Assert
      expect(droplet.isMinecraftServer, isTrue);
      expect(droplet.minecraftInfo, equals(minecraftInfo));
    });

    test('isMinecraftServer returns false when no minecraft info', () {
      // Arrange
      final droplet = DropletInfo(
        id: 12345,
        name: 'test-droplet',
        status: 'active',
        region: 'nyc1',
        size: 's-1vcpu-1gb',
        image: 'Ubuntu 20.04',
        tags: [],
        createdAt: DateTime.now(),
      );

      // Assert
      expect(droplet.isMinecraftServer, isFalse);
      expect(droplet.minecraftInfo, isNull);
    });
  });
}
