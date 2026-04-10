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
    // Envolvemos todo el Scaffold para que al tocar cualquier parte
    // del formulario que no sea un Input, se cierre el teclado/sugerencias.
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: appBar,
        // El cuerpo contiene el formulario y la lista
        body: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            // Al ser un ListView, el GestureDetector de arriba detectará
            // los toques en los espacios vacíos entre widgets.
            children: children,
          ),
        ),
        // El anuncio fijo al final
        bottomNavigationBar: const SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: SmartBannerAd(),
          ),
        ),
      ),
    );
  }
}
