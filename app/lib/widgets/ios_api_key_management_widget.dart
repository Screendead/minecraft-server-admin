import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:local_auth/local_auth.dart';
import '../services/ios_secure_api_key_service.dart';
import '../services/api_key_migration_service.dart';

/// iOS-specific API Key Management Widget with biometric authentication
class IOSApiKeyManagementWidget extends StatefulWidget {
  final IOSSecureApiKeyService apiKeyService;
  final ApiKeyMigrationService migrationService;

  const IOSApiKeyManagementWidget({
    Key? key,
    required this.apiKeyService,
    required this.migrationService,
  }) : super(key: key);

  @override
  State<IOSApiKeyManagementWidget> createState() => _IOSApiKeyManagementWidgetState();
}

class _IOSApiKeyManagementWidgetState extends State<IOSApiKeyManagementWidget> {
  bool _isLoading = false;
  bool _hasApiKey = false;
  bool _isBiometricAvailable = false;
  bool _needsMigration = false;
  String? _maskedApiKey;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final biometricAvailable = await widget.apiKeyService.isBiometricAvailable();
      final hasApiKey = await widget.apiKeyService.hasApiKey();
      final migrationStatus = await widget.migrationService.getMigrationStatus();
      
      setState(() {
        _isBiometricAvailable = biometricAvailable;
        _hasApiKey = hasApiKey;
        _needsMigration = migrationStatus['needsMigration'] ?? false;
        _isLoading = false;
      });

      if (hasApiKey) {
        await _loadMaskedApiKey();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking status: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMaskedApiKey() async {
    try {
      final apiKey = await widget.apiKeyService.getApiKey();
      if (apiKey != null) {
        setState(() {
          _maskedApiKey = _maskApiKey(apiKey);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading API key: $e';
      });
    }
  }

  String _maskApiKey(String apiKey) {
    if (apiKey.length <= 8) return '••••••••';
    return '${apiKey.substring(0, 4)}••••${apiKey.substring(apiKey.length - 4)}';
  }

  Future<void> _storeApiKey(String apiKey) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await widget.apiKeyService.storeApiKey(apiKey);
      await _checkStatus();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error storing API key: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateApiKey(String newApiKey) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await widget.apiKeyService.updateApiKey(newApiKey);
      await _checkStatus();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating API key: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _clearApiKey() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await widget.apiKeyService.clearApiKey();
      await _checkStatus();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error clearing API key: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _migrateToBiometric(String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await widget.migrationService.migrateToBiometric(password);
      await _checkStatus();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error migrating to biometric: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('API Key Management'),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (!_isBiometricAvailable) {
      return _buildBiometricUnavailable();
    }

    if (_needsMigration) {
      return _buildMigrationPrompt();
    }

    if (_hasApiKey) {
      return _buildApiKeyManagement();
    }

    return _buildApiKeySetup();
  }

  Widget _buildBiometricUnavailable() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 64,
            color: CupertinoColors.systemOrange,
          ),
          const SizedBox(height: 16),
          const Text(
            'Biometric Authentication Required',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'This app requires Face ID or Touch ID for maximum security. Please enable biometric authentication in your device settings.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: _checkStatus,
            child: const Text('Check Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildMigrationPrompt() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.arrow_up_arrow_down,
            size: 64,
            color: CupertinoColors.systemBlue,
          ),
          const SizedBox(height: 16),
          const Text(
            'Upgrade to Biometric Security',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your API key is currently protected with a password. Upgrade to Face ID/Touch ID for maximum security.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: () => _showMigrationDialog(),
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeySetup() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.lock_shield,
            size: 64,
            color: CupertinoColors.systemGreen,
          ),
          const SizedBox(height: 16),
          const Text(
            'Secure Your API Key',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Store your DigitalOcean API key with Face ID/Touch ID protection for maximum security.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: () => _showApiKeyInputDialog(),
            child: const Text('Add API Key'),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeyManagement() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Icon(
            CupertinoIcons.checkmark_shield,
            size: 64,
            color: CupertinoColors.systemGreen,
          ),
          const SizedBox(height: 16),
          const Text(
            'API Key Secured',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text(
                  'Current API Key:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _maskedApiKey ?? '••••••••••••••••',
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Courier',
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CupertinoButton.filled(
                  onPressed: () => _showApiKeyInputDialog(isUpdate: true),
                  child: const Text('Update'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CupertinoButton.destructive(
                  onPressed: () => _showClearConfirmationDialog(),
                  child: const Text('Clear'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMigrationDialog() {
    final passwordController = TextEditingController();
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Enter Current Password'),
        content: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: CupertinoTextField(
            controller: passwordController,
            placeholder: 'Password',
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (value) {
              Navigator.of(context).pop();
              _migrateToBiometric(value);
            },
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Migrate'),
            onPressed: () {
              Navigator.of(context).pop();
              _migrateToBiometric(passwordController.text);
            },
          ),
        ],
      ),
    );
  }

  void _showApiKeyInputDialog({bool isUpdate = false}) {
    final apiKeyController = TextEditingController();
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(isUpdate ? 'Update API Key' : 'Add API Key'),
        content: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: CupertinoTextField(
            controller: apiKeyController,
            placeholder: 'DigitalOcean API Key',
            textInputAction: TextInputAction.done,
            onSubmitted: (value) {
              Navigator.of(context).pop();
              if (isUpdate) {
                _updateApiKey(value);
              } else {
                _storeApiKey(value);
              }
            },
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(isUpdate ? 'Update' : 'Add'),
            onPressed: () {
              Navigator.of(context).pop();
              if (isUpdate) {
                _updateApiKey(apiKeyController.text);
              } else {
                _storeApiKey(apiKeyController.text);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showClearConfirmationDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear API Key'),
        content: const Text('Are you sure you want to clear your API key? This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Clear'),
            onPressed: () {
              Navigator.of(context).pop();
              _clearApiKey();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('API Key Management'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : _buildContent(),
            ),
            if (_errorMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: CupertinoColors.systemRed.withOpacity(0.1),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: CupertinoColors.systemRed),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
