import 'package:local_auth/local_auth.dart' as local_auth;
import 'package:minecraft_server_automation/common/interfaces/biometric_auth_service.dart';

/// iOS implementation of BiometricAuthService using local_auth package
class IOSBiometricAuthAdapter implements BiometricAuthServiceInterface {
  final local_auth.LocalAuthentication _localAuth;

  IOSBiometricAuthAdapter({local_auth.LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? local_auth.LocalAuthentication();

  @override
  Future<bool> isAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> authenticate({String? reason}) async {
    try {
      final isAvailable = await this.isAvailable();
      if (!isAvailable) return false;

      final result = await _localAuth.authenticate(
        localizedReason: reason ?? 'Please authenticate to continue',
        options: const local_auth.AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return result;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.map((biometric) {
        switch (biometric) {
          case local_auth.BiometricType.fingerprint:
            return BiometricType.fingerprint;
          case local_auth.BiometricType.face:
            return BiometricType.face;
          case local_auth.BiometricType.iris:
            return BiometricType.iris;
          default:
            return BiometricType.fingerprint; // Default fallback
        }
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
