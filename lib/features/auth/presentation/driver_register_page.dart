import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yava_delivery_driver/core/network/api_endpoints.dart';
import 'package:yava_delivery_driver/core/services/onboarding_service.dart';
import 'package:yava_delivery_driver/features/auth/application/auth_controller.dart';
import 'package:yava_delivery_driver/features/auth/presentation/driver_register_steps_2.dart';

class DriverRegisterPage extends ConsumerStatefulWidget {
  const DriverRegisterPage({super.key});

  static const routeName = 'driver-register';
  static const routePath = '/register/driver';

  @override
  ConsumerState<DriverRegisterPage> createState() => _DriverRegisterPageState();
}

class _DriverRegisterPageState extends ConsumerState<DriverRegisterPage> {
  final PageController _pageController = PageController();
  final ImagePicker _picker = ImagePicker();

  int _currentStep = 0;
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _isApprovedPreview = false;

  // Paso 1: Datos personales
  final _fullNameCtrl = TextEditingController();
  final _ciCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();
  String _selectedCity = 'Concepción';

  // Paso 2: Tipo de vehículo
  String _selectedVehicleType = 'Automóvil';

  // Paso 3: Información del vehículo
  String _selectedBrand = 'Chevrolet';
  String _selectedModel = 'Onix';
  String _selectedYear = '2023';
  final _plateCtrl = TextEditingController(text: '4325-ABC');
  String _selectedColor = 'Blanco';

  // Paso 5: Datos de pago
  String _selectedBank = 'Banco Unión';
  String _selectedAccountType = 'Caja de Ahorros';
  final _accountNumberCtrl = TextEditingController();
  final _accountHolderCtrl = TextEditingController();
  final _cciCtrl = TextEditingController();

  // Paso 6: Términos y condiciones
  final List<bool> _termsAccepted = [true, true, true, true, true, true];

  // Rutas de archivos locales
  final Map<String, String> _filePaths = {
    'car_front': '',
    'car_back': '',
    'ci_front': '',
    'ci_back': '',
    'license_front': '',
    'license_back': '',
    'ruat': '',
    'soat': '',
    'inspection': '',
    'rejap': '',
  };

  final List<String> _cities = const [
    'Concepción',
    'Santa Cruz',
    'Cochabamba',
    'San Ignacio de Velasco',
    'San Javier',
    'La Paz',
  ];

  final List<String> _brands = const [
    'Chevrolet',
    'Toyota',
    'Suzuki',
    'Nissan',
    'Honda',
    'Hyundai',
    'Kia',
  ];

  final List<String> _models = const [
    'Onix',
    'Corolla',
    'Swift',
    'Hilux',
    'Sentra',
    'Tucson',
    'Rio',
  ];

  final List<String> _years = const [
    '2026',
    '2025',
    '2024',
    '2023',
    '2022',
    '2021',
    '2020',
    '2019',
    '2018',
    '2015',
  ];

  final List<String> _colors = const [
    'Blanco',
    'Negro',
    'Plata',
    'Gris',
    'Rojo',
    'Azul',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameCtrl.dispose();
    _ciCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _birthDateCtrl.dispose();
    _plateCtrl.dispose();
    _accountNumberCtrl.dispose();
    _accountHolderCtrl.dispose();
    _cciCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDocumentImage(String key, String label) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0A1628),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFFE50914)),
                title: const Text('Tomar fotografía con la cámara'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF0075FF)),
                title: const Text('Seleccionar desde la galería'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 82);
      if (picked != null && mounted) {
        setState(() {
          _filePaths[key] = picked.path;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir la cámara/galería: $e')),
      );
    }
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25, 5, 15),
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 18),
    );
    if (picked != null) {
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      setState(() {
        _birthDateCtrl.text = '${picked.year}-$month-$day';
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFE50914),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _validateCurrentStep() {
    // Paso 1 (Índice 0): Datos Personales
    if (_currentStep == 0) {
      if (_fullNameCtrl.text.trim().length < 3 ||
          _ciCtrl.text.trim().isEmpty ||
          _phoneCtrl.text.trim().length < 7 ||
          _emailCtrl.text.trim().isEmpty ||
          !_emailCtrl.text.contains('@') ||
          _birthDateCtrl.text.isEmpty) {
        _showError('Completa todos los campos de datos personales (incluyendo correo y fecha).');
        return false;
      }
      if (_passwordCtrl.text.isEmpty || _passwordCtrl.text.length < 8) {
        _showError('La contraseña es obligatoria y debe tener al menos 8 caracteres.');
        return false;
      }
    }
    
    // Paso 2 (Índice 1): Tipo de vehículo (Siempre es válido por tener valor por defecto)
    
    // Paso 3 (Índice 2): Información del vehículo y fotos
    else if (_currentStep == 2) {
      if (_plateCtrl.text.trim().isEmpty) {
        _showError('Debes ingresar la placa de tu vehículo.');
        return false;
      }
      if (_filePaths['car_front']!.isEmpty || _filePaths['car_back']!.isEmpty) {
        _showError('Debes subir la foto frontal y posterior de tu vehículo.');
        return false;
      }
    }
    
    // Paso 4 (Índice 3): Documentos obligatorios
    else if (_currentStep == 3) {
      final missingDocs = <String>[];
      if (_filePaths['ci_front']!.isEmpty || _filePaths['ci_back']!.isEmpty) missingDocs.add('Cédula de Identidad');
      if (_filePaths['license_front']!.isEmpty || _filePaths['license_back']!.isEmpty) missingDocs.add('Licencia de Conducir');
      if (_filePaths['ruat']!.isEmpty) missingDocs.add('RUAT');
      if (_filePaths['soat']!.isEmpty) missingDocs.add('SOAT');
      if (_filePaths['rejap']!.isEmpty) missingDocs.add('Antecedentes (REJAP)');
      
      if (missingDocs.isNotEmpty) {
        _showError('Te faltan los siguientes documentos: ${missingDocs.join(', ')}');
        return false;
      }
    }

    // Paso 5 (Índice 4): Datos de Pago (No es estricto en este demo, pero se puede agregar validación de cuenta)
    else if (_currentStep == 4) {
      if (_accountNumberCtrl.text.trim().isEmpty || _accountHolderCtrl.text.trim().isEmpty) {
        _showError('Ingresa el número de cuenta y el titular para recibir tus pagos.');
        return false;
      }
    }

    // Paso 6 (Índice 5): Términos y Condiciones
    else if (_currentStep == 5) {
      if (_termsAccepted.any((accepted) => !accepted)) {
        _showError('Debes aceptar todos los términos y condiciones para finalizar el registro.');
        return false;
      }
    }
    
    return true;
  }

  void _nextStep() {
    FocusScope.of(context).unfocus();
    if (!_validateCurrentStep()) return;

    if (_currentStep < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else if (_currentStep == 5) {
      _submitToBackend();
    }
  }

  void _prevStep() {
    FocusScope.of(context).unfocus();
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/welcome');
      }
    }
  }

  (String, String) _splitFullName(String raw) {
    final parts = raw.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return ('Conductor', 'YAVÁ');
    if (parts.length == 1) return (parts.first, 'YAVÁ');
    return (parts.first, parts.sublist(1).join(' '));
  }

  List<int> _mapVehicleTypeToServiceIds(String vehicleType) {
    switch (vehicleType) {
      case 'Motocicleta':
        return [3];
      case 'Delivery (Moto)':
        return [3, 6, 7, 8, 9, 10, 11];
      case 'Carga / Transporte':
        return [4, 5, 10];
      case 'Taxi Ejecutivo':
        return [2, 5];
      case 'Automóvil':
      default:
        return [2, 4, 5];
    }
  }

  Map<String, dynamic> _buildDriverTermsPayload() {
    final now = DateTime.now().toUtc().toIso8601String();
    return {
      'terms_and_conditions': {
        'accepted': true,
        'version': '1.0',
        'accepted_at': now,
      },
      'privacy_policy': {
        'accepted': true,
        'version': '1.0',
        'accepted_at': now,
      },
      'platform_rules': {
        'accepted': true,
        'accepted_at': now,
      },
      'traffic_regulations': {
        'accepted': true,
        'accepted_at': now,
      },
      'truthfulness_declaration': {
        'accepted': true,
        'accepted_at': now,
      },
      'code_of_conduct': {
        'accepted': true,
        'accepted_at': now,
      },
    };
  }

  Future<void> _submitToBackend() async {
    setState(() => _isSubmitting = true);
    final warnings = <String>[];

    try {
      final controller = ref.read(authControllerProvider.notifier);
      final apiClient = ref.read(apiClientProvider);
      final storage = ref.read(storageServiceProvider);

      final (firstName, lastName) = _splitFullName(_fullNameCtrl.text);
      final phone = _phoneCtrl.text.trim();
      final email = _emailCtrl.text.trim().isNotEmpty
          ? _emailCtrl.text.trim()
          : 'driver_${phone.replaceAll(RegExp(r'[^0-9]'), '')}@yava.bo';
      final password = _passwordCtrl.text.length >= 8
          ? _passwordCtrl.text
          : 'Yava${phone.replaceAll(RegExp(r'[^0-9]'), '')}!';

      // 1. POST /api/driver/register
      var user = await controller.registerDriver(
        name: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
        ci: _ciCtrl.text.trim(),
        birthDate: _birthDateCtrl.text.trim().isNotEmpty ? _birthDateCtrl.text.trim() : null,
        city: _selectedCity,
        termAndRequirement: _buildDriverTermsPayload(),
      );

      if (user == null) {
        final err = ref.read(authControllerProvider).errorMessage ??
            'No se pudo registrar el conductor.';
        throw Exception(err);
      }

      // Si el registro no retorna token, se autentica directamente
      final currentToken = await storage.getToken();
      if (currentToken == null || currentToken.isEmpty) {
        final loggedUser = await controller.signIn(
          email: email,
          password: password,
        );
        if (loggedUser != null) {
          user = loggedUser;
        }
      }

      final userId = user.id;

      // 2. PUT /api/driver/{driverId}/update (Actualización de perfil)
      try {
        await apiClient.put(
          ApiEndpoints.driverUpdate(userId),
          body: {
            'name': firstName,
            'last_name': lastName,
            'email': email,
            'phone': phone,
            'ci': _ciCtrl.text.trim(),
            if (_birthDateCtrl.text.isNotEmpty)
              'birth_date': _birthDateCtrl.text.trim(),
          },
          requiresAuth: true,
        );
      } catch (e) {
        warnings.add('Datos adicionales: $e');
      }

      // 3. POST /api/driver/{driverId}/services (Asignación de categorías de servicio)
      try {
        await apiClient.post(
          ApiEndpoints.driverServices(userId),
          body: {
            'service_ids': _mapVehicleTypeToServiceIds(_selectedVehicleType),
          },
          requiresAuth: true,
        );
      } catch (e) {
        debugPrint('Error en driver services: $e');
      }

      // 4. POST /api/driver/vehicle (Carga multipart de vehículo)
      try {
        await apiClient.postMultipart(
          ApiEndpoints.driverVehicle,
          fields: {
            'user_id': userId.toString(),
            'placa': _plateCtrl.text.trim().isNotEmpty
                ? _plateCtrl.text.trim()
                : 'S/N-$userId',
            'tipo_vehiculo': _selectedVehicleType,
            'marca': _selectedBrand,
            'modelo': _selectedModel,
            'anho': _selectedYear,
            'color': _selectedColor,
            'capacidad': _selectedVehicleType.contains('Moto') ? '1' : '4',
          },
          filePaths: {
            if (_filePaths['ruat']!.isNotEmpty) 'ruat': _filePaths['ruat']!,
            if (_filePaths['soat']!.isNotEmpty) 'soat': _filePaths['soat']!,
            if (_filePaths['inspection']!.isNotEmpty)
              'inspeccion_tecnica': _filePaths['inspection']!,
            if (_filePaths['car_front']!.isNotEmpty)
              'foto_vehiculo': _filePaths['car_front']!,
            if (_filePaths['car_back']!.isNotEmpty)
              'autorizacion_uso': _filePaths['car_back']!,
          },
          requiresAuth: true,
        );
      } catch (e) {
        warnings.add('Vehículo: $e');
      }

      // 5. POST /api/driver/documents (Carga multipart de documentos)
      final hasAnyDoc = _filePaths['ci_front']!.isNotEmpty ||
          _filePaths['ci_back']!.isNotEmpty ||
          _filePaths['license_front']!.isNotEmpty ||
          _filePaths['license_back']!.isNotEmpty ||
          _filePaths['rejap']!.isNotEmpty;

      if (hasAnyDoc) {
        try {
          await apiClient.postMultipart(
            ApiEndpoints.driverDocuments,
            fields: {'user_id': userId.toString()},
            filePaths: {
              if (_filePaths['ci_front']!.isNotEmpty)
                'carnet_anverso': _filePaths['ci_front']!,
              if (_filePaths['ci_back']!.isNotEmpty)
                'carnet_reverso': _filePaths['ci_back']!,
              if (_filePaths['license_front']!.isNotEmpty)
                'licencia_conducir_anverso': _filePaths['license_front']!,
              if (_filePaths['license_back']!.isNotEmpty)
                'licencia_conducir_reverso': _filePaths['license_back']!,
              if (_filePaths['rejap']!.isNotEmpty)
                'autorizacion_municipal': _filePaths['rejap']!,
            },
            requiresAuth: true,
          );
        } catch (e) {
          warnings.add('Documentos: $e');
        }
      }

      try {
        await ref.read(onboardingServiceProvider).markCompleted();
      } catch (_) {}

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (warnings.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cuenta creada. Detalle en anexos: ${warnings.join(" | ")}',
            ),
            backgroundColor: Colors.orange.shade800,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      _pageController.animateToPage(
        6,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar conductor: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox.expand(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 350,
                child: Image.asset(
                  'assets/images/register/register_bg.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/register_bg.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF1A2942),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 265,
                left: 0,
                right: 0,
                height: 95,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.88),
                        Colors.white,
                      ],
                      stops: const [0.0, 0.65, 1.0],
                    ),
                  ),
                ),
              ),

              Column(
                children: [
                  SizedBox(height: topPadding + 30),
                  _buildTopProgressHeader(),

                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (idx) => setState(() => _currentStep = idx),
                      children: [
                        _buildStep1PersonalData(),
                        _buildStep2VehicleType(),
                        _buildStep3VehicleInfo(),
                        _buildStep4Documents(),
                        DriverStep5Bank(
                          selectedBank: _selectedBank,
                          onBankChanged: (v) => setState(() => _selectedBank = v),
                          selectedAccountType: _selectedAccountType,
                          onAccountTypeChanged: (v) =>
                              setState(() => _selectedAccountType = v),
                          accountNumberCtrl: _accountNumberCtrl,
                          accountHolderCtrl: _accountHolderCtrl,
                          cciCtrl: _cciCtrl,
                        ),
                        DriverStep6Terms(
                          termsAccepted: _termsAccepted,
                          onToggleTerm: (index, val) {
                            setState(() => _termsAccepted[index] = val);
                          },
                        ),
                        DriverStep7ReviewStatus(
                          isApprovedPreview: _isApprovedPreview,
                          onTogglePreviewMode: () {
                            setState(
                              () => _isApprovedPreview = !_isApprovedPreview,
                            );
                          },
                          onBackToStart: () =>
                              context.go('/login'), // <--- Cambio aplicado aquí
                          onGoToDriverPanel: () => context.go('/driver/home'),
                        ),
                      ],
                    ),
                  ),

                  if (_currentStep < 6) _buildBottomNavigationBar(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopProgressHeader() {
    final stepNumber = _currentStep + 1;
    final progressFactor = (stepNumber / 7.0).clamp(0.15, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _prevStep,
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 28,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Paso $stepNumber de 7',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 210,
                      height: 18,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.80),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: progressFactor,
                              child: Container(
                                height: 4,
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE50914),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(7, (index) {
                              final isActive = index <= _currentStep;
                              return Container(
                                width: 13,
                                height: 13,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFFE50914)
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isActive
                                        ? Colors.white.withValues(alpha: 0.9)
                                        : Colors.white,
                                    width: 1.5,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black26, blurRadius: 3),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final showBackButton = _currentStep == 4 || _currentStep == 5;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (showBackButton) ...[
              SizedBox(
                height: 54,
                width: 118,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _prevStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: const Color(0xFF0A1628),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_rounded, size: 20),
                      SizedBox(width: 6),
                      Text(
                        'Atrás',
                        style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shadowColor: const Color(0xFFE50914).withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: 22),
                            Text(
                              'Siguiente',
                              style: TextStyle(
                                fontSize: 17.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Icon(Icons.arrow_forward_rounded, size: 24),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1PersonalData() {
    return DriverStepLayout(
      title: 'Datos personales',
      subtitle: 'Completa tu información básica\npara crear tu cuenta.',
      children: [
        DriverCardInput(
          icon: Icons.person_outline_rounded,
          label: 'Nombre completo',
          hint: 'Ej. Juan Carlos Mendoza Rojas',
          controller: _fullNameCtrl,
        ),
        const SizedBox(height: 10),
        DriverCardInput(
          icon: Icons.badge_outlined,
          label: 'Número de cédula de identidad',
          hint: 'Ej. 12345678',
          controller: _ciCtrl,
        ),
        const SizedBox(height: 10),
        DriverCardInput(
          icon: Icons.smartphone_rounded,
          label: 'Número de celular',
          hint: 'Ej. 71234567',
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 10),
        DriverCardInput(
          icon: Icons.mail_outline_rounded,
          label: 'Correo electrónico',
          hint: 'Ej. juan.mendoza@email.com',
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 10),
        DriverCardInput(
          icon: Icons.calendar_today_outlined,
          label: 'Fecha de nacimiento',
          hint: 'dd / mm / aaaa',
          controller: _birthDateCtrl,
          readOnly: true,
          onTap: _selectBirthDate,
          trailing: const Icon(
            Icons.calendar_month_outlined,
            color: Color(0xFF64748B),
            size: 22,
          ),
        ),
        const SizedBox(height: 10),
        DriverCardDropdown(
          icon: Icons.location_on_outlined,
          label: 'Ciudad de residencia',
          value: _selectedCity,
          items: _cities,
          onChanged: (v) {
            if (v != null) setState(() => _selectedCity = v);
          },
        ),
        const SizedBox(height: 10),
        DriverCardInput(
          icon: Icons.lock_outline_rounded,
          label: 'Contraseña de acceso',
          hint: 'Mínimo 8 caracteres',
          controller: _passwordCtrl,
          obscureText: _obscurePassword,
          trailing: IconButton(
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF64748B),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2VehicleType() {
    final options = [
      (
        'Automóvil',
        'Transporte de pasajeros\nen la ciudad y/o interprovincial.',
        Icons.directions_car_filled_outlined,
        'assets/images/vehicles/auto_yava.png',
      ),
      (
        'Motocicleta',
        'Transporte rápido y seguro\nen la ciudad.',
        Icons.two_wheeler_rounded,
        'assets/images/vehicles/moto_yava.png',
      ),
      (
        'Delivery (Moto)',
        'Entrega de paquetes,\ndocumentos y compras.',
        Icons.inventory_2_outlined,
        'assets/images/vehicles/delivery_yava.png',
      ),
      (
        'Carga / Transporte',
        'Transporte de mercancías\ny encomiendas.',
        Icons.local_shipping_outlined,
        'assets/images/vehicles/carga_yava.png',
      ),
      (
        'Taxi Ejecutivo',
        'Servicio premium\nde pasajeros.',
        Icons.local_taxi_outlined,
        'assets/images/vehicles/taxi_ejecutivo_yava.png',
      ),
    ];

    return DriverStepLayout(
      title: 'Tipo de vehículo',
      subtitle: 'Selecciona el vehículo con el que trabajarás.',
      children: [
        ...options.map((opt) {
          final isSelected = _selectedVehicleType == opt.$1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedVehicleType = opt.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFFF5F5)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFE50914)
                        : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.6 : 1.1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFEE2E2)
                            : const Color(0xFFEDF2F7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        opt.$3,
                        color: const Color(0xFF0A1628),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opt.$1,
                            style: const TextStyle(
                              color: Color(0xFF0A1628),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            opt.$2,
                            style: const TextStyle(
                              color: Color(0xFF4A5568),
                              fontSize: 11.5,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 96,
                      height: 54,
                      child: Image.asset(
                        opt.$4,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          opt.$3,
                          size: 42,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFE50914)
                              : const Color(0xFFCBD5E1),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 11,
                                height: 11,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE50914),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFE50914), size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Puedes cambiar el tipo de vehículo más adelante\ndesde tu perfil.',
                  style: TextStyle(
                    color: Color(0xFF4A5568),
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep3VehicleInfo() {
    return DriverStepLayout(
      title: 'Información\ndel vehículo',
      subtitle: 'Completa los datos de tu vehículo\npara continuar.',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 11,
              child: Column(
                children: [
                  DriverCardDropdown(
                    icon: Icons.directions_car_outlined,
                    label: 'Marca',
                    value: _selectedBrand,
                    items: _brands,
                    compact: true,
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedBrand = v);
                    },
                  ),
                  const SizedBox(height: 10),
                  DriverCardDropdown(
                    icon: Icons.directions_car_filled_outlined,
                    label: 'Modelo',
                    value: _selectedModel,
                    items: _models,
                    compact: true,
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedModel = v);
                    },
                  ),
                  const SizedBox(height: 10),
                  DriverCardDropdown(
                    icon: Icons.calendar_today_outlined,
                    label: 'Año',
                    value: _selectedYear,
                    items: _years,
                    compact: true,
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedYear = v);
                    },
                  ),
                  const SizedBox(height: 10),
                  DriverCardInput(
                    icon: Icons.pin_outlined,
                    label: 'Placa',
                    hint: '4325-ABC',
                    controller: _plateCtrl,
                    compact: true,
                  ),
                  const SizedBox(height: 10),
                  DriverCardDropdown(
                    icon: Icons.palette_outlined,
                    label: 'Color',
                    value: _selectedColor,
                    items: _colors,
                    compact: true,
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedColor = v);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVehiclePhotoBox(
                    fileKey: 'car_front',
                    title: 'Foto del vehículo\n(frontal)',
                    fallbackAsset: 'assets/images/vehicles/auto_yava.png',
                  ),
                  const SizedBox(height: 14),
                  _buildVehiclePhotoBox(
                    fileKey: 'car_back',
                    title: 'Foto del vehículo\n(parte posterior)',
                    fallbackAsset: 'assets/images/vehicles/auto_yava.png',
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const DriverImportantBanner(
          title: 'Importante',
          text: 'El vehículo debe estar a tu nombre o contar con\nautorización (según tipo de registro).',
        ),
      ],
    );
  }

  Widget _buildVehiclePhotoBox({
    required String fileKey,
    required String title,
    required String fallbackAsset,
  }) {
    final selectedPath = _filePaths[fileKey] ?? '';
    return GestureDetector(
      onTap: () => _pickDocumentImage(fileKey, title.replaceAll('\n', ' ')),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 102,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selectedPath.isNotEmpty
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: selectedPath.isNotEmpty
                      ? Image.file(File(selectedPath), fit: BoxFit.cover)
                      : Image.asset(
                          fallbackAsset,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.directions_car_rounded,
                            size: 44,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                ),
              ),
              Positioned(
                right: -4,
                bottom: -6,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE50914),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.add_a_photo_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0A1628),
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Debe ser clara y mostrar\nla placa.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10.5,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4Documents() {
    return DriverStepLayout(
      title: 'Documentos\nrequeridos',
      subtitle: 'Sube fotos claras y legibles de los siguientes\ndocumentos para continuar con tu registro.',
      children: [
        _buildDocumentUploadRow(
          icon: Icons.badge_outlined,
          title: 'Cédula de identidad',
          isRequired: true,
          subtitle: 'Foto frontal y posterior.',
          primaryKey: 'ci_front',
          secondaryKey: 'ci_back',
        ),
        const SizedBox(height: 10),
        _buildDocumentUploadRow(
          icon: Icons.sports_motorsports_outlined,
          title: 'Licencia de conducir',
          isRequired: true,
          subtitle: 'Foto frontal y posterior.',
          primaryKey: 'license_front',
          secondaryKey: 'license_back',
        ),
        const SizedBox(height: 10),
        _buildDocumentUploadRow(
          icon: Icons.directions_car_outlined,
          title: 'Documento del vehículo',
          isRequired: true,
          subtitle: 'RUAT o Tarjeta de propiedad.',
          primaryKey: 'ruat',
        ),
        const SizedBox(height: 10),
        _buildDocumentUploadRow(
          icon: Icons.verified_user_outlined,
          title: 'SOAT vigente',
          isRequired: true,
          subtitle: 'Foto o PDF.',
          primaryKey: 'soat',
        ),
        const SizedBox(height: 10),
        _buildDocumentUploadRow(
          icon: Icons.description_outlined,
          title: 'Revisión técnica vehicular',
          isRequired: false,
          subtitle: 'Si tu ciudad lo requiere.',
          primaryKey: 'inspection',
        ),
        const SizedBox(height: 10),
        _buildDocumentUploadRow(
          icon: Icons.fingerprint_rounded,
          title: 'Antecedentes penales',
          isRequired: true,
          subtitle: 'Certificado de antecedentes penales\nREJAP (vigente).',
          primaryKey: 'rejap',
        ),
        const SizedBox(height: 12),
        const DriverImportantBanner(
          title: 'Importante',
          text: 'Todos los documentos deben estar vigentes, ser legibles\ny a tu nombre. Formatos permitidos: JPG, PNG o PDF.',
          isPinkBg: true,
        ),
      ],
    );
  }

  Widget _buildDocumentUploadRow({
    required IconData icon,
    required String title,
    required bool isRequired,
    required String subtitle,
    required String primaryKey,
    String? secondaryKey,
  }) {
    final path1 = _filePaths[primaryKey] ?? '';
    final path2 = secondaryKey != null ? (_filePaths[secondaryKey] ?? '') : '';
    final hasUploaded = path1.isNotEmpty || path2.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isRequired
                  ? const Color(0xFFFEE2E2).withValues(alpha: 0.65)
                  : const Color(0xFFEDF2F7),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF0A1628), size: 22),
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
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isRequired
                        ? const Color(0xFFE50914)
                        : const Color(0xFF94A3B8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isRequired ? 'Obligatorio' : 'Opcional',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10.5,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _pickDocumentImage(primaryKey, '$title (Anverso)'),
            child: Container(
              width: 56,
              height: 40,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: path1.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image.file(File(path1), fit: BoxFit.cover),
                    )
                  : const Icon(
                      Icons.assignment_ind_outlined,
                      size: 20,
                      color: Color(0xFF94A3B8),
                    ),
            ),
          ),
          if (secondaryKey != null)
            GestureDetector(
              onTap: () => _pickDocumentImage(secondaryKey, '$title (Reverso)'),
              child: Container(
                width: 56,
                height: 40,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: path2.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.file(File(path2), fit: BoxFit.cover),
                      )
                    : const Icon(
                        Icons.credit_card_rounded,
                        size: 20,
                        color: Color(0xFF94A3B8),
                      ),
              ),
            ),
          GestureDetector(
            onTap: () => _pickDocumentImage(primaryKey, title),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isRequired
                        ? const Color(0xFFFFF5F5)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: isRequired
                        ? const Color(0xFFE50914)
                        : const Color(0xFF64748B),
                    size: 22,
                  ),
                ),
                Positioned(
                  right: -3,
                  top: -3,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: hasUploaded || isRequired
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF64748B),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasUploaded || isRequired ? Icons.check_rounded : Icons.add_rounded,
                      color: Colors.white,
                      size: 11,
                    ),
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