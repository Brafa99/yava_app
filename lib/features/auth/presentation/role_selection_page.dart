import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  static const routeName = 'role-selection';
  static const routePath = '/role-selection';

  static const Color navy = Color(0xFF072D36);
  static const Color navyLight = Color(0xFF0F4C5C);
  static const Color coral = Color(0xFFFF6B57);
  static const Color lightGray = Color(0xFFE9EEF1);
  static const Color textDark = Color(0xFF17343B);
  static const Color muted = Color(0xFF718187);

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
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntro(),
                    const SizedBox(height: 28),
                    _buildRoleCard(
                      context: context,
                      title: 'Ganadero o Cliente',
                      description:
                          'Publica solicitudes, encuentra transporte y pide lo que necesites por delivery.',
                      icon: Icons.agriculture_rounded,
                      accentColor: navyLight,
                      route: '/onboarding/customer',
                      features: const [
                        'Solicitar transporte',
                        'Enviar productos o encomiendas',
                        'Recibir ofertas de transportistas',
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildRoleCard(
                      context: context,
                      title: 'Transportista o Conductor',
                      description:
                          'Encuentra cargas, administra tus viajes y conecta con clientes de toda la Chiquitanía.',
                      icon: Icons.local_shipping_rounded,
                      accentColor: coral,
                      route: '/onboarding/driver',
                      features: const [
                        'Encontrar solicitudes de transporte',
                        'Enviar ofertas a clientes',
                        'Administrar viajes y entregas',
                      ],
                    ),
                    const SizedBox(height: 26),
                    _buildAlreadyAccount(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: navy),
          ),
          Expanded(
            child: Image.asset(
              'assets/logo_yava_bg.png',
              height: 40,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return const Text(
                  'YAVA',
                  style: TextStyle(
                    color: navy,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 42),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Cómo usarás YAVA?',
          style: TextStyle(
            color: textDark,
            fontSize: 27,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Selecciona el tipo de cuenta que deseas crear. '
          'Podrás cambiar algunas preferencias más adelante.',
          style: TextStyle(color: muted, fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
    required String route,
    required List<String> features,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(icon, color: accentColor, size: 31),
                  ),
                  const Spacer(),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  color: muted,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 17),
              ...features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: accentColor,
                        size: 17,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                            color: textDark,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlreadyAccount(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          const Text(
            '¿Ya tienes una cuenta? ',
            style: TextStyle(color: muted, fontSize: 13),
          ),
          GestureDetector(
            onTap: () => context.push('/login'),
            child: const Text(
              'Inicia sesión',
              style: TextStyle(
                color: coral,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
