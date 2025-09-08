import 'package:flutter/material.dart';
import '../models/storage_multiplier.dart';
import '../models/cpu_category.dart';
import '../models/cpu_option.dart';

/// Widget for selecting storage multipliers (1x, 2x, 3x, 6x SSD)
class StorageMultiplierSelector extends StatelessWidget {
  final StorageMultiplier? selectedMultiplier;
  final CpuCategory category;
  final CpuOption option;
  final ValueChanged<StorageMultiplier?> onChanged;
  final bool isEnabled;

  const StorageMultiplierSelector({
    super.key,
    required this.selectedMultiplier,
    required this.category,
    required this.option,
    required this.onChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final availableMultipliers = StorageMultiplier.values
        .where((multiplier) => multiplier.isAvailableFor(category, option))
        .toList();

    // Auto-select the single multiplier if only one is available
    if (availableMultipliers.length == 1 && selectedMultiplier == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onChanged(availableMultipliers.first);
      });
    }

    // Hide selector if only one option is available
    if (availableMultipliers.length <= 1) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Storage',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableMultipliers.map((multiplier) {
            final isSelected = selectedMultiplier == multiplier;
            return _StorageMultiplierCard(
              multiplier: multiplier,
              isSelected: isSelected,
              isEnabled: isEnabled,
              onTap: () => onChanged(multiplier),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _StorageMultiplierCard extends StatelessWidget {
  final StorageMultiplier multiplier;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  const _StorageMultiplierCard({
    required this.multiplier,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              multiplier.displayName,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              multiplier.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
