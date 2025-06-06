import 'package:flutter/material.dart';
import '../theme/colors.dart';

class OfflineBanner extends StatelessWidget {
  final double height;
  final Color color;
  final String message;

  const OfflineBanner({
    super.key,
    this.height = 48.0,
    this.color = disabledSecondaryColor,
    this.message = 'You are offline',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,      
      width: double.infinity,
      color: color,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}