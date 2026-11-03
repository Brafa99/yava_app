import 'package:flutter/material.dart';
import 'package:yava_delivery_driver/features/driver/application/driver_ride_flow_controller.dart';
import 'package:yava_delivery_driver/features/transport/models/ride_requests_model.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/yava_swipe_button.dart';

class DriverInProgressCard extends StatelessWidget {
  final RideRequestModel ride;
  final DriverRideFlowController controller;

  const DriverInProgressCard({
    super.key,
    required this.ride,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF0075FF).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Perfil del Cliente
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF0075FF).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF0075FF).withValues(alpha: 0.5),
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF0075FF),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.client?.name ?? 'Cliente YAVÁ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '4.9',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Botones de acción circular
              _CircularAction(icon: Icons.phone, onTap: () {}),
              const SizedBox(width: 10),
              _CircularAction(icon: Icons.chat_bubble_outline, onTap: () {}),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),

          // Información de Navegación
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Navegación',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.turn_right_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${ride.distanceKm ?? 8.4} km',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ride.destinationAddress ?? 'Destino',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Tiempo est.',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${ride.estimatedTimeMinutes ?? 17} min',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Botones inferiores (Reportar, SOS)
          Row(
            children: [
              Expanded(
                child: _OutlinedActionButton(
                  text: 'Reportar',
                  icon: Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OutlinedActionButton(
                  text: 'SOS',
                  icon: Icons.sos_rounded,
                  color: const Color(0xFF0075FF),
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Botón Swipe Final
          YavaSwipeButton(
            text: 'Finalizar viaje',
            isRed: true, // Esto lo vuelve rojo vibrante
            onCompleted: () => controller.completeRide(ride.id),
          ),
        ],
      ),
    );
  }
}

class _CircularAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircularAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF0075FF).withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF0075FF).withValues(alpha: 0.5),
          ),
        ),
        child: Icon(icon, color: const Color(0xFF0075FF), size: 20),
      ),
    );
  }
}

class _OutlinedActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _OutlinedActionButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
