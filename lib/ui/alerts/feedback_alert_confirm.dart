  import 'package:flutter/material.dart';

ScaffoldMessengerState feedbackAlertConfirm(
    BuildContext context,
    String title, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    return ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(title),
          backgroundColor: backgroundColor,
          duration: duration,
        ),
      );
  }