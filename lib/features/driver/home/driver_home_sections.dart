import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../app/theme/yava_ui_tokens.dart';

import '../../../app/theme/yava_ui_tokens.dart';

// --- BARRA SUPERIOR DRIVER ---
class DriverTopBar extends StatelessWidget {
  const DriverTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _circularBtn(Icons.menu_rounded, () {}),
            Row(
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(text: 'YAV'),
                      TextSpan(
                        text: 'A',
                        style: TextStyle(color: Color(0xFFE50914)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'DRIVER',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            _circularBtn(Icons.notifications_rounded, () {}, hasBadge: true),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF061426).withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on_rounded, size: 13, color: Colors.white),
              SizedBox(width: 5),
              Text(
                'Concepción, Santa Cruz',
                style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: Colors.white70),
            ],
          ),
        ),
      ],
    );
  }

  Widget _circularBtn(IconData icon, VoidCallback onTap, {bool hasBadge = false}) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFF09182B).withValues(alpha: 0.70),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: IconButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: Colors.white, size: 19),
            if (hasBadge)
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(color: Color(0xFFE50914), shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- PERFIL DEL CONDUCTOR ---
class DriverProfileHeader extends StatelessWidget {
  final String driverName;
  final double rating;
  final int reviewsCount;
  final String? photoUrl;

  const DriverProfileHeader({
    super.key,
    required this.driverName,
    required this.rating,
    required this.reviewsCount,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF0075FF), width: 2),
            boxShadow: YavaUiTokens.neonGlow(const Color(0xFF0075FF), blur: 12),
          ),
          child: ClipOval(
            child: photoUrl != null && photoUrl!.trim().isNotEmpty
                ? Image.network(photoUrl!, fit: BoxFit.cover)
                : Image.asset(
                    'assets/images/banner_conductor_promo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white),
                  ),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hola, $driverName', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            const Text('Socio Conductor', style: TextStyle(color: Colors.white60, fontSize: 12)),
            const SizedBox(height: 3),
            Row(
              children: [
                ...List.generate(5, (_) => const Icon(Icons.star_rounded, color: Colors.amber, size: 14)),
                const SizedBox(width: 4),
                Text('$rating ($reviewsCount) >', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// --- BARRA DE DISPONIBILIDAD ---
class DriverAvailabilityBar extends StatelessWidget {
  final bool isOnline;
  final bool isLoading;
  final ValueChanged<bool> onToggle;

  const DriverAvailabilityBar({
    super.key,
    required this.isOnline,
    required this.isLoading,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isOnline ? const Color(0xFF003822) : const Color(0xFF1E2430),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: isOnline ? YavaUiTokens.onlineGreen : Colors.white24, width: 1.4),
              boxShadow: isOnline ? YavaUiTokens.neonGlow(YavaUiTokens.onlineGreen, blur: 14) : [],
            ),
            child: Row(
              children: [
                Icon(Icons.directions_car_rounded, color: isOnline ? YavaUiTokens.onlineGreen : Colors.white60, size: 20),
                const SizedBox(width: 8),
                Text(
                  isOnline ? 'DISPONIBLE' : 'DESCONECTADO',
                  style: TextStyle(
                    color: isOnline ? Colors.white : Colors.white60,
                    fontWeight: FontWeight.w900,
                    fontSize: 10.5,
                  ),
                ),
                const Spacer(),
                isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Switch.adaptive(
                        value: isOnline,
                        activeColor: YavaUiTokens.onlineGreen,
                        onChanged: onToggle,
                      ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        _modeChip(Icons.directions_car_rounded, 'Movilidad', true),
        const SizedBox(width: 8),
        _modeChip(Icons.two_wheeler_rounded, 'Delivery', false),
      ],
    );
  }

  Widget _modeChip(IconData icon, String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF003D82) : const Color(0xFF0B1728),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? const Color(0xFF0075FF) : Colors.white12),
      ),
      child: Column(
        children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.white60, size: 18),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontSize: 9, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// --- MÉTRICAS DE HOY ---
class DriverStatsGrid extends StatelessWidget {
  final double todayEarnings;
  final int completedServices;
  final double distanceKm;
  final String onlineTime;

  const DriverStatsGrid({
    super.key,
    required this.todayEarnings,
    required this.completedServices,
    required this.distanceKm,
    required this.onlineTime,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _statTile(Icons.account_balance_wallet_rounded, 'Bs ${todayEarnings.toStringAsFixed(2)}', 'Ganancia de hoy'),
        const SizedBox(width: 8),
        _statTile(Icons.assignment_turned_in_rounded, '$completedServices', 'Servicios'),
        const SizedBox(width: 8),
        _statTile(Icons.timeline_rounded, '$distanceKm km', 'Recorrido'),
        const SizedBox(width: 8),
        _statTile(Icons.access_time_rounded, onlineTime, 'Conectado'),
      ],
    );
  }

  Widget _statTile(IconData icon, String value, String title) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF071426),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF00A3FF), size: 16),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 8.0)),
          ],
        ),
      ),
    );
  }
}

// --- MAPA PREVIEW GPS (ESTILO FUTURISTA) ---

class DriverMiniMapSection extends StatefulWidget {
  const DriverMiniMapSection({super.key});

  @override
  State<DriverMiniMapSection> createState() => _DriverMiniMapSectionState();
}

class _DriverMiniMapSectionState extends State<DriverMiniMapSection> {
  GoogleMapController? _mapController;
  
  // Ubicación por defecto en Concepción, Santa Cruz
  static const LatLng _initialPosition = LatLng(-16.1311, -62.0298);

  // Estilo JSON oficial para oscurecer Google Maps (Estilo Cyber / Dark Mode)
  static const String _darkMapStyle = '''
  [
    {"elementType": "geometry", "stylers": [{"color": "#081528"}]},
    {"elementType": "labels.text.fill", "stylers": [{"color": "#8ec3b9"}]},
    {"elementType": "labels.text.stroke", "stylers": [{"color": "#1a3646"}]},
    {"featureType": "administrative.locality", "elementType": "labels.text.fill", "stylers": [{"color": "#d59563"}]},
    {"featureType": "poi", "elementType": "labels.text.fill", "stylers": [{"color": "#d59563"}]},
    {"featureType": "poi.park", "elementType": "geometry", "stylers": [{"color": "#021a30"}]},
    {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#0f2c4a"}]},
    {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#1f5682"}]},
    {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#143f66"}]},
    {"featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [{"color": "#1f6cb0"}]},
    {"featureType": "transit", "elementType": "geometry", "stylers": [{"color": "#0f2c4a"}]},
    {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#020d1a"}]},
    {"featureType": "water", "elementType": "labels.text.fill", "stylers": [{"color": "#4e6d70"}]}
  ]
  ''';

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // Aplicamos el diseño de mapa oscuro futurista
    _mapController?.setMapStyle(_darkMapStyle);
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF081528),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF0075FF).withValues(alpha: 0.5)),
        boxShadow: YavaUiTokens.neonGlow(const Color(0xFF0075FF), blur: 12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          children: [
            // Mapa Real interactivo de Google Maps
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _initialPosition,
                zoom: 14.5,
              ),
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              rotateGesturesEnabled: false,
              scrollGesturesEnabled: true,
              tiltGesturesEnabled: false,
            ),

            // Capa transparente opcional para evitar que el usuario interfiera accidentalmente con el mini scroll del mapa pequeño,
            // (O puedes quitar este IgnorePointer si deseas que el mini mapa sea completamente interactivo al deslizarlo).
            // IgnorePointer(
            //   child: Container(color: Colors.transparent),
            // ),

            // Botones flotantes de control estéticos
            Positioned(
              left: 12,
              top: 12,
              child: Column(
                children: [
                  _btn(Icons.my_location_rounded, () {
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(_initialPosition, 15),
                    );
                  }),
                  const SizedBox(height: 8),
                  _btn(Icons.layers_rounded, () {}),
                  const SizedBox(height: 8),
                  _btn(Icons.navigation_rounded, () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn(IconData icon, [VoidCallback? onTap]) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: IconButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

// --- TARJETA DE NUEVO SERVICIO ENTRANTE ---
class DriverIncomingRideCard extends StatelessWidget {
  final String origin;
  final String originSub;
  final String destination;
  final String destinationSub;
  final double distanceKm;
  final int durationMin;
  final double estimatedFare;
  final int countdownSeconds;
  final VoidCallback onReject;
  final VoidCallback onAccept;

  const DriverIncomingRideCard({
    super.key,
    required this.origin,
    required this.originSub,
    required this.destination,
    required this.destinationSub,
    required this.distanceKm,
    required this.durationMin,
    required this.estimatedFare,
    required this.countdownSeconds,
    required this.onReject,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF081C38), Color(0xFF030D1C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF0075FF), width: 1.5),
        boxShadow: YavaUiTokens.neonGlow(const Color(0xFF0075FF), blur: 18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(color: Color(0xFFE50914), shape: BoxShape.circle),
                child: const Center(child: Text('Y', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900))),
              ),
              const SizedBox(width: 8),
              const Text('NUEVO SERVICIO', style: TextStyle(color: Color(0xFF00A3FF), fontSize: 13, fontWeight: FontWeight.w900)),
              const Spacer(),
              Text('00:${countdownSeconds.toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onReject,
                child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _point(Colors.cyanAccent, origin, originSub),
                    Container(margin: const EdgeInsets.only(left: 6), height: 16, width: 2, color: Colors.white24),
                    _point(Colors.redAccent, destination, destinationSub),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 12, color: Colors.white60),
                      Text(' $distanceKm km', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                      const SizedBox(width: 6),
                      const Icon(Icons.access_time_rounded, size: 12, color: Colors.white60),
                      Text(' $durationMin min', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A2952),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF0075FF).withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Bs ${estimatedFare.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
                        const Text('Tarifa estimada', style: TextStyle(color: Colors.white60, fontSize: 9)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close_rounded, size: 16, color: Colors.white70),
                  label: const Text('Rechazar', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
                  label: const Text('Aceptar', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0075FF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _point(Color dotColor, String title, String subtitle) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }
}

// --- HERRAMIENTAS RÁPIDAS ---
class DriverQuickToolsRow extends StatelessWidget {
  const DriverQuickToolsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _tool(Icons.emergency_rounded, 'SOS', isRed: true),
        _tool(Icons.local_gas_station_rounded, 'Combustible'),
        _tool(Icons.directions_car_rounded, 'Mi vehículo'),
        _tool(Icons.bar_chart_rounded, 'Ganancias'),
        _tool(Icons.hexagon_outlined, 'YAVÁ Aura'),
      ],
    );
  }

  Widget _tool(IconData icon, String label, {bool isRed = false}) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isRed ? const Color(0xFF38070B) : const Color(0xFF09172B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isRed ? Colors.redAccent.withValues(alpha: 0.6) : Colors.white12),
          ),
          child: Icon(icon, color: isRed ? Colors.redAccent : Colors.white, size: 22),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// --- NAVBAR INFERIOR DRIVER ---
class DriverBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const DriverBottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF030A14).withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _item(0, Icons.home_rounded, 'Inicio'),
                _item(1, Icons.assignment_outlined, 'Servicios'),
                _centerBtn(),
                _item(3, Icons.account_balance_wallet_outlined, 'Ganancias'),
                _item(4, Icons.person_outline_rounded, 'Perfil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _centerBtn() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF02172D),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF0075FF), width: 2),
        boxShadow: YavaUiTokens.neonGlow(const Color(0xFF0075FF), blur: 14),
      ),
      child: const Center(
        child: Text('Y', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _item(int index, IconData icon, String label) {
    final isSelected = index == currentIndex;
    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF0075FF) : Colors.white60, size: 21),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF0075FF) : Colors.white60,
              fontSize: 9.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}