import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'encryption_service.dart';
import 'logging_service.dart';
import 'package:minecraft_server_automation/models/log_entry.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final SharedPreferences _sharedPreferences;
  final EncryptionService _encryptionService;
  final LoggingService _loggingService = LoggingService();

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
      await _loggingService.logUserInteraction(
        'User sign up attempt',
        details: 'Email: $email',
        metadata: {'email': email},
      );

      // Create user account
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        await _loggingService.logError(
          'User sign up failed - no user returned',
          category: LogCategory.authentication,
          details: 'Email: $email',
          metadata: {'email': email},
        );
        return false;
      }

      // Create user document in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      await _loggingService.logInfo(
        'User successfully signed up',
        category: LogCategory.authentication,
        details: 'User ID: ${user.uid}, Email: $email',
        metadata: {'userId': user.uid, 'email': email},
      );

      return true;
    } catch (e) {
      await _loggingService.logError(
        'User sign up failed',
        category: LogCategory.authentication,
        details: 'Email: $email, Error: $e',
        metadata: {'email': email},
        error: e,
      );
      return false;
    }
  }

  /// Signs in an existing user with email and password
  Future<bool> signIn(String email, String password) async {
    try {
      await _loggingService.logUserInteraction(
        'User sign in attempt',
        details: 'Email: $email',
        metadata: {'email': email},
      );

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

        await _loggingService.logInfo(
          'User successfully signed in',
          category: LogCategory.authentication,
          details: 'User ID: ${user.uid}, Email: $email',
          metadata: {'userId': user.uid, 'email': email},
        );
      }

      return true;
    } catch (e) {
      await _loggingService.logError(
        'User sign in failed',
        category: LogCategory.authentication,
        details: 'Email: $email, Error: $e',
        metadata: {'email': email},
        error: e,
      );
      return false;
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    final user = _firebaseAuth.currentUser;
    final userId = user?.uid;

    await _loggingService.logUserInteraction(
      'User sign out',
      details: userId != null ? 'User ID: $userId' : 'Unknown user',
      metadata: userId != null ? {'userId': userId} : null,
    );

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
      if (encryptedApiKey == null) {
        await _loggingService.logWarning(
          'API key decryption attempted but no encrypted key found',
          category: LogCategory.security,
        );
        return null;
      }

      final decryptedKey =
          _encryptionService.decrypt(encryptedApiKey, password);

      await _loggingService.logInfo(
        'API key successfully decrypted',
        category: LogCategory.security,
        details: 'Key length: ${decryptedKey.length}',
      );

      return decryptedKey;
    } catch (e) {
      await _loggingService.logError(
        'API key decryption failed',
        category: LogCategory.security,
        error: e,
      );
      return null;
    }
  }

  /// Updates the user's API key
  Future<bool> updateApiKey(String newApiKey, String password) async {
    try {
      await _loggingService.logUserInteraction(
        'API key update attempt',
        details: 'Key length: ${newApiKey.length}',
        metadata: {'keyLength': newApiKey.length},
      );

      final encryptedApiKey = _encryptionService.encrypt(newApiKey, password);
      await _sharedPreferences.setString('encrypted_api_key', encryptedApiKey);

      await _loggingService.logInfo(
        'API key successfully updated',
        category: LogCategory.security,
        details: 'Key length: ${newApiKey.length}',
      );

      return true;
    } catch (e) {
      await _loggingService.logError(
        'API key update failed',
        category: LogCategory.security,
        error: e,
      );
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
      await _loggingService.logError(
        'Error getting user data',
        category: LogCategory.authentication,
        error: e,
      );
      return null;
    }
  }
}
