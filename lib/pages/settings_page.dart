import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/locate/lang_selector.dart';
import 'package:tag_links/state/ads_disable_provider.dart';
import 'package:tag_links/theme/theme_selector_widget.dart';

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
          "Apoya Tag Links",
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
    return ListView(
      children: [
        ThemeSelector(),
        LangSelector(),
        if (adsActive == null) ...[
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(
              Icons.card_giftcard,
              color: Colors.red,
              size: 40,
            ),
            title: const Text(
              "¡Tengo un regalo para ti!",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("Haz clic aquí para ver de qué se trata."),
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
            leading: const Icon(Icons.coffee, color: Colors.brown),
            title: const Text("Invítame un café"),
            subtitle: const Text("Apoyo externo para el desarrollo."),
            onTap: _launchDonationUrl,
          ),

          const Divider(),

          SwitchListTile(
            secondary: const Icon(Icons.ads_click, color: Colors.blue),
            title: const Text("Banners pequeños"),
            subtitle: const Text(
              "Anuncios discretos que me ayudan económicamente.",
            ),
            value: adsActive,
            onChanged: (val) =>{
              // ref.read(adsDisabledUntilProvider.notifier).setStatus(val),
            }
          ),

          ListTile(
            leading: const Icon(Icons.video_library, color: Colors.orange),
            title: const Text("Ver un anuncio grande"),
            subtitle: const Text("Una ayuda rápida y gratuita."),
            onTap: () => _showRewardedAd(context),
          ),

          const SizedBox(height: 40),
          const Center(
            child: Text(
              "¡Gracias por usar la App!",
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
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
