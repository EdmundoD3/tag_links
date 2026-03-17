import 'package:flutter/material.dart';
import 'package:tag_links/core/ads/small_banner.dart';

class PageScaffold extends StatelessWidget {
  final PreferredSizeWidget appBar;
  final Widget? floatingActionButton;
  final Widget? bottomButtonBar;
  final List<Widget> body;

  const PageScaffold({super.key, required this.appBar, required this.floatingActionButton, required this.body, this.bottomButtonBar});

@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  return Scaffold(
  backgroundColor: theme.scaffoldBackgroundColor,
  appBar: appBar,
  floatingActionButton: floatingActionButton,

  body: SafeArea(
    child: Column(
      children: [...body],
    ),
  ),

  bottomNavigationBar: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SmartBannerAd(key: Key('global_banner')),
      const SizedBox(height: 8),
      bottomButtonBar?? const SizedBox.shrink(),
    ],
  ),
);
}
}
