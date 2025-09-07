import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../services/ios_biometric_encryption_service.dart';
import '../services/ios_secure_api_key_service.dart';

class DebugApiKeyBanner extends StatefulWidget {
  const DebugApiKeyBanner({super.key});

  @override
  State<DebugApiKeyBanner> createState() => _DebugApiKeyBannerState();
}

class _DebugApiKeyBannerState extends State<DebugApiKeyBanner> {
  String? _decryptedApiKey;
  bool _isLoading = false;
  String? _error;
  bool _hasBiometricKey = false;
  bool _hasPasswordKey = false;

  @override
  void initState() {
    super.initState();
    _checkApiKeyStatus();
  }

  Future<void> _checkApiKeyStatus() async {
    if (!mounted) return;

    try {
      final authProvider = context.read<AuthProvider>();
      
      // Check for password-based key
      final passwordKey = authProvider.sharedPreferences.getString('encrypted_api_key');
      _hasPasswordKey = passwordKey != null && passwordKey.isNotEmpty;
      
      // Check for biometric key (iOS only)
      if (Platform.isIOS) {
        final biometricService = IOSBiometricEncryptionService();
        final apiKeyService = IOSSecureApiKeyService(
          firestore: authProvider.firestore,
          auth: authProvider.firebaseAuth,
          biometricService: biometricService,
        );
        _hasBiometricKey = await apiKeyService.hasApiKey();
      }
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error checking API key status: $e';
        });
      }
    }
  }

  Future<void> _showDecryptDialog() async {
    if (!mounted) return;

    if (Platform.isIOS && _hasBiometricKey) {
      // Use biometric decryption
      await _loadBiometricApiKey();
    } else if (_hasPasswordKey) {
      // Use password decryption
      await _showPasswordDialog();
    } else {
      setState(() {
        _error = 'No API key found';
      });
    }
  }

  Future<void> _showPasswordDialog() async {
    if (!mounted) return;

    final passwordController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Debug: Enter Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the password to decrypt the API key:'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          if (kDebugMode) ...[
            TextButton(
              onPressed: () {
                passwordController.text = 'password123';
              },
              child: const Text('Debug Fill'),
            ),
          ],
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(passwordController.text);
            },
            child: const Text('Decrypt'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await _loadPasswordApiKey(result);
    }
  }

  Future<void> _loadPasswordApiKey(String password) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final apiKey = await authProvider.getDecryptedApiKey(password);

      if (mounted) {
        setState(() {
          _decryptedApiKey = apiKey;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadBiometricApiKey() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final biometricService = IOSBiometricEncryptionService();
      final apiKeyService = IOSSecureApiKeyService(
        firestore: authProvider.firestore,
        auth: authProvider.firebaseAuth,
        biometricService: biometricService,
      );
      
      final apiKey = await apiKeyService.getApiKey();

      if (mounted) {
        setState(() {
          _decryptedApiKey = apiKey;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.orange.shade200),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.bug_report,
            size: 16,
            color: Colors.orange.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Text(
        'Decrypting API key...',
        style: TextStyle(fontSize: 12),
      );
    }

    if (_error != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              'Error: $_error',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _showDecryptDialog,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Retry', style: TextStyle(fontSize: 11)),
          ),
        ],
      );
    }

    if (_decryptedApiKey == null) {
      String statusText = 'No API key found';
      if (_hasBiometricKey) {
        statusText = 'API key secured with Face ID/Touch ID';
      } else if (_hasPasswordKey) {
        statusText = 'API key encrypted with password';
      }

      return Row(
        children: [
          Expanded(
            child: Text(
              statusText,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _showDecryptDialog,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _hasBiometricKey ? 'Decrypt (Face ID)' : 'Decrypt',
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Debug API Key:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        SelectableText(
          _decryptedApiKey!,
          style: TextStyle(
            fontSize: 11,
            fontFamily: 'monospace',
            color: Colors.orange.shade800,
          ),
        ),
      ],
    );
  }
}
