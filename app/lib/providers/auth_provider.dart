import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/encryption_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final SharedPreferences _sharedPreferences;
  final EncryptionService _encryptionService;

  User? _user;
  bool _isLoading = true;
  String? _errorMessage;

  AuthProvider({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required SharedPreferences sharedPreferences,
    EncryptionService? encryptionService,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _sharedPreferences = sharedPreferences,
        _encryptionService = encryptionService ?? EncryptionService() {
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
  EncryptionService get encryptionService => _encryptionService;

  void _init() {
    // Listen to Firebase Auth state changes
    _firebaseAuth.authStateChanges().listen(
      (User? user) {
        _user = user;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print('Firebase Auth error: $error');
        _setError('Authentication error: $error');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> signUp(String email, String password, String apiKey) async {
    try {
      _setError(null);

      // Create user account
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) return false;

      // Encrypt and store API key
      final encryptedApiKey = _encryptionService.encrypt(apiKey, password);
      await _sharedPreferences.setString('encrypted_api_key', encryptedApiKey);

      // Create user document in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'apiKeyEncrypted': true,
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
      await _firebaseAuth.signOut();
      // Clear stored API key
      await _sharedPreferences.remove('encrypted_api_key');
    } catch (e) {
      _setError('Sign out failed: ${e.toString()}');
    }
  }

  Future<String?> getDecryptedApiKey(String password) async {
    try {
      final encryptedApiKey = _sharedPreferences.getString('encrypted_api_key');
      if (encryptedApiKey == null) return null;

      return _encryptionService.decrypt(encryptedApiKey, password);
    } catch (e) {
      _setError('Failed to decrypt API key: ${e.toString()}');
      return null;
    }
  }

  Future<bool> updateApiKey(String newApiKey, String password) async {
    try {
      final encryptedApiKey = _encryptionService.encrypt(newApiKey, password);
      await _sharedPreferences.setString('encrypted_api_key', encryptedApiKey);
      return true;
    } catch (e) {
      _setError('Failed to update API key: ${e.toString()}');
      return false;
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
}
