import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/ads/small_banner.dart';
import 'package:tag_links/core/locate/lang_selector.dart';
import 'package:tag_links/core/ads/ads_disable_provider.dart';
import 'package:tag_links/core/theme/theme_selector_widget.dart';

class SupportProjectPage extends ConsumerWidget {
  const SupportProjectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el estado (null al inicio, luego el valor de SharedPreferences)
    final adsActive = ref.watch(isAdsActiveProvider);

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(color: theme.appBarTheme.foregroundColor),
        ),
      ),
      body: _buildBody(context, ref, adsActive),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, bool? adsActive) {
    // 1. Mientras el estado es null, mostramos la opción de "Quitar Publicidad"
    //    o un loader si prefieres esperar a que SharedPreferences responda.
    //    En este caso, asumimos que si es null, es porque nunca ha decidido.
    final theme = Theme.of(context);

    return ListView(
      children: [
        ThemeSelector(),
        LangSelector(),
        if (adsActive == null) ...[
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(
              Icons.card_giftcard,
              color: Colors.blueAccent,
              size: 40,
            ),
            title: Text(
              "¡Tengo un regalo para ti!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            subtitle: Text(
              "Haz clic aquí para ver de qué se trata.",
              style: TextStyle(color: theme.hintColor),
            ),
            onTap: () => _showFreeAdsDialog(context, ref),
          ),
        ],

        // 2. Si ya decidió (es true o false), liberamos las opciones de apoyo
        if (adsActive != null) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "¿Cómo quieres apoyar el proyecto?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.coffee, color: Color(0xFFBB9457)),
            title: Text(
              "Invítame un café",
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
            ),
            subtitle: Text(
              "Apoyo externo para el desarrollo.",
              style: TextStyle(color: theme.hintColor),
            ),
            onTap: _launchDonationUrl,
          ),

          const Divider(
            color: Colors.grey,
            thickness: 1,
            indent: 10,
            endIndent: 10,
          ),

          ListTile(
            leading: const Icon(Icons.video_library, color: Colors.orange),
            title: Text(
              "Ver un anuncio grande",
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
            ),
            subtitle: Text(
              "Se desactiva por un día la publicidad.",
              style: TextStyle(color: theme.hintColor),
            ),
            onTap: () => _showRewardedAd(context),
          ),

          const SizedBox(height: 40),
          Center(
            child: Text(
              "¡Gracias por usar la App!",
              style: TextStyle(
                color: theme.textTheme.titleMedium?.color,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SmartBannerAd(),
        ],
      ],
    );
  }

  void _showFreeAdsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("¡La intención es lo que cuenta!"),
        content: Text(
          "No es necesario que pagues nada. Solo por usar la app y querer apoyarme, puedes desactivar los anuncios si lo deseas. ¡Gracias por estar aquí!",
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 2. Desactivamos los anuncios por defecto
              // ref.read(adsDisabledUntilProvider.notifier).setStatus(false);
              Navigator.pop(context);
            },
            child: Text("¡GRACIAS!"),
          ),
        ],
      ),
    );
  }

  void _showRewardedAd(BuildContext context) {
    // RewardedAd.load(
    //   adUnitId: AdMobConfig.rewardedAdUnitId,
    //   request: const AdRequest(),
    //   rewardedAdLoadCallback: RewardedAdLoadCallback(
    //     onAdLoaded: (RewardedAd ad) {
    //       ad.show(
    //         onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
    //           ScaffoldMessenger.of(context).showSnackBar(
    //             const SnackBar(
    //               content: Text(
    //                 "¡Muchas gracias! Tu apoyo mantiene este proyecto vivo ❤️",
    //               ),
    //               backgroundColor: Colors.green,
    //             ),
    //           );
    //         },
    //       );

    //       ad.fullScreenContentCallback = FullScreenContentCallback(
    //         onAdDismissedFullScreenContent: (ad) {
    //           ad.dispose();
    //         },
    //         onAdFailedToShowFullScreenContent: (ad, error) {
    //           ad.dispose();
    //         },
    //       );
    //     },
    //     onAdFailedToLoad: (LoadAdError error) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(
    //           content: Text("No se pudo cargar el anuncio 😥"),
    //           backgroundColor: Colors.red,
    //         ),
    //       );
    //     },
    //   ),
    // );
  }
  void _launchDonationUrl() {}
}
