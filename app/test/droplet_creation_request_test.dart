import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/droplet_creation_request.dart';

void main() {
  group('DropletCreationRequest', () {
    test('should create request with required parameters', () {
      final request = DropletCreationRequest(
        name: 'test-droplet',
        region: 'nyc3',
        size: 's-1vcpu-1gb',
        image: 'ubuntu-22-04-x64',
      );

      expect(request.name, 'test-droplet');
      expect(request.region, 'nyc3');
      expect(request.size, 's-1vcpu-1gb');
      expect(request.image, 'ubuntu-22-04-x64');
      expect(request.backups, false);
      expect(request.ipv6, true);
      expect(request.monitoring, true);
    });

    test('should create request with all parameters', () {
      final request = DropletCreationRequest(
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

      expect(request.name, 'test-droplet');
      expect(request.region, 'nyc3');
      expect(request.size, 's-1vcpu-1gb');
      expect(request.image, 'ubuntu-22-04-x64');
      expect(request.sshKeys, ['key1', 'key2']);
      expect(request.backups, true);
      expect(request.ipv6, false);
      expect(request.monitoring, false);
      expect(request.tags, ['tag1', 'tag2']);
      expect(request.userData, 'test user data');
      expect(request.vpcUuid, 'vpc-uuid');
    });

    test('should create request from form data', () {
      final request = DropletCreationRequest.fromFormData(
        name: 'test-droplet',
        region: 'nyc3',
        size: 's-1vcpu-1gb',
        image: 'ubuntu-22-04-x64',
        sshKeys: ['key1'],
        tags: ['minecraft-server'],
        userData: 'test user data',
      );

      expect(request.name, 'test-droplet');
      expect(request.region, 'nyc3');
      expect(request.size, 's-1vcpu-1gb');
      expect(request.image, 'ubuntu-22-04-x64');
      expect(request.sshKeys, ['key1']);
      expect(request.tags, ['minecraft-server']);
      expect(request.userData, 'test user data');
    });

    test('should convert to JSON correctly', () {
      final request = DropletCreationRequest(
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

      final json = request.toJson();

      expect(json['name'], 'test-droplet');
      expect(json['region'], 'nyc3');
      expect(json['size'], 's-1vcpu-1gb');
      expect(json['image'], 'ubuntu-22-04-x64');
      expect(json['ssh_keys'], ['key1', 'key2']);
      expect(json['backups'], true);
      expect(json['ipv6'], false);
      expect(json['monitoring'], false);
      expect(json['tags'], ['tag1', 'tag2']);
      expect(json['user_data'], 'test user data');
      expect(json['vpc_uuid'], 'vpc-uuid');
    });

    test('should exclude null/empty optional parameters from JSON', () {
      final request = DropletCreationRequest(
        name: 'test-droplet',
        region: 'nyc3',
        size: 's-1vcpu-1gb',
        image: 'ubuntu-22-04-x64',
      );

      final json = request.toJson();

      expect(json['name'], 'test-droplet');
      expect(json['region'], 'nyc3');
      expect(json['size'], 's-1vcpu-1gb');
      expect(json['image'], 'ubuntu-22-04-x64');
      expect(json['backups'], false);
      expect(json['ipv6'], true);
      expect(json['monitoring'], true);
      expect(json.containsKey('ssh_keys'), false);
      expect(json.containsKey('tags'), false);
      expect(json.containsKey('user_data'), false);
      expect(json.containsKey('vpc_uuid'), false);
    });

    test('should exclude empty lists from JSON', () {
      final request = DropletCreationRequest(
        name: 'test-droplet',
        region: 'nyc3',
        size: 's-1vcpu-1gb',
        image: 'ubuntu-22-04-x64',
        sshKeys: [],
        tags: [],
      );

      final json = request.toJson();

      expect(json.containsKey('ssh_keys'), false);
      expect(json.containsKey('tags'), false);
    });

    test('should implement equality correctly', () {
      final request1 = DropletCreationRequest(
        name: 'test-droplet',
        region: 'nyc3',
        size: 's-1vcpu-1gb',
        image: 'ubuntu-22-04-x64',
      );

      final request2 = DropletCreationRequest(
        name: 'test-droplet',
        region: 'nyc3',
        size: 's-1vcpu-1gb',
        image: 'ubuntu-22-04-x64',
      );

      final request3 = DropletCreationRequest(
        name: 'different-droplet',
        region: 'nyc3',
        size: 's-1vcpu-1gb',
        image: 'ubuntu-22-04-x64',
      );

      expect(request1, equals(request2));
      expect(request1, isNot(equals(request3)));
    });

    test('should implement toString correctly', () {
      final request = DropletCreationRequest(
        name: 'test-droplet',
        region: 'nyc3',
        size: 's-1vcpu-1gb',
        image: 'ubuntu-22-04-x64',
      );

      final string = request.toString();
      expect(string, contains('test-droplet'));
      expect(string, contains('nyc3'));
      expect(string, contains('s-1vcpu-1gb'));
      expect(string, contains('ubuntu-22-04-x64'));
    });
  });
}
