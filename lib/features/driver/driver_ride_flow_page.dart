import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yava_delivery_driver/features/driver/application/driver_ride_flow_controller.dart';
import 'package:yava_delivery_driver/features/driver/widgets/driver_completed_summary_screen.dart';
import 'package:yava_delivery_driver/features/transport/models/ride_requests_model.dart';
import 'widgets/driver_live_map.dart';
import '../../../shared/widgets/yava_swipe_button.dart';

class DriverRideFlowPage extends ConsumerStatefulWidget {
  final int rideId;
  final RideRequestModel initialRide;

  const DriverRideFlowPage({
    super.key,
    required this.rideId,
    required this.initialRide,
  });

  @override
  ConsumerState<DriverRideFlowPage> createState() => _DriverRideFlowPageState();
}

class _DriverRideFlowPageState extends ConsumerState<DriverRideFlowPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(driverRideFlowProvider.notifier)
          .loadRideDetails(widget.rideId, widget.initialRide);
    });
  }

  @override
  Widget build(BuildContext context) {
    final flowState = ref.watch(driverRideFlowProvider);

    if (flowState.isLoading && flowState.currentRide == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF081528),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0075FF)),
        ),
      );
    }

    final currentRide = flowState.currentRide ?? widget.initialRide;

    if (flowState.rideState == DriverRideState.completed) {
      return _buildCompletedSummaryScreen(context);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF081528),
      body: Stack(
        children: [
          // CAPA 1: El Mapa (Cyber Dark)
          Positioned.fill(
            child: DriverLiveMap(
              rideState: flowState.rideState,
              ride: currentRide,
            ),
          ),

          // CAPA 2: Top Banner dinámico (Estados)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: _buildTopBanner(flowState.rideState),
          ),

          // CAPA 3: Loading superpuesto si está procesando petición a API
          if (flowState.isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0075FF)),
                ),
              ),
            ),

          // CAPA 4: Tarjeta interactiva y Botón Swipe (Bottom Sheet)
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: _buildBottomActionCard(
              flowState.rideState,
              currentRide,
              ref,
            ),
          ),

          // Botones de control del mapa (GPS)
          Positioned(right: 20, bottom: 340, child: _buildMapControls()),
        ],
      ),
    );
  }

  // --- WIDGETS MODULARES DE LA UI ---

  Widget _buildTopBanner(DriverRideState state) {
    switch (state) {
      case DriverRideState.newRequest:
        return _bannerShell('NUEVO SERVICIO', 'Solicitud de viaje - Movilidad');
      case DriverRideState.waitingClient:
        return _bannerShell(
          'OFERTA ENVIADA',
          'Esperando respuesta del pasajero...',
          Icons.access_time_rounded,
        );
      case DriverRideState.accepted:
        return _bannerShell(
          '¡OFERTA ACEPTADA!',
          'Dirígete al punto de recogida',
          Icons.check_circle,
        );
      case DriverRideState.arrived:
        return _bannerShell(
          '¡HAS LLEGADO!',
          'Espera al pasajero en el punto indicado.',
          Icons.directions_walk,
        );
      case DriverRideState.inProgress:
        return _bannerShell(
          '¡PASAJERO A BORDO!',
          'Sigue la ruta hacia el destino.',
          Icons.airline_seat_recline_normal,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomActionCard(
    DriverRideState state,
    RideRequestModel ride,
    WidgetRef ref,
  ) {
    final controller = ref.read(driverRideFlowProvider.notifier);

    // Extracción de datos reales
    final clientName = ride.client?.name ?? 'Nuevo Pasajero';
    final fare = ride.offeredFare;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628).withOpacity(0.85),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF0075FF).withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Info del pasajero
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF0075FF).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Color(0xFF0075FF)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      '★ 4.9 • Pago en Efectivo',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Botón rápido para cancelar si surge emergencia
              if (state != DriverRideState.newRequest &&
                  state != DriverRideState.waitingClient)
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => _showCancelDialog(context, controller),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // LÓGICA DE BOTONES BASADA EN LA MÁQUINA DE ESTADOS Y LA API
          if (state == DriverRideState.newRequest)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => context.pop(), // Sale de la pantalla
                    child: const Text(
                      'Rechazar',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0075FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    // Conecta con el POST de la oferta
                    onPressed: () => controller.sendOffer(fare),
                    child: Text(
                      'Ofertar Bs ${fare.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

          if (state == DriverRideState.waitingClient)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(color: Color(0xFF0075FF)),
              ),
            ),

          if (state == DriverRideState.accepted)
            YavaSwipeButton(
              text: 'Desliza al llegar',
              // Conecta con el PATCH status = arrived
              onCompleted: () => controller.updateRideStatus(
                'arrived',
                DriverRideState.arrived,
              ),
            ),

          if (state == DriverRideState.arrived)
            YavaSwipeButton(
              text: 'Iniciar viaje',
              // Conecta con el PATCH status = in_progress
              onCompleted: () => controller.updateRideStatus(
                'in_progress',
                DriverRideState.inProgress,
              ),
            ),

          if (state == DriverRideState.inProgress)
            YavaSwipeButton(
              text: 'Finalizar viaje',
              isRed: true,
              // Conecta con el PATCH status = completed
              onCompleted: () => controller.updateRideStatus(
                'completed',
                DriverRideState.completed,
              ),
            ),
        ],
      ),
    );
  }

  void _showCancelDialog(
    BuildContext context,
    DriverRideFlowController controller,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A1628),
        title: const Text(
          'Cancelar Viaje',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Estás seguro de cancelar este viaje?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              'Volver',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              context.pop(); // Cierra el diálogo
              final success = await controller.cancelRide();
              if (success && mounted)
                context.go('/driver/home'); // Regresa al inicio
            },
            child: const Text(
              'Sí, Cancelar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedSummaryScreen(BuildContext context) {
    final flowState = ref.read(driverRideFlowProvider);
    final controller = ref.read(driverRideFlowProvider.notifier);

    if (flowState.currentRide == null) return const SizedBox.shrink();

    return DriverCompletedSummaryScreen(
      ride: flowState.currentRide!,
      controller: controller,
    );
  }

  Widget _bannerShell(String title, String subtitle, [IconData? icon]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0075FF).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0075FF).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          if (icon != null)
            Icon(icon, color: const Color(0xFF0075FF), size: 28),
          if (icon != null) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControls() {
    return Column(
      children: [
        FloatingActionButton.small(
          heroTag: 'nav_btn',
          backgroundColor: const Color(0xFF0A1628),
          onPressed: () {},
          child: const Icon(Icons.navigation_rounded, color: Color(0xFF0075FF)),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'layer_btn',
          backgroundColor: const Color(0xFF0A1628),
          onPressed: () {},
          child: const Icon(Icons.layers_rounded, color: Colors.white70),
        ),
      ],
    );
  }
}
