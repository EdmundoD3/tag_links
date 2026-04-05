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
    return Padding(
      padding: padding,
      child: Stack(
        children: [
          // Banner
          ClipRRect(child: child),

          if (showClose)
            Positioned(
              top: 0,
              right: 0,
              child: _CloseButton(onTap: onCloseTap),
            ),
        ],
      ),
    );
  }
}

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
      child: Container( // Quitamos el SizedBox o lo hacemos de 24x24
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
        child: const Icon(
          Icons.cancel_outlined, 
          size: 18, 
          color: Colors.blueAccent
        ),
      ),
    ),
  );
}
}
