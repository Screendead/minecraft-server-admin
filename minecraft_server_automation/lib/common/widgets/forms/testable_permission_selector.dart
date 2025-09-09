import 'package:flutter/material.dart';

/// Permission selector component that manages its own state
/// This makes it easier to test without complex state management
class PermissionSelector extends StatefulWidget {
  final List<String> requiredScopes;
  final Set<String> initialSelectedScopes;
  final Function(Set<String>)? onSelectionChanged;

  const PermissionSelector({
    super.key,
    required this.requiredScopes,
    this.initialSelectedScopes = const {},
    this.onSelectionChanged,
  });

  @override
  State<PermissionSelector> createState() => _PermissionSelectorState();
}

class _PermissionSelectorState extends State<PermissionSelector> {
  late Set<String> _selectedScopes;

  @override
  void initState() {
    super.initState();
    _selectedScopes = Set.from(widget.initialSelectedScopes);
  }

  @override
  void didUpdateWidget(PermissionSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelectedScopes != oldWidget.initialSelectedScopes) {
      _selectedScopes = Set.from(widget.initialSelectedScopes);
    }
  }

  void _toggleScope(String scope) {
    setState(() {
      if (_selectedScopes.contains(scope)) {
        _selectedScopes.remove(scope);
      } else {
        _selectedScopes.add(scope);
      }
    });
    widget.onSelectionChanged?.call(_selectedScopes);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Permissions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the permissions your API key needs:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.requiredScopes.map((scope) {
            final isSelected = _selectedScopes.contains(scope);
            return FilterChip(
              label: Text(scope),
              selected: isSelected,
              onSelected: (_) => _toggleScope(scope),
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Text(
          'Selected: ${_selectedScopes.length} / ${widget.requiredScopes.length} permissions',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
