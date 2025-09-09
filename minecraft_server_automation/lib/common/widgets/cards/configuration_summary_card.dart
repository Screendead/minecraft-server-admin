import 'package:flutter/material.dart';
import 'package:minecraft_server_automation/common/logic/droplet_configuration_logic.dart';
import 'package:minecraft_server_automation/models/region.dart';
import 'package:minecraft_server_automation/models/cpu_architecture.dart';
import 'package:minecraft_server_automation/models/cpu_category.dart';
import 'package:minecraft_server_automation/models/cpu_option.dart';
import 'package:minecraft_server_automation/models/storage_multiplier.dart';
import 'package:minecraft_server_automation/models/droplet_size.dart';

/// Configuration summary card that displays current configuration
/// This component is easily testable as it only depends on data
class ConfigurationSummaryCard extends StatelessWidget {
  final Region? selectedRegion;
  final CpuArchitecture? selectedArchitecture;
  final CpuCategory? selectedCategory;
  final CpuOption? selectedOption;
  final StorageMultiplier? selectedMultiplier;
  final DropletSize? selectedSize;
  final DropletConfigurationLogic configurationLogic;

  const ConfigurationSummaryCard({
    super.key,
    required this.selectedRegion,
    required this.selectedArchitecture,
    required this.selectedCategory,
    required this.selectedOption,
    required this.selectedMultiplier,
    required this.selectedSize,
    required this.configurationLogic,
  });

  @override
  Widget build(BuildContext context) {
    final summary = configurationLogic.getConfigurationSummary(
      region: selectedRegion,
      architecture: selectedArchitecture,
      category: selectedCategory,
      option: selectedOption,
      multiplier: selectedMultiplier,
      size: selectedSize,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  summary['isValid'] ? Icons.check_circle : Icons.warning,
                  color: summary['isValid']
                      ? Colors.green
                      : Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'Configuration Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(context, 'Region', summary['region']),
            _buildSummaryRow(context, 'Architecture', summary['architecture']),
            _buildSummaryRow(context, 'Category', summary['category']),
            _buildSummaryRow(context, 'Option', summary['option']),
            _buildSummaryRow(
                context, 'Storage Multiplier', summary['multiplier']),
            _buildSummaryRow(context, 'Size', summary['size']),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: summary['isValid']
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: summary['isValid'] ? Colors.green : Colors.red,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    summary['isValid'] ? Icons.check : Icons.close,
                    color: summary['isValid'] ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    summary['isValid']
                        ? 'Configuration is valid and ready to deploy'
                        : 'Configuration is incomplete or invalid',
                    style: TextStyle(
                      color: summary['isValid'] ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'Not selected',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: value != null
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
