import 'package:flutter/material.dart';
import 'package:tag_links/core/debug/debug_page.dart';

class GoDebugPageButon extends StatelessWidget {
  const GoDebugPageButon({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      onPressed: () => {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DebugPage()),
        ),
      },
      icon: Icon(Icons.bug_report, color:theme.iconTheme.color),
    );
  }
}
