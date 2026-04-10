import 'package:flutter/material.dart';
import 'package:tag_links/core/debug/debug_page.dart';
import 'package:tag_links/ui/utils/page_buil.dart';

class GoDebugPageButon extends StatelessWidget {
  const GoDebugPageButon({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      onPressed: () => {
        goPage(context: context, page:  DebugPage()),
      },
      padding: const EdgeInsets.all(0),
      tooltip: 'Debug',
      icon: Icon(Icons.bug_report, color:theme.iconTheme.color),
    );
  }
}
