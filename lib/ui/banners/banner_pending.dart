import 'package:flutter/material.dart';

enum TypeBannerPending { normal, bloqued }

Color _getColorForType({
  required TypeBannerPending type,
  required Color defaultColor,
}) {
  if (type == TypeBannerPending.normal) return defaultColor;
  if (type == TypeBannerPending.bloqued) {
    return Colors.amber.withValues(alpha: 0.15);
  }
  return defaultColor;
}

class BannerPending extends StatelessWidget {
  final String title;
  final TypeBannerPending type;
  final List<Widget> actions;

  const BannerPending({
    super.key,
    required this.title,
    required this.actions,
    this.type = TypeBannerPending.normal,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlight = theme.textTheme.labelMedium?.color;
    return MaterialBanner(
      backgroundColor: _getColorForType(
        type: type,
        defaultColor: theme.cardColor,
      ),
        dividerColor: Colors.transparent,
  surfaceTintColor: Colors.transparent,
      content: Row(
        children: [
          Icon(Icons.pending_actions, color: highlight, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: theme.textTheme.labelSmall?.color),
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }
}

class BannerOptionsTile extends StatelessWidget {
  final String title;
  final void Function() onTap;

  const BannerOptionsTile({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlight = theme.textTheme.labelMedium?.color;

    return TextButton(
      onPressed: onTap,
      child: Text(
        title,
        style: TextStyle(color: highlight, fontWeight: FontWeight.w600),
      ),
    );
  }
}
