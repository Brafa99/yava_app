import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:yava_delivery_driver/features/auth/application/auth_controller.dart';
import 'package:yava_delivery_driver/features/transport/customer_offer_page.dart';
import 'package:yava_delivery_driver/features/transport/transport_service.dart';

class CustomerNewRequestPage extends ConsumerStatefulWidget {
  const CustomerNewRequestPage({
    super.key,
    this.initialService,
  });

  static const routeName = 'customer-new-request';
  static const routePath = '/customer/new-request';

  final String? initialService;

  @override
  ConsumerState<CustomerNewRequestPage> createState() =>
      _CustomerNewRequestPageState();
}

class _CustomerNewRequestPageState
    extends ConsumerState<CustomerNewRequestPage> {
  GoogleMapController? _mapController;

  Position? _currentPosition;

  LatLng? _origin;
  LatLng? _destination;

  bool _loadingLocation = true;
  bool _locationError = false;

  String? _selectedService;

  final Set<Marker> _markers = {};

  final Map<String, _ServiceOption> _services = {
    'taxi': const _ServiceOption(
      id: 'taxi',
      title: 'Taxi',
      subtitle: 'Transporte rápido',
      icon: Icons.local_taxi,
    ),
    'mototaxi': const _ServiceOption(
      id: 'mototaxi',
      title: 'Mototaxi',
      subtitle: 'Rápido y económico',
      icon: Icons.two_wheeler,
    ),
    'camion': const _ServiceOption(
      id: 'camion',
      title: 'Camión',
      subtitle: 'Carga y ganado',
      icon: Icons.local_shipping,
    ),
    'delivery': const _ServiceOption(
      id: 'delivery',
      title: 'Delivery',
      subtitle: 'Envíos y encomiendas',
      icon: Icons.inventory_2_outlined,
    ),
    'viaje': const _ServiceOption(
      id: 'viaje',
      title: 'Viaje',
      subtitle: 'Traslado entre localidades',
      icon: Icons.route,
    ),
  };

  @override
  void initState() {
    super.initState();

    _selectedService = widget.initialService;

    _initializeLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
  if (!mounted) return;

  setState(() {
    _loadingLocation = true;
    _locationError = false;
  });

  try {
    // 1. Verificar que el GPS/ubicación del dispositivo esté activo.
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (!mounted) return;

      setState(() {
        _loadingLocation = false;
        _locationError = true;
      });

      _showMessage(
        'Activa la ubicación/GPS de tu dispositivo.',
      );

      return;
    }

    // 2. Verificar permisos.
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // 3. Permiso rechazado.
    if (permission == LocationPermission.denied) {
      if (!mounted) return;

      setState(() {
        _loadingLocation = false;
        _locationError = true;
      });

      _showMessage(
        'Necesitamos permiso de ubicación para continuar.',
      );

      return;
    }

    // 4. Permiso bloqueado permanentemente.
    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;

      setState(() {
        _loadingLocation = false;
        _locationError = true;
      });

      _showMessage(
        'El permiso de ubicación está bloqueado. '
        'Actívalo desde Ajustes.',
      );

      return;
    }

    // 5. Intentar obtener la posición actual.
    Position? position;

    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      ).timeout(
        const Duration(seconds: 15),
      );
    } catch (e) {
      debugPrint('GPS actual falló: $e');

      // 6. Si el GPS tarda demasiado, intentar última posición conocida.
      try {
        position = await Geolocator.getLastKnownPosition();
      } catch (e) {
        debugPrint('Última posición conocida falló: $e');
      }
    }

    // 7. Si todavía no tenemos posición, realmente no hay ubicación.
    if (position == null) {
      if (!mounted) return;

      setState(() {
        _loadingLocation = false;
        _locationError = true;
      });

      _showMessage(
        'No pudimos obtener tu ubicación. '
        'Verifica que el GPS esté activo.',
      );

      return;
    }

    debugPrint(
      'GPS YAVA: ${position.latitude}, ${position.longitude}',
    );

    final origin = LatLng(
      position.latitude,
      position.longitude,
    );

    if (!mounted) return;

    // 8. Guardar la ubicación REAL.
    setState(() {
      _currentPosition = position;
      _origin = origin;
      _loadingLocation = false;
      _locationError = false;
    });

    debugPrint(
      'ORIGIN YAVA: $_origin',
    );

    // 9. Crear marcador del origen.
    _updateOriginMarker();

    // 10. Centrar mapa cuando ya exista.
    await _moveCamera(origin);
  } catch (e, stackTrace) {
    debugPrint('ERROR GPS YAVA: $e');
    debugPrint('STACK GPS YAVA: $stackTrace');

    if (!mounted) return;

    setState(() {
      _loadingLocation = false;
      _locationError = true;
    });

    _showMessage(
      'No pudimos obtener tu ubicación actual.',
    );
  }
}

  void _updateOriginMarker() {
    if (_origin == null) return;

    setState(() {
      _markers.removeWhere(
        (marker) => marker.markerId.value == 'origin',
      );

      _markers.add(
        Marker(
          markerId: const MarkerId('origin'),
          position: _origin!,
          infoWindow: const InfoWindow(
            title: 'Punto de partida',
            snippet: 'Tu ubicación actual',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    });
  }

  void _updateDestinationMarker(LatLng position) {
    setState(() {
      _destination = position;

      _markers.removeWhere(
        (marker) => marker.markerId.value == 'destination',
      );

      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: position,
          infoWindow: const InfoWindow(
            title: 'Destino',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ),
      );
    });
  }

  Future<void> _moveCamera(LatLng position) async {
    if (_mapController == null) return;

    await _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(
        position,
        15,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
  _mapController = controller;

  if (_origin != null) {
    _moveCamera(_origin!);
  }
}

  void _onMapTap(LatLng position) {
    _updateDestinationMarker(position);

    _showMessage(
      'Destino seleccionado.',
    );
  }

  void _selectService(String service) {
    setState(() {
      _selectedService = service;
    });
  }

 Future<void> _useCurrentLocation() async {
  if (_origin == null) {
    await _initializeLocation();
    return;
  }

  await _moveCamera(_origin!);

  _showMessage(
    'Mapa centrado en tu ubicación.',
  );
}

  void _continueRequest() {
    if (_selectedService == null) {
      _showMessage(
        'Selecciona el tipo de servicio.',
      );
      return;
    }

    if (_origin == null) {
      _showMessage(
        'No tenemos tu ubicación de origen.',
      );
      return;
    }

    if (_destination == null) {
      _showMessage(
        'Toca el mapa para seleccionar tu destino.',
      );
      return;
    }

    _showRequestSummary();
  }

  void _showRequestSummary() {
    final service = _services[_selectedService];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            24,
            12,
            24,
            28,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Resumen de tu solicitud',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF072D36),
                  ),
                ),
                const SizedBox(height: 20),
                _SummaryRow(
                  icon: service?.icon ?? Icons.directions_car,
                  title: 'Servicio',
                  value: service?.title ?? 'Transporte',
                ),
                const SizedBox(height: 14),
                const _SummaryRow(
                  icon: Icons.my_location,
                  title: 'Origen',
                  value: 'Tu ubicación actual',
                ),
                const SizedBox(height: 14),
                const _SummaryRow(
                  icon: Icons.location_on,
                  title: 'Destino',
                  value: 'Destino seleccionado en el mapa',
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7F8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFF0F4C5C),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'El precio será propuesto por los '
                          'transportistas cercanos.',
                          style: TextStyle(
                            color: Color(0xFF64757B),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _createRequest();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B57),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Buscar conductor',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _createRequest() async {
  final user = ref.read(authControllerProvider).user;

  if (user == null) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'No se encontró la sesión del usuario.',
        ),
      ),
    );

    return;
  }

  if (_currentPosition == null || _origin == null) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'No se pudo obtener tu ubicación actual.',
        ),
      ),
    );

    return;
  }

  if (_destination == null) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Selecciona un destino en el mapa.',
        ),
      ),
    );

    return;
  }

  if (_selectedService == null) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Selecciona el tipo de servicio.',
        ),
      ),
    );

    return;
  }

  final service =
      ref.read(transportServiceProvider);

  try {
    final requestId =
        await service.createRequest(
      customerId: user.uid,
      serviceType: _selectedService!,
      origin: GeoPoint(
        _origin!.latitude,
        _origin!.longitude,
      ),
      destination: GeoPoint(
        _destination!.latitude,
        _destination!.longitude,
      ),
    );

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CustomerOffersPage(
          requestId: requestId,
          customerId: user.uid,
        ),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'No se pudo crear la solicitud: $e',
        ),
      ),
    );
  }
}

  void _showSearchingDialog({
  required String requestId,
}) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Buscando conductor',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Tu solicitud fue enviada correctamente.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Estamos buscando transportistas disponibles cerca de ti.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    },
  );
}

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF072D36),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildServiceSelector(),
            Expanded(
              child: _buildMapSection(),
            ),
            _buildBottomPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        8,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: Color(0xFF072D36),
            ),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'Nuevo viaje',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: Color(0xFF072D36),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _useCurrentLocation,
              icon: const Icon(
                Icons.my_location,
                color: Color(0xFF0F4C5C),
              ),
              tooltip: 'Mi ubicación',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSelector() {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: _services.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final service = _services.values.elementAt(index);
          final selected =
              _selectedService == service.id;

          return GestureDetector(
            onTap: () => _selectService(service.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 92,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF072D36)
                    : const Color(0xFFF4F7F8),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF072D36)
                      : Colors.transparent,
                ),
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    service.icon,
                    size: 27,
                    color: selected
                        ? Colors.white
                        : const Color(0xFF0F4C5C),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    service.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? Colors.white
                          : const Color(0xFF072D36),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapSection() {
    if (_loadingLocation) {
      return Container(
        color: const Color(0xFFF1F5F6),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Color(0xFFFF6B57),
              ),
              SizedBox(height: 14),
              Text(
                'Obteniendo tu ubicación...',
                style: TextStyle(
                  color: Color(0xFF64757B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_locationError || _origin == null) {
      return Container(
        color: const Color(0xFFF1F5F6),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_off_outlined,
                  size: 48,
                  color: Color(0xFF64757B),
                ),
                const SizedBox(height: 14),
                const Text(
                  'No pudimos obtener tu ubicación.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF072D36),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _initializeLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFFF6B57),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Intentar nuevamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _origin!,
            zoom: 15,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
          markers: _markers,
          onMapCreated: _onMapCreated,
          onTap: _onMapTap,
        ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.touch_app_outlined,
                  color: Color(0xFFFF6B57),
                  size: 21,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _destination == null
                        ? 'Toca el mapa para elegir tu destino'
                        : 'Destino seleccionado',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF072D36),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.my_location,
                  size: 20,
                  color: Color(0xFF0F4C5C),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Tu ubicación actual',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF072D36),
                    ),
                  ),
                ),
                if (_destination != null)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF2E8B57),
                    size: 22,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _continueRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFFF6B57),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceOption {
  const _ServiceOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF0F4C5C),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64757B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF072D36),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchingDialog extends StatefulWidget {
  const _SearchingDialog();

  @override
  State<_SearchingDialog> createState() =>
      _SearchingDialogState();
}

class _SearchingDialogState
    extends State<_SearchingDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1400,
      ),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFF6B57)
                            .withOpacity(
                          0.08 +
                              (_controller.value * 0.10),
                        ),
                      ),
                    ),
                    Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF072D36),
                      ),
                      child: const Icon(
                        Icons.local_taxi,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Buscando conductores',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF072D36),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Estamos buscando transportistas cercanos a tu ubicación.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64757B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFFFF6B57),
              ),
            ),
          ],
        ),
      ),
    );
  }
}