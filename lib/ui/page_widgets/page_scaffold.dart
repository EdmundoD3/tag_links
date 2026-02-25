import 'package:flutter/material.dart';

class PageScaffold extends StatelessWidget {
  final PreferredSizeWidget appBar;
  final Widget floatingActionButton;
  final List<Widget> body;

  const PageScaffold({super.key, required this.appBar, required this.floatingActionButton, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: Column(children: body)
    );
  }
}
