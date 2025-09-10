import 'package:flutter/material.dart';
import 'package:minecraft_server_automation/providers/auth_provider.dart';
import 'package:minecraft_server_automation/common/interfaces/auth_service.dart';

/// Adapter to make AuthProvider conform to AuthServiceInterface interface
class AuthProviderAdapter extends ChangeNotifier
    implements AuthServiceInterface {
  final AuthProvider _provider;

  AuthProviderAdapter(this._provider) {
    _provider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _provider.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  bool get isSignedIn => _provider.isSignedIn;

  @override
  bool get isLoading => _provider.isLoading;

  @override
  String? get errorMessage => _provider.errorMessage;

  @override
  String? get userId => _provider.user?.uid;

  @override
  Future<void> signIn(String email, String password) async {
    final success = await _provider.signIn(email, password);
    if (!success) {
      throw Exception(_provider.errorMessage ?? 'Sign in failed');
    }
  }

  @override
  Future<void> signUp(String email, String password) async {
    final success = await _provider.signUp(email, password);
    if (!success) {
      throw Exception(_provider.errorMessage ?? 'Sign up failed');
    }
  }

  @override
  Future<void> signOut() async {
    await _provider.signOut();
  }

  @override
  void clearError() {
    _provider.clearError();
  }
}
