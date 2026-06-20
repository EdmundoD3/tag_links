import 'package:flutter/material.dart';
import 'package:tag_links/core/decorate_color/decorated_color_themes.dart';

class AppBarPages extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final DecorateColor? decorateColor;

  const AppBarPages({
    super.key,
    required this.title,
    this.actions,
    this.decorateColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final foregroundColor =
        decorateColor?.text ?? theme.appBarTheme.foregroundColor;

    final accent = decorateColor?.strong.withAlpha(100);

    return AppBar(
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: foregroundColor),
      ),

      backgroundColor: decorateColor?.strong.withAlpha(210),

      iconTheme: IconThemeData(
        color: foregroundColor,
      ),

      bottom: accent == null
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(3),
              child: Container(
                height: 3,
                color: accent,
              ),
            ),

      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}