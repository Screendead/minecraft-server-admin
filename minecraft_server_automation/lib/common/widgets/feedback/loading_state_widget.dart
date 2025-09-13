import 'package:flutter/material.dart';
import 'loading_indicator.dart';

class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final double? size;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: size != null
          ? LoadingIndicator(
              message: message,
              size: size,
            )
          : LoadingIndicator.large(
              message: message,
            ),
    );
  }
}
