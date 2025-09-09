import 'package:flutter/material.dart';
import 'package:minecraft_server_automation/models/region.dart';

class LocationSection extends StatelessWidget {
  final Region? selectedRegion;
  final List<Region> availableRegions;
  final ValueChanged<Region?> onRegionChanged;
  final bool isFindingLocation;
  final VoidCallback onFindLocation;

  const LocationSection({
    super.key,
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
          initialValue: selectedRegion,
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
