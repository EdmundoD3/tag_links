import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/ads/ads_service_provider.dart';
import 'package:tag_links/core/ads/show_ad_management_menu.dart';
import 'package:tag_links/core/app_purchases/premium_sales_sheet.dart';
import 'package:tag_links/core/auth/account_sync_tile.dart';
import 'package:tag_links/core/coffe/invitame_un_caffe.dart';
import 'package:tag_links/core/locate/lang_selector.dart';
import 'package:tag_links/core/ads/ads_disable_provider.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/core/theme/theme_selector_widget.dart';
import 'package:tag_links/sync/sync_info.dart';

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
          ref.tr(TKeys.pages.settingsTitle, fallback: 'Configuración'),
          style: TextStyle(color: theme.appBarTheme.foregroundColor),
        ),
      ),
      floatingActionButton: null,
      body: SafeArea(
        child: Column(children: _buildBody(context, ref, adsActive)),
      ),
    );
  }

  List<Widget> _buildBody(
    BuildContext context,
    WidgetRef ref,
    bool? adsActive,
  ) {
    // 1. Mientras el estado es null, mostramos la opción de "Quitar Publicidad"
    //    o un loader si prefieres esperar a que SharedPreferences responda.
    //    En este caso, asumimos que si es null, es porque nunca ha decidido.

    final theme = Theme.of(context);
    return [
      ThemeSelector(),
      LangSelector(),

      // 2. Si ya decidió (es true o false), liberamos las opciones de apoyo
      if (adsActive != null) ...[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            ref.tr(
              TKeys.ads.supportTitle,
              fallback: '¿Cómo quieres apoyar el proyecto?',
            ),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        PremiumSalesSheet(showEmpty: null),

        InvitameUnCaffe(),

        if (adsActive)
          const Divider(
            color: Colors.grey,
            thickness: 1,
            indent: 10,
            endIndent: 10,
          ),
        if (adsActive)
          ListTile(
            leading: const Icon(Icons.video_library, color: Colors.orange),
            title: Text(
              ref.tr(TKeys.ads.viewLargeAd, fallback: 'Ver un anuncio grande'),
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
            ),
            subtitle: Text(
              ref.tr(
                TKeys.ads.disabledForOneDay,
                fallback: 'Se desactivará por un día la publicidad',
              ),
              style: TextStyle(color: theme.hintColor),
            ),
            onTap: () => showAdManagementMenu(
              context,
              ref,
              showRewardedAd: () async {
                // Usamos el servicio que ya tienes
                return await ref.read(adServiceProvider).showRewardedAd();
              },
              processPurchase: () async {
                // 3. Mostramos el modal de compra que creamos antes
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const PremiumSalesSheet(showEmpty: null),
                );
              },
            ),
          ),

        const Divider(
          color: Colors.grey,
          thickness: 1,
          indent: 10,
          endIndent: 10,
        ),
        // ------------- Account and Sync info ----------------
        AccountSyncTile(),
        BuildSyncInfo(),

        const SizedBox(height: 20),
        Center(
          child: Text(
            ref.tr(
              TKeys.ads.thanksForUsing,
              fallback: '¡Gracias por usar la App!',
            ),
            style: TextStyle(
              color: theme.textTheme.titleMedium?.color,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    ];
  }
}
