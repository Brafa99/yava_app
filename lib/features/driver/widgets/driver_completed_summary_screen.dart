import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yava_delivery_driver/features/driver/application/driver_ride_flow_controller.dart';
import 'package:yava_delivery_driver/features/transport/models/ride_requests_model.dart';


class DriverCompletedSummaryScreen extends StatefulWidget {
  final RideRequestModel ride;
  final DriverRideFlowController controller;

  const DriverCompletedSummaryScreen({
    super.key,
    required this.ride,
    required this.controller,
  });

  @override
  State<DriverCompletedSummaryScreen> createState() =>
      _DriverCompletedSummaryScreenState();
}

class _DriverCompletedSummaryScreenState
    extends State<DriverCompletedSummaryScreen> {
  int _selectedRating = 5;

  @override
  Widget build(BuildContext context) {
    // Cálculos simulados para la vista (En producción esto debería venir del backend)
    final double finalFare = widget.ride.agreedFare ?? widget.ride.offeredFare;
    final double commission = finalFare * 0.20; // 20% de comisión YAVÁ
    final double earnings = finalFare - commission;

    return Scaffold(
      backgroundColor: const Color(0xFF081528),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Cabecera (Check Verde)
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF87).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00FF87), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FF87).withValues(alpha: 0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF00FF87),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '¡Servicio completado!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Gracias por ser parte de YAVÁ',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // 2. Información del Pasajero
              _buildGlassCard(
                child: Row(
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
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.ride.client?.name ?? 'Cliente YAVÁ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '4.9 (128 viajes)',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Resumen del Viaje (Origen - Destino)
              _buildGlassCard(
                child: Column(
                  children: [
                    _buildRouteInfo(
                      Icons.my_location_rounded,
                      const Color(0xFF0075FF),
                      'Origen',
                      widget.ride.originAddress ?? 'No especificado',
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 14, top: 8, bottom: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.more_vert_rounded,
                          color: Colors.white24,
                          size: 20,
                        ),
                      ),
                    ),
                    _buildRouteInfo(
                      Icons.location_on_rounded,
                      Colors.redAccent,
                      'Destino',
                      widget.ride.destinationAddress ?? 'No especificado',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Estadísticas del Viaje
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      Icons.add_road_rounded,
                      '${widget.ride.distanceKm ?? 8.7} km',
                      'Distancia',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      Icons.access_time_rounded,
                      '${widget.ride.estimatedTimeMinutes ?? 21} min',
                      'Tiempo',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 5. Finanzas
              Row(
                children: [
                  Expanded(
                    child: _buildGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tarifa del servicio',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Bs ${finalFare.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Método de pago',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.money_rounded,
                                color: Color(0xFF00FF87),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.ride.paymentMethod.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Desglose
              _buildGlassCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSubFinance(
                      'Tu ganancia',
                      'Bs ${earnings.toStringAsFixed(2)}',
                      const Color(0xFF00FF87),
                    ),
                    _buildSubFinance(
                      'Comisión',
                      'Bs ${commission.toStringAsFixed(2)}',
                      Colors.white54,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 6. Calificación del Pasajero
              _buildGlassCard(
                child: Column(
                  children: [
                    const Text(
                      'Califica a tu pasajero',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _selectedRating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 36,
                          ),
                          onPressed: () {
                            setState(() => _selectedRating = index + 1);
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 7. Botones Inferiores
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        // Opcional: enviar calificación antes de salir
                        widget.controller.ratePassenger(
                          widget.ride.id,
                          _selectedRating,
                          "Buen pasajero",
                        );
                        context.go('/driver/requests');
                      },
                      icon: const Icon(Icons.home_rounded, size: 20),
                      label: const Text(
                        'Inicio',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0075FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: const Color(
                          0xFF0075FF,
                        ).withValues(alpha: 0.5),
                        elevation: 10,
                      ),
                      onPressed: () async {
                        await widget.controller.ratePassenger(
                          widget.ride.id,
                          _selectedRating,
                          "Buen pasajero",
                        );
                        if (context.mounted) {
                          context.go('/driver/requests'); // Vuelve al radar
                        }
                      },
                      child: const Text(
                        'Volver a estar disponible',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Utilidades UI
  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF0075FF).withValues(alpha: 0.2),
        ),
      ),
      child: child,
    );
  }

  Widget _buildRouteInfo(
    IconData icon,
    Color iconColor,
    String label,
    String address,
  ) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              Text(
                address,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return _buildGlassCard(
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubFinance(String label, String amount, Color amountColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            color: amountColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
