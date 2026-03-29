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

    // 2. Si las ads están pausadas temporalmente (por un Reward)
    final adsActivas = ref.watch(isAdsActiveProvider);
    
    if (!adsActivas || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: double.infinity, // Centramos en el ancho disponible
      height: _bannerAd!.size.height.toDouble() + 10, // Un poco de aire para el padding
      child: BannerWithCloseButton(
        onCloseTap: () => showAdManagementMenu(
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
              builder: (_) => const PremiumSalesSheet(showEmpty: null,),
            );
          },
        ),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}