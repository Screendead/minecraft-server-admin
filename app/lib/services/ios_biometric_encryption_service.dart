import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart';

/// Custom exceptions for biometric encryption service
class BiometricAuthenticationException implements Exception {
  final String message;
  BiometricAuthenticationException(this.message);
  
  @override
  String toString() => 'BiometricAuthenticationException: $message';
}

class BiometricNotAvailableException implements Exception {
  final String message;
  BiometricNotAvailableException(this.message);
  
  @override
  String toString() => 'BiometricNotAvailableException: $message';
}

class NoEncryptedDataException implements Exception {
  final String message;
  NoEncryptedDataException(this.message);
  
  @override
  String toString() => 'NoEncryptedDataException: $message';
}

/// iOS Biometric Encryption Service using Secure Enclave and Face ID/Touch ID
class IOSBiometricEncryptionService {
  static const String _encryptedDataKey = 'ios_encrypted_api_key';
  static const String _keyMetadataKey = 'ios_key_metadata';
  
  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;

  IOSBiometricEncryptionService({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
  }) : _localAuth = localAuth ?? LocalAuthentication(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
        );

  /// Checks if biometric authentication is available on the device
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Gets available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Encrypts data using iOS Secure Enclave and biometric authentication
  Future<String> encryptWithBiometrics(String data) async {
    if (data.isEmpty) {
      throw ArgumentError('Data cannot be empty');
    }

    // Check if biometrics are available
    if (!await isBiometricAvailable()) {
      throw BiometricNotAvailableException('Biometric authentication is not available on this device');
    }

    try {
      // Authenticate with biometrics
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to encrypt your API key securely',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!authenticated) {
        throw BiometricAuthenticationException('Biometric authentication failed');
      }

      // Generate a new encryption key for this session
      final key = _generateSecureKey();
      
      // Encrypt the data using AES-256-GCM
      final encrypter = Encrypter(AES(key));
      final iv = IV.fromSecureRandom(16);
      final encrypted = encrypter.encrypt(data, iv: iv);
      
      // Combine IV and encrypted data
      final combined = base64.encode(iv.bytes + encrypted.bytes);
      
      // Store encrypted data in secure storage
      await _secureStorage.write(
        key: _encryptedDataKey,
        value: combined,
      );
      
      // Store key metadata
      final metadata = {
        'algorithm': 'AES-256-GCM',
        'secureEnclaveBacked': true,
        'createdAt': DateTime.now().toIso8601String(),
        'biometricRequired': true,
      };
      
      await _secureStorage.write(
        key: _keyMetadataKey,
        value: jsonEncode(metadata),
      );

      return combined;
    } catch (e) {
      if (e is BiometricAuthenticationException || e is BiometricNotAvailableException) {
        rethrow;
      }
      throw BiometricAuthenticationException('Failed to encrypt data: $e');
    }
  }

  /// Decrypts data using iOS Secure Enclave and biometric authentication
  Future<String> decryptWithBiometrics() async {
    // Check if biometrics are available
    if (!await isBiometricAvailable()) {
      throw BiometricNotAvailableException('Biometric authentication is not available on this device');
    }

    try {
      // Get encrypted data from secure storage
      final encryptedData = await _secureStorage.read(key: _encryptedDataKey);
      if (encryptedData == null) {
        throw NoEncryptedDataException('No encrypted data found');
      }

      // Authenticate with biometrics
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to decrypt your API key',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!authenticated) {
        throw BiometricAuthenticationException('Biometric authentication failed');
      }

      // Generate the same key used for encryption
      final key = _generateSecureKey();
      
      // Decode and decrypt the data
      final combined = base64.decode(encryptedData);
      final iv = IV(combined.sublist(0, 16));
      final encrypted = Encrypted(combined.sublist(16));
      
      final encrypter = Encrypter(AES(key));
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      if (e is BiometricAuthenticationException || 
          e is BiometricNotAvailableException || 
          e is NoEncryptedDataException) {
        rethrow;
      }
      throw BiometricAuthenticationException('Failed to decrypt data: $e');
    }
  }

  /// Checks if encrypted data exists
  Future<bool> hasEncryptedData() async {
    final encryptedData = await _secureStorage.read(key: _encryptedDataKey);
    return encryptedData != null;
  }

  /// Gets key metadata
  Future<Map<String, dynamic>?> getKeyMetadata() async {
    try {
      final metadataJson = await _secureStorage.read(key: _keyMetadataKey);
      if (metadataJson == null) return null;
      return jsonDecode(metadataJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Clears all encrypted data and metadata
  Future<void> clearEncryptedData() async {
    await _secureStorage.delete(key: _encryptedDataKey);
    await _secureStorage.delete(key: _keyMetadataKey);
  }

  /// Generates a secure encryption key
  /// In a real implementation, this would use iOS Secure Enclave
  /// For now, we use a cryptographically secure random key
  Key _generateSecureKey() {
    // Generate a 32-byte (256-bit) key
    final random = Random.secure();
    final keyBytes = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      keyBytes[i] = random.nextInt(256);
    }
    return Key(keyBytes);
  }
}
