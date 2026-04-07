import 'package:flutter/material.dart';

class Trailing {
  final Widget child;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;

  const Trailing({
    required this.child,
    this.left,
    this.top,
    this.right,
    this.bottom,
  });
}

class BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final void Function(LongPressStartDetails) onLongPressStart;
  final Trailing? trailing;
  const BouncingButton({
    super.key,
    required this.child,
    this.trailing,
    this.onTap,
    required this.onLongPressStart,
  });

  @override
  State<BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. EL CUERPO PRINCIPAL
        Listener(
          onPointerDown: (_) => setState(() => _isPressed = true),
          onPointerUp: (_) => setState(() => _isPressed = false),
          onPointerCancel: (_) => setState(() => _isPressed = false),
          child: GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onTap: widget.onTap,
            onLongPressStart: (details) {
              setState(() => _isPressed = false);
              widget.onLongPressStart(details);
            },
            child: Stack(
              children: [
                widget.child,
                // CAPA DE RETROALIMENTACIÓN
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      // Importante: El color debe estar ARRIBA del child
                      color: _isPressed
                          ? Colors.black.withAlpha(13)
                          : Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. EL BOTÓN INDEPENDIENTE (Trailing)
        if (widget.trailing != null)
          Positioned(
            top: widget.trailing!.top,
            bottom: widget.trailing!.bottom,
            left: widget.trailing!.left,
            right: widget.trailing!.right,
            child: GestureDetector(
              // Esto atrapa el toque y evita que llegue al GestureDetector padre
              onTap: () {},
              child: Listener(
                // Esto detiene la propagación del evento de puntero al Listener padre
                onPointerDown: (event) {},
                behavior: HitTestBehavior.opaque,
                child: widget.trailing!.child, // <-- CAMBIO AQUÍ
              ),
            ),
          ),
      ],
    );
  }
}
