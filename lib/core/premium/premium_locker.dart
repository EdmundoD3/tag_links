import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ads/ads_disable_provider.dart';
import '../ads/show_ad_management_menu.dart';


class PremiumLocked extends ConsumerWidget {
  final bool locked;
  final Widget child;
  final IconData icon;

  const PremiumLocked({
    super.key,
    required this.child,
    this.icon = Icons.star,
    required this.locked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!locked) {
      return child;
    }
    // TODO despues hacer un hasPremiumAccessProvider
    final hasAccess = !ref.watch(isAdsActiveProvider);

    if (hasAccess) {
      return child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IgnorePointer(child: child),

        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: ()=> _onCloseTap(context,ref),
            ),
          ),
        ),

        Positioned(
          top: -2,
          right: -2,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 14,
              color: Colors.amber,
            ),
          ),
        ),
      ],
    );
  }
    void _onCloseTap(BuildContext context, WidgetRef ref) {
    return showAdManagementMenu(
      context,
      ref,
    );
  }
}
