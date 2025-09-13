import 'package:flutter/material.dart';
import 'loading_indicator.dart';

/// Loading overlay component that can be easily tested
/// This component is pure UI with no business logic dependencies
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingMessage;
  final Color? overlayColor;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingMessage,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor ?? Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: LoadingIndicator.large(
                    message: loadingMessage,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
