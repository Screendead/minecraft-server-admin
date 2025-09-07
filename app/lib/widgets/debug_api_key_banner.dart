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

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _loadApiKey();
    }
  }

  Future<void> _loadApiKey() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      // For debug purposes, we'll use a default password
      // In a real app, you might want to prompt for the password
      const debugPassword = 'password123';
      final apiKey = await authProvider.getDecryptedApiKey(debugPassword);
      
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
            onPressed: _loadApiKey,
            tooltip: 'Refresh API Key',
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Text(
        'Loading API key...',
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
        'No API key found',
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
