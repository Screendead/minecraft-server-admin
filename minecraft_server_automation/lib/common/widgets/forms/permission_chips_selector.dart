import 'package:flutter/material.dart';

class PermissionChipsSelector extends StatelessWidget {
  final List<String> requiredScopes;
  final Set<String> selectedScopes;
  final Function(String) onToggleScope;

  const PermissionChipsSelector({
    super.key,
    required this.requiredScopes,
    required this.selectedScopes,
    required this.onToggleScope,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: requiredScopes.map((scope) {
        final isSelected = selectedScopes.contains(scope);
        return FilterChip(
          label: Text(scope),
          selected: isSelected,
          onSelected: (_) => onToggleScope(scope),
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
        );
      }).toList(),
    );
  }
}
