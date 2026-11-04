import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yava_delivery_driver/features/transport/models/ride_requests_model.dart';
// Descomenta la siguiente línea si tienes un controlador para calificar:
// import 'package:yava_delivery_driver/features/customer/application/customer_ride_flow_controller.dart';

class CustomerCompletedSummaryScreen extends ConsumerStatefulWidget {
  final RideRequestModel ride;

  const CustomerCompletedSummaryScreen({
    super.key,
    required this.ride,
  });

  @override
  ConsumerState<CustomerCompletedSummaryScreen> createState() => _CustomerCompletedSummaryScreenState();
}

class _CustomerCompletedSummaryScreenState extends ConsumerState<CustomerCompletedSummaryScreen> {
  int _rating = 5;

  @override
  Widget build(BuildContext context) {
    // Extrayendo los datos reales del viaje
    final driverName = widget.ride.driver?.name ?? 'Conductor YAVÁ';
    final price = widget.ride.offeredFare;

    return Scaffold(
      backgroundColor: const Color(0xFF081528), // Fondo Dark
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // 1. Icono de Éxito Animado / Resaltado
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.15),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(0.1),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 54),
              ),
              const SizedBox(height: 28),
              
              // 2. Títulos
              const Text(
                '¡Llegaste a tu destino!',
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              const Text(
                'Esperamos que hayas tenido un excelente viaje. Aquí tienes el resumen.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 15, height: 1.4),
              ),
              
              const SizedBox(height: 40),
              
              // 3. Tarjeta de Recibo (Glassmorphism)
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1628),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF0075FF).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pago Total (Efectivo)', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        Text(
                          'Bs ${price.toStringAsFixed(0)}', 
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(color: Colors.white12, height: 1),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0075FF).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.directions_car_rounded, color: Color(0xFF0075FF)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(driverName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              const Text('Conductor Verificado', style: TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 4. Sistema de Calificación Interactiva
              const Text('¿Cómo calificarías el servicio?', style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    iconSize: 44,
                    icon: Icon(
                      index < _rating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: index < _rating ? Colors.amber : Colors.white24,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              
              const Spacer(),
              
              // 5. Botón de Finalización
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0075FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // Opcional: Aquí podrías disparar el endpoint para guardar la calificación
                    // ref.read(customerRideFlowProvider.notifier).rateDriver(widget.ride.id, _rating);
                    
                    // Retorna al Home para reiniciar el ciclo de la Demo
                    context.go('/customer/home');
                  },
                  child: const Text('Enviar y Volver al Inicio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
