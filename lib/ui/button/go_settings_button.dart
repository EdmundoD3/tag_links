import 'package:flutter/material.dart';
import 'package:tag_links/pages/settings_page.dart';
import 'package:tag_links/ui/utils/page_buil.dart';

class GoSettingsButton extends StatelessWidget {
  const GoSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      onPressed: () => goPage(context: context, page: SupportProjectPage()),
      icon: Icon(Icons.settings, color:theme.iconTheme.color),
    );
  }
}
