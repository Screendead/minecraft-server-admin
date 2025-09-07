import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionService {
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
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      return '';
    }
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
