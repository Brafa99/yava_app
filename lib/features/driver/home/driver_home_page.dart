import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yava_delivery_driver/core/services/socket_services.dart';
import 'package:yava_delivery_driver/features/transport/models/ride_requests_model.dart';
import '../../../app/theme/yava_ui_tokens.dart';
import '../../../core/network/api_endpoints.dart';
import '../../auth/application/auth_controller.dart';
import '../../transport/data/datasources/transport_remote_datasource.dart';
import 'driver_home_sections.dart';

// Provider del Datasource de Transporte
final transportRemoteDataSourceProvider = Provider<TransportRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TransportRemoteDataSourceImpl(apiClient: apiClient);
});

// Provider para consultar solicitudes disponibles (respaldo HTTP + Socket.io)
final availableRidesProvider = FutureProvider.autoDispose<List<RideRequestModel>>((ref) async {
  final ds = ref.watch(transportRemoteDataSourceProvider);
  return ds.getDriverAvailableRequests();
});

class DriverHomePage extends ConsumerStatefulWidget {
  const DriverHomePage({super.key});

  static const routeName = 'driver-home';
  static const routePath = '/driver/home';

  @override
  ConsumerState<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends ConsumerState<DriverHomePage> {
  bool _isOnline = false;
  bool _loadingStatus = false;
  Timer? _fallbackPollingTimer;

  @override
  void initState() {
    super.initState();
    _initSocketConnection();

    // Polling de respaldo (por si la red del socket se reconecta) cada 15 segundos
    _fallbackPollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (_isOnline && mounted) {
        ref.invalidate(availableRidesProvider);
      }
    });
  }

  void _initSocketConnection() {
    final user = ref.read(authControllerProvider).user;
    if (user != null) {
      try {
        // Inicializa Socket.io con el ID del driver y rol 'driver'
        SocketService().initSocket(user.id.toString(), 'driver');

        // Escucha en tiempo real los canales especificados por tu colega
        SocketService().listenDriverEvents(
          onNewRidePending: (data) {
            debugPrint('SOCKET.IO [taxi:viaje-pendiente] recibido: $data');
            if (_isOnline && mounted) {
              // Refresca instantáneamente la lista de solicitudes disponibles
              ref.invalidate(availableRidesProvider);
            }
          },
          onRideAccepted: (data) {
            debugPrint('SOCKET.IO [taxi:viaje-aceptar] recibido: $data');
            if (mounted) {
              // Si el cliente aceptó la oferta, pasa directo a la pantalla de tracking del viaje
              final rideId = data['ride_id'] ?? data['id'] ?? '1';
              context.push('/driver/tracking?rideId=$rideId');
            }
          },
        );
      } catch (e) {
        debugPrint('Error inicializando Socket.io en DriverHome: $e');
      }
    }
  }

  @override
  void dispose() {
    _fallbackPollingTimer?.cancel();
    try {
      SocketService().disconnect();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _toggleAvailability(bool value) async {
    setState(() => _loadingStatus = true);
    try {
      final user = ref.read(authControllerProvider).user;
      if (user != null) {
        final apiClient = ref.read(apiClientProvider);
        // Actualiza el estado en Laravel -> tabla users (is_online)
        await apiClient.put(
          ApiEndpoints.driverUpdate(user.id),
          body: {'is_online': value ? 1 : 0},
          requiresAuth: true,
        );
      }
      setState(() => _isOnline = value);

      if (value && mounted) {
        // Forzamos una consulta inmediata al activarse
        ref.invalidate(availableRidesProvider);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cambiar estado: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _loadingStatus = false);
    }
  }

  Future<void> _acceptRide(int rideId, double fare) async {
    try {
      final ds = ref.read(transportRemoteDataSourceProvider);
      // Envía la contraoferta al endpoint real POST /api/ride-requests/{id}/offer con offered_amount
      await ds.sendDriverOffer(rideId, fare);
      ref.invalidate(availableRidesProvider);
      if (!mounted) return;
      context.push('/driver/tracking?rideId=$rideId');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al aceptar servicio: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final availableRidesAsync = ref.watch(availableRidesProvider);
    final topPadding = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: YavaUiTokens.background,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // 1. Fondo Catedral Misional de Concepción (Estilo Noche / Futurista)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 340,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Colors.black87, Colors.transparent],
                    stops: [0.0, 0.7, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  'assets/images/concepcion_catedral_night.png',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, -0.35),
                  errorBuilder: (_, __, ___) => Container(color: const Color(0xFF040A14)),
                ),
              ),
            ),

            // 2. Contenido Scrollable
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, topPadding + 6, 16, 95),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DriverTopBar(),
                  const SizedBox(height: 12),

                  // Perfil del Socio Conductor
                  DriverProfileHeader(
                    driverName: user?.name ?? 'Guery',
                    rating: 4.9,
                    reviewsCount: 124,
                    photoUrl: user?.photo,
                  ),
                  const SizedBox(height: 16),

                  // Barra de Disponibilidad con Switch y Selector de Modo
                  DriverAvailabilityBar(
                    isOnline: _isOnline,
                    isLoading: _loadingStatus,
                    onToggle: _toggleAvailability,
                  ),
                  const SizedBox(height: 16),

                  // Tarjetas de Métricas (Ganancia, Servicios, Recorrido, Conectado)
                  const DriverStatsGrid(
                    todayEarnings: 186.50,
                    completedServices: 7,
                    distanceKm: 42.6,
                    onlineTime: '4 h 18 min',
                  ),
                  const SizedBox(height: 16),

                  // Mapa GPS Estilo Futurista (Neón Azul / Zonas de Calor)
                  const DriverMiniMapSection(),
                  const SizedBox(height: 16),

                  // Solicitud en Vivo conectada a Socket.io + Laravel
                  availableRidesAsync.when(
                    data: (rides) {
                      if (rides.isEmpty || !_isOnline) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              _isOnline ? 'Buscando solicitudes en Concepción...' : 'Actívate para recibir servicios',
                              style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        );
                      }
                      final firstRide = rides.first;
                      return DriverIncomingRideCard(
                        origin: firstRide.originAddress ?? 'Plaza Central - Concepción',
                        originSub: 'Punto de recogida',
                        destination: firstRide.destinationAddress ?? 'Destino del cliente',
                        destinationSub: 'Destino confirmado',
                        distanceKm: firstRide.distanceKm ?? 3.8,
                        durationMin: firstRide.estimatedTimeMinutes ?? 9,
                        estimatedFare: firstRide.offeredFare,
                        countdownSeconds: 25,
                        onReject: () => ref.invalidate(availableRidesProvider),
                        onAccept: () => _acceptRide(firstRide.id, firstRide.offeredFare),
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0075FF)),
                      ),
                    ),
                    error: (_, __) => const SizedBox(),
                  ),
                  const SizedBox(height: 16),

                  // Fila de Herramientas Rápidas (SOS, Combustible, Mi vehículo, Ganancias, Aura)
                  const DriverQuickToolsRow(),
                ],
              ),
            ),

            // 3. Navbar Inferior Flotante
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DriverBottomNavBar(
                currentIndex: 0,
                onTap: (index) {
                  if (index == 1) context.push('/driver/requests');
                  if (index == 2) context.push('/driver/vehicles');
                  if (index == 3) context.push('/driver/wallet');
                  if (index == 4) context.push('/driver/profile');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}