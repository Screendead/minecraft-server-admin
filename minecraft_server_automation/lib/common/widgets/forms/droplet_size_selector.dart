import 'package:flutter/material.dart';
import 'package:minecraft_server_automation/common/interfaces/droplet_config_service.dart';
import 'package:minecraft_server_automation/models/droplet_size.dart';
import 'package:minecraft_server_automation/models/cpu_architecture.dart';
import 'package:minecraft_server_automation/models/cpu_category.dart';
import 'package:minecraft_server_automation/models/cpu_option.dart';
import 'package:minecraft_server_automation/models/storage_multiplier.dart';
import 'package:minecraft_server_automation/models/region.dart';
import 'package:minecraft_server_automation/common/widgets/cards/droplet_size_card.dart';

/// Droplet size selector component that accepts a service interface
/// This makes it easy to inject mock services for testing
class DropletSizeSelector extends StatelessWidget {
  final DropletSize? selectedSize;
  final DropletConfigService configService;
  final Region? selectedRegion;
  final CpuArchitecture architecture;
  final CpuCategory category;
  final CpuOption option;
  final StorageMultiplier multiplier;
  final ValueChanged<DropletSize?> onChanged;
  final bool isEnabled;

  const DropletSizeSelector({
    super.key,
    required this.selectedSize,
    required this.configService,
    required this.selectedRegion,
    required this.architecture,
    required this.category,
    required this.option,
    required this.multiplier,
    required this.onChanged,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedRegion == null || !isEnabled) {
      return const SizedBox.shrink();
    }

    final availableSizes = configService.getSizesForStorage(
      selectedRegion!.slug,
      architecture,
      category,
      option,
      multiplier,
    );

    if (availableSizes.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.warning,
                color: Theme.of(context).colorScheme.error,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'No available sizes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'No droplet sizes are available for the selected configuration.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Droplet Size',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Available sizes for your configuration:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            ...availableSizes.map((size) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: DropletSizeCard(
                  size: size,
                  isSelected: selectedSize?.slug == size.slug,
                  onTap: () => onChanged(size),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
