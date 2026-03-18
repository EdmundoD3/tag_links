import 'package:flutter/material.dart';
import 'package:tag_links/core/ads/small_banner.dart';

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
    // 1. El cuerpo solo contiene el formulario y la lista
    body: Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
        children: children, // Quitamos el SmartBannerAd de aquí
      ),
    ),
    // 2. Colocamos el anuncio aquí para que esté fijo al final
    bottomNavigationBar: const SafeArea(
      child: SmartBannerAd(),
    ),
  );
}
}
