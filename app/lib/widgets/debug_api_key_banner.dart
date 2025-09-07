import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class DebugApiKeyBanner extends StatefulWidget {
  const DebugApiKeyBanner({super.key});

  @override
  State<DebugApiKeyBanner> createState() => _DebugApiKeyBannerState();
}

class _DebugApiKeyBannerState extends State<DebugApiKeyBanner> {
  String? _decryptedApiKey;
  bool _isLoading = false;
  String? _error;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _showPasswordDialog();
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _showPasswordDialog() async {
    if (!mounted) return;

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
              controller: _passwordController,
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
                _passwordController.text = 'password123';
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
              Navigator.of(context).pop(_passwordController.text);
            },
            child: const Text('Decrypt'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await _loadApiKey(result);
    }
  }

  Future<void> _loadApiKey(String password) async {
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
          IconButton(
            icon: Icon(
              Icons.refresh,
              size: 16,
              color: Colors.orange.shade700,
            ),
            onPressed: _showPasswordDialog,
            tooltip: 'Refresh API Key',
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
      return Text(
        'Error: $_error',
        style: TextStyle(
          fontSize: 12,
          color: Colors.red.shade700,
        ),
      );
    }

    if (_decryptedApiKey == null) {
      return const Text(
        'Tap refresh to enter password and decrypt API key',
        style: TextStyle(fontSize: 12),
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
