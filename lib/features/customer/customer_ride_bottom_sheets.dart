import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yava_delivery_driver/features/customer/application/customer_ride_flow_controller.dart';
import 'package:yava_delivery_driver/features/transport/models/ride_requests_model.dart';
import '../../../../shared/widgets/yava_swipe_button.dart';

// ==========================================
// MOCKUP 1: ¿A dónde vas? (Seleccionar Destino)
// ==========================================
// ==========================================
// MOCKUP 1: ¿A dónde vas? (Con Tarifario Demo Cochabamba)
// ==========================================
class CustomerSelectingDestinationSheet extends StatelessWidget {
  final CustomerRideFlowController controller;

  const CustomerSelectingDestinationSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Tarifario Demo - Coordenadas base en Cochabamba (Surtidor simulado cerca del centro)
    final double originLat = -17.3895;
    final double originLng = -66.1568;
    
    // Lista de los 8 destinos de tu imagen con coordenadas esparcidas por Cochabamba
    final destinos = [
      {'name': 'Barrio San Jorge', 'price': 5.50, 'lat': -17.3980, 'lng': -66.1450},
      {'name': 'Barrio Belén', 'price': 5.50, 'lat': -17.3750, 'lng': -66.1620},
      {'name': 'Comunidad Guayaba', 'price': 6.00, 'lat': -17.4100, 'lng': -66.1300},
      {'name': 'Comunidad Limoncito', 'price': 6.00, 'lat': -17.3600, 'lng': -66.1800},
      {'name': 'Barrio Villa Fátima', 'price': 6.00, 'lat': -17.4050, 'lng': -66.1700},
      {'name': 'Comunidad Altamira', 'price': 6.00, 'lat': -17.3800, 'lng': -66.1200},
      {'name': 'Comunidad Porvenir', 'price': 7.00, 'lat': -17.4200, 'lng': -66.1900},
      {'name': 'Aserradero San Antonio', 'price': 8.00, 'lat': -17.3500, 'lng': -66.1400},
    ];

    return _BaseSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('¿A dónde\nvas hoy?', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.1, color: Color(0xFF081528))),
          const SizedBox(height: 8),
          const Text('Selecciona tu destino (Desde Surtidor)', style: TextStyle(fontSize: 16, color: Colors.black54)),
          const SizedBox(height: 16),

          // Lista scrolleable de destinos
          SizedBox(
            height: 300, // Altura fija para que la tarjeta no ocupe toda la pantalla
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: destinos.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
              itemBuilder: (context, index) {
                final dest = destinos[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.location_on, color: Color(0xFFE50914)),
                  ),
                  title: Text(dest['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  subtitle: Text('Tarifa base: Bs. ${dest['price'].toStringAsFixed(2)}', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black26),
                  onTap: () {
                    // 1. Guardamos el Origen (Surtidor ficticio)
                    controller.setOrigin(originLat, originLng, 'Surtidor (Origen)');
                    
                    // 2. Guardamos el precio temporal en el controlador
                    controller.updateOfferedFare(dest['price']);
                    
                    // 3. Establecemos el Destino (Avanza automáticamente al Mockup 2 y dibuja la línea)
                    controller.setDestination(dest['lat'], dest['lng'], dest['name']);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// MOCKUP 2: Elegir Categoría (Auto, Moto...)
// ==========================================
class CustomerSelectingCategorySheet extends StatefulWidget {
  final CustomerRideFlowController controller;
  const CustomerSelectingCategorySheet({super.key, required this.controller});

  @override
  State<CustomerSelectingCategorySheet> createState() =>
      _CustomerSelectingCategorySheetState();
}

class _CustomerSelectingCategorySheetState
    extends State<CustomerSelectingCategorySheet> {
  int _selectedCat = 1;

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Cómo quieres\nviajar hoy?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.1,
              color: Color(0xFF081528),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Elige la opción que mejor se\nadapte a tus necesidades.',
            style: TextStyle(fontSize: 15, color: Colors.black54),
          ),
          const SizedBox(height: 20),

          // Grid de Vehículos
          SizedBox(
            height: 230,
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _VehicleCard(
                  id: 1,
                  title: 'Auto',
                  subtitle: 'Económico y cómodo',
                  icon: Icons.directions_car_rounded,
                  isSelected: _selectedCat == 1,
                  onTap: () => setState(() => _selectedCat = 1),
                ),
                _VehicleCard(
                  id: 2,
                  title: 'Moto',
                  subtitle: 'Más rápido en ciudad',
                  icon: Icons.two_wheeler_rounded,
                  isSelected: _selectedCat == 2,
                  onTap: () => setState(() => _selectedCat = 2),
                ),
              ],
            ),
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE50914),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => widget.controller.setCategory(
                _selectedCat,
                28.0,
              ), // Fija tarifa inicial simulada
              child: const Text(
                'Siguiente',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// MOCKUP 3: Confirmar Viaje (Oferta)
// ==========================================
class CustomerConfirmingTripSheet extends StatelessWidget {
  final CustomerRideFlowController controller;
  final double tempFare;

  const CustomerConfirmingTripSheet({
    super.key,
    required this.controller,
    required this.tempFare,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confirma tu\nviaje',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              height: 1.1,
              color: Color(0xFF081528),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Revisa los detalles de tu viaje\nantes de solicitar un conductor.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _InfoColumn(
                icon: Icons.access_time_rounded,
                title: '12 min',
                subtitle: 'Tiempo est.',
              ),
              _InfoColumn(
                icon: Icons.route_rounded,
                title: '5.8 km',
                subtitle: 'Distancia',
              ),
              _InfoColumn(
                icon: Icons.monetization_on_rounded,
                title: 'Bs ${tempFare.toStringAsFixed(0)}',
                subtitle: 'Tarifa',
                isHighlight: true,
              ),
            ],
          ),
          const SizedBox(height: 20),

          _ActionRow(
            icon: Icons.money_rounded,
            title: 'Efectivo',
            subtitle: 'Pago al finalizar el viaje',
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE50914),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () =>
                  controller.createRideRequest(), // Ejecuta el POST a Laravel
              child: const Text(
                'Confirmar viaje',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// MOCKUP 4: Buscando Driver y Recibiendo Ofertas
// ==========================================
class CustomerSearchingDriverSheet extends ConsumerWidget {
  const CustomerSearchingDriverSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(customerRideFlowProvider);
    final controller = ref.read(customerRideFlowProvider.notifier);
    final offers = flowState.rideOffers;

    return _BaseSheet(
      child: Column(
        children: [
          if (offers.isEmpty) ...[
            // 1. ESTADO: Buscando (Radar girando)
            const CircularProgressIndicator(color: Color(0xFFE50914)),
            const SizedBox(height: 20),
            const Text('Esperando ofertas de conductores...', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () {}, // Lógica de cancelar viaje si deseas
                child: const Text('Cancelar solicitud', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ] else ...[
            // 2. ESTADO: ¡Llegó una oferta del Driver!
            const Text('¡Un conductor ofreció llevarte!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF081528))),
            const SizedBox(height: 16),
            
            // Lista de ofertas (Normalmente es 1 en la demo)
            ...offers.map((offer) {
              // Ajusta las llaves según el JSON que te devuelva Laravel (ej. offer['driver']['name'])
              final driverName = offer['driver']?['name'] ?? 'Conductor YAVÁ';
              final price = offer['offered_price'] ?? 0.0;
              final offerId = offer['id'];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF0075FF)),
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFF0075FF).withOpacity(0.05),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(backgroundColor: Color(0xFF0075FF), child: Icon(Icons.person, color: Colors.white)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(driverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Oferta: Bs ${price.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF081528), fontWeight: FontWeight.w900, fontSize: 15)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0075FF), foregroundColor: Colors.white),
                      onPressed: () => controller.acceptDriverOffer(offerId), // ¡EL APRETÓN DE MANOS!
                      child: const Text('Aceptar'),
                    )
                  ],
                ),
              );
            }),
          ]
        ],
      ),
    );
  }
}

// ==========================================
// MOCKUP 5 Y 6: Conductor Aceptado / Llegando
// ==========================================
class CustomerDriverAcceptedSheet extends StatelessWidget {
  final RideRequestModel? ride;
  const CustomerDriverAcceptedSheet({super.key, this.ride});

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=11',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride?.driver?.name ?? 'Conductor YAVÁ',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      '★ 4.9 (328 viajes) • Toyota Rush',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.verified_user_rounded, color: Colors.blue),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CircleAction(icon: Icons.phone, text: 'Llamar'),
              _CircleAction(icon: Icons.chat_bubble_outline, text: 'Mensaje'),
              _CircleAction(icon: Icons.share, text: 'Compartir'),
              _CircleAction(icon: Icons.shield_outlined, text: 'Seguridad'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {},
              child: const Text(
                'Cancelar viaje',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// MOCKUP 7: Viaje en Curso (Customer)
// ==========================================
class CustomerInProgressSheet extends StatelessWidget {
  final RideRequestModel? ride;
  const CustomerInProgressSheet({super.key, this.ride});

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _InfoColumn(
                icon: Icons.access_time_rounded,
                title: '${ride?.estimatedTimeMinutes ?? 12} min',
                subtitle: 'Tiempo restante',
              ),
              _InfoColumn(
                icon: Icons.route_rounded,
                title: '${ride?.distanceKm ?? 5.8} km',
                subtitle: 'Distancia',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=11',
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ride?.driver?.name ?? 'Conductor YAVÁ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Toyota Rush Blanco',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              _CircleActionSmall(icon: Icons.phone),
              const SizedBox(width: 8),
              _CircleActionSmall(
                icon: Icons.shield_outlined,
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Botón Swipe rojo (Solo para emergencias / Finalizar por cliente)
          YavaSwipeButton(
            text: 'Finalizar viaje (Emergencia)',
            isRed: true,
            onCompleted:
                () {}, // Lógica para que el cliente aborte el viaje en curso
          ),
        ],
      ),
    );
  }
}

// ==========================================
// UTILIDADES UI (Comunes para todas las tarjetas)
// ==========================================

class _BaseSheet extends StatelessWidget {
  final Widget child;
  const _BaseSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isRed;
  final bool showArrow;

  const _LocationRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isRed,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: isRed ? const Color(0xFFE50914) : const Color(0xFF0075FF),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ],
          ),
        ),
        if (showArrow)
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.black26,
            size: 16,
          ),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final int id;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _VehicleCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE50914).withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFE50914) : Colors.black12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? const Color(0xFFE50914) : Colors.black87,
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.black54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isHighlight;

  const _InfoColumn({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: isHighlight ? const Color(0xFF081528) : Colors.black54,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isHighlight ? 18 : 16,
            color: isHighlight ? const Color(0xFF081528) : Colors.black87,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.edit, color: Colors.black26, size: 18),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final String text;
  const _CircleAction({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black12),
          ),
          child: Icon(icon, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _CircleActionSmall extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _CircleActionSmall({required this.icon, this.color = Colors.black87});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
