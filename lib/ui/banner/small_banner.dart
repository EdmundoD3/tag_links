import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/state/is_banner_aviable.dart';

class SmartBannerAd extends ConsumerWidget {
  const SmartBannerAd({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAds = ref.watch(isAdsActiveProvider) ?? true;

    if (!showAds) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: 60, // Altura estándar de banner
      color: Colors.grey[200], // Color de fondo mientras carga
      alignment: Alignment.center,
      child: const Text("AD BANNER HERE"), // Aquí irá tu AdWidget de Google
    );
  }
}