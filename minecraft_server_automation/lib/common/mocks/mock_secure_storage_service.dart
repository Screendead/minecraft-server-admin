import 'package:minecraft_server_automation/common/interfaces/secure_storage_service.dart';

/// Mock implementation of SecureStorageService for testing
class MockSecureStorageService implements SecureStorageService {
  final Map<String, String> _storage = {};
  bool _shouldThrow = false;
  String? _throwMessage;
  List<StorageOperation> _operations = [];

  @override
  Future<void> write(String key, String value) async {
    _operations.add(StorageOperation(
      type: StorageOperationType.write,
      key: key,
      value: value,
    ));

    if (_shouldThrow) {
      throw Exception(_throwMessage ?? 'Mock storage error');
    }

    _storage[key] = value;
  }

  @override
  Future<String?> read(String key) async {
    _operations.add(StorageOperation(
      type: StorageOperationType.read,
      key: key,
    ));

    if (_shouldThrow) {
      throw Exception(_throwMessage ?? 'Mock storage error');
    }

    return _storage[key];
  }

  @override
  Future<void> delete(String key) async {
    _operations.add(StorageOperation(
      type: StorageOperationType.delete,
      key: key,
    ));

    if (_shouldThrow) {
      throw Exception(_throwMessage ?? 'Mock storage error');
    }

    _storage.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _operations.add(StorageOperation(
      type: StorageOperationType.deleteAll,
    ));

    if (_shouldThrow) {
      throw Exception(_throwMessage ?? 'Mock storage error');
    }

    _storage.clear();
  }

  @override
  Future<Map<String, String>> readAll() async {
    _operations.add(StorageOperation(
      type: StorageOperationType.readAll,
    ));

    if (_shouldThrow) {
      throw Exception(_throwMessage ?? 'Mock storage error');
    }

    return Map.from(_storage);
  }

  @override
  Future<bool> containsKey(String key) async {
    _operations.add(StorageOperation(
      type: StorageOperationType.containsKey,
      key: key,
    ));

    if (_shouldThrow) {
      throw Exception(_throwMessage ?? 'Mock storage error');
    }

    return _storage.containsKey(key);
  }

  // Test helper methods
  void setShouldThrow(bool shouldThrow, [String? message]) {
    _shouldThrow = shouldThrow;
    _throwMessage = message;
  }

  void setValue(String key, String value) => _storage[key] = value;
  void clearStorage() => _storage.clear();
  Map<String, String> get storage => Map.from(_storage);
  List<StorageOperation> get operations => List.unmodifiable(_operations);
  void clearOperations() => _operations.clear();

  void reset() {
    _storage.clear();
    _operations.clear();
    _shouldThrow = false;
    _throwMessage = null;
  }
}

/// Record of storage operations
class StorageOperation {
  final StorageOperationType type;
  final String? key;
  final String? value;
  final DateTime timestamp;

  StorageOperation({
    required this.type,
    this.key,
    this.value,
  }) : timestamp = DateTime.now();
}

enum StorageOperationType {
  write,
  read,
  delete,
  deleteAll,
  readAll,
  containsKey,
}
