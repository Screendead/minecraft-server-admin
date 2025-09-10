import 'package:flutter/material.dart';

class PermissionChipsWidget extends StatefulWidget {
  final List<String> requiredScopes;
  final Function(List<String>)? onSelectionChanged;

  const PermissionChipsWidget({
    super.key,
    required this.requiredScopes,
    this.onSelectionChanged,
  });

  @override
  State<PermissionChipsWidget> createState() => _PermissionChipsWidgetState();
}

class _PermissionChipsWidgetState extends State<PermissionChipsWidget> {
  final Set<String> _selectedScopes = {};

  @override
  void initState() {
    super.initState();
    // Initialize with no scopes selected by default
    // Defer the callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSelectionChanged?.call(_selectedScopes.toList());
    });
  }

  void _toggleScope(String scope) {
    setState(() {
      if (_selectedScopes.contains(scope)) {
        _selectedScopes.remove(scope);
      } else {
        _selectedScopes.add(scope);
      }
    });
    widget.onSelectionChanged?.call(_selectedScopes.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 2.0,
      runSpacing: 2.0,
      children: widget.requiredScopes
          .map(
            (scope) => GestureDetector(
              onTap: () => _toggleScope(scope),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _selectedScopes.contains(scope)
                      ? Colors.green[600]
                      : Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                  border: _selectedScopes.contains(scope)
                      ? Border.all(color: Colors.green[400]!, width: 1)
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedScopes.contains(scope))
                      Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    else
                      Icon(
                        Icons.not_interested,
                        size: 14,
                        color: Colors.white,
                      ),
                    const SizedBox(width: 4),
                    Text(
                      scope,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: _selectedScopes.contains(scope)
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
