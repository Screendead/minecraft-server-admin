import 'package:flutter/material.dart';
import 'package:minecraft_server_automation/models/droplet_size.dart';
import 'package:minecraft_server_automation/utils/unit_formatter.dart';
import 'package:minecraft_server_automation/common/widgets/forms/spec_chip.dart';

class DropletSizeCard extends StatelessWidget {
  final DropletSize size;
  final bool isSelected;
  final VoidCallback? onTap;

  const DropletSizeCard({
    super.key,
    required this.size,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.memory,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      size.slug,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                size.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SpecChip(
                    icon: Icons.memory,
                    label: 'RAM',
                    value: UnitFormatter.formatMemory(size.memory),
                    isSelected: isSelected,
                  ),
                  const SizedBox(width: 8),
                  SpecChip(
                    icon: Icons.speed,
                    label: 'CPU',
                    value: UnitFormatter.formatCpuCount(size.vcpus),
                    isSelected: isSelected,
                  ),
                  const SizedBox(width: 8),
                  SpecChip(
                    icon: Icons.storage,
                    label: 'SSD',
                    value: UnitFormatter.formatStorage(size.disk),
                    isSelected: isSelected,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${size.priceMonthly.toStringAsFixed(2)}/month',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  Text(
                    '\$${size.priceHourly.toStringAsFixed(3)}/hour',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
