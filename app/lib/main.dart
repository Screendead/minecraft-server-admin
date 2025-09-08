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
          create: (context) => auth_provider.AuthProvider(
            firebaseAuth: FirebaseAuth.instance,
            firestore: FirebaseFirestore.instance,
            sharedPreferences: sharedPreferences,
          ),
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

/// Widget to handle app lifecycle events
/// This widget is placed inside the MultiProvider tree so it can access providers
class AppLifecycleHandler extends StatefulWidget {
  const AppLifecycleHandler({super.key});

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Get the AuthProvider from the context
    final authProvider = context.read<auth_provider.AuthProvider>();

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App is going to background - clear API key cache for security
        authProvider.onAppPaused();
        break;
      case AppLifecycleState.resumed:
        // App is coming back to foreground
        authProvider.onAppResumed();
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        authProvider.onAppPaused();
        break;
      case AppLifecycleState.hidden:
        // App is hidden (iOS specific)
        authProvider.onAppPaused();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const AuthWrapper();
  }
}
