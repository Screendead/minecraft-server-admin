import 'package:flutter/material.dart';
import 'package:minecraft_server_automation/common/widgets/feedback/loading_indicator.dart';

class SubmitButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;

  const SubmitButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.text = 'Create Droplet',
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: isLoading
          ? const LoadingIndicator.medium(
              message: 'Creating Droplet...',
              showInRow: true,
            )
          : Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
    );
  }
}
