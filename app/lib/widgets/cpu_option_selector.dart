import 'package:flutter/material.dart';
import '../models/cpu_option.dart';
import '../models/cpu_category.dart';

/// Widget for selecting CPU options (Regular, Premium Intel, Premium AMD)
class CpuOptionSelector extends StatelessWidget {
  final CpuOption? selectedOption;
  final CpuCategory category;
  final ValueChanged<CpuOption?> onChanged;
  final bool isEnabled;

  const CpuOptionSelector({
    super.key,
    required this.selectedOption,
    required this.category,
    required this.onChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final availableOptions = CpuOption.values
        .where((option) => option.isAvailableFor(category))
        .toList();

    // Auto-select the single option if only one is available
    if (availableOptions.length == 1 && selectedOption == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onChanged(availableOptions.first);
      });
    }

    // Hide selector if only one option is available
    if (availableOptions.length <= 1) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CPU Option',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: availableOptions.map((option) {
            final isSelected = selectedOption == option;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _CpuOptionCard(
                  option: option,
                  isSelected: isSelected,
                  isEnabled: isEnabled,
                  onTap: () => onChanged(option),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CpuOptionCard extends StatelessWidget {
  final CpuOption option;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  const _CpuOptionCard({
    required this.option,
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
        padding: const EdgeInsets.all(16),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    option.displayName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
                if (option == CpuOption.premiumIntel)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'NEW',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              option.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Disk: ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  option.diskType,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    decoration: option.diskType == 'NVMe SSD'
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    decorationStyle: option.diskType == 'NVMe SSD'
                        ? TextDecorationStyle.dotted
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Network: ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  option.networkSpeed,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
