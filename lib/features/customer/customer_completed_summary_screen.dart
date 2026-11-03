import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yava_delivery_driver/features/customer/application/customer_ride_flow_controller.dart';
import 'package:yava_delivery_driver/features/transport/models/ride_requests_model.dart';


class CustomerCompletedSummaryScreen extends StatefulWidget {
  final RideRequestModel ride;
  final CustomerRideFlowController controller;

  const CustomerCompletedSummaryScreen({
    super.key,
    required this.ride,
    required this.controller,
  });

  @override
  State<CustomerCompletedSummaryScreen> createState() => _CustomerCompletedSummaryScreenState();
}

class _CustomerCompletedSummaryScreenState extends State<CustomerCompletedSummaryScreen> {
  int _selectedRating = 5;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final double finalFare = widget.ride.agreedFare ?? widget.ride.offeredFare;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Estilo minimalista limpio (Blanco/Gris suave)
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Icono de Éxito Minimalista
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                '¡Viaje completado!',
                style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              const Text(
                'Gracias por viajar con YAVÁ. Esperamos verte pronto.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // 2. Tarjeta de Datos del Conductor
              _buildMinimalCard(
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: Colors.black87, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.ride.driver?.name ?? 'Luis Fernández',
                            style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '★ 4.9 (248 viajes) • Toyota Rush',
                            style: TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Sistema de Calificación con Estrellas
              _buildMinimalCard(
                child: Column(
                  children: [
                    const Text('¿Cómo fue tu viaje?', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Tu opinión nos ayuda a mejorar.', style: TextStyle(color: Colors.black45, fontSize: 12)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () => setState(() => _selectedRating = index + 1),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Detalle de Tarifa y Pago
              _buildMinimalCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total del viaje', style: TextStyle(color: Colors.black54, fontSize: 14)),
                        Text('Bs ${finalFare.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.payment_rounded, color: Colors.black87, size: 20),
                        const SizedBox(width: 10),
                        const Text('Método de pago', style: TextStyle(color: Colors.black54, fontSize: 14)),
                        const Spacer(),
                        Text(widget.ride.paymentMethod.toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 5. Botones de Acción (Estilo Yango/Uber)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Botón principal negro minimalista
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: _isSubmitting ? null : () async {
                    setState(() => _isSubmitting = true);
                    await widget.controller.rateDriver(_selectedRating, "Excelente viaje");
                    if (context.mounted) {
                      context.go('/customer/home'); // Regresa al inicio del pasajero
                    }
                  },
                  child: _isSubmitting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Volver al inicio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}