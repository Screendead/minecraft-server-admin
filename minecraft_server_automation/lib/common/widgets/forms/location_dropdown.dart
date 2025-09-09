import 'package:flutter/material.dart';
import 'package:minecraft_server_automation/models/region.dart';

class LocationDropdown extends StatelessWidget {
  final Region? selectedRegion;
  final List<Region> regions;
  final ValueChanged<Region?> onChanged;

  const LocationDropdown({
    super.key,
    required this.selectedRegion,
    required this.regions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Region>(
      value: selectedRegion,
      decoration: const InputDecoration(
        labelText: 'Location',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.location_on),
      ),
      items: regions.map((region) {
        return DropdownMenuItem<Region>(
          value: region,
          child: Text('${region.name} (${region.slug.toUpperCase()})'),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
