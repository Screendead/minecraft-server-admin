import 'package:flutter/material.dart';

/// Unified loading indicator widget to replace duplicated CircularProgressIndicator patterns
class LoadingIndicator extends StatelessWidget {
  final double? size;
  final double? strokeWidth;
  final Color? color;
  final String? message;
  final bool showInRow;
  final double spacing;

  const LoadingIndicator({
    super.key,
    this.size,
    this.strokeWidth,
    this.color,
    this.message,
    this.showInRow = false,
    this.spacing = 12.0,
  });

  /// Small loading indicator (16x16) with stroke width 2
  const LoadingIndicator.small({
    super.key,
    this.color,
    this.message,
    this.showInRow = false,
    this.spacing = 12.0,
  })  : size = 16,
        strokeWidth = 2;

  /// Medium loading indicator (20x20) with stroke width 2
  const LoadingIndicator.medium({
    super.key,
    this.color,
    this.message,
    this.showInRow = false,
    this.spacing = 12.0,
  })  : size = 20,
        strokeWidth = 2;

  /// Large loading indicator (40x40) with default stroke width
  const LoadingIndicator.large({
    super.key,
    this.color,
    this.message,
    this.showInRow = false,
    this.spacing = 16.0,
  })  : size = 40,
        strokeWidth = null;

  @override
  Widget build(BuildContext context) {
    final indicator = SizedBox(
      width: size ?? 20,
      height: size ?? 20,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth ?? 2,
        color: color,
      ),
    );

    if (message == null) {
      return indicator;
    }

    if (showInRow) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          indicator,
          SizedBox(width: spacing),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        indicator,
        SizedBox(height: spacing),
        Text(
          message!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

