import 'package:flutter/material.dart';
import 'package:minecraft_server_automation/models/region.dart';
import 'package:minecraft_server_automation/models/cpu_architecture.dart';
import 'package:minecraft_server_automation/models/cpu_category.dart';
import 'package:minecraft_server_automation/models/cpu_option.dart';
import 'package:minecraft_server_automation/models/storage_multiplier.dart';
import 'package:minecraft_server_automation/models/droplet_size.dart';
import 'package:minecraft_server_automation/widgets/recommended_config_widget.dart';
import 'package:minecraft_server_automation/widgets/custom_config_widget.dart';
import 'configuration_mode_selector.dart';
import 'package:minecraft_server_automation/common/widgets/cards/mode_selection_prompt.dart';

class DropletConfigurationSection extends StatelessWidget {
  final bool? isRecommendedMode;
  final Region? selectedRegion;
  final CpuArchitecture? selectedCpuArchitecture;
  final CpuCategory? selectedCpuCategory;
  final CpuOption? selectedCpuOption;
  final StorageMultiplier? selectedStorageMultiplier;
  final DropletSize? selectedDropletSize;
  final List<Region> availableRegions;
  final bool isLoadingData;
  final ValueChanged<bool?> onConfigurationModeChanged;
  final ValueChanged<Region?> onRegionChanged;
  final ValueChanged<CpuArchitecture?> onCpuArchitectureChanged;
  final ValueChanged<CpuCategory?> onCpuCategoryChanged;
  final ValueChanged<CpuOption?> onCpuOptionChanged;
  final ValueChanged<StorageMultiplier?> onStorageMultiplierChanged;
  final ValueChanged<DropletSize?> onDropletSizeChanged;

  const DropletConfigurationSection({
    super.key,
    required this.isRecommendedMode,
    required this.selectedRegion,
    required this.selectedCpuArchitecture,
    required this.selectedCpuCategory,
    required this.selectedCpuOption,
    required this.selectedStorageMultiplier,
    required this.selectedDropletSize,
    required this.availableRegions,
    required this.isLoadingData,
    required this.onConfigurationModeChanged,
    required this.onRegionChanged,
    required this.onCpuArchitectureChanged,
    required this.onCpuCategoryChanged,
    required this.onCpuOptionChanged,
    required this.onStorageMultiplierChanged,
    required this.onDropletSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Configuration mode selection
        ConfigurationModeSelector(
          isRecommended: isRecommendedMode,
          onChanged: onConfigurationModeChanged,
        ),
        const SizedBox(height: 16),

        // Configuration widgets based on mode
        if (isRecommendedMode == null) ...[
          const ModeSelectionPrompt(),
        ] else if (isRecommendedMode == true) ...[
          RecommendedConfigWidget(
            selectedRegion: selectedRegion,
            availableRegions: availableRegions,
            onRegionChanged: onRegionChanged,
            isLoading: isLoadingData,
          ),
        ] else ...[
          CustomConfigWidget(
            selectedRegion: selectedRegion,
            selectedCpuArchitecture: selectedCpuArchitecture,
            selectedCpuCategory: selectedCpuCategory,
            selectedCpuOption: selectedCpuOption,
            selectedStorageMultiplier: selectedStorageMultiplier,
            selectedDropletSize: selectedDropletSize,
            availableRegions: availableRegions,
            onRegionChanged: onRegionChanged,
            onCpuArchitectureChanged: onCpuArchitectureChanged,
            onCpuCategoryChanged: onCpuCategoryChanged,
            onCpuOptionChanged: onCpuOptionChanged,
            onStorageMultiplierChanged: onStorageMultiplierChanged,
            onDropletSizeChanged: onDropletSizeChanged,
          ),
        ],
      ],
    );
  }
}
