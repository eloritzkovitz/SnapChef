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
    return DefaultTextStyle(
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16.0,
        fontFamily: 'Roboto',
      ),
      child: Container(
        height: 32,
        width: double.infinity,
        color: color,
        alignment: Alignment.center,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, color: Colors.white),
              const SizedBox(width: 8),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }
}
