/// Abstract interface for authentication services
/// This allows for easy mocking in tests
abstract class AuthServiceInterface {
  bool get isSignedIn;
  bool get isLoading;
  String? get errorMessage;
  String? get userId;

  Future<void> signIn(String email, String password);
  Future<void> signUp(String email, String password);
  Future<void> signOut();
  void clearError();
}
