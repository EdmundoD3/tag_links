import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:share_handler/share_handler.dart';
import 'package:tag_links/core/ads/ads_service_provider.dart';
import 'package:tag_links/core/app_purchases/premium_provider.dart';
import 'package:tag_links/core/theme/theme_provider.dart';
import 'package:tag_links/data/database.dart';
import 'package:tag_links/pages/home_page.dart';
import 'package:tag_links/state/url_provider.dart';
import 'package:tag_links/core/theme/app_theme.dart';
import 'package:tag_links/utils/handle_media_in_coming_url.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Si tienes un splash screen o algo que espere, asegúrate que no se quede trabado
  final db = await AppDatabase().database;
  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
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
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  @override
  void initState() {
    super.initState();

    MobileAds.instance.initialize();

    _subHandleUrl = ShareListener.stream.listen(_handleMedia);
    ShareListener.getInitial().then(_handleMedia);
    // 1. PremiumNotifier: Usamos read una sola vez para despertar el provider
    // sin crear un bucle de reconstrucción en el primer frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(premiumNotifierProvider);
    });
    // 2. 🚀 CARGA DE ADS (Solo si NO es Premium)
    Future.delayed(const Duration(seconds: 8), () {
      // Verificamos si el usuario es premium antes de cargar basura visual
      final isPremium = ref.read(premiumNotifierProvider);

      if (isPremium) {
        return;
      }

      try {
        final ads = ref.read(adServiceProvider);
        ads.loadRewardedAd();
        ads.loadInterstitialAd();
        debugPrint('AdMob: Carga inicial ejecutada tras espera.');
      } catch (e) {
        debugPrint('AdMob: Fallo silencioso en emulador: $e');
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
    final palette = ref.watch(paletteProvider);

    return MaterialApp(
      theme: getPalette(palette: palette),
      home: const HomePage(folder: null),
    );
  }
}
