import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../services/ios_biometric_encryption_service.dart';
import '../services/ios_secure_api_key_service.dart';

class ApiKeyManagementBanner extends StatefulWidget {
  const ApiKeyManagementBanner({super.key});

  @override
  State<ApiKeyManagementBanner> createState() => _ApiKeyManagementBannerState();
}

class _ApiKeyManagementBannerState extends State<ApiKeyManagementBanner> {
  String? _decryptedApiKey;
  bool _isLoading = false;
  String? _error;
  bool _hasBiometricKey = false;
  bool _hasPasswordKey = false;
  bool _showDecryptedKey = false;

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
          _showDecryptedKey = true;
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
          _showDecryptedKey = true;
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

  Future<void> _storeApiKey(String apiKey) async {
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

      await apiKeyService.storeApiKey(apiKey);
      await _checkApiKeyStatus();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error storing API key: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateApiKey(String newApiKey) async {
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

      await apiKeyService.updateApiKey(newApiKey);
      await _checkApiKeyStatus();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error updating API key: $e';
          _isLoading = false;
        });
      }
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
          _showDecryptedKey = false;
          _decryptedApiKey = null;
          _isLoading = false;
        });
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
    final apiKeyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isUpdate ? 'Update API Key' : 'Add API Key'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'DigitalOcean API Key',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              const Text(
                'Required Scopes:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your API key must have the following scopes:',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  const requiredScopes = [
                    'account:read',
                    'droplet:create',
                    'block_storage:create',
                    'block_storage:delete',
                    'block_storage:read',
                    'block_storage:update',
                    'block_storage_action:create',
                    'block_storage_action:read',
                    'block_storage_snapshot:create',
                    'block_storage_snapshot:delete',
                    'block_storage_snapshot:read',
                    'droplet:admin',
                    'droplet:create',
                    'droplet:delete',
                    'droplet:read',
                    'droplet:update',
                    'monitoring:create',
                    'monitoring:delete',
                    'monitoring:read',
                    'monitoring:update',
                    'project:create',
                    'project:delete',
                    'project:read',
                    'project:update',
                    'regions:read',
                    'sizes:read',
                    'snapshot:read',
                    'snapshot:delete',
                    'ssh_key:create',
                    'ssh_key:delete',
                    'ssh_key:read',
                    'ssh_key:update',
                    'tag:create',
                    'tag:delete',
                    'tag:read',
                    'uptime:create',
                    'uptime:delete',
                    'uptime:read',
                    'uptime:update',
                  ];

                  return Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    children: requiredScopes
                        .map(
                          (scope) => Chip(
                            label: Text(scope),
                            backgroundColor: Colors.grey.shade800,
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'The API key will be validated before being stored.',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (isUpdate) {
                _updateApiKey(apiKeyController.text);
              } else {
                _storeApiKey(apiKeyController.text);
              }
            },
            child: Text(isUpdate ? 'Update' : 'Add'),
          ),
        ],
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.security,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'API Key Management',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _buildSubtitleContent(),
            ],
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
      );
    }

    if (_error != null) {
      return Text(
        'Error: $_error',
        style: TextStyle(
          fontSize: 12,
          color: Colors.red.shade700,
        ),
      );
    }

    // No API key found
    if (!_hasBiometricKey && !_hasPasswordKey) {
      return const Text(
        'No API key found. Add one to get started.',
        style: TextStyle(fontSize: 12),
      );
    }

    // API key exists - show status
    String statusText = 'API key available';
    if (_hasBiometricKey) {
      statusText = 'API key secured with Face ID/Touch ID';
    } else if (_hasPasswordKey) {
      statusText = 'API key encrypted with password';
    }

    // If decrypted, show different status
    if (_showDecryptedKey && _decryptedApiKey != null) {
      statusText =
          'API key decrypted (${_decryptedApiKey!.substring(0, 4)}••••)';
    }

    return Text(
      statusText,
      style: const TextStyle(fontSize: 12),
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
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: _showDecryptDialog,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Retry', style: TextStyle(fontSize: 11)),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _checkApiKeyStatus,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Refresh', style: TextStyle(fontSize: 11)),
          ),
        ],
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
        if (!_showDecryptedKey) ...[
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
          TextButton(
            onPressed: () => _showApiKeyInputDialog(isUpdate: true),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Edit', style: TextStyle(fontSize: 11)),
          ),
        ],
        if (_showDecryptedKey) ...[
          TextButton(
            onPressed: () => _showApiKeyInputDialog(isUpdate: true),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Update', style: TextStyle(fontSize: 11)),
          ),
          TextButton(
            onPressed: _showClearConfirmationDialog,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear', style: TextStyle(fontSize: 11)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _showDecryptedKey = false;
                _decryptedApiKey = null;
              });
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Hide', style: TextStyle(fontSize: 11)),
          ),
        ],
        if (!_hasBiometricKey && _hasPasswordKey)
          TextButton(
            onPressed: () => _showApiKeyInputDialog(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Add Biometric', style: TextStyle(fontSize: 11)),
          ),
      ],
    );
  }
}
