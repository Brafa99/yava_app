import 'package:flutter/material.dart';
import '../../../app/theme/yava_ui_tokens.dart';

class DriverCompletedModal extends StatefulWidget {
  final double totalFare;
  final double driverNet;
  final double commission;
  final Function(int score, String comment) onSubmitRating;
  final VoidCallback onBackHome;
  final VoidCallback onGoAvailable;

  const DriverCompletedModal({
    super.key,
    required this.totalFare,
    required this.driverNet,
    required this.commission,
    required this.onSubmitRating,
    required this.onBackHome,
    required this.onGoAvailable,
  });

  @override
  State<DriverCompletedModal> createState() => _DriverCompletedModalState();
}

class _DriverCompletedModalState extends State<DriverCompletedModal> {
  int _rating = 5;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFA051224), Color(0xFD020814)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.6), width: 1.5),
        boxShadow: YavaUiTokens.neonGlow(const Color(0xFF00E676), blur: 28),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge Éxito con Anillo Verde Neón
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00E676), width: 2),
                boxShadow: YavaUiTokens.neonGlow(const Color(0xFF00E676), blur: 16),
              ),
              child: const Icon(Icons.check_rounded, color: Color(0xFF00E676), size: 36),
            ),
            const SizedBox(height: 12),
            const Text(
              '¡Servicio completado!',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 3),
            const Text(
              'Gracias por ser parte de YAVÁ',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 20),

            // Tarifa y Ganancias Netas
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF071220),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tarifa del servicio', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      Text('Bs ${widget.totalFare.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tu ganancia (80%)', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.w700)),
                      Text('Bs ${widget.driverNet.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF00E676), fontSize: 16, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Comisión YAVÁ (20%)', style: TextStyle(color: Colors.white60, fontSize: 11)),
                      Text('Bs ${widget.commission.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Módulo de Calificación al Pasajero (5 Estrellas)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF071220),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Califica a tu pasajero',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starVal = index + 1;
                      return IconButton(
                        onPressed: () => setState(() => _rating = starVal),
                        icon: Icon(
                          starVal <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 34,
                        ),
                      );
                    }),
                  ),
                  TextField(
                    controller: _commentController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Muy buen pasajero, respetuoso...',
                      hintStyle: const TextStyle(color: Colors.white30),
                      filled: true,
                      fillColor: const Color(0xFF09182B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Botones Finales
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onBackHome,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Volver al inicio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSubmitRating(_rating, _commentController.text.trim());
                      widget.onGoAvailable();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0075FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    child: const Text('Disponible', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}