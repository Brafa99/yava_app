import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DriverOnboardingPage extends StatefulWidget {
  const DriverOnboardingPage({super.key});

  static const routeName = 'driver-onboarding';
  static const routePath = '/onboarding/driver';

  @override
  State<DriverOnboardingPage> createState() => _DriverOnboardingPageState();
}

class _DriverOnboardingPageState extends State<DriverOnboardingPage> {
  static const Color navy = Color(0xFF072D36);
  static const Color navyLight = Color(0xFF0F4C5C);
  static const Color coral = Color(0xFFFF6B57);
  static const Color muted = Color(0xFF718187);

  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<_DriverOnboardingItem> _pages = const [
    _DriverOnboardingItem(
      icon: Icons.local_shipping_rounded,
      title: 'Encuentra nuevas cargas',
      description:
          'Accede a solicitudes de transporte publicadas por clientes y ganaderos de la región.',
    ),
    _DriverOnboardingItem(
      icon: Icons.route_rounded,
      title: 'Organiza tus viajes',
      description:
          'Administra tus servicios, revisa destinos y mantén tus viajes organizados.',
    ),
    _DriverOnboardingItem(
      icon: Icons.payments_rounded,
      title: 'Genera nuevas oportunidades',
      description:
          'Envía tus ofertas, coordina con clientes y amplía tu red de trabajo en la Chiquitanía.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    } else {
      context.push('/register?role=driver');
    }
  }

  void _skip() {
    context.push('/register?role=driver');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: navy),
          ),
          const Spacer(),
          TextButton(
            onPressed: _skip,
            child: const Text(
              'Omitir',
              style: TextStyle(color: muted, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_DriverOnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              color: coral.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 174,
                  height: 174,
                  decoration: BoxDecoration(
                    color: coral.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: navy,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: Colors.white, size: 58),
                ),
                const Positioned(
                  right: 25,
                  top: 33,
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: coral,
                    size: 28,
                  ),
                ),
                const Positioned(
                  left: 29,
                  bottom: 39,
                  child: Icon(Icons.route_rounded, color: coral, size: 30),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: navy,
              fontSize: 26,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted, fontSize: 14, height: 1.55),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 10, 28, 25),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (index) {
              final isActive = index == _currentPage;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? coral : const Color(0xFFD2DDE0),
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: coral,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentPage == _pages.length - 1
                        ? 'Crear mi cuenta'
                        : 'Continuar',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward_rounded, size: 19),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverOnboardingItem {
  const _DriverOnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
