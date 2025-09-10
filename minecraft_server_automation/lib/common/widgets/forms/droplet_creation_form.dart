import 'package:flutter/material.dart';
import 'package:minecraft_server_automation/models/minecraft_version.dart';
import 'package:minecraft_server_automation/models/region.dart';
import 'package:minecraft_server_automation/models/cpu_architecture.dart';
import 'package:minecraft_server_automation/models/cpu_category.dart';
import 'package:minecraft_server_automation/models/cpu_option.dart';
import 'package:minecraft_server_automation/models/storage_multiplier.dart';
import 'package:minecraft_server_automation/models/droplet_size.dart';
import 'droplet_name_field.dart';
import 'minecraft_version_dropdown.dart';
import 'world_save_upload.dart';
import 'droplet_configuration_section.dart';
import 'package:minecraft_server_automation/common/widgets/buttons/submit_button.dart';

class DropletCreationForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final bool? isRecommendedMode;
  final Region? selectedRegion;
  final CpuArchitecture? selectedCpuArchitecture;
  final CpuCategory? selectedCpuCategory;
  final CpuOption? selectedCpuOption;
  final StorageMultiplier? selectedStorageMultiplier;
  final DropletSize? selectedDropletSize;
  final MinecraftVersion? selectedMinecraftVersion;
  final String? selectedWorldSavePath;
  final List<Region> availableRegions;
  final List<MinecraftVersion> minecraftVersions;
  final bool isLoadingData;
  final bool isCreatingDroplet;
  final ValueChanged<bool?> onConfigurationModeChanged;
  final ValueChanged<Region?> onRegionChanged;
  final ValueChanged<CpuArchitecture?> onCpuArchitectureChanged;
  final ValueChanged<CpuCategory?> onCpuCategoryChanged;
  final ValueChanged<CpuOption?> onCpuOptionChanged;
  final ValueChanged<StorageMultiplier?> onStorageMultiplierChanged;
  final ValueChanged<DropletSize?> onDropletSizeChanged;
  final ValueChanged<MinecraftVersion?> onMinecraftVersionChanged;
  final VoidCallback? onPickWorldSave;
  final VoidCallback? onRemoveWorldSave;
  final VoidCallback? onSubmit;

  const DropletCreationForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.isRecommendedMode,
    required this.selectedRegion,
    required this.selectedCpuArchitecture,
    required this.selectedCpuCategory,
    required this.selectedCpuOption,
    required this.selectedStorageMultiplier,
    required this.selectedDropletSize,
    required this.selectedMinecraftVersion,
    required this.selectedWorldSavePath,
    required this.availableRegions,
    required this.minecraftVersions,
    required this.isLoadingData,
    required this.isCreatingDroplet,
    required this.onConfigurationModeChanged,
    required this.onRegionChanged,
    required this.onCpuArchitectureChanged,
    required this.onCpuCategoryChanged,
    required this.onCpuOptionChanged,
    required this.onStorageMultiplierChanged,
    required this.onDropletSizeChanged,
    required this.onMinecraftVersionChanged,
    required this.onPickWorldSave,
    required this.onRemoveWorldSave,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropletNameField(
              controller: nameController,
              enabled: !isCreatingDroplet,
            ),
            const SizedBox(height: 16),

            // Configuration section
            DropletConfigurationSection(
              isRecommendedMode: isRecommendedMode,
              selectedRegion: selectedRegion,
              selectedCpuArchitecture: selectedCpuArchitecture,
              selectedCpuCategory: selectedCpuCategory,
              selectedCpuOption: selectedCpuOption,
              selectedStorageMultiplier: selectedStorageMultiplier,
              selectedDropletSize: selectedDropletSize,
              availableRegions: availableRegions,
              isLoadingData: isLoadingData,
              onConfigurationModeChanged:
                  isCreatingDroplet ? (_) {} : onConfigurationModeChanged,
              onRegionChanged: isCreatingDroplet ? (_) {} : onRegionChanged,
              onCpuArchitectureChanged:
                  isCreatingDroplet ? (_) {} : onCpuArchitectureChanged,
              onCpuCategoryChanged:
                  isCreatingDroplet ? (_) {} : onCpuCategoryChanged,
              onCpuOptionChanged:
                  isCreatingDroplet ? (_) {} : onCpuOptionChanged,
              onStorageMultiplierChanged:
                  isCreatingDroplet ? (_) {} : onStorageMultiplierChanged,
              onDropletSizeChanged:
                  isCreatingDroplet ? (_) {} : onDropletSizeChanged,
            ),
            const SizedBox(height: 16),

            // Minecraft version (always shown)
            MinecraftVersionDropdown(
              selectedVersion: selectedMinecraftVersion,
              versions: minecraftVersions,
              onChanged: isCreatingDroplet ? (_) {} : onMinecraftVersionChanged,
            ),
            const SizedBox(height: 16),

            // World save upload (always shown)
            WorldSaveUpload(
              selectedPath: selectedWorldSavePath,
              onPickFile: isCreatingDroplet ? null : onPickWorldSave,
              onRemoveFile: isCreatingDroplet ? null : onRemoveWorldSave,
            ),
            const SizedBox(height: 32),

            // Submit button
            SubmitButton(
              onPressed: isCreatingDroplet ? null : onSubmit,
              isLoading: isCreatingDroplet,
            ),
          ],
        ),
      ),
    );
  }
}
