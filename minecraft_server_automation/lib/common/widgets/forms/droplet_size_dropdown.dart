import 'package:flutter/material.dart';
import 'package:minecraft_server_automation/models/droplet_size.dart';
import 'package:minecraft_server_automation/models/region.dart';
import 'package:minecraft_server_automation/models/cpu_architecture.dart';
import 'package:minecraft_server_automation/models/cpu_category.dart';
import 'package:minecraft_server_automation/models/cpu_option.dart';
import 'package:minecraft_server_automation/models/storage_multiplier.dart';
import 'package:minecraft_server_automation/common/widgets/cards/droplet_size_card.dart';
import 'package:minecraft_server_automation/common/di/service_locator.dart';

class DropletSizeDropdown extends StatelessWidget {
  final DropletSize? selectedSize;
  final Region? selectedRegion;
  final CpuArchitecture? selectedCpuArchitecture;
  final CpuCategory? selectedCpuCategory;
  final CpuOption? selectedCpuOption;
  final StorageMultiplier? selectedStorageMultiplier;
  final ValueChanged<DropletSize?> onChanged;

  const DropletSizeDropdown({
    super.key,
    required this.selectedSize,
    required this.selectedRegion,
    required this.selectedCpuArchitecture,
    required this.selectedCpuCategory,
    required this.selectedCpuOption,
    required this.selectedStorageMultiplier,
    required this.onChanged,
  });

  List<DropletSize> _getAvailableSizes() {
    if (selectedRegion == null ||
        selectedCpuArchitecture == null ||
        selectedCpuCategory == null ||
        selectedCpuOption == null ||
        selectedStorageMultiplier == null) {
      return [];
    }

    // Get the config service from the service locator
    final serviceLocator = ServiceLocator();
    final configService = serviceLocator.dropletConfigService;

    return configService.getSizesForStorage(
      selectedRegion!.slug,
      selectedCpuArchitecture!,
      selectedCpuCategory!,
      selectedCpuOption!,
      selectedStorageMultiplier!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableSizes = _getAvailableSizes();
    final isEnabled = selectedRegion != null &&
        selectedCpuArchitecture != null &&
        selectedCpuCategory != null &&
        selectedCpuOption != null &&
        selectedStorageMultiplier != null;

    if (!isEnabled) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Droplet Size',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.memory,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(
                  'Complete the selection steps above',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (availableSizes.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Droplet Size',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.error),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No droplet sizes available for the selected configuration',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Droplet Size',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (availableSizes.length == 1)
          DropletSizeCard(
            size: availableSizes.first,
            isSelected: true,
            onTap: () => onChanged(availableSizes.first),
          )
        else
          DropdownButtonFormField<DropletSize>(
            initialValue: selectedSize,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.memory),
            ),
            items: availableSizes.map((size) {
              return DropdownMenuItem<DropletSize>(
                value: size,
                child: Text(size.displayName),
              );
            }).toList(),
            onChanged: onChanged,
          ),
      ],
    );
  }
}
