import 'package:flutter/material.dart';
import 'permission_chips_widget.dart';

class ApiKeyInputDialog extends StatefulWidget {
  final bool isUpdate;
  final Function(String) onConfirm;

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

  void _handleConfirm() {
    if (_apiKeyController.text.isNotEmpty) {
      widget.onConfirm(_apiKeyController.text);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isUpdate ? 'Update API Key' : 'Add API Key'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'DigitalOcean API Key',
                border: OutlineInputBorder(),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isButtonEnabled ? _handleConfirm : null,
          child: Text(widget.isUpdate ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
