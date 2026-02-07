import 'package:flutter/material.dart';
import 'package:tag_links/pages/settings_page.dart';

class GoSettingsButton extends StatelessWidget {
  const GoSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      onPressed: () => {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SupportProjectPage()),
        ),
      },
      icon: Icon(Icons.settings, color:theme.iconTheme.color),
    );
  }
}
