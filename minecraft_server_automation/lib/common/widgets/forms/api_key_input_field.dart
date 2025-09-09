import 'package:flutter/material.dart';

class ApiKeyInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isValidating;
  final String? errorMessage;
  final ValueChanged<String> onChanged;

  const ApiKeyInputField({
    super.key,
    required this.controller,
    required this.isValidating,
    required this.onChanged,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'DigitalOcean API Key',
            hintText: 'Enter your DigitalOcean API key',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.key),
            suffixIcon: isValidating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          onChanged: onChanged,
          enabled: !isValidating,
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            errorMessage!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        ],
      ],
    );
  }
}
