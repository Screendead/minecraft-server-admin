import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../services/ios_biometric_encryption_service.dart';
import '../services/ios_secure_api_key_service.dart';
import 'api_key_input_dialog.dart';

class ApiKeyManagementBanner extends StatefulWidget {
  const ApiKeyManagementBanner({super.key});

  @override
  State<ApiKeyManagementBanner> createState() => _ApiKeyManagementBannerState();
}

class _ApiKeyManagementBannerState extends State<ApiKeyManagementBanner> {
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
      final passwordKey =
          authProvider.sharedPreferences.getString('encrypted_api_key');
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
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error checking API key status: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _storeApiKey(String apiKey) async {
    if (!mounted) return false;

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

      await apiKeyService.storeApiKey(apiKey);
      await _checkApiKeyStatus();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API key linked successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return true;
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      rethrow; // Re-throw so the dialog can catch and display the error
    }
  }

  Future<bool> _updateApiKey(String newApiKey) async {
    if (!mounted) return false;

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

      await apiKeyService.updateApiKey(newApiKey);
      await _checkApiKeyStatus();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API key updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return true;
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      rethrow; // Re-throw so the dialog can catch and display the error
    }
  }

  Future<void> _clearApiKey() async {
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

      await apiKeyService.clearApiKey();
      await _checkApiKeyStatus();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API key cleared successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error clearing API key: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _showApiKeyInputDialog({bool isUpdate = false}) {
    showDialog(
      context: context,
      builder: (context) => ApiKeyInputDialog(
        isUpdate: isUpdate,
        onConfirm: (apiKey) async {
          if (isUpdate) {
            return await _updateApiKey(apiKey);
          } else {
            return await _storeApiKey(apiKey);
          }
        },
      ),
    );
  }

  void _showClearConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear API Key'),
        content: const Text(
            'Are you sure you want to clear your API key? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearApiKey();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.blue.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.security,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'API Key Management',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _buildSubtitleContent(),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildSubtitleContent() {
    if (_isLoading) {
      return const Text(
        'Loading...',
        style: TextStyle(fontSize: 12),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }

    if (_error != null) {
      return Text(
        'Error: $_error',
        style: TextStyle(
          fontSize: 12,
          color: Colors.red.shade700,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      );
    }

    // No API key found
    if (!_hasBiometricKey && !_hasPasswordKey) {
      return const Text(
        'No API key found. Add one to get started.',
        style: TextStyle(fontSize: 12),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }

    // API key exists - show status
    String statusText = 'API key available';
    if (_hasBiometricKey) {
      statusText = 'API key secured with Face ID/Touch ID';
    } else if (_hasPasswordKey) {
      statusText = 'API key encrypted with password';
    }

    return Text(
      statusText,
      style: const TextStyle(fontSize: 12),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  Widget _buildButtons() {
    if (_isLoading) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_error != null) {
      return TextButton(
        onPressed: () {
          setState(() {
            _error = null;
            _isLoading = true;
          });
          _checkApiKeyStatus();
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text('Refresh', style: TextStyle(fontSize: 11)),
      );
    }

    // No API key found
    if (!_hasBiometricKey && !_hasPasswordKey) {
      return TextButton(
        onPressed: () => _showApiKeyInputDialog(),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text('Add API Key', style: TextStyle(fontSize: 11)),
      );
    }

    // API key exists - show management buttons
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => _showApiKeyInputDialog(isUpdate: true),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Replace', style: TextStyle(fontSize: 11)),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: _showClearConfirmationDialog,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: Colors.red,
          ),
          child: const Text('Delete', style: TextStyle(fontSize: 11)),
        ),
      ],
    );
  }
}
