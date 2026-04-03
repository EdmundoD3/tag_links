import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/ads/ads_disable_provider.dart';
import 'package:tag_links/core/ads/interstitial_ads_provider.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/ui/alerts/feedback_alert_confirm.dart';

void showAdManagementMenu(
  BuildContext context,
  WidgetRef ref, {
  required Future<bool> Function() showRewardedAd,
  required Future<void> Function() processPurchase,
}) {
  showModalBottomSheet(
    backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
    showDragHandle: true,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      bool isLoading = false;
      final theme = Theme.of(context);
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ref.tr(
                    TKeys.ads.disableTitle,
                    fallback: '¿Quieres quitar la publicidad?',
                  ),
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  ref.tr(
                    TKeys.ads.disableSubtitle,
                    fallback:
                        'Puedes quitar los anuncios viendo un video o apoyar el proyecto',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                /// 🎥 REWARDED AD
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() => isLoading = true);

                            final success = await showRewardedAd();

                            if (success) {
                              // 🔹 Desactiva banners 24h
                              await ref
                                  .read(adsDisabledUntilProvider.notifier)
                                  .disableForHours(24);

                              // 🔹 Reinicia interstitial (48h)
                              await ref
                                  .read(interstitialAdsProvider.notifier)
                                  .registerAdShown();

                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                              if (context.mounted) {
                                FeedbackAlertConfirm.thanksForRewardedAd(
                                  context,
                                  ref,
                                );
                              }
                            } else {
                              if (context.mounted) {
                                FeedbackAlertConfirm.errorForRewardedAd(
                                  context,
                                  ref,
                                );
                              }
                            }

                            setState(() => isLoading = false);
                          },
                    icon: const Icon(Icons.play_circle_fill),
                    label: Text(
                      ref.tr(
                        TKeys.ads.remove24h,
                        fallback: 'Quitar anuncios por 24h',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 1,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor:
                          theme.inputDecorationTheme.fillColor, // Fondo oscuro
                      foregroundColor:
                          theme.textTheme.titleLarge?.color, // Texto blanco
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// ❌ CLOSE
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    ref.tr(TKeys.ads.maybeLater, fallback: 'Tal vez luego'),
                    style: TextStyle(color: theme.textTheme.titleLarge?.color),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
