import 'package:minecraft_server_automation/common/interfaces/auth_service.dart';

/// Mock implementation of AuthService for testing
class MockAuthService implements AuthService {
  bool _isSignedIn = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _userId;

  // Test control properties
  bool shouldThrowOnSignIn = false;
  bool shouldThrowOnSignUp = false;
  bool shouldSucceedOnSignIn = true;
  bool shouldSucceedOnSignUp = true;
  String? mockUserId;

  @override
  bool get isSignedIn => _isSignedIn;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get errorMessage => _errorMessage;

  @override
  String? get userId => _userId;

  @override
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    if (shouldThrowOnSignIn) {
      _isLoading = false;
      _errorMessage = 'Mock sign in error';
      throw Exception('Mock sign in error');
    }

    if (shouldSucceedOnSignIn) {
      _isSignedIn = true;
      _userId = mockUserId ?? 'mock_user_id';
    } else {
      _errorMessage = 'Invalid credentials';
    }

    _isLoading = false;
  }

  @override
  Future<void> signUp(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    if (shouldThrowOnSignUp) {
      _isLoading = false;
      _errorMessage = 'Mock sign up error';
      throw Exception('Mock sign up error');
    }

    if (shouldSucceedOnSignUp) {
      _isSignedIn = true;
      _userId = mockUserId ?? 'mock_user_id';
    } else {
      _errorMessage = 'Email already exists';
    }

    _isLoading = false;
  }

  @override
  Future<void> signOut() async {
    _isSignedIn = false;
    _userId = null;
    _errorMessage = null;
  }

  @override
  void clearError() {
    _errorMessage = null;
  }

  // Test helper methods
  void reset() {
    _isSignedIn = false;
    _isLoading = false;
    _errorMessage = null;
    _userId = null;
    shouldThrowOnSignIn = false;
    shouldThrowOnSignUp = false;
    shouldSucceedOnSignIn = true;
    shouldSucceedOnSignUp = true;
    mockUserId = null;
  }

  void setSignedIn(bool value) {
    _isSignedIn = value;
  }

  void setLoading(bool value) {
    _isLoading = value;
  }

  void setError(String? error) {
    _errorMessage = error;
  }
}
