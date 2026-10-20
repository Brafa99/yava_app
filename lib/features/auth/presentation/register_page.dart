import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yava_delivery_driver/core/services/onboarding_service.dart';
import 'package:yava_delivery_driver/features/auth/application/auth_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key, required this.role});

  /// Rol homologado con MySQL: 'client' o 'driver'
  final String role;

  static const routeName = 'register';
  static const routePath = '/register';

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedCity = 'Concepción';
  final List<String> _cities = const [
    'Concepción',
    'Santa Cruz',
    'San Javier',
    'San Ignacio de Velasco',
    'Cochabamba',
    'La Paz',
  ];

  bool _obscurePassword = true;
  bool _acceptedTerms = true;
  int _currentStep = 1; // 1 = Formulario, 2 = ¡Cuenta creada con éxito!

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isDriver => widget.role == 'driver';

  /// Separa "Juan Pérez Quispe" en name ("Juan") y last_name ("Pérez Quispe")
  /// para cumplir con los campos requeridos por Laravel en api-docs.json
  (String, String) _splitFullName(String rawName) {
    final parts = rawName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return ('Usuario', 'YAVÁ');
    if (parts.length == 1) return (parts.first, 'YAVÁ');
    final firstName = parts.first;
    final lastName = parts.sublist(1).join(' ');
    return (firstName, lastName);
  }

  Future<void> _submitStep1() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debes aceptar los Términos y Condiciones de YAVÁ.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final (firstName, lastName) = _splitFullName(_fullNameController.text);
    final phone = _phoneController.text.trim();
    // Si el usuario dejó el correo vacío, generamos uno válido con su celular para Laravel
    final rawEmail = _emailController.text.trim();
    final email = rawEmail.isNotEmpty
        ? rawEmail
        : 'user_${phone.replaceAll(RegExp(r'[^0-9]'), '')}@yava.bo';
    final password = _passwordController.text;

    final controller = ref.read(authControllerProvider.notifier);

    final user = _isDriver
        ? await controller.registerDriver(
            name: firstName,
            lastName: lastName,
            email: email,
            password: password,
            phone: phone,
            ci: phone,
            city: _selectedCity,
          )
        : await controller.registerClient(
            name: firstName,
            lastName: lastName,
            email: email,
            password: password,
            phone: phone,
            city: _selectedCity,
          );

    if (!mounted) return;

    if (user == null) {
      final errorMessage =
          ref.read(authControllerProvider).errorMessage ?? 'Error al crear la cuenta.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    await ref.read(onboardingServiceProvider).markCompleted();

    if (!mounted) return;

    // Pasamos al Paso 2 ("¡Cuenta creada con éxito!")
    setState(() {
      _currentStep = 2;
    });
  }

  void _finishAndGoHome() {
    final user = ref.read(authControllerProvider).user;
    if (user?.role == 'driver' || _isDriver) {
      context.go('/driver/home');
    } else {
      context.go('/customer/home');
    }
  }

  void _showOptionalFeatureInfo(String title) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$title: Puedes configurarlo también desde tu perfil.'),
          backgroundColor: const Color(0xFF0A192F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final topPadding = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox.expand(
          child: Stack(
            children: [
              // 1. Cabecera oficial (Ya incluye el logo YAVÁ oscuro, el auto a la derecha y el fundido blanco inferior)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 365,
                child: Image.asset(
                  'assets/images/register/register_bg.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/login/register_bg.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF0C4A78),
                    ),
                  ),
                ),
              ),

              // 2. Degradado mínimo solo en el borde inferior de la imagen (330px -> 365px) para unir con el fondo blanco
              Positioned(
                top: 310,
                left: 0,
                right: 0,
                height: 60,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white,
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Contenido Scrollable
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(22, topPadding + 6, 22, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barra Superior: Flecha atrás • Barra de Progreso Roja • Paso X de 2
                    _buildTopStepBar(context),

                    // Espacio calibrado para quedar justo debajo del logo YAVÁ que ya está en la imagen
                    const SizedBox(height: 122),

                    // Subtítulo del rol (PASAJERO / CONDUCTOR) debajo del logo de la imagen
                    _buildBrandLogo(),

                    const SizedBox(height: 10),

                    // Transición entre Paso 1 (Formulario) y Paso 2 (Éxito)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: _currentStep == 1
                          ? _buildStep1Form(authState.isLoading)
                          : _buildStep2Success(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- BARRA SUPERIOR CON PROGRESO DE PASOS ---
  Widget _buildTopStepBar(BuildContext context) {
    final isStep2 = _currentStep == 2;

    return Row(
      children: [
        // Botón volver
        IconButton(
          onPressed: () {
            if (_currentStep == 2) {
              _finishAndGoHome();
            } else if (context.canPop()) {
              context.pop();
            } else {
              context.go('/auth-entry');
            }
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 28,
            shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
          ),
        ),

        const Spacer(),

        // Indicador gráfico de 3 nodos (Rojo hasta la mitad en Paso 1, completo en Paso 2)
        SizedBox(
          width: 175,
          height: 24,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Línea de fondo blanca/gris
              Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Línea activa roja
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: isStep2 ? 1.0 : 0.52,
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE50914),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              // Los 3 círculos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _stepDot(active: true),
                  _stepDot(active: true),
                  _stepDot(active: isStep2),
                ],
              ),
            ],
          ),
        ),

        const Spacer(),

        // Texto: Paso 1 de 2 / Paso 2 de 2
        Text(
          'Paso $_currentStep de 2',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
          ),
        ),
      ],
    );
  }

  Widget _stepDot({required bool active}) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE50914) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4),
        ],
      ),
    );
  }

  // --- LOGO YAVÁ DIRECTO DESDE ASSETS ---
  Widget _buildBrandLogo() {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: 54,
        child: Image.asset(
          'assets/images/yava_home_bg_empty.png',
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/images/yava_home_bg_entire.png',
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
            errorBuilder: (_, __, ___) => Image.asset(
              'assets/logo_yava_bg.png',
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // PASO 1 DE 2: FORMULARIO "CREAR TU CUENTA"
  // ===========================================================================
  Widget _buildStep1Form(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('register_step_1'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Crear tu cuenta',
            style: TextStyle(
              color: Color(0xFF0A1628),
              fontSize: 31,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _isDriver
                ? 'Regístrate y genera ingresos manejando\nde forma segura y flexible.'
                : 'Regístrate y muévete de forma\nsegura, rápida y cómoda.',
            style: const TextStyle(
              color: Color(0xFF4A5568),
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),

          // 1. Nombre completo
          _RegisterCardInput(
            icon: Icons.person_outline_rounded,
            label: 'Nombre completo',
            hint: 'Ej. Juan Pérez Quispe',
            controller: _fullNameController,
            validator: (v) {
              if (v == null || v.trim().length < 3) {
                return 'Ingresa tu nombre completo';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // 2. Número de celular
          _RegisterCardInput(
            icon: Icons.smartphone_rounded,
            label: 'Número de celular',
            hint: 'Ej. 71234567',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v == null || v.trim().length < 7) {
                return 'Ingresa un número de celular válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // 3. Correo electrónico
          _RegisterCardInput(
            icon: Icons.mail_outline_rounded,
            label: 'Correo electrónico (opcional)',
            hint: 'Ej. juan@email.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v != null && v.trim().isNotEmpty && !v.contains('@')) {
                return 'Ingresa un correo válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // 4. Contraseña
          _RegisterCardInput(
            icon: Icons.lock_outline_rounded,
            label: 'Contraseña',
            hint: 'Mínimo 8 caracteres',
            controller: _passwordController,
            obscureText: _obscurePassword,
            suffix: IconButton(
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF718096),
                size: 22,
              ),
            ),
            validator: (v) {
              if (v == null || v.length < 8) {
                return 'La contraseña debe tener al menos 8 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // 5. Selector de Ciudad
          _buildCityDropdownCard(),
          const SizedBox(height: 16),

          // Checkbox de Términos y Condiciones
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 26,
                height: 26,
                child: Checkbox(
                  value: _acceptedTerms,
                  activeColor: const Color(0xFFE50914),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        color: Color(0xFF1A202C),
                        fontSize: 12.5,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(text: 'Acepto los '),
                        TextSpan(
                          text: 'Términos y Condiciones',
                          style: TextStyle(
                            color: Color(0xFFE50914),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(text: ' y la '),
                        TextSpan(
                          text: 'Política de Privacidad',
                          style: TextStyle(
                            color: Color(0xFFE50914),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(text: ' de YAVÁ.'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Botón Rojo: Siguiente ->
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submitStep1,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE50914),
                disabledBackgroundColor:
                    const Color(0xFFE50914).withValues(alpha: 0.55),
                foregroundColor: Colors.white,
                elevation: 6,
                shadowColor: const Color(0xFFE50914).withValues(alpha: 0.45),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 24),
                        Text(
                          'Siguiente',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Icon(Icons.arrow_forward_rounded, size: 24),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityDropdownCard() {
    return Container(
      height: 66,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 58,
            child: Icon(
              Icons.location_on_outlined,
              color: Color(0xFF0A1628),
              size: 24,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFFE2E8F0),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Ciudad',
                  style: TextStyle(
                    color: Color(0xFF4A5568),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCity,
                    isDense: true,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF4A5568),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF0A1628),
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                    ),
                    items: _cities
                        .map(
                          (city) => DropdownMenuItem<String>(
                            value: city,
                            child: Text(city),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCity = val);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }

  // ===========================================================================
  // PASO 2 DE 2: "¡CUENTA CREADA CON ÉXITO!"
  // ===========================================================================
  Widget _buildStep2Success() {
    return Column(
      key: const ValueKey('register_step_2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¡Cuenta creada\ncon éxito!',
          style: TextStyle(
            color: Color(0xFF0A1628),
            fontSize: 31,
            fontWeight: FontWeight.w900,
            height: 1.08,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ahora completa tu perfil para\nque tu experiencia sea más rápida\ny segura.',
          style: TextStyle(
            color: Color(0xFF4A5568),
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            height: 1.32,
          ),
        ),
        const SizedBox(height: 18),

        // Avatar Central + Botón de Cámara ("Agrega tu foto")
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _showOptionalFeatureInfo('Subir foto de perfil'),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE2E8F0),
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Container(
                          color: const Color(0xFFE2E8F0),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.person_rounded,
                            size: 62,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                      
                      // child: ClipOval(
                      //   child: Image.asset(
                      //     'assets/images/banner_conductor_promo.png',
                      //     fit: BoxFit.cover,
                      //     errorBuilder: (_, __, ___) => const Icon(
                      //       Icons.person_rounded,
                      //       size: 56,
                      //       color: Color(0xFF64748B),
                      //     ),
                      //   ),
                      // ),

                    ),
                    Positioned(
                      right: 0,
                      bottom: 2,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1628),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Agrega tu foto',
                style: TextStyle(
                  color: Color(0xFF0A1628),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Ayuda a que los conductores te reconozcan\nmás fácilmente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12.5,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 2 Tarjetas de Estado Verificado (Cuenta verificada • Correo registrado)
        Row(
          children: [
            Expanded(
              child: _VerifiedBadgeCard(
                icon: Icons.person_outline_rounded,
                title: 'Cuenta verificada',
                subtitle: 'Tu número de celular\nha sido confirmado.',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _VerifiedBadgeCard(
                icon: Icons.mail_outline_rounded,
                title: 'Correo registrado',
                subtitle: 'Recibirás notificaciones\nde tus viajes.',
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Opciones adicionales (recomendado)
        const Text(
          'Opciones adicionales (recomendado)',
          style: TextStyle(
            color: Color(0xFF0A1628),
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),

        _OptionalActionTile(
          icon: Icons.location_on_outlined,
          title: 'Agregar dirección de inicio',
          subtitle: 'Ej. Casa, Oficina',
          onTap: () => _showOptionalFeatureInfo('Dirección de inicio'),
        ),
        const SizedBox(height: 10),
        _OptionalActionTile(
          icon: Icons.star_border_rounded,
          title: 'Agregar destinos frecuentes',
          subtitle: 'Ej. Trabajo, Universidad',
          onTap: () => _showOptionalFeatureInfo('Destinos frecuentes'),
        ),
        const SizedBox(height: 10),
        _OptionalActionTile(
          icon: Icons.credit_card_rounded,
          title: 'Método de pago',
          subtitle: 'Tarjeta, YAVÁ Wallet o Efectivo',
          onTap: () => _showOptionalFeatureInfo('Método de pago'),
        ),
        const SizedBox(height: 22),

        // Botón Rojo: Comenzar a usar YAVÁ ->
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _finishAndGoHome,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE50914),
              foregroundColor: Colors.white,
              elevation: 6,
              shadowColor: const Color(0xFFE50914).withValues(alpha: 0.45),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 24),
                Text(
                  'Comenzar a usar YAVÁ',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, size: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- TARJETA DE INPUT CON ICONO Y DIVISOR VERTICAL (PASO 1) ---
class _RegisterCardInput extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _RegisterCardInput({
    required this.icon,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (_) => validator != null ? validator!(controller.text) : null,
      builder: (fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 66,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: fieldState.hasError
                      ? Colors.redAccent
                      : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 58,
                    child: Icon(
                      icon,
                      color: const Color(0xFF0A1628),
                      size: 24,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: const Color(0xFFE2E8F0),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: Color(0xFF4A5568),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        TextField(
                          controller: controller,
                          obscureText: obscureText,
                          keyboardType: keyboardType,
                          onChanged: (val) => fieldState.didChange(val),
                          style: const TextStyle(
                            color: Color(0xFF0A1628),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: hint,
                            hintStyle: const TextStyle(
                              color: Color(0xFFA0AEC0),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w400,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (suffix != null) suffix!,
                  const SizedBox(width: 6),
                ],
              ),
            ),
            if (fieldState.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 14, top: 4),
                child: Text(
                  fieldState.errorText!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// --- TARJETA DE INSIGNIA VERIFICADA (PASO 2) ---
class _VerifiedBadgeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _VerifiedBadgeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: const Color(0xFF0A1628), size: 28),
              Positioned(
                right: -4,
                bottom: -2,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0A1628),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10.5,
                    height: 1.2,
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

// --- ITEM DE OPCIÓN ADICIONAL (PASO 2) ---
class _OptionalActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionalActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF0A1628), size: 25),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF0A1628),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF64748B),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}