import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'encryption_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final SharedPreferences _sharedPreferences;
  final EncryptionService _encryptionService;

  AuthService({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required SharedPreferences sharedPreferences,
    EncryptionService? encryptionService,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _sharedPreferences = sharedPreferences,
        _encryptionService = encryptionService ?? EncryptionService();

  /// Signs up a new user with email and password
  Future<bool> signUp(String email, String password) async {
    try {
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
      print('Sign up error: $e');
      return false;
    }
  }

  /// Signs in an existing user with email and password
  Future<bool> signIn(String email, String password) async {
    try {
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
      print('Sign in error: $e');
      return false;
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    // Clear stored API key
    await _sharedPreferences.remove('encrypted_api_key');
  }

  /// Checks if a user is currently signed in
  Future<bool> isSignedIn() async {
    return _firebaseAuth.currentUser != null;
  }

  /// Gets the current user
  Future<User?> getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  /// Gets the decrypted API key for the current user
  Future<String?> getDecryptedApiKey(String password) async {
    try {
      final encryptedApiKey = _sharedPreferences.getString('encrypted_api_key');
      if (encryptedApiKey == null) return null;

      return _encryptionService.decrypt(encryptedApiKey, password);
    } catch (e) {
      print('Error decrypting API key: $e');
      return null;
    }
  }

  /// Updates the user's API key
  Future<bool> updateApiKey(String newApiKey, String password) async {
    try {
      final encryptedApiKey = _encryptionService.encrypt(newApiKey, password);
      await _sharedPreferences.setString('encrypted_api_key', encryptedApiKey);
      return true;
    } catch (e) {
      print('Error updating API key: $e');
      return false;
    }
  }

  /// Gets user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }
}
