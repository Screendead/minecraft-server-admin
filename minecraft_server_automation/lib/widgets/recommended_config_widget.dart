import 'package:flutter/material.dart';
import 'package:minecraft_server_automation/common/di/service_locator.dart';
import 'package:minecraft_server_automation/models/region.dart';
import 'package:minecraft_server_automation/common/widgets/forms/location_section.dart';
import 'package:minecraft_server_automation/common/widgets/cards/configuration_details.dart';
import 'package:minecraft_server_automation/common/widgets/cards/placeholder_message.dart';

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
      RecommendedConfigWidgetState();
}

class RecommendedConfigWidgetState extends State<RecommendedConfigWidget> {
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
      final regionService = ServiceLocator().regionSelectionService;
      final closestRegion =
          await regionService.findClosestRegion(widget.availableRegions);
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
            LocationSection(
              selectedRegion: widget.selectedRegion,
              availableRegions: widget.availableRegions,
              onRegionChanged: widget.onRegionChanged,
              isFindingLocation: _isFindingLocation,
              onFindLocation: _findClosestRegion,
            ),
            const SizedBox(height: 16),

            // Configuration details - only show if region is selected
            if (widget.selectedRegion != null)
              const ConfigurationDetails()
            else
              const PlaceholderMessage(
                icon: Icons.location_on_outlined,
                title: 'Select a region to see recommended configuration',
                subtitle:
                    'Click "Find Closest" to automatically detect your nearest region',
              ),
          ],
        ),
      ),
    );
  }
}
