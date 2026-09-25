import 'package:flutter/material.dart';

import 'package:yava_delivery_driver/app/theme/app_colors.dart';

class CustomerQuickRequestPage extends StatefulWidget {
  const CustomerQuickRequestPage({super.key, required this.service});

  final String service;

  @override
  State<CustomerQuickRequestPage> createState() =>
      _CustomerQuickRequestPageState();
}

class _CustomerQuickRequestPageState extends State<CustomerQuickRequestPage> {
  final TextEditingController _destinationController = TextEditingController();

  int _step = 0;
  String? _selectedDestination;

  final List<_MockDriver> _drivers = const [
    _MockDriver(
      name: 'Carlos M.',
      rating: 4.9,
      vehicle: 'Toyota Prius • Blanco',
      price: 18,
      eta: '3 min',
    ),
    _MockDriver(
      name: 'María R.',
      rating: 4.8,
      vehicle: 'Suzuki Swift • Gris',
      price: 21,
      eta: '5 min',
    ),
    _MockDriver(
      name: 'Luis A.',
      rating: 4.7,
      vehicle: 'Toyota Corolla • Negro',
      price: 24,
      eta: '7 min',
    ),
  ];

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  String get _serviceName {
    switch (widget.service) {
      case 'moto':
        return 'Moto';
      default:
        return 'Taxi';
    }
  }

  IconData get _serviceIcon {
    switch (widget.service) {
      case 'moto':
        return Icons.two_wheeler_rounded;
      default:
        return Icons.local_taxi_rounded;
    }
  }

  void _continue() {
    final destination = _destinationController.text.trim();

    if (destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona o escribe un destino.')),
      );
      return;
    }

    setState(() {
      _selectedDestination = destination;
      _step = 1;
    });
  }

  void _selectDestination(String value) {
    _destinationController.text = value;

    setState(() {
      _selectedDestination = value;
    });
  }

  void _selectDriver(_MockDriver driver) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Solicitud preparada',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Text(
            '${_serviceName} seleccionado.\n\n'
            'Destino: $_selectedDestination\n\n'
            'Conductor: ${driver.name}\n'
            'Precio estimado: Bs ${driver.price.toStringAsFixed(0)}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Solicitud de $_serviceName preparada.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Solicitar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        title: Text(
          _step == 0 ? 'Nueva solicitud' : 'Conductores cercanos',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _step == 0 ? _buildDestinationStep() : _buildDriversStep(),
      ),
    );
  }

  Widget _buildDestinationStep() {
    return SingleChildScrollView(
      key: const ValueKey('destination'),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceHeader(),
          const SizedBox(height: 22),
          const Text(
            '¿A dónde vamos?',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Selecciona tu destino para buscar opciones disponibles.',
            style: TextStyle(color: AppColors.mutedInk, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.mist),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.my_location_rounded,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Origen',
                            style: TextStyle(
                              color: AppColors.mutedInk,
                              fontSize: 11,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Tu ubicación actual',
                            style: TextStyle(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.clay,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _destinationController,
                        decoration: const InputDecoration(
                          labelText: 'Destino',
                          hintText: 'Ej. Plaza 24 de Septiembre',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Destinos sugeridos',
            style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          _destinationOption(
            Icons.location_city_rounded,
            'Plaza 24 de Septiembre',
            'Centro',
          ),
          _destinationOption(
            Icons.shopping_bag_outlined,
            'Ventura Mall',
            'Equipetrol',
          ),
          _destinationOption(
            Icons.local_hospital_outlined,
            'Hospital Japonés',
            'Santa Cruz',
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _continue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              child: const Text(
                'Buscar conductores',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: AppColors.navy,
              shape: BoxShape.circle,
            ),
            child: Icon(_serviceIcon, color: AppColors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Servicio seleccionado',
                  style: TextStyle(color: AppColors.mutedInk, fontSize: 11),
                ),
                Text(
                  _serviceName,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: AppColors.success),
        ],
      ),
    );
  }

  Widget _destinationOption(IconData icon, String title, String subtitle) {
    return Card(
      elevation: 0,
      color: AppColors.white,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: () => _selectDestination(title),
        leading: Icon(icon, color: AppColors.navyLight),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.mutedInk,
        ),
      ),
    );
  }

  Widget _buildDriversStep() {
    return ListView(
      key: const ValueKey('drivers'),
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.mist,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.clay),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Destino',
                      style: TextStyle(color: AppColors.mutedInk, fontSize: 11),
                    ),
                    Text(
                      _selectedDestination ?? '',
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _step = 0;
                  });
                },
                child: const Text('Cambiar'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Opciones disponibles',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Conductores de ejemplo para la demostración.',
          style: TextStyle(color: AppColors.mutedInk),
        ),
        const SizedBox(height: 15),
        ..._drivers.map(_driverCard),
      ],
    );
  }

  Widget _driverCard(_MockDriver driver) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: AppColors.mist,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded, color: AppColors.navy),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver.name,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    driver.vehicle,
                    style: const TextStyle(
                      color: AppColors.mutedInk,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.sunrise,
                        size: 16,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        driver.rating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${driver.eta} de dist.',
                        style: const TextStyle(
                          color: AppColors.mutedInk,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Bs ${driver.price}',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                ElevatedButton(
                  onPressed: () => _selectDriver(driver),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(88, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: const Text(
                    'Elegir',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MockDriver {
  const _MockDriver({
    required this.name,
    required this.rating,
    required this.vehicle,
    required this.price,
    required this.eta,
  });

  final String name;
  final double rating;
  final String vehicle;
  final int price;
  final String eta;
}
