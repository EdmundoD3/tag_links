import 'package:flutter/material.dart';
import 'package:tag_links/core/debug/debug_page.dart';
import 'package:tag_links/core/decorate_color/decorated_color_themes.dart';
import 'package:tag_links/ui/utils/page_buil.dart';

class GoDebugPageButon extends StatelessWidget {
  final DecorateColor? decorateColor;
  const GoDebugPageButon({super.key, this.decorateColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      onPressed: () => {
        goPage(context: context, page:  DebugPage()),
      },
      padding: const EdgeInsets.all(0),
      tooltip: 'Debug',
      icon: Icon(Icons.bug_report, color: decorateColor?.light??theme.colorScheme.onPrimary),
    );
  }
}
