import 'package:flutter/material.dart';

class BodyForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final PreferredSizeWidget appBar;
  final List<Widget> children;

  const BodyForm({
    super.key,
    required this.formKey,
    required this.appBar,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Form(
        key: formKey,
        child: ListView(padding: const EdgeInsets.all(16), children: children),
      ),
    );
  }
}
