import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/ads/ad_service.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tag_links/core/ads/ads_disable_provider.dart';
import 'package:tag_links/core/ads/banner_with_closed_button.dart';
import 'package:tag_links/core/ads/show_ad_management_menu.dart';

class SmartBannerAd extends ConsumerStatefulWidget {
  const SmartBannerAd({super.key});

  @override
  ConsumerState<SmartBannerAd> createState() => _SmartBannerAdState();
}

class _SmartBannerAdState extends ConsumerState<SmartBannerAd> {
  // BannerAd? _bannerAd;
  // bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    // _loadAd();
  }

  // void _loadAd() {
  //   _bannerAd = BannerAd(
  //     adUnitId: AdMobConfig.bannerAdUnitId,
  //     size: AdSize.banner,
  //     request: const AdRequest(),
  //     listener: BannerAdListener(
  //       onAdLoaded: (_) {
  //         setState(() => _isLoaded = true);
  //       },
  //       onAdFailedToLoad: (ad, error) {
  //         ad.dispose();
  //       },
  //     ),
  //   )..load();
  // }

  @override
  void dispose() {
    // _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showAds = ref.watch(isAdsActiveProvider);

    // if (!showAds || !_isLoaded || _bannerAd == null) {
    if (!showAds) {
      return const SizedBox.shrink();
    }
    return BannerWithCloseButton(
      onCloseTap: () => showAdManagementMenu(
        context,
        ref,
        showRewardedAd: () => AdService().showRewardedAd(),
        processPurchase: () async {
          // TODO: Implement purchase logic
          debugPrint("SmartBannerAd: processPurchase falta implementar");
        }
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        color: Colors.grey[300],
        alignment: Alignment.center,
        child: const Text('Banner de Publicidad'),
      ),
    );
  }
}
