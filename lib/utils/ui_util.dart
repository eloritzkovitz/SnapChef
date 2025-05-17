import 'package:flutter/material.dart';

class UIUtil {  
  /// Show error message in a SnackBar.
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}