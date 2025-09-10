import 'package:flutter/material.dart';
import 'mode_option.dart';

class ConfigurationModeSelector extends StatelessWidget {
  final bool? isRecommended;
  final ValueChanged<bool?> onChanged;

  const ConfigurationModeSelector({
    super.key,
    required this.isRecommended,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuration Mode',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ModeOption(
                    title: 'Recommended',
                    subtitle: 'Optimized for most Minecraft servers',
                    icon: Icons.star,
                    isSelected: isRecommended == true,
                    onTap: () => onChanged(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModeOption(
                    title: 'Custom',
                    subtitle: 'Full control over all settings',
                    icon: Icons.tune,
                    isSelected: isRecommended == false,
                    onTap: () => onChanged(false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
