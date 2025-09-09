import 'package:flutter/material.dart';

class DropletNameField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const DropletNameField({
    super.key,
    required this.controller,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: const InputDecoration(
        labelText: 'Droplet Name',
        hintText: 'Enter a name for your Minecraft server',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.computer),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a droplet name';
        }
        if (value.trim().length < 3) {
          return 'Name must be at least 3 characters long';
        }
        return null;
      },
    );
  }
}
