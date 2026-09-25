import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yava_delivery_driver/features/transport/customer_quick_request_page.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  static const routeName = 'customer-home';
  static const routePath = '/customer/home';

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage>
    with SingleTickerProviderStateMixin {
  static const navy = Color.fromARGB(255, 26, 59, 102);
  static const navyLight = Color.fromARGB(255, 50, 93, 148);
  static const Color coral = Color(0xFFFF6B57);
  static const Color mint = Color(0xFF397D72);
  static const Color lightGray = Color(0xFFE9EEF1);
  static const Color muted = Color(0xFF64757B);

  late final AnimationController _bannerController;
  late final Animation<double> _bannerScale;
  late final Animation<double> _bannerFade;

  @override
  void initState() {
    super.initState();

    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _bannerScale = CurvedAnimation(
      parent: _bannerController,
      curve: Curves.easeOutBack,
    );

    _bannerFade = CurvedAnimation(
      parent: _bannerController,
      curve: Curves.easeOut,
    );

    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) {
        _bannerController.forward();
      }
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroBanner(context),
                    const SizedBox(height: 16),
                    _buildLocationCard(context),
                    const SizedBox(height: 20),
                    _buildSectionTitle('¿Qué necesitas hoy?'),
                    const SizedBox(height: 11),
                    _buildServicesGrid(context),
                    const SizedBox(height: 22),
                    _buildSectionTitle('Servicios populares'),
                    const SizedBox(height: 10),
                    _buildPopularService(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 5),
      child: Row(
        children: [
          _HeaderButton(
            icon: Icons.menu_rounded,
            onTap: () {
              _showMenu(context);
            },
          ),
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
          _HeaderButton(
            icon: Icons.notifications_rounded,
            onTap: () {
              context.push('/notifications');
            },
            showDot: true,
          ),
          const SizedBox(width: 3),
          _buildProfileAvatar(),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MenuAction(
                  icon: Icons.receipt_long_rounded,
                  title: 'Mis solicitudes',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/requests');
                  },
                ),
                _MenuAction(
                  icon: Icons.workspace_premium_rounded,
                  title: 'Beneficios',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/benefits');
                  },
                ),
                _MenuAction(
                  icon: Icons.person_rounded,
                  title: 'Mi perfil',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/customer/profile');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 39,
      height: 39,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE8EEF0),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.person_rounded, color: navyLight, size: 22),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return FadeTransition(
      opacity: _bannerFade,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.94, end: 1).animate(_bannerScale),
        child: Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(blurRadius: 18, offset: const Offset(0, 7))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/chiquitania_home.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [navy, navyLight, mint],
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [navy, navyLight, navyLight],
                    ),
                  ),
                ),
                Positioned(
                  right: -24,
                  top: -35,
                  child: Container(
                    width: 125,
                    height: 125,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: coral.withValues(alpha: 0.16),
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  top: 22,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded, color: coral, size: 15),
                        SizedBox(width: 4),
                        Text(
                          'Muévete fácil',
                          style: TextStyle(
                            color: navy,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Positioned(
                  left: 17,
                  top: 23,
                  child: Text(
                    'Tu próximo viaje\nempieza aquí.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      height: 1.02,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                Positioned(
                  left: 17,
                  bottom: 18,
                  child: GestureDetector(
                    onTap: () {
                      context.push('/customer/new-request');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: coral,
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: coral.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Solicitar ahora',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 10, 9),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F3F1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.my_location_rounded,
                    color: navyLight,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tu ubicación actual',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Concepción, Santa Cruz',
                        style: TextStyle(
                          fontSize: 13,
                          color: navy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: const Color(0xFFF0F5F4),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () {},
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.gps_fixed_rounded,
                        color: navyLight,
                        size: 17,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: lightGray),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                context.push('/customer/new-request');
              },
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(19),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 11, 11, 11),
                child: Row(
                  children: [
                    Container(
                      width: 29,
                      height: 29,
                      decoration: BoxDecoration(
                        color: coral.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: coral,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        '¿A dónde vamos?',
                        style: TextStyle(
                          fontSize: 13,
                          color: navy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: navy,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: navy,
        fontSize: 16,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    final services = [
      const _ServiceItem(
        icon: Icons.local_taxi_rounded,
        label: 'Taxi',
        dark: true,
      ),
      const _ServiceItem(
        icon: Icons.two_wheeler_rounded,
        label: 'Moto',
        dark: true,
      ),
      const _ServiceItem(
        icon: Icons.delivery_dining_rounded,
        label: 'Delivery',
        dark: true,
      ),
      const _ServiceItem(
        icon: Icons.inventory_2_rounded,
        label: 'Encomienda',
        dark: true,
      ),
      const _ServiceItem(
        icon: Icons.local_shipping_rounded,
        label: 'Viajes',
        dark: true,
      ),
      const _ServiceItem(
        icon: Icons.apps_rounded,
        label: 'Más servicios',
        dark: false,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.02,
      ),
      itemBuilder: (context, index) {
        return _AnimatedServiceTile(
          service: services[index],
          index: index,
          onTap: () {
            _handleServiceTap(context, services[index]);
          },
        );
      },
    );
  }

  void _handleServiceTap(BuildContext context, _ServiceItem service) {
    if (service.label == 'Taxi') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const CustomerQuickRequestPage(service: 'taxi'),
        ),
      );
      return;
    }

    if (service.label == 'Moto') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const CustomerQuickRequestPage(service: 'moto'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 85),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: navy,
        content: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: coral, size: 19),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                '${service.label} estará disponible próximamente.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularService(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/customer/new-request');
      },
      child: Container(
        height: 118,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          color: navyLight,
          boxShadow: [
            BoxShadow(
              color: navyLight.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/chiquitania_home.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [navyLight, mint],
                      ),
                    ),
                  );
                },
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xE0072D36),
                      Color(0x60072D36),
                      Color(0x15072D36),
                    ],
                  ),
                ),
              ),
              const Positioned(
                left: 16,
                top: 17,
                child: Text(
                  'Recorre la Chiquitanía\ncon YAVÁ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Positioned(
                left: 17,
                bottom: 18,
                child: Row(
                  children: [
                    Icon(Icons.explore_rounded, color: coral, size: 16),
                    SizedBox(width: 5),
                    Text(
                      'Descubre tu próximo destino',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 14,
                bottom: 14,
                child: Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.16),
                        blurRadius: 9,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: navy,
                    size: 21,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      height: 69,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _bottomItem(
              icon: Icons.home_rounded,
              label: 'Inicio',
              active: true,
              onTap: () {},
            ),
          ),
          Expanded(
            child: _bottomItem(
              icon: Icons.assignment_outlined,
              label: 'Actividad',
              onTap: () {
                context.push('/customer/trips');
              },
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: navy,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: navy.withValues(alpha: 0.27),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/images/logo_icon.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return const Icon(
                          Icons.location_on_rounded,
                          color: coral,
                          size: 28,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _bottomItem(
              icon: Icons.workspace_premium_outlined,
              label: 'Beneficios',
              onTap: () {
                context.push('/benefits');
              },
            ),
          ),
          Expanded(
            child: _bottomItem(
              icon: Icons.person_outline_rounded,
              label: 'Perfil',
              onTap: () {
                context.push('/customer/profile');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: active ? 1.06 : 1,
              duration: const Duration(milliseconds: 180),
              child: Icon(
                icon,
                size: 21,
                color: active ? coral : const Color(0xFF66777C),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: active ? coral : const Color(0xFF66777C),
                fontSize: 8.5,
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.onTap,
    this.showDot = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: Icon(icon, color: _CustomerHomePageState.navy, size: 23),
            ),
          ),
        ),
        if (showDot)
          Positioned(
            right: 7,
            top: 5,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: _CustomerHomePageState.coral,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _AnimatedServiceTile extends StatefulWidget {
  const _AnimatedServiceTile({
    required this.service,
    required this.index,
    required this.onTap,
  });

  final _ServiceItem service;
  final int index;
  final VoidCallback onTap;

  @override
  State<_AnimatedServiceTile> createState() => _AnimatedServiceTileState();
}

class _AnimatedServiceTileState extends State<_AnimatedServiceTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final service = widget.service;

    return AnimatedScale(
      scale: _pressed ? 0.94 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Material(
        color: service.dark ? _CustomerHomePageState.navy : Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: service.dark ? 1 : 2,
        shadowColor: Colors.black.withValues(alpha: 0.11),
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) {
            setState(() {
              _pressed = true;
            });
          },
          onTapCancel: () {
            setState(() {
              _pressed = false;
            });
          },
          onTapUp: (_) {
            setState(() {
              _pressed = false;
            });
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: _CustomerHomePageState.coral.withValues(alpha: 0.16),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: service.dark
                        ? Colors.white.withValues(alpha: 0.10)
                        : const Color(0xFFF0F5F4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    service.icon,
                    size: 26,
                    color: service.dark
                        ? Colors.white
                        : _CustomerHomePageState.navy,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  service.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: service.dark
                        ? Colors.white
                        : _CustomerHomePageState.navy,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuAction extends StatelessWidget {
  const _MenuAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF2F0),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: _CustomerHomePageState.navyLight, size: 21),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: _CustomerHomePageState.navy,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: _CustomerHomePageState.muted,
      ),
      onTap: onTap,
    );
  }
}

class _ServiceItem {
  const _ServiceItem({
    required this.icon,
    required this.label,
    required this.dark,
  });

  final IconData icon;
  final String label;
  final bool dark;
}
