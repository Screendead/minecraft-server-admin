import 'package:flutter/material.dart';
import 'package:minecraft_server_automation/models/cpu_architecture.dart';

class CpuArchitectureSelector extends StatelessWidget {
  final CpuArchitecture? selectedArchitecture;
  final ValueChanged<CpuArchitecture?> onChanged;
  final bool isEnabled;

  const CpuArchitectureSelector({
    super.key,
    required this.selectedArchitecture,
    required this.onChanged,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<CpuArchitecture>(
      initialValue: selectedArchitecture,
      decoration: const InputDecoration(
        labelText: 'CPU Architecture',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.memory),
      ),
      items: CpuArchitecture.values.map((architecture) {
        return DropdownMenuItem<CpuArchitecture>(
          value: architecture,
          child: Text(architecture.displayName),
        );
      }).toList(),
      onChanged: isEnabled ? onChanged : null,
    );
  }
}
