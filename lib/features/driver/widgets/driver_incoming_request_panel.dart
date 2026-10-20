import 'package:flutter/material.dart';
import '../../../app/theme/yava_ui_tokens.dart';

class DriverIncomingRequestPanel extends StatelessWidget {
  final String clientName;
  final double clientRating;
  final int tripsCount;
  final String origin;
  final String originSub;
  final String destination;
  final String destinationSub;
  final double distanceKm;
  final int durationMin;
  final double estimatedFare;
  final String paymentMethod;
  final String notes;
  final int countdownSeconds;
  final VoidCallback onReject;
  final VoidCallback onAccept;

  const DriverIncomingRequestPanel({
    super.key,
    required this.clientName,
    required this.clientRating,
    required this.tripsCount,
    required this.origin,
    required this.originSub,
    required this.destination,
    required this.destinationSub,
    required this.distanceKm,
    required this.durationMin,
    required this.estimatedFare,
    required this.paymentMethod,
    required this.notes,
    required this.countdownSeconds,
    required this.onReject,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFA051224), Color(0xFD020814)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: const Color(0xFF0088FF).withValues(alpha: 0.7), width: 1.6),
        boxShadow: YavaUiTokens.neonGlow(const Color(0xFF0075FF), blur: 28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra de agarre superior
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),

          // Header: Título "NUEVO SERVICIO" + Círculo Cronómetro 25 seg
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0075FF).withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00A2FF)),
                ),
                child: const Icon(Icons.directions_car_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NUEVO SERVICIO',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                  Text(
                    'Solicitud de viaje - Movilidad',
                    style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const Spacer(),
              // Anillo de cuenta regresiva
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: CircularProgressIndicator(
                      value: countdownSeconds / 25.0,
                      strokeWidth: 3.5,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D2FF)),
                    ),
                  ),
                  Text(
                    '$countdownSeconds',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Tarjeta del Cliente (María Fernanda)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF09182B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
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
                        clientName,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                          Text(' $clientRating ($tripsCount viajes)', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF004488).withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Usuario verificado', style: TextStyle(color: Color(0xFF66B2FF), fontSize: 9.5, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white54, size: 24),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Ruta Origen / Destino
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
                      _routePoint(const Color(0xFF00D2FF), 'Recoger', origin, originSub),
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: SizedBox(height: 16, child: VerticalDivider(color: Colors.white24, thickness: 2)),
                      ),
                      _routePoint(const Color(0xFFFF2E3A), 'Destino', destination, destinationSub),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$distanceKm km', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
                    const Text('3 min', style: TextStyle(color: Color(0xFF00D2FF), fontSize: 11, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Text('$durationMin min', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
                    const Text('Tiempo est.', style: TextStyle(color: Colors.white60, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3 Cajas Inferiores (Distancia total, Tiempo estimado, Tarifa estimada en Bs)
          Row(
            children: [
              _metricBox('Distancia total', '$distanceKm km'),
              const SizedBox(width: 8),
              _metricBox('Tiempo estimado', '$durationMin min'),
              const SizedBox(width: 8),
              _metricBox('Tarifa estimada', 'Bs ${estimatedFare.toStringAsFixed(2)}', isHighlight: true),
            ],
          ),
          const SizedBox(height: 14),

          // Método de pago y observaciones
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF071220),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.payment_rounded, color: Color(0xFF00D2FF), size: 18),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Método de pago', style: TextStyle(color: Colors.white60, fontSize: 9.5)),
                          Text(paymentMethod, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF071220),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Observaciones', style: TextStyle(color: Colors.white60, fontSize: 9.5)),
                            Text(notes.isEmpty ? 'Sin observaciones' : notes, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Botones de Acción (Rechazar / Aceptar)
          Row(
            children: [
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFFFF2E3A), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    backgroundColor: const Color(0xFF380004).withValues(alpha: 0.6),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.close_rounded, color: Color(0xFFFF2E3A), size: 18),
                      SizedBox(width: 6),
                      Text('Rechazar', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0075FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 6,
                    shadowColor: const Color(0xFF0075FF).withValues(alpha: 0.8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text('Aceptar', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _routePoint(Color dotColor, String title, String mainText, String subText) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 3),
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: dotColor, blurRadius: 6)]),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white60, fontSize: 10)),
              Text(mainText, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
              Text(subText, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricBox(String label, String value, {bool isHighlight = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: isHighlight ? const Color(0xFF003882).withValues(alpha: 0.6) : const Color(0xFF071220),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isHighlight ? const Color(0xFF00D2FF) : Colors.white12),
        ),
        child: Column(
          children: [
            Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 9.5)),
            const SizedBox(height: 4),
            Text(value, textAlign: TextAlign.center, style: TextStyle(color: isHighlight ? const Color(0xFF00D2FF) : Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}