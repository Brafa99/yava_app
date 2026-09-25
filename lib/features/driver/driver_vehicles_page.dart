import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:yava_delivery_driver/app/theme/app_colors.dart';

class DriverVehiclesPage extends StatelessWidget {
  const DriverVehiclesPage({super.key});

  static const routePath = '/driver/vehicles';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/driver/home');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.sand,
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          foregroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/driver/home');
              }
            },
          ),
          title: const Text(
            'Mi vehículo',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19),
          ),
        ),
        body: user == null
            ? const _VehicleMockView()
            : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('driver_vehicles')
                    .doc(user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const _VehicleMockView();
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.navyLight,
                      ),
                    );
                  }

                  final data = snapshot.data?.data();

                  if (data == null) {
                    return const _VehicleMockView();
                  }

                  return _VehicleView(data: data);
                },
              ),
      ),
    );
  }
}

class _VehicleView extends StatelessWidget {
  const _VehicleView({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        _VehicleHero(
          brand: _string(data['brand'], 'Toyota'),
          model: _string(data['model'], 'Corolla'),
          plate: _string(data['plate'], 'YAV-001'),
          color: _string(data['color'], 'Blanco'),
        ),
        const SizedBox(height: 18),
        _VehicleInfoCard(data: data),
        const SizedBox(height: 16),
        const _VehicleStatusCard(),
      ],
    );
  }
}

class _VehicleMockView extends StatelessWidget {
  const _VehicleMockView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        const _VehicleHero(
          brand: 'Toyota',
          model: 'Corolla',
          plate: 'YAV-001',
          color: 'Blanco',
        ),
        const SizedBox(height: 18),
        const _VehicleInfoCard(
          data: {
            'year': 2022,
            'color': 'Blanco',
            'type': 'Automóvil',
            'capacity': 4,
          },
        ),
        const SizedBox(height: 16),
        const _VehicleStatusCard(),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.mist,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.navyLight),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Esta información puede conectarse directamente '
                  'con el perfil del conductor en Firestore.',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 11,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VehicleHero extends StatelessWidget {
  const _VehicleHero({
    required this.brand,
    required this.model,
    required this.plate,
    required this.color,
  });

  final String brand;
  final String model;
  final String plate;
  final String color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.navyLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.mist.withOpacity(0.95),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_car_filled_rounded,
              color: AppColors.navy,
              size: 38,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            '$brand $model',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            color,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.sunrise.withOpacity(0.16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.sunrise.withOpacity(0.25)),
            ),
            child: Text(
              plate,
              style: const TextStyle(
                color: AppColors.sunrise,
                fontSize: 14,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleInfoCard extends StatelessWidget {
  const _VehicleInfoCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mist),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información del vehículo',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 15),
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            title: 'Año',
            value: _string(data['year'], '2022'),
          ),
          _InfoRow(
            icon: Icons.palette_outlined,
            title: 'Color',
            value: _string(data['color'], 'Blanco'),
          ),
          _InfoRow(
            icon: Icons.directions_car_rounded,
            title: 'Tipo',
            value: _string(data['type'], 'Automóvil'),
          ),
          _InfoRow(
            icon: Icons.people_alt_outlined,
            title: 'Capacidad',
            value: '${data['capacity'] ?? 4} pasajeros',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Icon(icon, color: AppColors.navyLight, size: 19),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.mutedInk,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleStatusCard extends StatelessWidget {
  const _VehicleStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.mist),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_rounded, color: AppColors.success, size: 25),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vehículo habilitado',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Tu vehículo está habilitado para operar.',
                  style: TextStyle(
                    color: AppColors.mutedInk,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _string(dynamic value, String fallback) {
  if (value == null || value.toString().trim().isEmpty) {
    return fallback;
  }

  return value.toString();
}
