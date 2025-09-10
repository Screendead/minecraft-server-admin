/// Abstract interface for secure storage operations
/// This allows for easy mocking in tests
abstract class SecureStorageServiceInterface {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
  Future<Map<String, String>> readAll();
  Future<bool> containsKey(String key);
}
