import 'dart:async';
import 'dart:math';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tag_links/core/ads/ad_mob_config.dart';

class AdService {
  // RewardedAd? _rewardedAd;

  Future<bool> showRewardedAd() async {
    // final completer = Completer<bool>();

    // await RewardedAd.load(
    //   adUnitId: AdMobConfig.rewardedAdUnitId,
    //   request: const AdRequest(),
    //   rewardedAdLoadCallback: RewardedAdLoadCallback(
    //     onAdLoaded: (ad) {
    //       _rewardedAd = ad;

    //       ad.fullScreenContentCallback = FullScreenContentCallback(
    //         onAdDismissedFullScreenContent: (ad) {
    //           ad.dispose();
    //           if (!completer.isCompleted) {
    //             completer.complete(false);
    //           }
    //         },
    //         onAdFailedToShowFullScreenContent: (ad, error) {
    //           ad.dispose();
    //           if (!completer.isCompleted) {
    //             completer.complete(false);
    //           }
    //         },
    //       );

    //       ad.show(
    //         onUserEarnedReward: (ad, reward) {
    //           if (!completer.isCompleted) {
    //             completer.complete(true);
    //           }
    //         },
    //       );
    //     },
    //     onAdFailedToLoad: (error) {
    //       if (!completer.isCompleted) {
    //         completer.complete(false);
    //       }
    //     },
    //   ),
    // );

    // return completer.future;
    return true; //solo en debug
  }
}
