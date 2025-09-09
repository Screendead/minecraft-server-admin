import 'package:flutter/material.dart';
import 'package:minecraft_server_automation/models/storage_multiplier.dart';
import 'package:minecraft_server_automation/models/cpu_category.dart';
import 'package:minecraft_server_automation/models/cpu_option.dart';
import 'package:minecraft_server_automation/models/cpu_architecture.dart';
import 'package:minecraft_server_automation/models/region.dart';
import 'package:minecraft_server_automation/common/widgets/cards/storage_multiplier_card.dart';
import 'package:minecraft_server_automation/common/di/service_locator.dart';

/// Widget for selecting storage multipliers (1x, 2x, 3x, 6x SSD)
class StorageMultiplierSelector extends StatelessWidget {
  final StorageMultiplier? selectedMultiplier;
  final CpuCategory category;
  final CpuOption option;
  final CpuArchitecture architecture;
  final Region? selectedRegion;
  final ValueChanged<StorageMultiplier?> onChanged;
  final bool isEnabled;

  const StorageMultiplierSelector({
    super.key,
    required this.selectedMultiplier,
    required this.category,
    required this.option,
    required this.architecture,
    required this.selectedRegion,
    required this.onChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedRegion == null) {
      return const SizedBox.shrink();
    }

    // Get the config service from the service locator
    final serviceLocator = ServiceLocator();
    final configService = serviceLocator.dropletConfigService;

    final allMultipliers = StorageMultiplier.values
        .where((multiplier) => multiplier.isAvailableFor(category, option))
        .toList();

    // Filter multipliers that have available configurations
    final availableMultipliers = allMultipliers.where((multiplier) {
      final sizes = configService.getSizesForStorage(
        selectedRegion!.slug,
        architecture,
        category,
        option,
        multiplier,
      );
      return sizes.isNotEmpty;
    }).toList();

    // Auto-select the single multiplier if only one is available
    if (availableMultipliers.length == 1 && selectedMultiplier == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onChanged(availableMultipliers.first);
      });
    }

    // Hide selector if no multipliers have available configurations
    if (availableMultipliers.isEmpty) {
      return const SizedBox.shrink();
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
            return StorageMultiplierCard(
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
