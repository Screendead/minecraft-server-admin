import 'package:flutter/material.dart';
import 'package:minecraft_server_automation/common/widgets/forms/permission_chips_selector.dart';

class PermissionsSummaryCard extends StatelessWidget {
  final List<String> selectedScopes;
  final List<String> requiredScopes;
  final bool showPermissions;
  final VoidCallback onTogglePermissions;

  const PermissionsSummaryCard({
    super.key,
    required this.selectedScopes,
    required this.requiredScopes,
    required this.showPermissions,
    required this.onTogglePermissions,
  });

  @override
  Widget build(BuildContext context) {
    final allRequiredSelected = requiredScopes.every((scope) => selectedScopes.contains(scope));
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  allRequiredSelected ? Icons.check_circle : Icons.warning,
                  color: allRequiredSelected 
                      ? Colors.green 
                      : Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    allRequiredSelected 
                        ? 'All required permissions selected'
                        : 'Some required permissions are missing',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: allRequiredSelected 
                              ? Colors.green 
                              : Theme.of(context).colorScheme.error,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: onTogglePermissions,
                  child: Text(showPermissions ? 'Hide Details' : 'Show Details'),
                ),
              ],
            ),
            if (showPermissions) ...[
              const SizedBox(height: 12),
              Text(
                'Selected: ${selectedScopes.length} / ${requiredScopes.length} required permissions',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              PermissionChipsSelector(
                requiredScopes: requiredScopes,
                selectedScopes: selectedScopes.toSet(),
                onToggleScope: (_) {}, // Read-only display
              ),
            ],
          ],
        ),
      ),
    );
  }
}
