import 'package:flutter/material.dart';

class BannerWithCloseButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onCloseTap;
  final EdgeInsets padding;
  final double width;
  final double closeSize;
  const BannerWithCloseButton({
    super.key,
    required this.child,
    required this.onCloseTap,
    required this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    this.closeSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    // Obtenemos el ancho máximo disponible
    final maxWidth = MediaQuery.of(context).size.width - (padding.horizontal);

    // Calculamos tu ancho ideal, pero limitado al máximo de la pantalla
    final totalWidth = (width + closeSize * 1.8).clamp(0.0, maxWidth);

    return Padding(
      padding: padding,
      child: Column(
        children: [
          SizedBox(
            width: totalWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [_CloseButton(onTap: onCloseTap, size: closeSize)],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _CloseButton extends StatefulWidget {
  final VoidCallback onTap;
  final double size;

  const _CloseButton({required this.onTap, required this.size});

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
          // decoration: BoxDecoration(
          //   color: Colors.white.withValues(alpha: 0.8),
          //   shape: BoxShape.circle,
          //   boxShadow: [
          //     BoxShadow(
          //       color: Colors.black.withValues(alpha: 0.1),
          //       blurRadius: 4,
          //     ),
          //   ],
          // ),
          child: Icon(
            Icons.cancel_outlined,
            size: widget.size,
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }
}
