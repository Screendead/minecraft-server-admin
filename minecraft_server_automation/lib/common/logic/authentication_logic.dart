import 'package:minecraft_server_automation/common/interfaces/auth_service.dart';

/// Business logic for authentication
/// This class can be easily unit tested without UI dependencies
class AuthenticationLogic {
  final AuthServiceInterface _authService;

  AuthenticationLogic(this._authService);

  /// Validate email format
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Validate password strength
  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Validate form data
  Map<String, String?> validateFormData({
    required String email,
    required String password,
    String? confirmPassword,
  }) {
    final errors = <String, String?>{};

    if (email.isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!isValidEmail(email)) {
      errors['email'] = 'Please enter a valid email';
    }

    if (password.isEmpty) {
      errors['password'] = 'Password is required';
    } else if (!isValidPassword(password)) {
      errors['password'] = 'Password must be at least 6 characters';
    }

    if (confirmPassword != null && password != confirmPassword) {
      errors['confirmPassword'] = 'Passwords do not match';
    }

    return errors;
  }

  /// Sign in with validation
  Future<AuthResult> signInWithValidation(String email, String password) async {
    final errors = validateFormData(email: email, password: password);
    if (errors.isNotEmpty) {
      return AuthResult.failure(errors);
    }

    try {
      await _authService.signIn(email, password);
      if (_authService.isSignedIn) {
        return AuthResult.success();
      } else {
        return AuthResult.failure({'general': _authService.errorMessage ?? 'Sign in failed'});
      }
    } catch (e) {
      return AuthResult.failure({'general': e.toString()});
    }
  }

  /// Sign up with validation
  Future<AuthResult> signUpWithValidation(String email, String password, String confirmPassword) async {
    final errors = validateFormData(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    if (errors.isNotEmpty) {
      return AuthResult.failure(errors);
    }

    try {
      await _authService.signUp(email, password);
      if (_authService.isSignedIn) {
        return AuthResult.success();
      } else {
        return AuthResult.failure({'general': _authService.errorMessage ?? 'Sign up failed'});
      }
    } catch (e) {
      return AuthResult.failure({'general': e.toString()});
    }
  }

  /// Get current auth state
  AuthState getCurrentState() {
    return AuthState(
      isSignedIn: _authService.isSignedIn,
      isLoading: _authService.isLoading,
      errorMessage: _authService.errorMessage,
      userId: _authService.userId,
    );
  }
}

/// Result of authentication operations
class AuthResult {
  final bool isSuccess;
  final Map<String, String?> errors;

  AuthResult._(this.isSuccess, this.errors);

  factory AuthResult.success() => AuthResult._(true, {});
  factory AuthResult.failure(Map<String, String?> errors) => AuthResult._(false, errors);
}

/// Current authentication state
class AuthState {
  final bool isSignedIn;
  final bool isLoading;
  final String? errorMessage;
  final String? userId;

  const AuthState({
    required this.isSignedIn,
    required this.isLoading,
    this.errorMessage,
    this.userId,
  });
}
