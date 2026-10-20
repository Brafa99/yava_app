import 'package:flutter/material.dart';
import 'package:yava_delivery_driver/taxi_page.dart';
// import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final List<ServiceItem> services = const [
    ServiceItem(
      title: 'Taxi',
      icon: 'assets/images/taxi.png',
    ),
    ServiceItem(
      title: 'Taxi Moto',
      icon: 'assets/images/taxi_moto.png',
    ),
    ServiceItem(
      title: 'Delivery',
      icon: 'assets/images/bag.png',
    ),
    ServiceItem(
      title: 'Moto Express',
      icon: 'assets/images/moto_express.png',
    ),
    ServiceItem(
      title: 'Trufi',
      icon: 'assets/images/trufi.png',
    ),
    ServiceItem(
      title: 'Viajes Interprov.',
      icon: 'assets/images/viajes_interprov.png',
    ),
    ServiceItem(
      title: 'Carga',
      icon: 'assets/images/camion_carga.webp',
    ),
    ServiceItem(
      title: 'Ganadero',
      icon: 'assets/images/camion_ganadero.png',
    ),
    ServiceItem(
      title: 'Auxilio',
      icon: 'assets/images/emergency.png',
    ),
    ServiceItem(
      title: 'Remolque',
      icon: 'assets/images/remolque.jpg',
    ),
    ServiceItem(
      title: 'Encomiendas',
      icon: 'assets/images/encomiendas.png',
    ),
    ServiceItem(
      title: 'Más servicios',
      icon: 'assets/images/puntos_azules.png',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(size),

                Expanded(
                  child: _buildServicesArea(),
                ),
              ],
            ),

            // Botón de ubicación
            Positioned(
              left: 0,
              right: 0,
              bottom: 66,
              child: Center(
                child: _buildLocationButton(),
              ),
            ),

            // Navegación inferior
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNavigation(),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader(Size size) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
      child: Column(
        children: [
          SizedBox(
            height: 38,
            child: Row(
              children: [
                // Menú
                _headerIcon(
                  icon: Icons.menu_rounded,
                ),

                const Spacer(),

                // Logo
                const Text(
                  'YAVÁ',
                  style: TextStyle(
                    color: Color(0xFFFFD21F),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),

                const Spacer(),

                // Campana
                _headerIcon(
                  icon: Icons.notifications_none_rounded,
                ),
              ],
            ),
          ),

          const SizedBox(height: 1),

          // Ciudad
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 12,
              ),
              SizedBox(width: 3),
              Text(
                'Concepción',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size: 14,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Buscador
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 7,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const TextField(
              enabled: false,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                hintText: '¿A dónde vamos?',
                hintStyle: TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 17,
                  color: Color(0xFF8E8E8E),
                ),
                prefixIconConstraints: BoxConstraints(
                  minWidth: 35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerIcon({
    required IconData icon,
  }) {
    return SizedBox(
      width: 38,
      height: 38,
      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  // ------------------------------------------------------------
  // SERVICIOS
  // ------------------------------------------------------------

  Widget _buildServicesArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            8,
            8,
            8,
            95,
          ),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOut,
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 1.13,
              ),
              itemBuilder: (context, index) {
                return _buildServiceCard(
                  services[index],
                  index,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceCard(
  ServiceItem service,
  int index,
) {
  final bool isTaxi = index == 0;

  return GestureDetector(
    onTap: isTaxi
        ? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TaxiPage(),
              ),
            );
          }
        : null,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFE4E4E4),
          width: 0.7,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 7,
                left: 8,
                right: 8,
              ),
              child: Center(
                child: Image.asset(
                  service.icon,
                  width: 34,
                  height: 34,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 2,
              ),
              child: Center(
                child: Text(
                  service.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 8.5,
                    color: Color(0xFF292929),
                    fontWeight: FontWeight.w600,
                    height: 1.05,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  // ------------------------------------------------------------
  // BOTÓN GPS
  // ------------------------------------------------------------

  Widget _buildLocationButton() {
    return Container(
      width: 46,
      height: 46,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.location_on_rounded,
            color: Color(0xFFFFD21F),
            size: 25,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BOTTOM NAVIGATION
  // ------------------------------------------------------------

  Widget _buildBottomNavigation() {
    return Container(
      height: 59,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(7),
          topRight: Radius.circular(7),
        ),
      ),
      child: Row(
        children: [
          _buildBottomItem(
            icon: Icons.home_rounded,
            label: 'Inicio',
            selected: true,
          ),
          _buildBottomItem(
            icon: Icons.apps_rounded,
            label: 'Servicios',
          ),
          _buildBottomItem(
            icon: Icons.local_activity_outlined,
            label: 'Actividad',
          ),
          _buildBottomItem(
            icon: Icons.card_giftcard_rounded,
            label: 'Beneficios',
          ),
          _buildBottomItem(
            icon: Icons.person_outline_rounded,
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildBottomItem({
    required IconData icon,
    required String label,
    bool selected = false,
  }) {
    final color = selected
        ? const Color(0xFFFFD21F)
        : const Color(0xFFBDBDBD);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 19,
            color: color,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: selected
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MODELO
// ============================================================

class ServiceItem {
  final String title;
  final String icon;

  const ServiceItem({
    required this.title,
    required this.icon,
  });
}