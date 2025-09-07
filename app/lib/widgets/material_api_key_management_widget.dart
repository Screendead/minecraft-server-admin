import 'package:flutter/material.dart';
import '../services/ios_secure_api_key_service.dart';
import '../services/ios_biometric_encryption_service.dart';

/// Material Design API Key Management Widget with biometric authentication
class MaterialApiKeyManagementWidget extends StatefulWidget {
  final IOSSecureApiKeyService apiKeyService;
  final IOSBiometricEncryptionService biometricService;

  const MaterialApiKeyManagementWidget({
    Key? key,
    required this.apiKeyService,
    required this.biometricService,
  }) : super(key: key);

  @override
  State<MaterialApiKeyManagementWidget> createState() => _MaterialApiKeyManagementWidgetState();
}

class _MaterialApiKeyManagementWidgetState extends State<MaterialApiKeyManagementWidget> {
  bool _isLoading = false;
  bool _hasApiKey = false;
  bool _isBiometricAvailable = false;
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
      final biometricAvailable = await widget.biometricService.isBiometricAvailable();
      final hasApiKey = await widget.apiKeyService.hasApiKey();
      
      setState(() {
        _isBiometricAvailable = biometricAvailable;
        _hasApiKey = hasApiKey;
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


  Widget _buildContent() {
    if (!_isBiometricAvailable) {
      return _buildBiometricUnavailable();
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
          Icon(
            Icons.warning_amber,
            size: 64,
            color: Colors.orange.shade600,
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
          ElevatedButton.icon(
            onPressed: _checkStatus,
            icon: const Icon(Icons.refresh),
            label: const Text('Check Again'),
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
          Icon(
            Icons.security,
            size: 64,
            color: Colors.green.shade600,
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
          ElevatedButton.icon(
            onPressed: () => _showApiKeyInputDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add API Key'),
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
          Icon(
            Icons.check_circle,
            size: 64,
            color: Colors.green.shade600,
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showApiKeyInputDialog(isUpdate: true),
                  icon: const Icon(Icons.edit),
                  label: const Text('Update'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showClearConfirmationDialog(),
                  icon: const Icon(Icons.delete),
                  label: const Text('Clear'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showApiKeyInputDialog({bool isUpdate = false}) {
    final apiKeyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isUpdate ? 'Update API Key' : 'Add API Key'),
        content: TextField(
          controller: apiKeyController,
          decoration: const InputDecoration(
            labelText: 'DigitalOcean API Key',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
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
        content: const Text('Are you sure you want to clear your API key? This action cannot be undone.'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Key Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(),
          ),
          if (_errorMessage.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.red.shade50,
              child: Text(
                _errorMessage,
                style: TextStyle(color: Colors.red.shade700),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
