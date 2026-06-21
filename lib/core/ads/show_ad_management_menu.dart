import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/ads/rewarded_ad_button.dart';
import 'package:tag_links/core/app_purchases/widget/premium_purchase_button.dart';
import 'package:tag_links/core/locate/t_keys.dart';

void showAdManagementMenu(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    backgroundColor: Theme.of(context).cardColor,
    showDragHandle: true,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
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
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    color: theme.textTheme.labelMedium?.color,
                  ),
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
                    color: theme.textTheme.bodySmall?.color?.withAlpha(220),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                // Premium
                const PremiumPurchaseButton(),
                const SizedBox(height: 12),

                /// 🎥 REWARDED AD
                const RewardedAdButton(),

                const SizedBox(height: 12),

                /// ❌ CLOSE
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    ref.tr(TKeys.ads.maybeLater, fallback: 'Tal vez luego'),
                    style: TextStyle(color: theme.textTheme.bodySmall?.color),
                  ),
                ),
                //espacio para los dispositivos que no lo generan por default
                SizedBox(height: MediaQuery.paddingOf(context).bottom),
              ],
            ),
          );
        },
      );
    },
  );
}
