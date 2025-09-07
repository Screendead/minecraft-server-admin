import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../widgets/debug_api_key_banner.dart';
import '../widgets/material_api_key_management_widget.dart';
import '../services/ios_biometric_encryption_service.dart';
import '../services/ios_secure_api_key_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minecraft Server Admin'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Show API Key Management button on iOS
          if (Platform.isIOS)
            IconButton(
              icon: const Icon(Icons.security),
              onPressed: () => _showApiKeyManagement(context),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Debug API Key Banner (only in debug mode)
          const DebugApiKeyBanner(),

          // Main content
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_esports,
                    size: 64,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Minecraft Server Admin',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Welcome! Your server admin panel is ready.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showApiKeyManagement(BuildContext context) {
    // Get services from the main app
    final authProvider = context.read<AuthProvider>();
    
    // Create service instances (these should be the same instances from main.dart)
    final biometricService = IOSBiometricEncryptionService();
    final apiKeyService = IOSSecureApiKeyService(
      firestore: authProvider.firestore,
      auth: authProvider.firebaseAuth,
      biometricService: biometricService,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MaterialApiKeyManagementWidget(
          apiKeyService: apiKeyService,
          biometricService: biometricService,
        ),
      ),
    );
  }
}
