import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class BannerWithCloseButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onCloseTap;
  final EdgeInsets padding;
  final bool showClose;

  const BannerWithCloseButton({
    super.key,
    required this.child,
    required this.onCloseTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    this.showClose = true,
  });

  @override
  Widget build(BuildContext context) {
    // Definimos cuánto queremos que el botón sobresalga.
    // Con 16px, la mitad del botón (que mide ~24px) quedará fuera.
    const double offsetValue = 16.0;

    return Padding(
      padding: padding,
      child: Stack(
        clipBehavior: Clip.none, // IMPORTANTE: permite que la X se dibuje fuera del marco
        children: [
          // 1. EL BANNER
          ClipRRect(child: child),

          // 2. LA X (Posicionada en la esquina superior derecha hacia afuera)
          if (showClose)
            Positioned(
              top: -offsetValue,    // Sube la X hacia arriba
              right: -offsetValue,  // Mueve la X hacia la derecha
              child: _CloseButton(onTap: onCloseTap),
            ),
        ],
      ),
    );
  }
}

// ... aquí sigue tu clase _CloseButton igual que la tenías ...

class _CloseButton extends StatefulWidget {
  final VoidCallback onTap;

  const _CloseButton({required this.onTap});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: widget.onTap, // Usar onTap o onPressed según prefieras
        behavior: HitTestBehavior.opaque,
        child: Container(
          // Quitamos el SizedBox o lo hacemos de 24x24
          padding: const EdgeInsets.all(2), // Da un margen pequeño al icono
          child: const Icon(
            Icons.cancel_outlined,
            size: 18,
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }
}
