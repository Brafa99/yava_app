import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:yava_delivery_driver/app/theme/app_colors.dart';

class DriverProfilePage extends StatefulWidget {
  const DriverProfilePage({super.key});

  static const routePath = '/driver/profile';

  @override
  State<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  bool _loggingOut = false;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  String get _displayName {
    final user = _currentUser;

    if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
      return user.displayName!.trim();
    }

    if (user?.email != null && user!.email!.contains('@')) {
      return user.email!.split('@').first;
    }

    return 'Conductor YAVÁ';
  }

  String get _email {
    return _currentUser?.email ?? 'Correo no disponible';
  }

  String get _uid {
    return _currentUser?.uid ?? 'UID no disponible';
  }

  String get _initials {
    final name = _displayName.trim();

    if (name.isEmpty) {
      return 'YA';
    }

    final parts = name.split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
            '${parts.last.substring(0, 1)}'
        .toUpperCase();
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
        ),
      );
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.sand,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Cerrar sesión',
            style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            '¿Quieres cerrar tu sesión de YAVÁ?',
            style: TextStyle(color: AppColors.mutedInk, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: AppColors.mutedInk,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await _logout();
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/driver/home');
    }
  }

  void _showComingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title estará disponible próximamente.'),
        backgroundColor: AppColors.navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;

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
            'Mi perfil',
            style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
          ),
          actions: [
            IconButton(
              tooltip: 'Cerrar sesión',
              onPressed: _loggingOut ? null : _confirmLogout,
              icon: const Icon(Icons.logout_rounded),
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: SafeArea(
          top: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildProfileHeader(user),
                    const SizedBox(height: 22),
                    _buildSectionTitle('Mi cuenta'),
                    const SizedBox(height: 10),
                    _buildMenuCard(
                      icon: Icons.person_outline_rounded,
                      iconBackground: AppColors.mist,
                      iconColor: AppColors.navy,
                      title: 'Datos personales',
                      subtitle: 'Información de tu cuenta YAVÁ',
                      onTap: () => _showPersonalData(),
                    ),
                    const SizedBox(height: 10),
                    _buildMenuCard(
                      icon: Icons.badge_outlined,
                      iconBackground: AppColors.sunrise.withOpacity(0.13),
                      iconColor: AppColors.sunrise,
                      title: 'Documentos',
                      subtitle: 'Licencia, SOAT y documentación',
                      trailing: _buildStatusChip(
                        label: 'Verificado',
                        color: AppColors.success,
                      ),
                      onTap: () {
                        context.go('/driver/documents');
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildMenuCard(
                      icon: Icons.directions_car_outlined,
                      iconBackground: AppColors.clay.withOpacity(0.12),
                      iconColor: AppColors.clay,
                      title: 'Mi vehículo',
                      subtitle: 'Vehículo registrado para trabajar',
                      onTap: () {
                        context.go('/driver/vehicles');
                      },
                    ),
                    const SizedBox(height: 22),
                    _buildSectionTitle('Operación'),
                    const SizedBox(height: 10),
                    _buildMenuCard(
                      icon: Icons.account_balance_wallet_outlined,
                      iconBackground: AppColors.sunrise.withOpacity(0.13),
                      iconColor: AppColors.sunrise,
                      title: 'Mi billetera',
                      subtitle: 'Saldo, comisiones y movimientos',
                      onTap: () {
                        context.go('/driver/wallet');
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildMenuCard(
                      icon: Icons.local_offer_outlined,
                      iconBackground: AppColors.mist,
                      iconColor: AppColors.navyLight,
                      title: 'Mis ofertas',
                      subtitle: 'Ofertas realizadas a clientes',
                      onTap: () {
                        context.go('/driver/offers');
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildMenuCard(
                      icon: Icons.history_rounded,
                      iconBackground: AppColors.mist.withOpacity(0.75),
                      iconColor: AppColors.navy,
                      title: 'Historial de viajes',
                      subtitle: 'Consulta tus servicios realizados',
                      onTap: () {
                        context.go('/driver/trips');
                      },
                    ),
                    const SizedBox(height: 22),
                    _buildSectionTitle('Preferencias'),
                    const SizedBox(height: 10),
                    _buildMenuCard(
                      icon: Icons.notifications_none_rounded,
                      iconBackground: AppColors.mist,
                      iconColor: AppColors.navy,
                      title: 'Notificaciones',
                      subtitle: 'Alertas y solicitudes de servicio',
                      trailing: _buildStatusChip(
                        label: 'Activas',
                        color: AppColors.success,
                      ),
                      onTap: () {
                        _showComingSoon('Notificaciones');
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildMenuCard(
                      icon: Icons.settings_outlined,
                      iconBackground: AppColors.mutedInk.withOpacity(0.10),
                      iconColor: AppColors.mutedInk,
                      title: 'Configuración',
                      subtitle: 'Preferencias de la aplicación',
                      onTap: () {
                        _showComingSoon('Configuración');
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildMenuCard(
                      icon: Icons.help_outline_rounded,
                      iconBackground: AppColors.navy.withOpacity(0.08),
                      iconColor: AppColors.navy,
                      title: 'Ayuda y soporte',
                      subtitle: 'Estamos para ayudarte',
                      onTap: () {
                        _showComingSoon('Ayuda y soporte');
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildDemoInfo(),
                    const SizedBox(height: 18),
                    _buildLogoutButton(),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'YAVÁ · Movilidad con identidad chiquitana',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.mutedInk,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.15),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -45,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.mist.withOpacity(0.10),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -80,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.navyLight.withOpacity(0.25),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatar(user),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.72),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.30),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 8, color: AppColors.success),
                          SizedBox(width: 6),
                          Text(
                            'Conductor activo',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(User? user) {
    final photoUrl = user?.photoURL;

    if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      return Container(
        width: 74,
        height: 74,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.mist.withOpacity(0.75), width: 2),
          image: DecorationImage(
            image: NetworkImage(photoUrl),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.mist,
        border: Border.all(color: AppColors.mist.withOpacity(0.8), width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: const TextStyle(
          color: AppColors.navy,
          fontSize: 23,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          decoration: BoxDecoration(
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
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 23),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.mutedInk,
                        fontSize: 11.5,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (trailing != null)
                trailing
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.mutedInk,
                  size: 23,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.navy.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.navy.withOpacity(0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: AppColors.navy,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cuenta protegida',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tu identidad y acceso se gestionan mediante Firebase Authentication.',
                  style: TextStyle(
                    color: AppColors.mutedInk,
                    fontSize: 11.5,
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

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: _loggingOut ? null : _confirmLogout,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: BorderSide(color: AppColors.error.withOpacity(0.35)),
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        icon: _loggingOut
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.error,
                ),
              )
            : const Icon(Icons.logout_rounded, size: 20),
        label: Text(
          _loggingOut ? 'Cerrando sesión...' : 'Cerrar sesión',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  void _showPersonalData() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.sand,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.mutedInk.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Datos personales',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                _buildDataRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Nombre',
                  value: _displayName,
                ),
                const SizedBox(height: 12),
                _buildDataRow(
                  icon: Icons.email_outlined,
                  label: 'Correo',
                  value: _email,
                ),
                const SizedBox(height: 12),
                _buildDataRow(
                  icon: Icons.fingerprint_rounded,
                  label: 'ID de usuario',
                  value: _uid,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                    },
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(fontWeight: FontWeight.w800),
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

  Widget _buildDataRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.navy, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.mutedInk,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
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
