import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:yava_delivery_driver/features/transport/transport_service.dart';

import '../../../app/theme/app_colors.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const navy = Color.fromARGB(255, 26, 59, 102);
  static const navyLight = Color.fromARGB(255, 50, 93, 148);
  static const Color petroleum = Color(0xFF0F4C5C);
  static const Color coral = Color(0xFFFF6B57);
  static const Color mint = Color(0xFF397D72);
  static const Color lightGray = Color(0xFFE9EEF1);
  static const Color muted = Color(0xFF64757B);

  bool _available = false;
  bool _loggingOut = false;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _initializeWallet();
  }

  Future<void> _initializeWallet() async {
    final user = _currentUser;

    if (user == null) return;

    try {
      await TransportService().ensureDriverWallet(user.uid);
    } catch (_) {
      // El Home continúa funcionando aunque la inicialización
      // de la billetera falle temporalmente.
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> get _walletStream {
    final user = _currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _firestore.collection('driver_wallets').doc(user.uid).snapshots();
  }

  Future<void> _logout() async {
    if (_loggingOut) return;

    setState(() {
      _loggingOut = true;
    });

    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      context.go('/login');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loggingOut = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo cerrar sesión: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showLogoutDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Cerrar sesión',
            style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w900),
          ),
          content: const Text(
            '¿Quieres cerrar tu sesión de YAVÁ Driver?',
            style: TextStyle(color: AppColors.mutedInk, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar', style: TextStyle(color: navyLight)),
            ),
            ElevatedButton(
              onPressed: _loggingOut
                  ? null
                  : () async {
                      Navigator.of(dialogContext).pop();
                      await _logout();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoon(String title) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$title estará disponible próximamente.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.navy,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;

    final displayName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : 'Conductor';

    return Scaffold(
      backgroundColor: AppColors.sand,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(displayName)),

            SliverToBoxAdapter(child: _buildAvailabilityCard()),

            SliverToBoxAdapter(child: _buildWalletCard()),

            SliverToBoxAdapter(child: _buildOperationSection()),

            SliverToBoxAdapter(child: _buildFooter()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String displayName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: navy,
              borderRadius: BorderRadius.circular(17),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withOpacity(0.16),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.navigation_rounded,
              color: AppColors.white,
              size: 27,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Image.asset(
                    'assets/logo_yava_bg.png',
                    height: 42,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'YAVÁ',
                          style: TextStyle(
                            color: navy,
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hola, $displayName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.mutedInk,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          _headerButton(
            icon: Icons.person_outline_rounded,
            onPressed: () {
              context.go('/driver/profile');
            },
          ),

          const SizedBox(width: 7),

          _headerButton(
            icon: Icons.logout_rounded,
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
    );
  }

  Widget _headerButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: navy, size: 21),
        ),
      ),
    );
  }

  Widget _buildAvailabilityCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          color: _available ? AppColors.navy : AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _available ? AppColors.navy : AppColors.mist,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _available
                    ? AppColors.white.withOpacity(0.13)
                    : AppColors.mist,
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(
                _available
                    ? Icons.radio_button_checked_rounded
                    : Icons.pause_circle_outline_rounded,
                color: _available ? AppColors.sunrise : AppColors.warning,
                size: 27,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _available ? 'Estás disponible' : 'Estás fuera de línea',
                    style: TextStyle(
                      color: _available ? AppColors.white : navyLight,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _available
                        ? 'Recibirás solicitudes cercanas.'
                        : 'Actívate para comenzar a recibir viajes.',
                    style: TextStyle(
                      color: _available ? const Color(0xFFD9E9DD) : navyLight,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            Switch.adaptive(
              value: _available,
              activeColor: AppColors.sunrise,
              activeTrackColor: AppColors.sunrise.withOpacity(0.35),
              onChanged: (value) {
                setState(() {
                  _available = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _walletStream,
        builder: (context, snapshot) {
          final data = snapshot.data?.data();

          final balance = data?['balance'] is num
              ? (data!['balance'] as num).toDouble()
              : 100.0;

          final totalCommission = data?['totalCommission'] is num
              ? (data!['totalCommission'] as num).toDouble()
              : 0.0;

          return Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            child: InkWell(
              onTap: () {
                context.go('/driver/wallet');
              },
              borderRadius: BorderRadius.circular(26),
              child: Container(
                decoration: BoxDecoration(
                  color: navy,

                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: navy.withOpacity(0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Stack(
                    children: [
                      // Fondo decorativo pastel.
                      Positioned(
                        right: -55,
                        top: -65,
                        child: Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            color: AppColors.mist.withOpacity(0.13),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),

                      Positioned(
                        right: 35,
                        bottom: -85,
                        child: Container(
                          width: 145,
                          height: 145,
                          decoration: BoxDecoration(
                            color: AppColors.navyLight.withOpacity(0.28),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(21),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: AppColors.mist.withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: AppColors.white.withOpacity(0.08),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet_rounded,
                                    color: AppColors.sunrise,
                                    size: 24,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Billetera YAVÁ',
                                        style: TextStyle(
                                          color: AppColors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        'Saldo disponible',
                                        style: TextStyle(
                                          color: AppColors.mist,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.sunrise.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.sunrise.withOpacity(
                                        0.18,
                                      ),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.lock_rounded,
                                        color: AppColors.sunrise,
                                        size: 14,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'Activo',
                                        style: TextStyle(
                                          color: AppColors.sunrise,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 22),

                            // Saldo principal.
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Bs',
                                  style: TextStyle(
                                    color: AppColors.sunrise,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  balance.toStringAsFixed(2),
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            Container(
                              height: 1,
                              color: AppColors.white.withOpacity(0.10),
                            ),

                            const SizedBox(height: 15),

                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.sunrise.withOpacity(0.13),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.percent_rounded,
                                    color: AppColors.sunrise,
                                    size: 17,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Comisiones acumuladas',
                                        style: TextStyle(
                                          color: AppColors.mist,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        '20% por servicio completado',
                                        style: TextStyle(
                                          color: AppColors.mist,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Text(
                                  'Bs ${totalCommission.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOperationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Operación',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Todo lo que necesitas para trabajar con YAVÁ.',
            style: TextStyle(color: navyLight, fontSize: 13),
          ),

          const SizedBox(height: 17),

          Row(
            children: [
              Expanded(
                child: _operationCard(
                  title: 'Solicitudes',
                  subtitle: 'Viajes cercanos',
                  icon: Icons.near_me_rounded,
                  color: AppColors.clay,
                  onTap: () {
                    context.go('/driver/requests');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _operationCard(
                  title: 'Viaje activo',
                  subtitle: 'Ver recorrido',
                  icon: Icons.navigation_rounded,
                  color: AppColors.sunrise,
                  onTap: () {
                    context.go('/driver/tracking');
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _operationCard(
                  title: 'Mi vehículo',
                  subtitle: 'Administrar',
                  icon: Icons.local_shipping_outlined,
                  color: AppColors.navyLight,
                  onTap: () {
                    context.go('/driver/vehicles');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _operationCard(
                  title: 'Documentos',
                  subtitle: 'Verificación',
                  icon: Icons.verified_user_outlined,
                  color: AppColors.success,
                  onTap: () {
                    context.go('/driver/documents');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _operationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Container(
          constraints: const BoxConstraints(minHeight: 128),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: AppColors.mist),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 23),
              ),

              const Spacer(),

              const SizedBox(height: 13),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: navyLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: navyLight, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.sunrise,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'YAVÁ Driver • Muévete a tu manera',
            style: TextStyle(
              color: navyLight,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
