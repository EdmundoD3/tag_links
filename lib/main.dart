import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:share_handler/share_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tag_links/config/google_sign_in_config.dart';
import 'package:tag_links/core/ads/ads_disable_provider.dart';
import 'package:tag_links/core/ads/ads_service_provider.dart';
import 'package:tag_links/core/app_purchases/premium_provider.dart';
import 'package:tag_links/core/google/auth_manager.dart';
import 'package:tag_links/core/theme/generate_palete.dart';
import 'package:tag_links/core/theme/theme_provider.dart';
import 'package:tag_links/data/database.dart';
import 'package:tag_links/pages/home_page.dart';
import 'package:tag_links/data/shared_prefs_provider.dart';
import 'package:tag_links/state/url_provider.dart';
import 'package:tag_links/sync/last_sync_storage.dart';
import 'package:tag_links/sync/sync_fowder_handler.dart';
import 'package:tag_links/sync/widgets/app_life_cycle_observer.dart';
import 'package:tag_links/core/media_in_coming/handle_media_in_coming_url.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  // 1. Obtener la instancia del Singleton
  final googleSignIn = GoogleSignIn.instance;

  // 2. Configurar el cliente nativo para los Backups de Drive
  await googleSignIn.initialize(serverClientId: GoogleSignInAppConfig.clientId);

  // 3. Carga en paralelo de DB y SharedPreferences (¡Excelente optimización!)
  final results = await Future.wait([
    AppDatabase().database,
    SharedPreferences.getInstance(),
  ]);

  final db = results[0] as Database;
  final prefs = results[1] as SharedPreferences;

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sharedPrefsProvider.overrideWithValue(prefs),
        // Aquí ocurre la magia: Inyectas la instancia perfectamente configurada
        googleSignInProvider.overrideWithValue(googleSignIn),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final StreamSubscription _subHandleUrl;

  @override
  void initState() {
    super.initState();
    MobileAds.instance.initialize();

    _subHandleUrl = ShareListener.stream.listen(_handleMedia);
    ShareListener.getInitial().then(_handleMedia);

    // 2. 🚀 CARGA DE ADS INTELIGENTE
    // No necesitamos PostFrameCallback para despertar al notifier porque
    // el estado ya es accesible sincrónicamente gracias al override.
    _initAdsLogic();
  }

  void _initAdsLogic() {
    // 8 segundos es un buen margen para que el usuario se acomode
    Future.delayed(const Duration(seconds: 8), () {
      // IMPORTANTE: Usa el mismo provider que definimos (premiumStatusProvider)
      final isPremium = ref.read(premiumStatusProvider);

      if (isPremium) {
        debugPrint('AdMob: Usuario Premium. No cargamos nada.');
        return;
      }

      // Si no es premium, revisamos si tiene "Ads desactivados temporalmente"
      // (Por haber visto un video premiado, por ejemplo)
      final adsActive = ref.read(isAdsActiveProvider);

      if (adsActive) {
        final ads = ref.read(adServiceProvider);
        ads.loadRewardedAd();
        ads.loadInterstitialAd();
      }
    });
  }

  void _handleMedia(SharedMedia? media) {
    if (media == null) return;
    return handleMedia(media, ref);
  }

  @override
  void dispose() {
    _subHandleUrl.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(paletteProvider);

    // 2. Envolvemos SIEMPRE en el MaterialApp
    return MaterialApp(
      theme: getPalette(palette: palette),
      home: const AppLifecycleObserver(child: MainPageRouter()),
    );
  }
}

class MainPageRouter extends ConsumerStatefulWidget {
  const MainPageRouter({super.key});

  @override
  ConsumerState<MainPageRouter> createState() => _MainPageRouterState();
}

class _MainPageRouterState extends ConsumerState<MainPageRouter> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final syncInfo = ref.read(lastSyncProvider);

      final ahora = DateTime.now().millisecondsSinceEpoch;
      const veinticuatroHoras = 24 * 60 * 60 * 1000;

      if (ahora - (syncInfo.lastPulledAt ?? ahora) >= veinticuatroHoras) {
        SyncFlowHandler.handleSilentSyncCheck(context, ref);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const HomePage(folder: null);
  }
}