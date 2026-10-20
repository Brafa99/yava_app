import 'package:flutter/material.dart';

class DriverActiveTripPanel extends StatefulWidget {
  final String status; // 'ACEPTADO', 'EN_ORIGEN', 'EN_CURSO'
  final String clientName;
  final String origin;
  final String destination;
  final String distanceText;
  final String timeText;
  final VoidCallback onSlideComplete;
  final VoidCallback onCancel;

  const DriverActiveTripPanel({
    super.key,
    required this.status,
    required this.clientName,
    required this.origin,
    required this.destination,
    required this.distanceText,
    required this.timeText,
    required this.onSlideComplete,
    required this.onCancel,
  });

  @override
  State<DriverActiveTripPanel> createState() => _DriverActiveTripPanelState();
}

class _DriverActiveTripPanelState extends State<DriverActiveTripPanel> {
  double _dragPosition = 0.0;
  bool _completed = false;

  String get _sliderText {
    switch (widget.status) {
      case 'ACEPTADO':
        return 'Desliza al llegar';
      case 'EN_ORIGEN':
        return 'Desliza para iniciar viaje';
      case 'EN_CURSO':
        return 'Finalizar servicio';
      default:
        return 'Deslizar';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFA051224), Color(0xFD020814)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: const Color(0xFF0088FF).withValues(alpha: 0.6), width: 1.5),
        boxShadow: const [BoxShadow(color: Color(0x660075FF), blurRadius: 24, offset: Offset(0, -6))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),

          // Perfil del Cliente y Botones de Contacto (Llamada, Mensaje, Más)
          Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundImage: AssetImage('assets/images/banner_conductor_promo.png'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.clientName,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                        Text(' 4.9 (128 viajes)', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              _actionBtn(Icons.call_rounded, const Color(0xFF00E676), () {}),
              const SizedBox(width: 8),
              _actionBtn(Icons.chat_bubble_rounded, const Color(0xFF0075FF), () {}),
              const SizedBox(width: 8),
              _actionBtn(Icons.more_horiz_rounded, Colors.white24, () {}),
            ],
          ),
          const SizedBox(height: 16),

          // Origen / Destino y Métrica en vivo
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF071220),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _routeText(const Color(0xFF00D2FF), 'Recoger', widget.origin),
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: SizedBox(height: 12, child: VerticalDivider(color: Colors.white24, thickness: 2)),
                      ),
                      _routeText(const Color(0xFFFF2E3A), 'Destino', widget.destination),
                    ],
                  ),
                ),
                Container(width: 1, height: 50, color: Colors.white12, margin: const EdgeInsets.symmetric(horizontal: 12)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(widget.distanceText, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
                    const Text('para recoger', style: TextStyle(color: Colors.white60, fontSize: 9.5)),
                    const SizedBox(height: 8),
                    Text(widget.timeText, style: const TextStyle(color: Color(0xFF00D2FF), fontSize: 15, fontWeight: FontWeight.w900)),
                    const Text('est. llegada', style: TextStyle(color: Colors.white60, fontSize: 9.5)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- WIDGET SLIDER "SLIDE TO ACT" (DESLIZAR AL LLEGAR / INICIAR / FINALIZAR) ---
          LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              const buttonWidth = 60.0;
              final maxSlide = maxWidth - buttonWidth - 8;

              return Container(
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF020D1A),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFF0075FF), width: 1.5),
                  boxShadow: const [BoxShadow(color: Color(0x550075FF), blurRadius: 14)],
                ),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Center(
                      child: Text(
                        _sliderText,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: Duration(milliseconds: _completed ? 0 : 200),
                      left: 4 + _dragPosition,
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          if (_completed) return;
                          setState(() {
                            _dragPosition += details.delta.dx;
                            if (_dragPosition < 0) _dragPosition = 0;
                            if (_dragPosition > maxSlide) _dragPosition = maxSlide;
                          });
                        },
                        onHorizontalDragEnd: (details) {
                          if (_completed) return;
                          if (_dragPosition >= maxSlide * 0.78) {
                            setState(() {
                              _dragPosition = maxSlide;
                              _completed = true;
                            });
                            widget.onSlideComplete();
                          } else {
                            setState(() => _dragPosition = 0.0);
                          }
                        },
                        child: Container(
                          width: buttonWidth,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00D2FF), Color(0xFF0075FF)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: const [BoxShadow(color: Color(0xFF00D2FF), blurRadius: 10)],
                          ),
                          child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 26),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // Botón inferior Cancelar Servicio
          TextButton.icon(
            onPressed: widget.onCancel,
            icon: const Icon(Icons.close_rounded, color: Color(0xFFFF2E3A), size: 16),
            label: const Text('Cancelar servicio', style: TextStyle(color: Color(0xFFFF2E3A), fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ),
    );
  }
  

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
      child: IconButton(onPressed: onTap, icon: Icon(icon, color: color, size: 20), padding: EdgeInsets.zero),
    );
  }

  Widget _routeText(Color color, String label, String text) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: Colors.white60, fontSize: 11)),
        Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800))),
      ],
    );
  }
}