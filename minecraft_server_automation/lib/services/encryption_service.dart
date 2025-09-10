import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:minecraft_server_automation/common/interfaces/encryption_service.dart';

class EncryptionService implements EncryptionServiceInterface {
  static const String _salt = 'minecraft-server-admin-salt';

  /// Encrypts the given text using AES-256-CBC with a password-derived key
  String encrypt(String text, String password) {
    if (text.isEmpty) return '';

    try {
      // Derive key from password using SHA256 hash
      final key = _deriveKey(password);

      // Create encryptor
      final encrypter = Encrypter(AES(key));
      final iv = IV.fromSecureRandom(16);

      // Encrypt the text
      final encrypted = encrypter.encrypt(text, iv: iv);

      // Combine IV and encrypted data, then encode as base64
      final combined = base64.encode(iv.bytes + encrypted.bytes);
      return combined;
    } catch (e) {
      return '';
    }
  }

  /// Decrypts the given encrypted text using AES-256-CBC
  String decrypt(String encryptedText, String password) {
    if (encryptedText.isEmpty) return '';

    try {
      // Decode from base64
      final combined = base64.decode(encryptedText);

      // Extract IV and encrypted data
      final iv = IV(combined.sublist(0, 16));
      final encrypted = Encrypted(combined.sublist(16));

      // Derive key from password
      final key = _deriveKey(password);

      // Create encryptor and decrypt
      final encrypter = Encrypter(AES(key));
      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      // Validate that the decrypted data is not garbage
      // Check if the result contains only printable ASCII characters
      // This helps detect when wrong password produces garbage data
      if (!_isValidDecryptedData(decrypted)) {
        return '';
      }

      return decrypted;
    } catch (e) {
      return '';
    }
  }

  /// Validates that decrypted data is not garbage
  /// Checks if the data contains mostly valid text characters
  bool _isValidDecryptedData(String data) {
    if (data.isEmpty) return true;

    // Count valid characters (printable ASCII, common whitespace, and basic Unicode)
    int validCharCount = 0;
    int totalCharCount = data.length;

    for (int i = 0; i < data.length; i++) {
      final codeUnit = data.codeUnitAt(i);
      // Allow printable ASCII (32-126), common whitespace (9, 10, 13), and basic Unicode (128+)
      if (codeUnit >= 9 && (codeUnit <= 13 || codeUnit >= 32)) {
        validCharCount++;
      }
    }

    // If more than 90% of characters are valid, consider it valid text
    // This is more strict than before to better reject garbage data from wrong passwords
    final isValidText = (validCharCount / totalCharCount) > 0.9;

    // Additional check: ensure the data has reasonable content
    // For very short strings (1-2 chars), just check they're valid characters
    // For longer strings, require at least one letter to reject pure garbage
    final hasReasonableContent = data.length == 1 ||
        (data.length >= 2 && RegExp(r'[a-zA-Z]').hasMatch(data));

    return isValidText && hasReasonableContent;
  }

  /// Derives a key from password using SHA256 hash
  Key _deriveKey(String password) {
    // Create a deterministic key from password and salt
    final combined = utf8.encode(password + _salt);
    final hash = sha256.convert(combined);

    // Pad or truncate to 32 bytes for AES-256
    final keyBytes = hash.bytes;
    final key = Uint8List(32);

    for (int i = 0; i < 32; i++) {
      key[i] = keyBytes[i % keyBytes.length];
    }

    return Key(key);
  }
}
