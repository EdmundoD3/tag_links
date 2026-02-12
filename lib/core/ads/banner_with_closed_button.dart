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
    this.padding = const EdgeInsets.symmetric(vertical: 8),
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
              top: 6,
              right: 6,
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
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, size: 14, color: Colors.white),
        ),
      ),
    );
  }
}
