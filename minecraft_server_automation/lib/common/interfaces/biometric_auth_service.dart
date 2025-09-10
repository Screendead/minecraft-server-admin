/// Abstract interface for biometric authentication
/// This allows for easy mocking in tests
abstract class BiometricAuthServiceInterface {
  Future<bool> isBiometricAvailable();
  Future<List<BiometricType>> getAvailableBiometrics();
  Future<String> encryptWithBiometrics(String data);
  Future<String> decryptWithBiometrics();
  Future<bool> hasEncryptedData();
  Future<Map<String, dynamic>?> getKeyMetadata();
  Future<void> clearEncryptedData();
  Future<void> rotateEncryptionKey();
}

/// Types of biometric authentication available
enum BiometricType {
  fingerprint,
  face,
  iris,
  voice,
}

/// Result of biometric authentication
class BiometricAuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final BiometricAuthError? error;

  const BiometricAuthResult({
    required this.isSuccess,
    this.errorMessage,
    this.error,
  });

  factory BiometricAuthResult.success() =>
      const BiometricAuthResult(isSuccess: true);
  factory BiometricAuthResult.failure(String message,
          [BiometricAuthError? error]) =>
      BiometricAuthResult(
          isSuccess: false, errorMessage: message, error: error);
}

/// Biometric authentication error types
enum BiometricAuthError {
  userCancel,
  notAvailable,
  notEnrolled,
  lockedOut,
  permanentLockedOut,
  systemCancel,
  passcodeNotSet,
  biometricNotAvailable,
  biometricNotEnrolled,
  biometricLockedOut,
  biometricPermanentlyLockedOut,
  other,
}
