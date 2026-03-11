import 'package:flutter/material.dart';

class BannerPending extends StatelessWidget {
  final String title;
  final List<Widget> actions;

  const BannerPending({super.key, required this.title, required this.actions});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MaterialBanner(
      backgroundColor: theme.cardColor,
      content: Text(
        title,
        style: TextStyle(color: theme.textTheme.labelSmall?.color),
      ),
      actions: actions,
    );
  }
}

class BannerOptionsTile extends StatelessWidget {
  final String title;
  final Function() onTap;

  const BannerOptionsTile({super.key, required this.title, required this.onTap});


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
              onPressed: onTap,
              child: Text(
                title,
                style: TextStyle(color: theme.textTheme.titleLarge?.color),
              ),
            );
  }
  
}