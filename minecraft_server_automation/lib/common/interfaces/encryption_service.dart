/// Abstract interface for encryption services
/// This allows for easy mocking in tests
abstract class EncryptionServiceInterface {
  /// Encrypts the given text using the provided password
  String encrypt(String text, String password);

  /// Decrypts the given encrypted text using the provided password
  String decrypt(String encryptedText, String password);
}
