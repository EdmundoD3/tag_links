  import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/t_keys.dart';

class FeedbackAlertConfirm {
  static ScaffoldMessengerState thanksForRewardedAd(BuildContext context, WidgetRef ref) {
    return feedbackAlertConfirm(
      context,
      ref.tr(TKeys.ads.thanksReward, fallback: 'Gracias!'),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 4),
    );
  }
  static ScaffoldMessengerState errorForRewardedAd(BuildContext context, WidgetRef ref) {
    return feedbackAlertConfirm(
      context,
      ref.tr(TKeys.ads.errorShowing, fallback: 'Error al mostrar el anuncio, inténtalo de nuevo más tarde.'),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 4),
    );
  }
}

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