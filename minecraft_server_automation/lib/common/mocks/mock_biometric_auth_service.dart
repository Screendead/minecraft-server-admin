import 'package:minecraft_server_automation/common/interfaces/biometric_auth_service.dart';

/// Mock implementation of BiometricAuthService for testing
class MockBiometricAuthService implements BiometricAuthService {
  // Test control properties
  bool _isAvailable = true;
  bool _shouldSucceed = true;
  List<BiometricType> _availableBiometrics = [BiometricType.fingerprint];
  List<BiometricAuthCall> _calls = [];

  @override
  Future<bool> isAvailable() async {
    _calls.add(BiometricAuthCall(type: BiometricAuthCallType.isAvailable));
    return _isAvailable;
  }

  @override
  Future<bool> authenticate({String? reason}) async {
    _calls.add(BiometricAuthCall(
      type: BiometricAuthCallType.authenticate,
      reason: reason,
    ));

    if (!_isAvailable) return false;
    if (!_shouldSucceed) return false;

    // Simulate authentication delay
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    _calls.add(
        BiometricAuthCall(type: BiometricAuthCallType.getAvailableBiometrics));
    return List.from(_availableBiometrics);
  }

  // Test helper methods
  void setAvailable(bool available) => _isAvailable = available;
  void setShouldSucceed(bool succeed) => _shouldSucceed = succeed;
  void setAvailableBiometrics(List<BiometricType> biometrics) =>
      _availableBiometrics = List.from(biometrics);

  List<BiometricAuthCall> get calls => List.unmodifiable(_calls);
  void clearCalls() => _calls.clear();

  void reset() {
    _isAvailable = true;
    _shouldSucceed = true;
    _availableBiometrics = [BiometricType.fingerprint];
    _calls.clear();
  }
}

/// Record of biometric authentication calls
class BiometricAuthCall {
  final BiometricAuthCallType type;
  final String? reason;
  final DateTime timestamp;

  BiometricAuthCall({
    required this.type,
    this.reason,
  }) : timestamp = DateTime.now();
}

enum BiometricAuthCallType {
  isAvailable,
  authenticate,
  getAvailableBiometrics,
}
