import 'package:flutter/material.dart';

class YavaSwipeButton extends StatefulWidget {
  final String text;
  final bool isRed;
  final VoidCallback onCompleted;
  final bool isLoading;

  const YavaSwipeButton({
    super.key,
    required this.text,
    required this.onCompleted,
    this.isRed = false,
    this.isLoading = false,
  });

  @override
  State<YavaSwipeButton> createState() => _YavaSwipeButtonState();
}

class _YavaSwipeButtonState extends State<YavaSwipeButton>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  bool _isCompleted = false;
  late AnimationController _resetController;
  late Animation<double> _resetAnimation;

  final double _buttonHeight = 58.0;
  final double _thumbSize = 46.0;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _resetController.addListener(() {
      setState(() {
        _dragPosition = _resetAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details, double maxWidth) {
    if (_isCompleted || widget.isLoading) return;

    setState(() {
      _dragPosition += details.delta.dx;
      // Limitar el arrastre entre 0 y el ancho máximo menos el tamaño del botón
      if (_dragPosition < 0) _dragPosition = 0;
      if (_dragPosition > maxWidth - _thumbSize - 12) {
        _dragPosition = maxWidth - _thumbSize - 12;
      }
    });
  }

  void _onDragEnd(DragEndDetails details, double maxWidth) {
    if (_isCompleted || widget.isLoading) return;

    final maxDrag = maxWidth - _thumbSize - 12;
    // Si arrastró más del 80% del camino, completar la acción
    if (_dragPosition > maxDrag * 0.8) {
      setState(() {
        _dragPosition = maxDrag;
        _isCompleted = true;
      });
      widget.onCompleted();
    } else {
      // Si no llegó al final, animar de regreso a 0
      _resetAnimation = Tween<double>(begin: _dragPosition, end: 0.0).animate(
        CurvedAnimation(parent: _resetController, curve: Curves.easeOutBack),
      );
      _resetController.forward(from: 0.0);
    }
  }

  // Permite reiniciar el botón desde el controlador padre si hay un error en la API
  void reset() {
    setState(() {
      _isCompleted = false;
      _dragPosition = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definición de colores según el estado (Azul o Rojo)
    final Color mainColor = widget.isRed
        ? const Color(0xFFE50914)
        : const Color(0xFF0075FF);
    final Color glowColor = widget.isRed
        ? const Color(0x66E50914)
        : const Color(0x660075FF);
    final Color darkBg = const Color(0xFF081528);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: _buttonHeight,
          decoration: BoxDecoration(
            color: darkBg,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: mainColor.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor,
                blurRadius: 16,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Texto central (se desvanece al deslizar)
              Center(
                child: Opacity(
                  opacity:
                      (1 -
                              (_dragPosition /
                                  (constraints.maxWidth - _thumbSize)))
                          .clamp(0.0, 1.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.isRed)
                        const Icon(
                          Icons.flag_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      if (widget.isRed) const SizedBox(width: 8),
                      Text(
                        widget.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!widget.isRed)
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white54,
                          size: 14,
                        ),
                      if (!widget.isRed)
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white30,
                          size: 14,
                        ),
                    ],
                  ),
                ),
              ),

              // Rastro de color que sigue al botón
              Container(
                height: _buttonHeight,
                width: _dragPosition + _thumbSize + 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      mainColor.withValues(alpha: 0.1),
                      mainColor.withValues(alpha: 0.4),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),

              // Botón arrastrable (Thumb)
              Positioned(
                left: 6 + _dragPosition,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) =>
                      _onDragUpdate(details, constraints.maxWidth),
                  onHorizontalDragEnd: (details) =>
                      _onDragEnd(details, constraints.maxWidth),
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: BoxDecoration(
                      color: mainColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: mainColor.withValues(alpha: 0.8),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: widget.isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
