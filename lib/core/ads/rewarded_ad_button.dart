
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/ads/ads_disable_provider.dart';
import 'package:tag_links/core/ads/ads_service_provider.dart';
import 'package:tag_links/core/ads/interstitial_ads_provider.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/ui/modals/feedback_alert_confirm.dart';

class RewardedAdButton extends ConsumerWidget {
  const RewardedAdButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final result = await ref.read(adServiceProvider).showRewardedAd();

          switch (result) {
            case RewardedResult.shown:
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
                FeedbackAlertConfirm.thanksForRewardedAd(context, ref);
              }
              break;

            case RewardedResult.unavailable:
              if (context.mounted) {
                FeedbackAlertConfirm.errorForRewardedAd(context, ref);
              }
              break;

            case RewardedResult.alreadyShowing:
              debugPrint('Rewarded ignorado: ya hay un anuncio abierto');
              break;
          }
        },
        icon: Icon(
          Icons.ondemand_video,
          color: theme.textTheme.labelMedium?.color,
        ),
        label: Text(
          ref.tr(TKeys.ads.premium24h, fallback: 'Premium por 24 horas'),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 1,
          backgroundColor: theme.cardColor,
          foregroundColor: theme.textTheme.labelMedium?.color,
          side: BorderSide(color: theme.focusColor.withAlpha(120), width: 1),
        ),
      ),
    );
  }
}
