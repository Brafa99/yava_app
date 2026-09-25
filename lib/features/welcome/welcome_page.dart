import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const routeName = 'welcome';
  static const routePath = '/welcome';

  static const Color navy = Color(0xFF072D36);
  static const Color navyLight = Color(0xFF0F4C5C);
  static const Color coral = Color(0xFFFF6B57);
  static const Color lightGray = Color(0xFFE9EEF1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(),
          _buildDarkOverlay(),
          SafeArea(
            child: Column(
              children: [
                _buildTopSlogan(),

                const Spacer(flex: 2),

                _buildLogo(),

                const SizedBox(height: 18),

                _buildMainTitle(),

                const SizedBox(height: 10),

                _buildSubtitle(),

                const Spacer(flex: 2),

                _buildFeatureHighlights(),

                const SizedBox(height: 28),

                _buildActions(context),

                const SizedBox(height: 28),

                _buildBottomText(),

                const SizedBox(height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Image.asset(
      'assets/chiquitania.jpeg',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A2934), Color(0xFF072D36), Color(0xFF03191F)],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDarkOverlay() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [
                Color(0xE6071820),
                Color(0x55071820),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Color(0xAA03141A),
                Color(0xF503141A),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopSlogan() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, right: 24, left: 24),
      child: Align(
        alignment: Alignment.topRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('NUESTRA', style: _smallUppercaseStyle()),
            Text('TIERRA', style: _smallUppercaseStyle()),
            Text('TE MUEVE', style: _smallUppercaseStyle()),
            const SizedBox(height: 7),
            Container(width: 35, height: 1.5, color: coral),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 42),
      child: Image.asset(
        'assets/yava_azul_bg.png',
        width: 205,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return const Text(
            'YAVA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
              letterSpacing: 5,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        'MOVILIDAD & DELIVERY',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 3.2,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Column(
      children: [
        Container(width: 45, height: 1, color: coral),
        const SizedBox(height: 12),
        const Text(
          'LA CHIQUITANÍA',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFE6D6B5),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.4,
          ),
        ),
        const Text(
          'CONECTADA EN UNA SOLA APP.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.8,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureHighlights() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _featureItem(icon: Icons.person_outline_rounded, label: 'PERSONAS'),
          _featureItem(icon: Icons.inventory_2_outlined, label: 'PRODUCTOS'),
          _featureItem(
            icon: Icons.auto_awesome_outlined,
            label: 'OPORTUNIDADES',
          ),
          _featureItem(icon: Icons.landscape_outlined, label: 'NUESTRA TIERRA'),
        ],
      ),
    );
  }

  Widget _featureItem({required IconData icon, required String label}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.82), size: 18),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 7.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 52),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                context.push('/role-selection');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: coral,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Comenzar',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded, size: 19),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () {
                context.push('/login');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.65),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Iniciar Sesión',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomText() {
    return Column(
      children: [
        Container(
          width: 42,
          height: 1,
          color: Colors.white.withValues(alpha: 0.35),
        ),
        const SizedBox(height: 13),
        const Text(
          'DESDE CONCEPCIÓN',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'PARA TODA LA CHIQUITANÍA',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 7.5,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  TextStyle _smallUppercaseStyle() {
    return TextStyle(
      color: Colors.white.withValues(alpha: 0.82),
      fontSize: 8,
      fontWeight: FontWeight.w500,
      letterSpacing: 2.3,
    );
  }
}
