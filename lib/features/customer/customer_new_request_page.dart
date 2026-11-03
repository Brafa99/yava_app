import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yava_delivery_driver/app/theme/app_colors.dart';
import 'package:yava_delivery_driver/core/network/api_endpoints.dart';
import 'package:yava_delivery_driver/features/auth/application/auth_controller.dart';
import 'package:yava_delivery_driver/features/customer/home/customer_home_page.dart';

enum TripState { selecting, searching, active, finished }

class CustomerNewRequestPage extends ConsumerStatefulWidget {
  final String? initialService;
  const CustomerNewRequestPage({super.key, this.initialService});

  static const routeName = 'customer-new-request';
  static const routePath = '/customer/new-request';

  @override
  ConsumerState<CustomerNewRequestPage> createState() => _CustomerNewRequestPageState();
}

class _CustomerNewRequestPageState extends ConsumerState<CustomerNewRequestPage> {
  TripState _tripState = TripState.selecting;
  
  // Mapa y Coordenadas
  GoogleMapController? _mapController;
  LatLng _originLatLng = const LatLng(-16.1311, -62.0298);
  LatLng _destinationLatLng = const LatLng(-16.1395, -62.0215);
  String _originAddress = 'Buscando tu ubicación...';
  String _destinationAddress = '¿A dónde vas?';
  
  String _selectedCategorySlug = 'auto';
  double _offeredFare = 15.0;

  @override
  void initState() {
    super.initState();
    if (widget.initialService != null) {
      _selectedCategorySlug = widget.initialService!.toLowerCase();
    }
    _initGpsLocation();
  }
  
  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg), 
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0A1628), // AppColors.navy
      )
    );
  }

  // 1. OBTENER UBICACIÓN REAL (Manejo robusto de GPS apagado)
  Future<void> _initGpsLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // El GPS está apagado desde el centro de notificaciones.
        _showToast('Por favor, enciende el GPS de tu teléfono para continuar.');
        // Opcionalmente, puedes abrir la configuración de ubicación:
        // await Geolocator.openLocationSettings();
        
        // Configuramos la ubicación en la sede principal (Concepción) como fallback temporal
        if (mounted) {
           setState(() {
             _originLatLng = const LatLng(-16.1311, -62.0298); // Plaza Concepción
             _originAddress = 'Ubicación no detectada (GPS apagado)';
           });
           _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_originLatLng, 15));
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showToast('Permiso de ubicación denegado.');
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
          _showToast('Los permisos de ubicación están bloqueados. Habilítalos en la configuración.');
          // await Geolocator.openAppSettings();
          return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 10));

      if (mounted) {
        setState(() {
          _originLatLng = LatLng(pos.latitude, pos.longitude);
          _originAddress = 'Tu ubicación actual';
        });
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_originLatLng, 16));
      }
    } catch (e) {
      _showToast('No se pudo obtener el GPS preciso. Usando ubicación por defecto.');
      if (mounted) {
           setState(() {
             _originLatLng = const LatLng(-16.1311, -62.0298);
             _originAddress = 'Ubicación no detectada';
           });
           _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_originLatLng, 15));
        }
    }
  }

  void _handleBack() {
    if (_tripState == TripState.searching) {
      // TODO: Llamar a POST /api/ride-requests/{id}/cancel
      setState(() => _tripState = TripState.selecting);
    } else if (_tripState == TripState.selecting) {
      context.canPop() ? context.pop() : context.go('/customer/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Stack(
          children: [
            // 1. MAPA SIEMPRE ACTIVO DE FONDO
            GoogleMap(
              initialCameraPosition: CameraPosition(target: _originLatLng, zoom: 15),
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              onMapCreated: (ctrl) => _mapController = ctrl,
              markers: {
                Marker(
                  markerId: const MarkerId('origin'),
                  position: _originLatLng,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                ),
                if (_destinationAddress != '¿A dónde vas?')
                  Marker(
                    markerId: const MarkerId('destination'),
                    position: _destinationLatLng,
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                  ),
              },
              polylines: _tripState != TripState.selecting ? {
                Polyline(
                  polylineId: const PolylineId('route'),
                  color: AppColors.navyLight,
                  width: 5,
                  points: [_originLatLng, _destinationLatLng],
                )
              } : {},
            ),

            // 2. BOTÓN VOLVER
            if (_tripState != TripState.active && _tripState != TripState.finished)
              Positioned(
                top: MediaQuery.paddingOf(context).top + 10,
                left: 16,
                child: GestureDetector(
                  onTap: _handleBack,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: AppColors.navy),
                  ),
                ),
              ),

            // 3. PANEL INFERIOR DINÁMICO
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _buildBottomPanel(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    switch (_tripState) {
      case TripState.selecting:
        return _buildSelectingPanel();
      case TripState.searching:
        return _buildSearchingPanel();
      case TripState.active:
        return _buildActiveTripPanel();
      case TripState.finished:
        return _buildFinishedPanel();
    }
  }

  // --- ESTADO 1: SELECCIÓN Y COTIZACIÓN ---
// --- ESTADO 1: SELECCIÓN Y COTIZACIÓN (CONECTADO A LARAVEL) ---
  Widget _buildSelectingPanel() {
    // 1. Obtenemos las categorías reales desde el provider
    final categoriesAsync = ref.watch(serviceCategoriesProvider);
    final mobilityCategories = categoriesAsync.maybeWhen(
      data: (list) => list.where((c) => c.type == 'MOVILIDAD').toList(),
      orElse: () => [],
    );

    // Si aún no carga, mostramos un loader
    if (categoriesAsync.isLoading) {
      return Container(
        height: 200,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Center(child: CircularProgressIndicator(color: AppColors.error)),
      );
    }

    return Container(
      key: const ValueKey('panel_selecting'),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Origen y Destino
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.sand,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.my_location_rounded, color: AppColors.navy, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_originAddress, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: AppColors.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_destinationAddress, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.mutedInk)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Carrusel de Vehículos DINÁMICO desde Laravel
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: mobilityCategories.map((cat) {
                  final isSelected = _selectedCategorySlug == cat.slug;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategorySlug = cat.slug;
                        // Ajuste visual del precio según categoría
                        if (cat.slug == 'moto') _offeredFare = 10.0;
                        else if (cat.slug == 'ejecutivo') _offeredFare = 25.0;
                        else _offeredFare = 15.0;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFF5F5) : Colors.white,
                        border: Border.all(
                          color: isSelected ? AppColors.error : AppColors.mist,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            cat.slug.contains('moto') ? Icons.two_wheeler_rounded : Icons.directions_car_rounded,
                            color: isSelected ? AppColors.error : AppColors.navy,
                          ),
                          const SizedBox(height: 4),
                          Text(cat.name.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Ofertar Tarifa
            Row(
              children: [
                const Icon(Icons.payments_outlined, color: AppColors.navyLight),
                const SizedBox(width: 10),
                const Text('Tu oferta:', style: TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('Bs ${_offeredFare.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.error),
                  onPressed: () { 
                    // Aquí puedes abrir tu modal de editar tarifa
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                // Aquí cambia el estado a BUSCANDO CONDUCTOR
                setState(() => _tripState = TripState.searching);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Confirmar Viaje', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  // --- ESTADO 2: BUSCANDO CONDUCTOR ---
  Widget _buildSearchingPanel() {
    return Container(
      key: const ValueKey('panel_searching'),
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.error),
            const SizedBox(height: 20),
            const Text(
              'Buscando conductor...',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.navy),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enviando tu solicitud a los conductores cercanos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedInk),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: _handleBack,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
              ),
              child: const Text('Cancelar búsqueda'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => setState(() => _tripState = TripState.active), // Botón Demo
              child: const Text('Simular Conductor Encontrado (Demo)'),
            ),
          ],
        ),
      ),
    );
  }

  // --- ESTADO 3: VIAJE EN CURSO ---
  Widget _buildActiveTripPanel() {
    return Container(
      key: const ValueKey('panel_active'),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tu conductor está en camino',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.navy),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const CircleAvatar(radius: 26, backgroundColor: AppColors.mist, child: Icon(Icons.person, color: AppColors.navyLight)),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Luis Fernández', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      Text('Toyota Rush • Blanco', style: TextStyle(color: AppColors.mutedInk, fontSize: 13)),
                      Text('YAV-4521', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.navyLight)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: AppColors.sand, shape: BoxShape.circle),
                  child: const Icon(Icons.phone_rounded, color: AppColors.navy),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => setState(() => _tripState = TripState.finished), // Botón Demo
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Simular Fin de Viaje (Demo)'),
            ),
          ],
        ),
      ),
    );
  }

  // --- ESTADO 4: FINALIZADO ---
  Widget _buildFinishedPanel() {
    return Container(
      key: const ValueKey('panel_finished'),
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 54),
            const SizedBox(height: 16),
            const Text('¡Llegaste a tu destino!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.navy)),
            const SizedBox(height: 8),
            Text('Monto a pagar: Bs ${_offeredFare.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.error)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/customer/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}