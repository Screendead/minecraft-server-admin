import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart' as auth_provider;
import 'providers/droplets_provider.dart';
import 'providers/droplet_config_provider.dart';
import 'providers/logs_provider.dart';
import 'services/logging_service.dart';
import 'models/log_entry.dart';
import 'common/components/layout/app_lifecycle_handler.dart';
import 'common/di/service_locator.dart';

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
      // Connected to Firebase emulators - no logging needed for debug mode
    } catch (e) {
      // Emulators might not be running, that's okay for now
      // Log this as a warning since it's not critical for development
      LoggingService().logWarning(
        'Firebase emulators not available: $e',
        category: LogCategory.system,
      );
    }
  } else {
    // Running in production mode - using Firebase production services
  }

  // Initialize shared preferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize logging service
  await LoggingService().initialize();

  runApp(MyApp(sharedPreferences: sharedPreferences));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  const MyApp({
    super.key,
    required this.sharedPreferences,
  });
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final authProvider = auth_provider.AuthProvider(
              firebaseAuth: FirebaseAuth.instance,
              firestore: FirebaseFirestore.instance,
              sharedPreferences: sharedPreferences,
            );

            // Initialize service locator with providers
            ServiceLocator().registerDefaults(
              authProvider: authProvider,
              dropletConfigProvider: DropletConfigProvider(),
            );

            return authProvider;
          },
        ),
        ChangeNotifierProvider(
          create: (context) => DropletsProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => DropletConfigProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => LogsProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Minecraft Server Admin',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const AppLifecycleHandler(),
      ),
    );
  }
}
