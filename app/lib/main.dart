import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart' as auth_provider;
import 'providers/ios_biometric_provider.dart';
import 'services/ios_biometric_encryption_service.dart';
import 'services/ios_secure_api_key_service.dart';
import 'services/api_key_migration_service.dart';
import 'services/encryption_service.dart';
import 'widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Connect to Firebase emulators in debug mode only
  if (const bool.fromEnvironment('dart.vm.product') == false) {
    try {
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
      print('Connected to Firebase emulators');
    } catch (e) {
      // Emulators might not be running, that's okay for now
      print('Firebase emulators not available: $e');
    }
  } else {
    print('Running in production mode - using Firebase production services');
  }

  // Initialize shared preferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize services
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final encryptionService = EncryptionService();
  final biometricService = IOSBiometricEncryptionService();
  final apiKeyService = IOSSecureApiKeyService(
    firestore: firestore,
    auth: firebaseAuth,
    biometricService: biometricService,
  );
  final migrationService = ApiKeyMigrationService(
    sharedPreferences: sharedPreferences,
    encryptionService: encryptionService,
    iosSecureApiKeyService: apiKeyService,
    biometricService: biometricService,
  );

  runApp(MyApp(
    sharedPreferences: sharedPreferences,
    biometricService: biometricService,
    apiKeyService: apiKeyService,
    migrationService: migrationService,
  ));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  final IOSBiometricEncryptionService biometricService;
  final IOSSecureApiKeyService apiKeyService;
  final ApiKeyMigrationService migrationService;

  const MyApp({
    super.key,
    required this.sharedPreferences,
    required this.biometricService,
    required this.apiKeyService,
    required this.migrationService,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => auth_provider.AuthProvider(
            firebaseAuth: FirebaseAuth.instance,
            firestore: FirebaseFirestore.instance,
            sharedPreferences: sharedPreferences,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => IOSBiometricProvider(
            biometricService: biometricService,
            apiKeyService: apiKeyService,
            migrationService: migrationService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Minecraft Server Admin',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}
