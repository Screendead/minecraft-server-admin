import 'package:flutter/material.dart';
import 'package:minecraft_server_automation/models/minecraft_version.dart';

class MinecraftVersionDropdown extends StatelessWidget {
  final MinecraftVersion? selectedVersion;
  final List<MinecraftVersion> versions;
  final ValueChanged<MinecraftVersion?> onChanged;

  const MinecraftVersionDropdown({
    super.key,
    required this.selectedVersion,
    required this.versions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<MinecraftVersion>(
      initialValue: selectedVersion,
      decoration: const InputDecoration(
        labelText: 'Minecraft Version',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.games),
      ),
      items: versions.map((version) {
        return DropdownMenuItem<MinecraftVersion>(
          value: version,
          child: Text(version.displayName),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
