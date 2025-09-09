import 'package:flutter_test/flutter_test.dart';
import 'package:minecraft_server_automation/models/droplet_creation_request.dart';

void main() {
  group('DropletCreationRequest', () {
    test('should create instance with required parameters', () {
      const request = DropletCreationRequest(
        name: 'test-droplet',
        region: 'nyc1',
        size: 's-1vcpu-1gb',
        image: 'ubuntu-20-04-x64',
      );

      expect(request.name, equals('test-droplet'));
      expect(request.region, equals('nyc1'));
      expect(request.size, equals('s-1vcpu-1gb'));
      expect(request.image, equals('ubuntu-20-04-x64'));
      expect(request.sshKeys, isNull);
      expect(request.backups, isFalse);
      expect(request.ipv6, isTrue);
      expect(request.monitoring, isTrue);
      expect(request.tags, isNull);
      expect(request.userData, isNull);
      expect(request.vpcUuid, isNull);
    });

    test('should create instance with all parameters', () {
      const request = DropletCreationRequest(
        name: 'test-droplet',
        region: 'nyc1',
        size: 's-1vcpu-1gb',
        image: 'ubuntu-20-04-x64',
        sshKeys: ['key1', 'key2'],
        backups: true,
        ipv6: false,
        monitoring: false,
        tags: ['tag1', 'tag2'],
        userData: '#!/bin/bash\necho "Hello World"',
        vpcUuid: 'vpc-uuid-123',
      );

      expect(request.name, equals('test-droplet'));
      expect(request.region, equals('nyc1'));
      expect(request.size, equals('s-1vcpu-1gb'));
      expect(request.image, equals('ubuntu-20-04-x64'));
      expect(request.sshKeys, equals(['key1', 'key2']));
      expect(request.backups, isTrue);
      expect(request.ipv6, isFalse);
      expect(request.monitoring, isFalse);
      expect(request.tags, equals(['tag1', 'tag2']));
      expect(request.userData, equals('#!/bin/bash\necho "Hello World"'));
      expect(request.vpcUuid, equals('vpc-uuid-123'));
    });

    group('fromFormData factory', () {
      test('should create instance with required parameters', () {
        final request = DropletCreationRequest.fromFormData(
          name: 'test-droplet',
          region: 'nyc1',
          size: 's-1vcpu-1gb',
          image: 'ubuntu-20-04-x64',
        );

        expect(request.name, equals('test-droplet'));
        expect(request.region, equals('nyc1'));
        expect(request.size, equals('s-1vcpu-1gb'));
        expect(request.image, equals('ubuntu-20-04-x64'));
        expect(request.sshKeys, isNull);
        expect(request.backups, isFalse);
        expect(request.ipv6, isTrue);
        expect(request.monitoring, isTrue);
        expect(request.tags, isNull);
        expect(request.userData, isNull);
        expect(request.vpcUuid, isNull);
      });

      test('should create instance with all parameters', () {
        final request = DropletCreationRequest.fromFormData(
          name: 'test-droplet',
          region: 'nyc1',
          size: 's-1vcpu-1gb',
          image: 'ubuntu-20-04-x64',
          sshKeys: ['key1', 'key2'],
          backups: true,
          ipv6: false,
          monitoring: false,
          tags: ['tag1', 'tag2'],
          userData: '#!/bin/bash\necho "Hello World"',
          vpcUuid: 'vpc-uuid-123',
        );

        expect(request.name, equals('test-droplet'));
        expect(request.region, equals('nyc1'));
        expect(request.size, equals('s-1vcpu-1gb'));
        expect(request.image, equals('ubuntu-20-04-x64'));
        expect(request.sshKeys, equals(['key1', 'key2']));
        expect(request.backups, isTrue);
        expect(request.ipv6, isFalse);
        expect(request.monitoring, isFalse);
        expect(request.tags, equals(['tag1', 'tag2']));
        expect(request.userData, equals('#!/bin/bash\necho "Hello World"'));
        expect(request.vpcUuid, equals('vpc-uuid-123'));
      });
    });

    group('toJson', () {
      test('should convert to JSON with required fields only', () {
        const request = DropletCreationRequest(
          name: 'test-droplet',
          region: 'nyc1',
          size: 's-1vcpu-1gb',
          image: 'ubuntu-20-04-x64',
        );

        final json = request.toJson();

        expect(json['name'], equals('test-droplet'));
        expect(json['region'], equals('nyc1'));
        expect(json['size'], equals('s-1vcpu-1gb'));
        expect(json['image'], equals('ubuntu-20-04-x64'));
        expect(json['backups'], isFalse);
        expect(json['ipv6'], isTrue);
        expect(json['monitoring'], isTrue);
        expect(json.containsKey('ssh_keys'), isFalse);
        expect(json.containsKey('tags'), isFalse);
        expect(json.containsKey('user_data'), isFalse);
        expect(json.containsKey('vpc_uuid'), isFalse);
      });

      test('should convert to JSON with all fields', () {
        const request = DropletCreationRequest(
          name: 'test-droplet',
          region: 'nyc1',
          size: 's-1vcpu-1gb',
          image: 'ubuntu-20-04-x64',
          sshKeys: ['key1', 'key2'],
          backups: true,
          ipv6: false,
          monitoring: false,
          tags: ['tag1', 'tag2'],
          userData: '#!/bin/bash\necho "Hello World"',
          vpcUuid: 'vpc-uuid-123',
        );

        final json = request.toJson();

        expect(json['name'], equals('test-droplet'));
        expect(json['region'], equals('nyc1'));
        expect(json['size'], equals('s-1vcpu-1gb'));
        expect(json['image'], equals('ubuntu-20-04-x64'));
        expect(json['backups'], isTrue);
        expect(json['ipv6'], isFalse);
        expect(json['monitoring'], isFalse);
        expect(json['ssh_keys'], equals(['key1', 'key2']));
        expect(json['tags'], equals(['tag1', 'tag2']));
        expect(json['user_data'], equals('#!/bin/bash\necho "Hello World"'));
        expect(json['vpc_uuid'], equals('vpc-uuid-123'));
      });

      test('should exclude empty optional fields from JSON', () {
        const request = DropletCreationRequest(
          name: 'test-droplet',
          region: 'nyc1',
          size: 's-1vcpu-1gb',
          image: 'ubuntu-20-04-x64',
          sshKeys: [],
          tags: [],
          userData: '',
          vpcUuid: '',
        );

        final json = request.toJson();

        expect(json.containsKey('ssh_keys'), isFalse);
        expect(json.containsKey('tags'), isFalse);
        expect(json.containsKey('user_data'), isFalse);
        expect(json.containsKey('vpc_uuid'), isFalse);
      });

      test('should exclude null optional fields from JSON', () {
        const request = DropletCreationRequest(
          name: 'test-droplet',
          region: 'nyc1',
          size: 's-1vcpu-1gb',
          image: 'ubuntu-20-04-x64',
          sshKeys: null,
          tags: null,
          userData: null,
          vpcUuid: null,
        );

        final json = request.toJson();

        expect(json.containsKey('ssh_keys'), isFalse);
        expect(json.containsKey('tags'), isFalse);
        expect(json.containsKey('user_data'), isFalse);
        expect(json.containsKey('vpc_uuid'), isFalse);
      });
    });

    group('toString', () {
      test('should return string representation', () {
        const request = DropletCreationRequest(
          name: 'test-droplet',
          region: 'nyc1',
          size: 's-1vcpu-1gb',
          image: 'ubuntu-20-04-x64',
        );

        final string = request.toString();

        expect(string, contains('DropletCreationRequest'));
        expect(string, contains('name: test-droplet'));
        expect(string, contains('region: nyc1'));
        expect(string, contains('size: s-1vcpu-1gb'));
        expect(string, contains('image: ubuntu-20-04-x64'));
      });
    });

    group('equality', () {
      test('should be equal to identical instance', () {
        const request1 = DropletCreationRequest(
          name: 'test-droplet',
          region: 'nyc1',
          size: 's-1vcpu-1gb',
          image: 'ubuntu-20-04-x64',
        );

        const request2 = DropletCreationRequest(
          name: 'test-droplet',
          region: 'nyc1',
          size: 's-1vcpu-1gb',
          image: 'ubuntu-20-04-x64',
        );

        expect(request1, equals(request2));
        expect(request1.hashCode, equals(request2.hashCode));
      });

      test('should not be equal to different instance', () {
        const request1 = DropletCreationRequest(
          name: 'test-droplet',
          region: 'nyc1',
          size: 's-1vcpu-1gb',
          image: 'ubuntu-20-04-x64',
        );

        const request2 = DropletCreationRequest(
          name: 'different-droplet',
          region: 'nyc1',
          size: 's-1vcpu-1gb',
          image: 'ubuntu-20-04-x64',
        );

        expect(request1, isNot(equals(request2)));
        expect(request1.hashCode, isNot(equals(request2.hashCode)));
      });

      test('should not be equal to different type', () {
        const request = DropletCreationRequest(
          name: 'test-droplet',
          region: 'nyc1',
          size: 's-1vcpu-1gb',
          image: 'ubuntu-20-04-x64',
        );

        expect(request, isNot(equals('not a request')));
      });

      test('should be equal to itself', () {
        const request = DropletCreationRequest(
          name: 'test-droplet',
          region: 'nyc1',
          size: 's-1vcpu-1gb',
          image: 'ubuntu-20-04-x64',
        );

        expect(request, equals(request));
      });
    });

    group('hashCode', () {
      test('should be consistent with equality', () {
        const request1 = DropletCreationRequest(
          name: 'test-droplet',
          region: 'nyc1',
          size: 's-1vcpu-1gb',
          image: 'ubuntu-20-04-x64',
        );

        const request2 = DropletCreationRequest(
          name: 'test-droplet',
          region: 'nyc1',
          size: 's-1vcpu-1gb',
          image: 'ubuntu-20-04-x64',
        );

        expect(request1.hashCode, equals(request2.hashCode));
      });

      test('should be different for different instances', () {
        const request1 = DropletCreationRequest(
          name: 'test-droplet',
          region: 'nyc1',
          size: 's-1vcpu-1gb',
          image: 'ubuntu-20-04-x64',
        );

        const request2 = DropletCreationRequest(
          name: 'different-droplet',
          region: 'nyc1',
          size: 's-1vcpu-1gb',
          image: 'ubuntu-20-04-x64',
        );

        expect(request1.hashCode, isNot(equals(request2.hashCode)));
      });
    });
  });
}
