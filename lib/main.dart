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
import 'package:tag_links/state/url_provider.dart';
import 'package:tag_links/core/theme/app_theme.dart';
import 'package:tag_links/utils/handle_media_in_coming_url.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  final db = await AppDatabase().database;
  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MyApp(),
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

    _subHandleUrl = ShareListener.stream.listen(_handleMedia);
    ShareListener.getInitial().then(_handleMedia);

    // 1. Activar PremiumNotifier inmediatamente (es ligero)
    Future.microtask(() => ref.read(premiumNotifierProvider));

    // 2. 🚀 CARGA DE ADS MUCHO DESPUÉS
    // Esperamos 6 segundos para que el emulador cargue WebView e Impeller
    Future.delayed(const Duration(seconds: 6), () {
      if (!mounted) return;
      try {
        final ads = ref.read(adServiceProvider);
        ads.loadRewardedAd();
        ads.loadInterstitialAd();
        debugPrint('AdMob: Carga inicial programada ejecutada.');
      } catch (e) {
        debugPrint('AdMob: Error en carga diferida: $e');
      }
    });
  }

  void _handleMedia(SharedMedia? media) {
    return handleMedia(media, ref);
  }

  // Future<void> _initPurchaseStream() async {
  //   if (_subscription != null) return;

  //   final available = await InAppPurchase.instance.isAvailable();
  //   if (!available || !mounted) return;

  //   _subscription = InAppPurchase.instance.purchaseStream.listen(
  //     _listenToPurchaseUpdated,
  //     onDone: () => _subscription?.cancel(),
  //     onError: (error, stack) {
  //       debugPrint('Purchase stream error: $error');
  //     },
  //   );

  //   // IMPORTANTE: Pedimos a la tienda que nos envíe las compras activas
  //   // para actualizar la fecha de expiración (Heartbeat).
  //   await InAppPurchase.instance.restorePurchases();
  // }

  // void _listenToPurchaseUpdated(List<PurchaseDetails> list) {
  //   assert(() {
  //     debugPrint('Purchase update: ${list.length}');
  //     return true;
  //   }());

  //   InAppPurchaseManager.listenToPurchaseUpdated(list);
  // }

  @override
  void dispose() {
    _subHandleUrl.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(paletteProvider);

    return MaterialApp(
      theme: getPalette(palette: palette),
      home: const HomePage(),
    );
  }
}
