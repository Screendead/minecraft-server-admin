import 'package:flutter/material.dart';
import 'package:minecraft_server_automation/models/cpu_architecture.dart';
import 'package:minecraft_server_automation/models/cpu_category.dart';
import 'package:minecraft_server_automation/models/cpu_option.dart';
import 'package:minecraft_server_automation/models/storage_multiplier.dart';
import 'package:minecraft_server_automation/models/droplet_size.dart';
import 'package:minecraft_server_automation/models/region.dart';
import 'package:minecraft_server_automation/widgets/cpu_option_selector.dart';
import 'package:minecraft_server_automation/widgets/storage_multiplier_selector.dart';
import 'package:minecraft_server_automation/common/widgets/forms/location_dropdown.dart';
import 'package:minecraft_server_automation/common/widgets/forms/cpu_architecture_selector.dart';
import 'package:minecraft_server_automation/common/widgets/forms/cpu_category_selector.dart';
import 'package:minecraft_server_automation/common/widgets/forms/droplet_size_dropdown.dart';
import 'package:minecraft_server_automation/common/di/service_locator.dart';

/// Widget that displays the custom droplet configuration options
class CustomConfigWidget extends StatelessWidget {
  final Region? selectedRegion;
  final CpuArchitecture? selectedCpuArchitecture;
  final CpuCategory? selectedCpuCategory;
  final CpuOption? selectedCpuOption;
  final StorageMultiplier? selectedStorageMultiplier;
  final DropletSize? selectedDropletSize;
  final List<Region> availableRegions;
  final ValueChanged<Region?> onRegionChanged;
  final ValueChanged<CpuArchitecture?> onCpuArchitectureChanged;
  final ValueChanged<CpuCategory?> onCpuCategoryChanged;
  final ValueChanged<CpuOption?> onCpuOptionChanged;
  final ValueChanged<StorageMultiplier?> onStorageMultiplierChanged;
  final ValueChanged<DropletSize?> onDropletSizeChanged;

  const CustomConfigWidget({
    super.key,
    required this.selectedRegion,
    required this.selectedCpuArchitecture,
    required this.selectedCpuCategory,
    required this.selectedCpuOption,
    required this.selectedStorageMultiplier,
    required this.selectedDropletSize,
    required this.availableRegions,
    required this.onRegionChanged,
    required this.onCpuArchitectureChanged,
    required this.onCpuCategoryChanged,
    required this.onCpuOptionChanged,
    required this.onStorageMultiplierChanged,
    required this.onDropletSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Get the config service from the service locator
    final serviceLocator = ServiceLocator();
    final configService = serviceLocator.dropletConfigService;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tune,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Custom Configuration',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Configure all aspects of your droplet for maximum control and customization.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),

            // Location selection
            LocationDropdown(
              selectedRegion: selectedRegion,
              regions: availableRegions,
              onChanged: onRegionChanged,
            ),
            const SizedBox(height: 16),

            // CPU Architecture selection
            CpuArchitectureSelector(
              selectedArchitecture: selectedCpuArchitecture,
              onChanged: onCpuArchitectureChanged,
              isEnabled: selectedRegion != null,
            ),
            const SizedBox(height: 16),

            // CPU Category selection (only if architecture is selected)
            if (selectedCpuArchitecture != null) ...[
              CpuCategorySelector(
                selectedCategory: selectedCpuCategory,
                architecture: selectedCpuArchitecture!,
                configService: configService,
                selectedRegion: selectedRegion,
                onChanged: onCpuCategoryChanged,
                isEnabled: selectedRegion != null,
              ),
              const SizedBox(height: 16),
            ],

            // CPU Option selection (only if category is selected)
            if (selectedCpuCategory != null) ...[
              CpuOptionSelector(
                selectedOption: selectedCpuOption,
                category: selectedCpuCategory!,
                architecture: selectedCpuArchitecture!,
                selectedRegion: selectedRegion,
                onChanged: onCpuOptionChanged,
                isEnabled: selectedRegion != null,
              ),
              const SizedBox(height: 16),
            ],

            // Storage Multiplier selection (only if option is selected)
            if (selectedCpuOption != null) ...[
              StorageMultiplierSelector(
                selectedMultiplier: selectedStorageMultiplier,
                category: selectedCpuCategory!,
                option: selectedCpuOption!,
                architecture: selectedCpuArchitecture!,
                selectedRegion: selectedRegion,
                onChanged: onStorageMultiplierChanged,
                isEnabled: selectedRegion != null,
              ),
              const SizedBox(height: 16),
            ],

            // Droplet size selection
            DropletSizeDropdown(
              selectedSize: selectedDropletSize,
              selectedRegion: selectedRegion,
              selectedCpuArchitecture: selectedCpuArchitecture,
              selectedCpuCategory: selectedCpuCategory,
              selectedCpuOption: selectedCpuOption,
              selectedStorageMultiplier: selectedStorageMultiplier,
              onChanged: onDropletSizeChanged,
            ),
          ],
        ),
      ),
    );
  }
}
