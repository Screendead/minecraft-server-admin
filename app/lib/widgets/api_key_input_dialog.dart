import 'package:flutter/material.dart';
import 'permission_chips_widget.dart';

class ApiKeyInputDialog extends StatefulWidget {
  final bool isUpdate;
  final Future<bool> Function(String) onConfirm;

  const ApiKeyInputDialog({
    super.key,
    required this.isUpdate,
    required this.onConfirm,
  });

  @override
  State<ApiKeyInputDialog> createState() => _ApiKeyInputDialogState();
}

class _ApiKeyInputDialogState extends State<ApiKeyInputDialog> {
  final TextEditingController _apiKeyController = TextEditingController();
  final List<String> _selectedScopes = [];
  bool _isButtonEnabled = false;
  bool _showPermissions = false;
  bool _isValidating = false;
  String? _errorMessage;

  static const List<String> _requiredScopes = [
    'account:read',
    'actions:read',
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
    'image:read',
    'image:delete',
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
    'vpc:read',
  ];

  @override
  void initState() {
    super.initState();
    _apiKeyController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _apiKeyController.removeListener(_onTextChanged);
    _apiKeyController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isButtonEnabled = _apiKeyController.text.isNotEmpty;
      // Clear error when user starts typing
      if (_errorMessage != null) {
        _errorMessage = null;
      }
    });
  }

  void _togglePermissions() {
    setState(() {
      _showPermissions = !_showPermissions;
    });
  }

  void _onScopeSelectionChanged(List<String> selectedScopes) {
    // Use WidgetsBinding to defer the setState until after the current build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _selectedScopes.clear();
          _selectedScopes.addAll(selectedScopes);
        });
      }
    });
  }

  Future<void> _handleConfirm() async {
    if (_apiKeyController.text.isEmpty) return;

    setState(() {
      _isValidating = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.onConfirm(_apiKeyController.text);
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _extractUserFriendlyErrorMessage(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isValidating = false;
        });
      }
    }
  }

  String _extractUserFriendlyErrorMessage(dynamic error) {
    final errorString = error.toString();

    // Handle common error patterns and extract meaningful messages
    if (errorString.contains('Invalid DigitalOcean API key')) {
      return 'Invalid API key. Please check your key and try again.';
    }

    if (errorString.contains('User must be authenticated')) {
      return 'Please sign in to store your API key.';
    }

    if (errorString.contains('BiometricAuthenticationException') ||
        errorString.contains('BiometricNotAvailableException')) {
      return 'Biometric authentication failed. Please try again.';
    }

    if (errorString.contains('NoEncryptedDataException')) {
      return 'No encrypted data found. Please try again.';
    }

    if (errorString.contains('Failed to store API key:')) {
      // Extract the original error message after "Failed to store API key: "
      final match =
          RegExp(r'Failed to store API key: (.+)').firstMatch(errorString);
      if (match != null) {
        final innerError = match.group(1);
        if (innerError != null && innerError.isNotEmpty) {
          return _extractUserFriendlyErrorMessage(innerError);
        }
      }
    }

    if (errorString.contains('Failed to update API key:')) {
      // Extract the original error message after "Failed to update API key: "
      final match =
          RegExp(r'Failed to update API key: (.+)').firstMatch(errorString);
      if (match != null) {
        final innerError = match.group(1);
        if (innerError != null && innerError.isNotEmpty) {
          return _extractUserFriendlyErrorMessage(innerError);
        }
      }
    }

    // If it's a generic Exception, try to extract the message
    if (errorString.startsWith('Exception: ')) {
      return errorString.substring(11); // Remove "Exception: " prefix
    }

    // Fallback to a generic message
    return 'An error occurred. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isUpdate ? 'Update API Key' : 'Add API Key'),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600, // Prevent dialog from being too wide
          minWidth: 300, // Minimum width for readability
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _apiKeyController,
                decoration: InputDecoration(
                  labelText: 'DigitalOcean API Key',
                  border: const OutlineInputBorder(),
                  errorText: _errorMessage,
                  errorMaxLines:
                      3, // Allow error text to wrap to multiple lines
                ),
                autofocus: true,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Required Scopes:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _togglePermissions,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      _showPermissions ? 'Hide' : 'View Scopes',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              if (_showPermissions) ...[
                const SizedBox(height: 8),
                const Text(
                  'Your API key must have the following scopes:',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                PermissionChipsWidget(
                  requiredScopes: _requiredScopes,
                  onSelectionChanged: _onScopeSelectionChanged,
                ),
                const SizedBox(height: 8),
              ],
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              (_isButtonEnabled && !_isValidating) ? _handleConfirm : null,
          child: _isValidating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.isUpdate ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
