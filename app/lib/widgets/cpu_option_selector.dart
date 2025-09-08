import 'package:flutter/material.dart';
import '../models/cpu_option.dart';
import '../models/cpu_category.dart';
import '../models/cpu_architecture.dart';
import '../providers/droplet_config_provider.dart';
import '../services/digitalocean_api_service.dart';

/// Widget for selecting CPU options (Regular, Premium Intel, Premium AMD)
class CpuOptionSelector extends StatelessWidget {
  final CpuOption? selectedOption;
  final CpuCategory category;
  final CpuArchitecture architecture;
  final Region? selectedRegion;
  final DropletConfigProvider configProvider;
  final ValueChanged<CpuOption?> onChanged;
  final bool isEnabled;

  const CpuOptionSelector({
    super.key,
    required this.selectedOption,
    required this.category,
    required this.architecture,
    required this.selectedRegion,
    required this.configProvider,
    required this.onChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedRegion == null) {
      return const SizedBox.shrink();
    }

    final allOptions = CpuOption.values
        .where((option) => option.isAvailableFor(category))
        .toList();

    // Filter options that have available configurations
    final availableOptions = allOptions.where((option) {
      final availableMultipliers = configProvider.getAvailableStorageMultipliersFor(category, option);
      return availableMultipliers.any((multiplier) {
        final sizes = configProvider.getSizesForStorage(
          selectedRegion!.slug,
          architecture,
          category,
          option,
          multiplier,
        );
        return sizes.isNotEmpty;
      });
    }).toList();

    // Auto-select the single option if only one is available
    if (availableOptions.length == 1 && selectedOption == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onChanged(availableOptions.first);
      });
    }

    // Hide selector if no options have available configurations
    if (availableOptions.isEmpty) {
      return const SizedBox.shrink();
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
        IntrinsicHeight(
          child: Row(
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
            Text(
              option.displayName,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  'Disk: ${option.diskType}',
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
                Text(
                  'Network: ${option.networkSpeed}',
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
