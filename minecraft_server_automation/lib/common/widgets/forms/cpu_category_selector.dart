import 'package:flutter/material.dart';
import 'package:minecraft_server_automation/common/interfaces/droplet_config_service.dart';
import 'package:minecraft_server_automation/models/cpu_category.dart';
import 'package:minecraft_server_automation/models/cpu_architecture.dart';
import 'package:minecraft_server_automation/models/region.dart';

/// CPU category selector component that accepts a service interface
/// This makes it easy to inject mock services for testing
class CpuCategorySelector extends StatelessWidget {
  final CpuCategory? selectedCategory;
  final CpuArchitecture architecture;
  final DropletConfigService configService;
  final Region? selectedRegion;
  final ValueChanged<CpuCategory?> onChanged;
  final bool isEnabled;

  const CpuCategorySelector({
    super.key,
    required this.selectedCategory,
    required this.architecture,
    required this.configService,
    required this.selectedRegion,
    required this.onChanged,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedRegion == null || !isEnabled) {
      return const SizedBox.shrink();
    }

    final allCategories = configService.getAvailableCategoriesForArchitecture(architecture);

    // Filter categories that have available configurations
    final availableCategories = allCategories.where((category) {
      final availableOptions = configService.getAvailableOptionsForCategory(category);
      return availableOptions.any((option) {
        final availableMultipliers = configService.getAvailableStorageMultipliersFor(category, option);
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
      });
    }).toList();

    // Auto-select the single category if only one is available
    if (availableCategories.length == 1 && selectedCategory == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onChanged(availableCategories.first);
      });
    }

    // Hide selector if no categories have available configurations
    if (availableCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CPU Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<CpuCategory>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Select CPU Category',
                border: OutlineInputBorder(),
              ),
              items: availableCategories.map((category) {
                return DropdownMenuItem<CpuCategory>(
                  value: category,
                  child: Text(category.displayName),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
