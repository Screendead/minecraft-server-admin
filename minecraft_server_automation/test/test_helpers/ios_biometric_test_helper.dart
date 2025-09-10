import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

/// Test helper class for iOS Biometric Encryption Service tests
/// Provides consistent test data generation and utilities
class IOSBiometricTestHelper {
  /// Generates a consistent test encryption key for testing
  static Key generateTestKey() {
    final keyBytes = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      keyBytes[i] = i;
    }
    return Key(keyBytes);
  }

  /// Generates a base64-encoded test key
  static String encodeTestKey() {
    return base64.encode(generateTestKey().bytes);
  }

  /// Generates a random test key for testing key generation
  static Key generateRandomTestKey() {
    final keyBytes = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      keyBytes[i] = (i * 7 + 13) % 256; // Different pattern for variety
    }
    return Key(keyBytes);
  }

  /// Creates valid encrypted data structure for testing
  static String createValidEncryptedData(String plaintext) {
    final key = generateTestKey();
    final encrypter = Encrypter(AES(key));
    final iv = IV.fromSecureRandom(16);
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    return base64.encode(iv.bytes + encrypted.bytes);
  }

  /// Creates invalid base64 data for testing error scenarios
  static String createInvalidBase64Data() {
    return 'invalid-base64-data!@#';
  }

  /// Creates corrupted key data for testing error scenarios
  static String createCorruptedKeyData() {
    // Return a key that's not 32 bytes when decoded
    return base64.encode(Uint8List.fromList([1, 2, 3])); // Only 3 bytes
  }

  /// Creates valid metadata for testing
  static Map<String, dynamic> createValidMetadata() {
    return {
      'algorithm': 'AES-256-GCM',
      'secureEnclaveBacked': true,
      'createdAt': DateTime.now().toIso8601String(),
      'biometricRequired': true,
    };
  }

  /// Creates invalid JSON metadata for testing error scenarios
  static String createInvalidJsonMetadata() {
    return 'invalid json {';
  }
}
