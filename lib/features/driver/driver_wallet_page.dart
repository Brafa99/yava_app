import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:yava_delivery_driver/app/theme/app_colors.dart';

class DriverWalletPage extends StatefulWidget {
  const DriverWalletPage({super.key});

  static const routePath = '/driver/wallet';

  @override
  State<DriverWalletPage> createState() => _DriverWalletPageState();
}

class _DriverWalletPageState extends State<DriverWalletPage> {
  User? get _currentUser => FirebaseAuth.instance.currentUser;

  Stream<DocumentSnapshot<Map<String, dynamic>>> get _walletStream {
    final user = _currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('driver_wallets')
        .doc(user.uid)
        .snapshots();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/driver/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.sand,
        appBar: AppBar(
          backgroundColor: AppColors.sand,
          foregroundColor: AppColors.ink,
          elevation: 0,
          leading: IconButton(
            tooltip: 'Volver',
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text(
            'Mi billetera',
            style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
          ),
        ),
        body: SafeArea(
          top: false,
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _walletStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.navy),
                );
              }

              final data = snapshot.data?.data();

              final balance = data?['balance'] is num
                  ? (data!['balance'] as num).toDouble()
                  : 100.0;

              final totalCommission = data?['totalCommission'] is num
                  ? (data!['totalCommission'] as num).toDouble()
                  : 0.0;

              final lastCommission = data?['lastCommission'] is num
                  ? (data!['lastCommission'] as num).toDouble()
                  : 0.0;

              final lastTripId = data?['lastTripId'];

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildBalanceCard(balance: balance),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Resumen'),
                        const SizedBox(height: 10),
                        _buildSummaryCards(
                          totalCommission: totalCommission,
                          lastCommission: lastCommission,
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Último movimiento'),
                        const SizedBox(height: 10),
                        _buildLastMovement(
                          lastCommission: lastCommission,
                          lastTripId: lastTripId,
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Cómo funciona'),
                        const SizedBox(height: 10),
                        _buildHowItWorks(),
                        const SizedBox(height: 24),
                        _buildAccountStatus(),
                        const SizedBox(height: 20),
                        _buildInfoNote(),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard({required double balance}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.18),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              right: -55,
              top: -65,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.mist.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -70,
              bottom: -90,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.navyLight.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.mist.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AppColors.sunrise,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 13),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Billetera YAVÁ',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Saldo disponible',
                              style: TextStyle(
                                color: AppColors.mist,
                                fontSize: 11,
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
                          color: AppColors.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.success.withOpacity(0.25),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.success,
                              size: 14,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Activa',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Saldo disponible',
                    style: TextStyle(
                      color: AppColors.mist,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Bs',
                        style: TextStyle(
                          color: AppColors.sunrise,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        balance.toStringAsFixed(2),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.2,
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
                  const Row(
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.sunrise,
                        size: 16,
                      ),
                      SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          'Tu saldo se actualiza automáticamente '
                          'al completar cada servicio.',
                          style: TextStyle(
                            color: AppColors.mist,
                            fontSize: 10.5,
                            height: 1.35,
                          ),
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.ink,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildSummaryCards({
    required double totalCommission,
    required double lastCommission,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.percent_rounded,
            iconColor: AppColors.sunrise,
            title: 'Comisiones',
            value: 'Bs ${totalCommission.toStringAsFixed(2)}',
            subtitle: 'Acumuladas',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.receipt_long_outlined,
            iconColor: AppColors.navyLight,
            title: 'Última',
            value: 'Bs ${lastCommission.toStringAsFixed(2)}',
            subtitle: 'Comisión',
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mutedInk.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.11),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(height: 13),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.mutedInk,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.mutedInk, fontSize: 9.5),
          ),
        ],
      ),
    );
  }

  Widget _buildLastMovement({
    required double lastCommission,
    required dynamic lastTripId,
  }) {
    final hasMovement =
        lastTripId != null && lastTripId.toString().trim().isNotEmpty;

    if (!hasMovement) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.mutedInk.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.history_rounded,
                color: AppColors.navy,
                size: 22,
              ),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sin movimientos todavía',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Cuando completes tu primer servicio, '
                    'aquí aparecerá la comisión correspondiente.',
                    style: TextStyle(
                      color: AppColors.mutedInk,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mutedInk.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.sunrise.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.arrow_downward_rounded,
              color: AppColors.sunrise,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Comisión de servicio',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Viaje: ${lastTripId.toString()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.mutedInk,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '- Bs ${lastCommission.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.navy.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          _buildInfoStep(
            number: '01',
            icon: Icons.local_taxi_outlined,
            title: 'Completas un servicio',
            description: 'El cliente paga el precio acordado por el viaje.',
          ),
          const SizedBox(height: 14),
          _buildInfoStep(
            number: '02',
            icon: Icons.percent_rounded,
            title: 'YAVÁ procesa el 20%',
            description:
                'La comisión de plataforma se calcula automáticamente.',
          ),
          const SizedBox(height: 14),
          _buildInfoStep(
            number: '03',
            icon: Icons.account_balance_wallet_outlined,
            title: 'Se actualiza tu saldo',
            description:
                'El saldo de tu billetera refleja la comisión procesada.',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoStep({
    required String number,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(13),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.navy, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    number,
                    style: const TextStyle(
                      color: AppColors.sunrise,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.mutedInk,
                  fontSize: 10.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountStatus() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: AppColors.success,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cuenta de conductor activa',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Tu billetera está habilitada para operar en YAVÁ.',
                  style: TextStyle(color: AppColors.mutedInk, fontSize: 10.5),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.navy.withOpacity(0.055),
        borderRadius: BorderRadius.circular(17),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.navy, size: 19),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Tu saldo inicial es de Bs 100. Las comisiones se '
              'descuentan automáticamente al completar cada viaje.',
              style: TextStyle(
                color: AppColors.mutedInk,
                fontSize: 10.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.error,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No pudimos cargar tu billetera',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.mutedInk, fontSize: 11),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => setState(() {}),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: AppColors.white,
              ),
              child: const Text(
                'Reintentar',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
