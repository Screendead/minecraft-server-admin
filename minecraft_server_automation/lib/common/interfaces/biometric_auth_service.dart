/// Abstract interface for biometric authentication
/// This allows for easy mocking in tests
abstract class BiometricAuthServiceInterface {
  Future<bool> isAvailable();
  Future<bool> authenticate({String? reason});
  Future<List<BiometricType>> getAvailableBiometrics();
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
