import 'package:flutter/material.dart';
import '../../../app/theme/yava_ui_tokens.dart';
import '../../../shared/models/service_category_model.dart';

// --- BARRA SUPERIOR COMPACTA Y ALINEADA ---
// --- BARRA SUPERIOR CON ESPACIADO ESTÉTICO ---
class CustomerTopBar extends StatelessWidget {
  final bool isNight;
  final VoidCallback onToggleTheme;

  const CustomerTopBar({
    super.key,
    required this.isNight,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 50,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Botón Menú a la izquierda
              Align(
                alignment: Alignment.centerLeft,
                child: _circularButton(Icons.menu_rounded, () {}),
              ),

              // 2. Logo centrado
              SizedBox(
                
                height: 76,
                child: Image.asset(
                  'assets/images/yava_home_bg.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Text(
                    'YAVÁ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),

              // 3. Iconos de Tema y Notificación alineados a la derecha
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _circularButton(
                      isNight ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                      onToggleTheme,
                      iconColor: isNight ? Colors.amber : Colors.white,
                    ),
                    const SizedBox(width: 6),
                    _circularButton(
                      Icons.notifications_rounded,
                      () {},
                      hasBadge: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6), // Separación limpia entre el logo y el selector de ciudad
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF061426).withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on_rounded, size: 13, color: Colors.white),
              SizedBox(width: 5),
              Text(
                'Concepción, Santa Cruz',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 15,
                color: Colors.white70,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _circularButton(
    IconData icon,
    VoidCallback onTap, {
    bool hasBadge = false,
    Color iconColor = Colors.white,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF09182B).withValues(alpha: 0.70),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: IconButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: iconColor, size: 18),
            if (hasBadge)
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE50914),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- TÍTULO PRINCIPAL CON INTERLINEADO CÓMODO ---
class CustomerHeroTitle extends StatelessWidget {
  final bool isNight;

  const CustomerHeroTitle({
    super.key,
    required this.isNight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿Qué necesitas hoy?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 15),

        Text(
          'La Chiquitanía conectada\nen una sola App.',
          style: 
          isNight
          ?
          const TextStyle(
           
           color: Colors.white, 
            fontSize: 12,
            height: 1.3,
            fontWeight: FontWeight.w500,
          )
          :const TextStyle(
           
           color: Colors.grey, 
            fontSize: 12,
            height: 1.3,
            fontWeight: FontWeight.w500,
          )
        ),
        const SizedBox(height: 7),
        Container(
          width: 26,
          height: 3,
          decoration: BoxDecoration(
            color: const Color(0xFFE50914),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

// --- TARJETA DE MOVILIDAD (COMPACTA Y SIMÉTRICA CON DELIVERY) ---
class MobilityMainCard extends StatelessWidget {
  final List<ServiceCategoryModel> categories;
  final VoidCallback onActionTap;
  final ValueChanged<String> onCategoryTap;

  const MobilityMainCard({
    super.key,
    this.categories = const [],
    required this.onActionTap,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = categories.isNotEmpty
        ? categories
        : [
            ServiceCategoryModel(id: 2, name: 'Auto', slug: 'auto', type: 'MOVILIDAD', sortOrder: 1, isActive: true),
            ServiceCategoryModel(id: 3, name: 'Moto', slug: 'moto', type: 'MOVILIDAD', sortOrder: 2, isActive: true),
            ServiceCategoryModel(id: 4, name: 'Trufi', slug: 'trufi', type: 'MOVILIDAD', sortOrder: 3, isActive: true),
            ServiceCategoryModel(id: 5, name: 'Viaje\nInterprovincial', slug: 'viaje-interprovincial', type: 'MOVILIDAD', sortOrder: 4, isActive: true),
          ];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0058C6), Color(0xFF042654), Color(0xFF021024)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF00A2FF).withValues(alpha: 0.7),
          width: 3.0,
        ),
        boxShadow: YavaUiTokens.neonGlow(const Color(0xFF0075FF), blur: 16),
      ),
      child: Stack(
        children: [
          // Auto blanco a la derecha
          Positioned(
            top: 14,
            right: -10,
            width: 102,
            height: 64,
            child: Opacity(
              opacity: 0.55,
              child: Image.asset(
                'assets/images/blue_card.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/car_blue_glow.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF0075FF),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: Colors.white.withValues(alpha: 1.0)),
                  boxShadow: YavaUiTokens.softGlow(const Color(0xFF0075FF)),
                ),
                child: const Icon(Icons.directions_car_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 6),
              const Text(
                'MOVILIDAD',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14.5),
              ),
              const SizedBox(height: 2),
              const Text(
                'Muévete seguro, rápido\ny a tu precio.',
                style: TextStyle(color: Colors.white70, fontSize: 9.5, height: 1.18),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 32,
                child: ElevatedButton(
                  onPressed: onActionTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0075FF),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Quiero viajar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, size: 10),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 2 filas con childAspectRatio 1.01 para igualar exactamente las 3 filas de Delivery
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 6,
                mainAxisSpacing: 8,
                childAspectRatio: 1.01,
                children: items.take(4).map((cat) {
                  return _mobilityTile(
                    _iconForMobility(cat.slug),
                    cat.name.replaceAll(' ', '\n'),
                    () => onCategoryTap(cat.slug),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconForMobility(String slug) {
    switch (slug) {
      case 'moto':
        return Icons.two_wheeler_rounded;
      case 'trufi':
        return Icons.airport_shuttle_rounded;
      case 'viaje-interprovincial':
        return Icons.alt_route_rounded;
      default:
        return Icons.directions_car_filled_rounded;
    }
  }

  Widget _mobilityTile(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF021B38).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF0075FF).withValues(alpha: 0.35)),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  height: 1.05,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- TARJETA DE DELIVERY (COMPACTA Y SIMÉTRICA CON MOVILIDAD) ---
class DeliveryMainCard extends StatelessWidget {
  final bool isNight;
  final List<ServiceCategoryModel> categories;
  final VoidCallback onActionTap;
  final ValueChanged<String> onCategoryTap;

  const DeliveryMainCard({
    super.key,
    required this.isNight,
    this.categories = const [],
    required this.onActionTap,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = categories.isNotEmpty
        ? categories
        : [
            ServiceCategoryModel(id: 6, name: 'Restaurantes', slug: 'restaurantes', type: 'DELIVERY', sortOrder: 1, isActive: true),
            ServiceCategoryModel(id: 7, name: 'Tiendas', slug: 'tiendas', type: 'DELIVERY', sortOrder: 2, isActive: true),
            ServiceCategoryModel(id: 8, name: 'Farmacias', slug: 'farmacias', type: 'DELIVERY', sortOrder: 3, isActive: true),
            ServiceCategoryModel(id: 9, name: 'Mercados', slug: 'mercados', type: 'DELIVERY', sortOrder: 4, isActive: true),
            ServiceCategoryModel(id: 10, name: 'Envíos', slug: 'envios', type: 'DELIVERY', sortOrder: 5, isActive: true),
            ServiceCategoryModel(id: 11, name: 'Mandados', slug: 'mandados', type: 'DELIVERY', sortOrder: 6, isActive: true),
          ];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9E0B14), Color(0xFF5A0006), Color(0xFF220002)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFF3845).withValues(alpha: 1.0),
          width: 3.0,
        ),
        boxShadow: YavaUiTokens.neonGlow(const Color(0xFFE50914), blur: 16),
      ),
      child: Stack(
        children: [
          // Moto o bolsa a la derecha
          Positioned(
            top: 12,
            right: -8,
            width: 100,
            height: 68,
            child: Opacity(
              opacity: 0.55,
              child: Image.asset(
                'assets/images/moto_red_glow.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFE50914),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  boxShadow: YavaUiTokens.softGlow(const Color(0xFFE50914)),
                ),
                child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 6),
              const Text(
                'DELIVERY',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14.5),
              ),
              const SizedBox(height: 2),
              const Text(
                'Todo lo que necesitas\nen la puerta de tu casa.',
                style: TextStyle(color: Colors.white70, fontSize: 9.5, height: 1.18),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 32,
                child: ElevatedButton(
                  onPressed: onActionTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Quiero pedir', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, size: 10),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 3 filas con childAspectRatio 1.55 para ser más compactas y cuadrar con Movilidad
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 1.55,
                children: items.take(6).map((cat) {
                  return _deliveryTile(
                    _iconForDelivery(cat.slug),
                    cat.name,
                    () => onCategoryTap(cat.slug),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconForDelivery(String slug) {
    switch (slug) {
      case 'restaurantes':
        return Icons.restaurant_rounded;
      case 'tiendas':
        return Icons.shopping_cart_rounded;
      case 'farmacias':
        return Icons.local_hospital_rounded;
      case 'mercados':
        return Icons.storefront_rounded;
      case 'envios':
        return Icons.inventory_2_rounded;
      case 'mandados':
        return Icons.directions_run_rounded;
      default:
        return Icons.shopping_bag_rounded;
    }
  }

  Widget _deliveryTile(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF380004).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFF2E3A).withValues(alpha: 0.35)),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  height: 1.05,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- BANNER PROMOCIONAL INFERIOR COMPACTO ---
class ConcepcionPromoBanner extends StatelessWidget {
  const ConcepcionPromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 98,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF060F1E),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE50914).withValues(alpha: 0.8),
          width: 3.0,
        ),
        boxShadow: YavaUiTokens.neonGlow(const Color(0xFFE50914), blur: 12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE50914),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Concepción se mueve\ncon YAVÁ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Apoyando a nuestros comercios,\nconductores y emprendedores.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 9.5,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/images/banner_conductor_promo.png',
              width: 105,
              height: 78,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.person_pin_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- BARRA INFERIOR ---
// --- BARRA INFERIOR PEGADA AL FONDO ---
class YavaBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const YavaBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF030811).withValues(alpha: 0.98),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_rounded, 'Inicio'),
                _navItem(1, Icons.access_time_rounded, 'Mis viajes'),
                _centerYButton(),
                _navItem(3, Icons.shopping_bag_outlined, 'Mis pedidos'),
                _navItem(4, Icons.person_outline_rounded, 'Perfil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _centerYButton() {
    return GestureDetector(
      onTap: () => onTap(2),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF02172D),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF0075FF), width: 2.0),
          boxShadow: YavaUiTokens.neonGlow(const Color(0xFF0075FF), blur: 14),
        ),
        child: const Center(
          child: Text(
            'Y',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = index == currentIndex;
    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFFE50914) : Colors.white54,
            size: 21,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFE50914) : Colors.white54,
              fontSize: 9.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}