import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/config/ad_mob_config.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tag_links/core/ads/ads_disable_provider.dart';
import 'package:tag_links/core/ads/ads_service_provider.dart';
import 'package:tag_links/core/ads/banner_with_closed_button.dart';
import 'package:tag_links/core/ads/show_ad_management_menu.dart';
import 'package:tag_links/core/app_purchases/premium_sales_sheet.dart';

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
        onAdLoaded: (_) => setState(() => _isLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Banner Error: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adsActivas = ref.watch(isAdsActiveProvider);

    if (!adsActivas || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      // Le damos un margen arriba para que el botón que sobresale no se pegue al widget de arriba
      margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      // Altura del banner normal
      // height: _bannerAd!.size.height.toDouble(),
      child: BannerWithCloseButton(
        // Quitamos el padding horizontal si quieres que la X esté pegada al borde del banner real
        // padding: EdgeInsets,
        onCloseTap: _onCloseTap,
        width: _bannerAd!.size.width.toDouble(),
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      ),
    );
  }

  void _onCloseTap() {
    return showAdManagementMenu(
      context,
      ref,
      showRewardedAd: () async =>
          await ref.read(adServiceProvider).showRewardedAd(),
      processPurchase: () async {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const PremiumSalesSheet(showEmpty: null),
        );
      },
    );
  }
}
