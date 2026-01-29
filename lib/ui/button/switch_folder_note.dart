import 'package:flutter/material.dart';

class SwitchFolderNote extends StatelessWidget {
  final bool isFolder;
  final VoidCallback? onTap;
  final double size; // Ahora es requerido para facilitar los cálculos, o dale un default

  const SwitchFolderNote({
    super.key,
    required this.isFolder,
    this.onTap,
    this.size = 40.0, // Tamaño base por defecto
  });

  @override
  Widget build(BuildContext context) {
    // --- Cálculos Proporcionales ---
    final double activeSize = size;
    final double inactiveSize = size * 0.7; // El de atrás es 30% más pequeño
    final double indicatorSize = size * 0.35; // El icono de swap es proporcional
    
    // El contenedor debe ser más ancho que el icono para permitir el desplazamiento lateral
    final double containerWidth = size * 1.5; 
    final double containerHeight = size * 1.2;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // Mejora el área de toque
      child: SizedBox(
        width: containerWidth,
        height: containerHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Icono de ATRÁS (Inactivo)
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              // Si es folder, la nota está atrás a la izquierda. Si no, el folder está atrás a la derecha.
              alignment: isFolder
                  ? const Alignment(-0.7, -0.5)
                  : const Alignment(0.7, -0.5),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: 0.4,
                child: Icon(
                  isFolder ? Icons.sticky_note_2 : Icons.folder,
                  size: inactiveSize,
                  color: Color(0xFF757575),
                ),
              ),
            ),

            // 2. Icono de ENFRENTE (Activo)
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              alignment: isFolder
                  ? const Alignment(0.3, 0.4)
                  : const Alignment(-0.3, 0.4),
              child: Icon(
                isFolder ? Icons.folder : Icons.sticky_note_2,
                size: activeSize,
                color: isFolder ?  Colors.deepPurple[400] : Colors.indigo[400],
              ),
            ),

            // 3. Indicador de intercambio (Sync)
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                padding: EdgeInsets.all(size * 0.05), // Padding proporcional
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Icon(
                  Icons.sync,
                  size: indicatorSize,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}