import 'package:flutter/material.dart';

class FixedWidthTab extends StatelessWidget {
  final String text;
  final IconData icon;
  final double width;

  const FixedWidthTab({
    super.key,
    required this.text,
    required this.icon,
    this.width = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Tab(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(height: 2),
            Text(
              text,
              style: const TextStyle(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
