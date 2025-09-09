import 'package:flutter/material.dart';
import 'package:minecraft_server_automation/models/cpu_option.dart';
import 'package:minecraft_server_automation/models/cpu_category.dart';
import 'package:minecraft_server_automation/models/cpu_architecture.dart';
import 'package:minecraft_server_automation/models/region.dart';
import 'package:minecraft_server_automation/common/widgets/cards/cpu_option_card.dart';
import 'package:minecraft_server_automation/common/di/service_locator.dart';

/// Widget for selecting CPU options (Regular, Premium Intel, Premium AMD)
class CpuOptionSelector extends StatelessWidget {
  final CpuOption? selectedOption;
  final CpuCategory category;
  final CpuArchitecture architecture;
  final Region? selectedRegion;
  final ValueChanged<CpuOption?> onChanged;
  final bool isEnabled;

  const CpuOptionSelector({
    super.key,
    required this.selectedOption,
    required this.category,
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

    final allOptions = CpuOption.values
        .where((option) => option.isAvailableFor(category))
        .toList();

    // Filter options that have available configurations
    final availableOptions = allOptions.where((option) {
      final availableMultipliers =
          configService.getAvailableStorageMultipliersFor(category, option);
      return availableMultipliers.any((multiplier) {
        final sizes = configService.getSizesForStorage(
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
                  child: CpuOptionCard(
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
