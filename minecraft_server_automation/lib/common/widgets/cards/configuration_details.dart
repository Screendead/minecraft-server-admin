import 'package:flutter/material.dart';
import 'package:minecraft_server_automation/common/widgets/forms/config_row.dart';

class ConfigurationDetails extends StatelessWidget {
  const ConfigurationDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          ConfigRow(
            icon: Icons.memory,
            label: 'CPU',
            value: 'Shared CPU / Basic / Regular',
          ),
          const SizedBox(height: 8),
          ConfigRow(
            icon: Icons.speed,
            label: 'vCPUs',
            value: '1 vCPU',
          ),
          const SizedBox(height: 8),
          ConfigRow(
            icon: Icons.storage,
            label: 'RAM',
            value: '512 MB',
          ),
          const SizedBox(height: 8),
          ConfigRow(
            icon: Icons.storage,
            label: 'Storage',
            value: '10 GB SSD',
          ),
        ],
      ),
    );
  }
}
