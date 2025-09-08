import 'package:flutter/material.dart';
import '../services/digitalocean_api_service.dart';
import '../services/region_selection_service.dart';
import '../utils/unit_formatter.dart';

/// Widget that displays the recommended droplet configuration
class RecommendedConfigWidget extends StatefulWidget {
  final Region? selectedRegion;
  final List<Region> availableRegions;
  final ValueChanged<Region?> onRegionChanged;
  final bool isLoading;

  const RecommendedConfigWidget({
    super.key,
    required this.selectedRegion,
    required this.availableRegions,
    required this.onRegionChanged,
    this.isLoading = false,
  });

  @override
  State<RecommendedConfigWidget> createState() =>
      _RecommendedConfigWidgetState();
}

class _RecommendedConfigWidgetState extends State<RecommendedConfigWidget> {
  bool _isFindingLocation = false;

  @override
  void initState() {
    super.initState();
    // Don't automatically find location - wait for user to click "Find Closest"
  }

  Future<void> _findClosestRegion() async {
    if (widget.availableRegions.isEmpty) return;

    setState(() {
      _isFindingLocation = true;
    });

    try {
      final closestRegion = await RegionSelectionService.findClosestRegion(
          widget.availableRegions);
      if (closestRegion != null && mounted) {
        widget.onRegionChanged(closestRegion);
      }
    } catch (e) {
      // If location finding fails, don't select anything
      // Error is silently handled - user can manually select region
    } finally {
      if (mounted) {
        setState(() {
          _isFindingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recommended Configuration',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'This configuration is optimized for most Minecraft servers and provides the best value for money.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),

            // Location selection
            _LocationSection(
              selectedRegion: widget.selectedRegion,
              availableRegions: widget.availableRegions,
              onRegionChanged: widget.onRegionChanged,
              isFindingLocation: _isFindingLocation,
              onFindLocation: _findClosestRegion,
            ),
            const SizedBox(height: 16),

            // Configuration details - only show if region is selected
            if (widget.selectedRegion != null)
              _ConfigurationDetails()
            else
              _PlaceholderMessage(),
          ],
        ),
      ),
    );
  }
}

class _LocationSection extends StatelessWidget {
  final Region? selectedRegion;
  final List<Region> availableRegions;
  final ValueChanged<Region?> onRegionChanged;
  final bool isFindingLocation;
  final VoidCallback onFindLocation;

  const _LocationSection({
    required this.selectedRegion,
    required this.availableRegions,
    required this.onRegionChanged,
    required this.isFindingLocation,
    required this.onFindLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Location',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            if (isFindingLocation)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            else
              TextButton.icon(
                onPressed: onFindLocation,
                icon: const Icon(Icons.my_location, size: 16),
                label: const Text('Find Closest'),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Region>(
          value: selectedRegion,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
            hintText: 'Select region',
          ),
          items: availableRegions.map((region) {
            return DropdownMenuItem<Region>(
              value: region,
              child: Text('${region.name} (${region.slug.toUpperCase()})'),
            );
          }).toList(),
          onChanged: onRegionChanged,
        ),
      ],
    );
  }
}

class _ConfigurationDetails extends StatelessWidget {
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
          _ConfigRow(
            icon: Icons.memory,
            label: 'CPU',
            value: 'Shared CPU / Basic / Regular',
          ),
          const SizedBox(height: 8),
          _ConfigRow(
            icon: Icons.speed,
            label: 'vCPUs',
            value: '1 vCPU',
          ),
          const SizedBox(height: 8),
          _ConfigRow(
            icon: Icons.memory,
            label: 'RAM',
            value: UnitFormatter.formatMemory(512), // 512 MB
          ),
          const SizedBox(height: 8),
          _ConfigRow(
            icon: Icons.storage,
            label: 'Storage',
            value: '${UnitFormatter.formatStorage(10)} SSD', // 10 GB
          ),
          const SizedBox(height: 8),
          _ConfigRow(
            icon: Icons.cloud_upload,
            label: 'Transfer',
            value: UnitFormatter.formatTransfer(1000), // 1 TB
          ),
          const SizedBox(height: 8),
          _ConfigRow(
            icon: Icons.attach_money,
            label: 'Price',
            value: '\$4.00/month',
            isHighlight: true,
          ),
        ],
      ),
    );
  }
}

class _PlaceholderMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 32,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'Select a region to see recommended configuration',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Click "Find Closest" to automatically detect your nearest region',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ConfigRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isHighlight;

  const _ConfigRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isHighlight
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                  color: isHighlight
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ),
      ],
    );
  }
}
