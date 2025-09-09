import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:minecraft_server_automation/common/interfaces/secure_storage_service.dart';

/// iOS implementation of SecureStorageService using flutter_secure_storage
class IOSSecureStorageAdapter implements SecureStorageService {
  final FlutterSecureStorage _secureStorage;

  IOSSecureStorageAdapter({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  @override
  Future<void> write(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  @override
  Future<String?> read(String key) async {
    return await _secureStorage.read(key: key);
  }

  @override
  Future<void> delete(String key) async {
    await _secureStorage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await _secureStorage.deleteAll();
  }

  @override
  Future<Map<String, String>> readAll() async {
    return await _secureStorage.readAll();
  }

  @override
  Future<bool> containsKey(String key) async {
    return await _secureStorage.containsKey(key: key);
  }
}
