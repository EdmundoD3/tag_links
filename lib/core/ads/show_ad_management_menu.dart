import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/ads/ads_disable_provider.dart';
import 'package:tag_links/core/ads/interstitial_ads_provider.dart';

void showAdManagementMenu(
  BuildContext context,
  WidgetRef ref, {
  required Future<bool> Function() showRewardedAd,
  required Future<void> Function() processPurchase,
}) {
  showModalBottomSheet(
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
                  "¿Te estorba la publicidad?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Puedes quitar los anuncios viendo un video o apoyar el proyecto.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.hintColor),
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
                            }

                            setState(() => isLoading = false);
                          },
                    icon: const Icon(Icons.play_circle_fill),
                    label: const Text("Quitar anuncios por 24h"),
                    style: ElevatedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// 💎 PREMIUM
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await processPurchase();
                    },
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      "Plan sin anuncios - \$2.50 / año",
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// ❌ CLOSE
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Tal vez luego",
                    style: TextStyle(),
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
