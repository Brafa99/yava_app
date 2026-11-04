import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yava_delivery_driver/features/customer/application/customer_ride_flow_controller.dart';
import 'package:yava_delivery_driver/features/customer/customer_ride_bottom_sheets.dart';
import 'widgets/customer_live_map.dart';
import 'package:yava_delivery_driver/features/customer/widgets/customer_completed_summary_screen.dart';

class CustomerRideFlowPage extends ConsumerStatefulWidget {
  const CustomerRideFlowPage({super.key});

  @override
  ConsumerState<CustomerRideFlowPage> createState() =>
      _CustomerRideFlowPageState();
}

class _CustomerRideFlowPageState extends ConsumerState<CustomerRideFlowPage> {
  @override
  void initState() {
    super.initState();
    // Simulamos que el cliente ya tiene una ubicación por defecto o la obtiene del GPS
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(customerRideFlowProvider.notifier)
          .setOrigin(-16.1311, -62.0298, 'Plaza Principal');
    });
  }

  @override
  Widget build(BuildContext context) {
    final flowState = ref.watch(customerRideFlowProvider);

    // 1. Mostrar pantalla de Resumen si el viaje terminó (Mockup 8)
    if (flowState.rideState == CustomerRideState.completed) {
      return CustomerCompletedSummaryScreen(
        ride: flowState.currentRide!, 
      );
    }

    return Scaffold(
      backgroundColor: Colors.white, // Fondo claro general
      body: Stack(
        children: [
          // CAPA 1: Mapa en Vivo (Fondo Diurno)
          Positioned.fill(
            child: CustomerLiveMap(
              rideState: flowState.rideState,
              ride: flowState.currentRide,
              tempOriginLat: flowState.originLat,
              tempOriginLng: flowState.originLng,
              tempDestLat: flowState.destLat,
              tempDestLng: flowState.destLng,
            ),
          ),

          // CAPA 2: Botón de regreso / Menú (Arriba a la izquierda)
          Positioned(
            top: 50,
            left: 20,
            child: _buildBackButton(context, flowState.rideState),
          ),

          // CAPA 3: Banner Superior Dinámico (Mockups 4, 5, 6, 7)
          if (_shouldShowTopBanner(flowState.rideState))
            Positioned(
              top: 110,
              left: 20,
              right: 20,
              child: _buildTopBanner(flowState.rideState),
            ),

          // CAPA 4: Tarjetas Inferiores Dinámicas (Bottom Sheets)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildDynamicBottomSheet(flowState.rideState, ref),
          ),
        ],
      ),
    );
  }

  // --- LÓGICA DE UI ---

  Widget _buildBackButton(BuildContext context, CustomerRideState state) {
    // Si estamos esperando al conductor o en viaje, ocultar botón de atrás o cambiar su acción
    final bool canGoBack =
        state == CustomerRideState.selectingCategory ||
        state == CustomerRideState.confirmingTrip;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
        onPressed: () {
          if (canGoBack) {
            // Retroceder un paso en la UI
            final prev = state == CustomerRideState.confirmingTrip
                ? CustomerRideState.selectingCategory
                : CustomerRideState.selectingDestination;
            ref.read(customerRideFlowProvider.notifier).goBackTo(prev);
          } else {
            // Si está en el inicio o en otra fase, cerrar pantalla
            if (context.canPop()) context.pop();
          }
        },
      ),
    );
  }

  bool _shouldShowTopBanner(CustomerRideState state) {
    return state == CustomerRideState.searchingDriver ||
        state == CustomerRideState.driverAccepted ||
        state == CustomerRideState.driverArrived ||
        state == CustomerRideState.inProgress;
  }

  Widget _buildTopBanner(CustomerRideState state) {
    // Replica los títulos flotantes grandes de YAVÁ (Mockups 4, 5, 6, 7)
    String title = '';
    String subtitle = '';

    switch (state) {
      case CustomerRideState.searchingDriver:
        title = 'Buscando\ntu driver';
        subtitle = 'Estamos conectando con el\nconductor más cercano a ti.';
        break;
      case CustomerRideState.driverAccepted:
        title = '¡Conductor\nencontrado!';
        subtitle =
            'Tu viaje está en camino.\nRevisa los detalles de tu conductor.';
        break;
      case CustomerRideState.driverArrived:
        title = 'Tu conductor\nestá llegando';
        subtitle = 'En pocos minutos estará\nen tu ubicación.';
        break;
      case CustomerRideState.inProgress:
        title = 'Viaje\nen curso';
        subtitle = 'Estamos en camino\na tu destino.';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Aquí iría el logo YAVÁ Pasajero si quieres ponerlo
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF081528), // Azul oscuro YAVÁ
            fontSize: 36,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Carga la tarjeta inferior correspondiente al estado
  Widget _buildDynamicBottomSheet(CustomerRideState state, WidgetRef ref) {
    final controller = ref.read(customerRideFlowProvider.notifier);
    final flowState = ref.read(customerRideFlowProvider);

    switch (state) {
      case CustomerRideState.selectingDestination: // Mockup 1
        return CustomerSelectingDestinationSheet(controller: controller);

      case CustomerRideState.selectingCategory: // Mockup 2
        return CustomerSelectingCategorySheet(controller: controller);

      case CustomerRideState.confirmingTrip: // Mockup 3
        return CustomerConfirmingTripSheet(
          controller: controller,
          tempFare: flowState.offeredFare ?? 20.0,
        );

      case CustomerRideState.searchingDriver: // Mockup 4
        return const CustomerSearchingDriverSheet();

      case CustomerRideState.driverAccepted: // Mockup 5
      case CustomerRideState
          .driverArrived: // Mockup 6 (Usa casi la misma UI abajo)
        return CustomerDriverAcceptedSheet(ride: flowState.currentRide);

      case CustomerRideState.inProgress: // Mockup 7
        return CustomerInProgressSheet(ride: flowState.currentRide);

      default:
        return const SizedBox.shrink();
    }
  }
}
