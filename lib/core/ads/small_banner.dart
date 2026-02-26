import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/ads/ad_mob_config.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tag_links/core/ads/ads_disable_provider.dart';
import 'package:tag_links/core/ads/ads_service_provider.dart';
import 'package:tag_links/core/ads/banner_with_closed_button.dart';
import 'package:tag_links/core/ads/show_ad_management_menu.dart';
import 'package:tag_links/ui/alerts/feedback_alert_confirm.dart';

class SmartBannerAd extends ConsumerStatefulWidget {
  const SmartBannerAd({super.key});

  @override
  ConsumerState<SmartBannerAd> createState() => _SmartBannerAdState();
}

class _SmartBannerAdState extends ConsumerState<SmartBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: AdMobConfig.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose(); // ¡IMPORTANTE! Descoméntalo para liberar RAM
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showAds = ref.watch(isAdsActiveProvider);
    debugPrint('showAds: $showAds');
    // Si las ads están desactivadas o el anuncio aún no carga, no mostramos nada
    if (!showAds || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return BannerWithCloseButton(
      onCloseTap: () => showAdManagementMenu(
        context,
        ref,
        // Dentro de tu SmartBannerAd
        showRewardedAd: () async {
          final success = await ref.read(adServiceProvider).showRewardedAd();
          if (success) {
            debugPrint("¡Usuario premiado!");
            // Aquí desactivas las ads o das el premio
            ref.read(adsDisabledUntilProvider.notifier).disableForHours(24);
            if (context.mounted) {
              FeedbackAlertConfirm.thanksForRewardedAd(context, ref);
            }
            return true;
          } else {
            if (context.mounted) {
              FeedbackAlertConfirm.errorForRewardedAd(context, ref);
            }
            debugPrint("El anuncio no estaba listo o el usuario lo cerró");
            return false;
          }
        },
        processPurchase: () async {
          debugPrint("SmartBannerAd: processPurchase falta implementar");
        },
      ),
      child: SizedBox(
        // Usamos SizedBox con el tamaño exacto del banner
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!), // ESTO es lo que muestra el anuncio
      ),
    );
  }
}
