import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:share_handler/share_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_links/core/ads/ads_disable_provider.dart';
import 'package:tag_links/core/ads/ads_service_provider.dart';
import 'package:tag_links/core/app_purchases/premium_provider.dart';
import 'package:tag_links/core/auth/skiped_auth_provider.dart';
import 'package:tag_links/core/auth/welcome_page.dart';
import 'package:tag_links/core/google/auth_provider.dart';
import 'package:tag_links/core/theme/theme_provider.dart';
import 'package:tag_links/data/database.dart';
import 'package:tag_links/pages/home_page.dart';
import 'package:tag_links/data/shared_prefs_provider.dart';
import 'package:tag_links/state/url_provider.dart';
import 'package:tag_links/core/theme/app_theme.dart';
import 'package:tag_links/ui/is_loading_indicators/scaffold_login_loading_is_loading.dart';
import 'package:tag_links/utils/handle_media_in_coming_url.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await GoogleSignIn.instance.initialize(
    // El ID de cliente web es necesario para Drive en Android
    serverClientId: "70853418136-2able9jn660lj626faatvcao7bbktn62.apps.googleusercontent.com",
  );
  // Cargamos ambos motores en paralelo para ganar velocidad
  final results = await Future.wait([
    AppDatabase().database,
    SharedPreferences.getInstance(),
  ]);

  final db = results[0] as dynamic; // Tu instancia de DB
  final prefs = results[1] as SharedPreferences;

  runApp(
    ProviderScope(
      overrides: [
        // Inyectamos globalmente
        databaseProvider.overrideWithValue(db),
        sharedPrefsProvider.overrideWithValue(prefs),
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
    // _subscription?.cancel(); // ELIMINAR (Ya lo hace el Notifier solo)
    super.dispose();
  }

@override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final skipData = ref.watch(skipedAuthProvider);
    final palette = ref.watch(paletteProvider);

    // 1. Definimos qué cuerpo (pantalla) mostrar
    Widget currentScreen;

    if (auth.isLoading) {
      currentScreen = const ScaffoldLoginLoading();
    } else if (auth.isAuthenticated || skipData.getHasSkippedAuth() == true) {
      currentScreen = const HomePage(folder: null);
    } else {
      currentScreen = const WelcomePage();
    }

    // 2. Envolvemos SIEMPRE en el MaterialApp
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Opcional: quita la banda roja
      theme: getPalette(palette: palette),
      home: currentScreen,
    );
  }
}