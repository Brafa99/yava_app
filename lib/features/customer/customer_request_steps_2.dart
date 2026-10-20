import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomerActiveAndCompletedSteps extends StatefulWidget {
  final int currentStep; // 5, 6, 7 u 8
  final LatLng originLatLng;
  final LatLng destinationLatLng;
  final String originAddress;
  final String destinationAddress;
  final double distanceKm;
  final int estimatedMinutes;
  final double offeredFare;
  final String paymentMethod;
  final String driverName;
  final double driverRating;
  final int driverTrips;
  final String driverVehicle;
  final String driverPlate;
  final ValueChanged<int> onAdvanceStepDemo;
  final VoidCallback onCancelTrip;
  final ValueChanged<int> onRateDriver;
  final VoidCallback onBackHome;
  final VoidCallback onRepeatTrip;

  const CustomerActiveAndCompletedSteps({
    super.key,
    required this.currentStep,
    required this.originLatLng,
    required this.destinationLatLng,
    required this.originAddress,
    required this.destinationAddress,
    required this.distanceKm,
    required this.estimatedMinutes,
    required this.offeredFare,
    required this.paymentMethod,
    required this.driverName,
    required this.driverRating,
    required this.driverTrips,
    required this.driverVehicle,
    required this.driverPlate,
    required this.onAdvanceStepDemo,
    required this.onCancelTrip,
    required this.onRateDriver,
    required this.onBackHome,
    required this.onRepeatTrip,
  });

  @override
  State<CustomerActiveAndCompletedSteps> createState() =>
      _CustomerActiveAndCompletedStepsState();
}

class _CustomerActiveAndCompletedStepsState
    extends State<CustomerActiveAndCompletedSteps> {
  Timer? _carMoveTimer;
  double _routeProgress = 0.25;
  int _selectedStars = 5;

  @override
  void initState() {
    super.initState();
    // Anima el movimiento GPS del vehículo sobre la ruta azul en tiempo real
    _carMoveTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (!mounted || widget.currentStep == 8) return;
      setState(() {
        _routeProgress += 0.04;
        if (_routeProgress > 0.92) _routeProgress = 0.15;
      });
    });
  }

  @override
  void dispose() {
    _carMoveTimer?.cancel();
    super.dispose();
  }

  LatLng get _animatedCarPosition {
    final lat = widget.originLatLng.latitude +
        (widget.destinationLatLng.latitude - widget.originLatLng.latitude) *
            _routeProgress;
    final lng = widget.originLatLng.longitude +
        (widget.destinationLatLng.longitude - widget.originLatLng.longitude) *
            _routeProgress;
    return LatLng(lat, lng);
  }

  void _showQuickActionSnackBar(String action) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$action — ${widget.driverName} (${widget.driverPlate})'),
          backgroundColor: const Color(0xFF0A1628),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _showReceiptDialog() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recibo del Viaje • YAVÁ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0A1628),
                ),
              ),
              const Divider(height: 24),
              _receiptRow('Conductor:', widget.driverName),
              _receiptRow('Vehículo:', '${widget.driverVehicle} (${widget.driverPlate})'),
              _receiptRow('Origen:', widget.originAddress),
              _receiptRow('Destino:', widget.destinationAddress),
              _receiptRow('Distancia / Tiempo:', '${widget.distanceKm} km • ${widget.estimatedMinutes} min'),
              _receiptRow('Método de pago:', widget.paymentMethod),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total pagado',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0A1628),
                    ),
                  ),
                  Text(
                    'Bs ${widget.offeredFare.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFE50914),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Cerrar recibo',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0A1628),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentStep == 8) {
      return _buildStep8Completed();
    }
    return _buildSteps5To7ActiveTrip();
  }

  // ===========================================================================
  // PASOS 5, 6 Y 7: CONDUCTOR ENCONTRADO / LLEGANDO / VIAJE EN CURSO
  // ===========================================================================
  Widget _buildSteps5To7ActiveTrip() {
    final step = widget.currentStep;
    final isStep5 = step == 5;
    final isStep6 = step == 6;
    final isStep7 = step == 7;

    final title = isStep5
        ? '¡Conductor\nencontrado!'
        : isStep6
            ? 'Tu conductor\nestá llegando'
            : 'Viaje\nen curso';

    final subtitle = isStep5
        ? 'Tu viaje está en camino.\nRevisa los detalles de tu conductor.'
        : isStep6
            ? 'En pocos minutos estará\nen tu ubicación.'
            : 'Estamos en camino\na tu destino.';

    return SingleChildScrollView(
      key: ValueKey('req_active_$step'),
      padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isStep5) ...[
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE50914),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 8),
          ],
          GestureDetector(
            onTap: () => widget.onAdvanceStepDemo(step + 1),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0A1628),
                fontSize: 32,
                fontWeight: FontWeight.w900,
                height: 1.05,
                letterSpacing: -0.6,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.28,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE50914),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 12),

          // Barra blanca superior de métricas exclusiva del Paso 7 ("Viaje en curso")
          if (isStep7) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.access_time_rounded, size: 22),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.estimatedMinutes} min',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: Color(0xFF0A1628),
                              ),
                            ),
                            const Text(
                              'Tiempo restante',
                              style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 30, color: const Color(0xFFE2E8F0)),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.route_outlined, size: 22),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.distanceKm} km',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: Color(0xFF0A1628),
                              ),
                            ),
                            const Text(
                              'Distancia',
                              style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 30, color: const Color(0xFFE2E8F0)),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on_rounded, size: 20),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.destinationAddress,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  height: 1.1,
                                  color: Color(0xFF0A1628),
                                ),
                              ),
                              const Text(
                                'Destino',
                                style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Mapa GoogleMap con Ruta Azul y Marcador en Movimiento
          _buildLiveTrackingMap(showEtaBubble: !isStep7),

          const SizedBox(height: 12),

          // Tarjeta del Conductor
          _buildDriverInfoCard(useRedIcons: !isStep5),

          const SizedBox(height: 14),

          // Botón Inferior: "Finalizar viaje" (Paso 7) o "Cancelar viaje X" (Pasos 5 y 6)
          if (isStep7)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => widget.onAdvanceStepDemo(8),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50914),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24),
                    const Text(
                      'Finalizar viaje',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2.2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: widget.onCancelTrip,
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF5F5),
                  side: const BorderSide(color: Color(0xFFE50914), width: 1.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 22),
                    Text(
                      'Cancelar viaje',
                      style: TextStyle(
                        color: Color(0xFFE50914),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Icon(Icons.close_rounded, color: Color(0xFFE50914), size: 22),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLiveTrackingMap({required bool showEtaBubble}) {
    final carPos = _animatedCarPosition;

    return Container(
      height: 185,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          alignment: Alignment.center,
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: carPos,
                zoom: 14.6,
              ),
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              polylines: {
                Polyline(
                  polylineId: const PolylineId('blue_live_route'),
                  color: const Color(0xFF1D4ED8),
                  width: 5,
                  points: [
                    widget.originLatLng,
                    carPos,
                    widget.destinationLatLng,
                  ],
                ),
              },
              markers: {
                Marker(
                  markerId: const MarkerId('live_orig'),
                  position: widget.originLatLng,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure,
                  ),
                ),
                Marker(
                  markerId: const MarkerId('live_car'),
                  position: carPos,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueViolet,
                  ),
                  infoWindow: const InfoWindow(title: 'Vehículo YAVÁ en ruta'),
                ),
                Marker(
                  markerId: const MarkerId('live_dest'),
                  position: widget.destinationLatLng,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                ),
              },
            ),
            Positioned(
              left: 10,
              top: 10,
              child: _floatingMapCard('Tu ubicación', widget.originAddress),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: _floatingMapCard('Destino', widget.destinationAddress),
            ),
            if (showEtaBubble)
              Positioned(
                top: 38,
                child: GestureDetector(
                  onTap: () => widget.onAdvanceStepDemo(widget.currentStep + 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1628),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 6),
                      ],
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'Llegando en',
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                        Text(
                          '3 min',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _floatingMapCard(String title, String subtitle) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 135),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0A1628),
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 9.5,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfoCard({required bool useRedIcons}) {
    final iconColor =
        useRedIcons ? const Color(0xFFE50914) : const Color(0xFF0A1628);
    final circleBg =
        useRedIcons ? const Color(0xFFFFF5F5) : const Color(0xFFF1F5F9);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFFE2E8F0),
                    backgroundImage:
                        AssetImage('assets/images/banner_conductor_promo.png'),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.driverName,
                            style: const TextStyle(
                              color: Color(0xFF0A1628),
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 13,
                                color: Color(0xFF1D4ED8),
                              ),
                              SizedBox(width: 3),
                              Text(
                                'Conductor verificado',
                                style: TextStyle(
                                  color: Color(0xFF1D4ED8),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        Text(
                          ' ${widget.driverRating}  ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                            color: Color(0xFF0A1628),
                          ),
                        ),
                        Text(
                          '(${widget.driverTrips} viajes)',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.directions_car_outlined,
                          size: 18,
                          color: Color(0xFF0A1628),
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.driverVehicle,
                              style: const TextStyle(
                                color: Color(0xFF0A1628),
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              widget.driverPlate,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 96,
                height: 62,
                child: Image.asset(
                  'assets/images/vehicles/auto_yava.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.directions_car_filled_rounded,
                    size: 44,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _driverActionItem(
                Icons.phone_in_talk_outlined,
                'Llamar',
                circleBg,
                iconColor,
                () => _showQuickActionSnackBar('Llamando al conductor'),
              ),
              _driverActionItem(
                Icons.chat_bubble_outline_rounded,
                'Mensaje',
                circleBg,
                iconColor,
                () => _showQuickActionSnackBar('Chat directo habilitado'),
              ),
              _driverActionItem(
                Icons.ios_share_rounded,
                'Compartir\nmi viaje',
                circleBg,
                iconColor,
                () => _showQuickActionSnackBar('Enlace de seguimiento copiado'),
              ),
              _driverActionItem(
                Icons.verified_user_outlined,
                'Centro\nde seguridad',
                circleBg,
                iconColor,
                () => _showQuickActionSnackBar('Asistencia YAVÁ Seguridad activa'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _driverActionItem(
    IconData icon,
    String label,
    Color bg,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0A1628),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PASO 8: "¡VIAJE COMPLETADO!" (Réplica exacta de Paso8_2.png)
  // ===========================================================================
  Widget _buildStep8Completed() {
    return SingleChildScrollView(
      key: const ValueKey('req_step_8'),
      padding: const EdgeInsets.fromLTRB(20, 62, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE50914),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                '¡Viaje\ncompletado!',
                style: TextStyle(
                  color: Color(0xFF0A1628),
                  fontSize: 33,
                  fontWeight: FontWeight.w900,
                  height: 1.04,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFF16A34A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 30),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Gracias por viajar con YAVÁ.\nEsperamos verte pronto.',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.28,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE50914),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 14),

          // Tarjeta de Resumen (Fecha, Distancia, Tiempo + Origen/Destino + Mini Mapa)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: Color(0xFFE50914), size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Fecha', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                          Text(
                            'Hoy • YAVÁ',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0A1628),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
                    const SizedBox(width: 8),
                    const Icon(Icons.route_outlined, color: Color(0xFFE50914), size: 20),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Distancia', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                        Text(
                          '${widget.distanceKm} km',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0A1628),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
                    const SizedBox(width: 8),
                    const Icon(Icons.access_time_rounded, color: Color(0xFFE50914), size: 20),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tiempo', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                        Text(
                          '${widget.estimatedMinutes} min',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0A1628),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 20, color: Color(0xFFF1F5F9)),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Origen',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0A1628),
                            ),
                          ),
                          Text(
                            widget.originAddress,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Destino',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0A1628),
                            ),
                          ),
                          Text(
                            widget.destinationAddress,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 6,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          height: 92,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: widget.destinationLatLng,
                              zoom: 13.8,
                            ),
                            zoomControlsEnabled: false,
                            myLocationButtonEnabled: false,
                            liteModeEnabled: true,
                            polylines: {
                              Polyline(
                                polylineId: const PolylineId('done_poly'),
                                color: const Color(0xFF1D4ED8),
                                width: 4,
                                points: [
                                  widget.originLatLng,
                                  widget.destinationLatLng,
                                ],
                              ),
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Tarjeta compacta del Conductor
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F5).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundImage:
                      AssetImage('assets/images/banner_conductor_promo.png'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.driverName,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0A1628),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 15),
                          Text(
                            ' ${widget.driverRating} (${widget.driverTrips} viajes)',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      Text(
                        '${widget.driverVehicle} • ${widget.driverPlate}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0A1628),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 86,
                  height: 54,
                  child: Image.asset(
                    'assets/images/vehicles/auto_yava.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.directions_car_filled_rounded,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ¿Cómo fue tu viaje? + 5 Estrellas Interactivas conectadas a POST /api/ratings
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¿Cómo fue tu viaje?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0A1628),
                        ),
                      ),
                      Text(
                        'Tu opinión nos ayuda a mejorar.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (i) {
                    final star = i + 1;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedStars = star);
                        widget.onRateDriver(star);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          star <= _selectedStars
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 26,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Total del viaje Bs 28.00
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Color(0xFFE50914),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total del viaje',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0A1628),
                        ),
                      ),
                      Text(
                        'Tarifa final',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Bs ${widget.offeredFare.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0A1628),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Método de pago
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.credit_card_rounded, color: Color(0xFF0A1628), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Método de pago',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0A1628),
                        ),
                      ),
                      Text(
                        widget.paymentMethod,
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3 Botones Inferiores: Ver recibo | Repetir viaje | Volver al inicio
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showReceiptDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE50914),
                    side: const BorderSide(color: Color(0xFFFECACA)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: const Icon(Icons.receipt_long_rounded, size: 17),
                  label: const Text(
                    'Ver recibo',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onRepeatTrip,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE50914),
                    side: const BorderSide(color: Color(0xFFFECACA)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 17),
                  label: const Text(
                    'Repetir viaje',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onBackHome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: const Icon(Icons.home_outlined, size: 17),
                  label: const Text(
                    'Volver al inicio',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}