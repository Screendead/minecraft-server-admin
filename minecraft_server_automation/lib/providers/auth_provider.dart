import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minecraft_server_automation/services/ios_biometric_encryption_service.dart';
import 'package:minecraft_server_automation/services/ios_secure_api_key_service.dart';
import 'package:minecraft_server_automation/services/logging_service.dart';
import 'package:minecraft_server_automation/models/log_entry.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final SharedPreferences _sharedPreferences;
  final LoggingService _loggingService = LoggingService();

  User? _user;
  bool _isLoading = true;
  String? _errorMessage;

  // API key caching services
  IOSSecureApiKeyService? _iosApiKeyService;

  AuthProvider({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required SharedPreferences sharedPreferences,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _sharedPreferences = sharedPreferences {
    _init();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isSignedIn => _user != null;
  String? get errorMessage => _errorMessage;

  // Expose services for other providers
  FirebaseAuth get firebaseAuth => _firebaseAuth;
  FirebaseFirestore get firestore => _firestore;
  SharedPreferences get sharedPreferences => _sharedPreferences;

  // Get the iOS API key service (lazy initialization)
  IOSSecureApiKeyService? get iosApiKeyService {
    if (_iosApiKeyService == null && _user != null) {
      final biometricService = IOSBiometricEncryptionService();
      _iosApiKeyService = IOSSecureApiKeyService(
        firestore: _firestore,
        auth: _firebaseAuth,
        biometricService: biometricService,
      );
    }
    return _iosApiKeyService;
  }

  void _init() {
    // Listen to Firebase Auth state changes
    _firebaseAuth.authStateChanges().listen(
      (User? user) {
        final previousUser = _user;
        _user = user;
        _isLoading = false;

        // Update logging service with user context
        _loggingService.setUserId(user?.uid);

        // Log auth state changes
        if (user != null && previousUser == null) {
          _loggingService.logInfo(
            'User authenticated',
            category: LogCategory.authentication,
            details: 'User ID: ${user.uid}, Email: ${user.email}',
            metadata: {'userId': user.uid, 'email': user.email},
          );
        } else if (user == null && previousUser != null) {
          _loggingService.logInfo(
            'User signed out',
            category: LogCategory.authentication,
            details: 'Previous User ID: ${previousUser.uid}',
            metadata: {'previousUserId': previousUser.uid},
          );
        }

        // Clear API key services when user signs out
        if (user == null) {
          _iosApiKeyService?.onSignOut();
          _iosApiKeyService = null;
        }

        notifyListeners();
      },
      onError: (error) {
        _loggingService.logError(
          'Firebase Auth state change error',
          category: LogCategory.authentication,
          error: error,
        );
        _setError('Authentication error: $error');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> signUp(String email, String password) async {
    try {
      _setError(null);

      // Create user account
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) return false;

      // Create user document in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      _setError('Sign up failed: ${e.toString()}');
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _setError(null);

      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login time
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      }

      return true;
    } catch (e) {
      _setError('Sign in failed: ${e.toString()}');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      // Clear API key cache before signing out
      _iosApiKeyService?.onSignOut();

      await _firebaseAuth.signOut();

      // Clear service references
      _iosApiKeyService = null;
    } catch (e) {
      _setError('Sign out failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data();
    } catch (e) {
      _setError('Failed to get user data: ${e.toString()}');
      return null;
    }
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Handle app lifecycle changes
  void onAppPaused() {
    _iosApiKeyService?.onAppPaused();
  }

  void onAppResumed() {
    _iosApiKeyService?.onAppResumed();
  }

  /// Get API key cache status for debugging
  Map<String, dynamic>? getApiKeyCacheStatus() {
    return _iosApiKeyService?.getCacheStatus();
  }
}
