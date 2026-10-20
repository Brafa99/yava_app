import 'package:flutter/material.dart';

// =============================================================================
// LAYOUT COMÚN DE CADA PASO (DEJA ESPACIO SUPERIOR PARA EL FONDO Y LOGO YAVÁ)
// =============================================================================
class DriverStepLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? topBadge;
  final Color? underlineColor;
  final List<Widget> children;

  const DriverStepLayout({
    super.key,
    required this.title,
    required this.subtitle,
    this.topBadge,
    this.underlineColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 118, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (topBadge != null) ...[
            topBadge!,
            const SizedBox(height: 8),
          ],
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0A1628),
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
              height: 1.06,
            ),
          ),
          if (underlineColor != null) ...[
            const SizedBox(height: 8),
            Container(
              width: 110,
              height: 4,
              decoration: BoxDecoration(
                color: underlineColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF4A5568),
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              height: 1.28,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

// =============================================================================
// PASO 5 DE 7: DATOS DE PAGO (Réplica de Paso6.png)
// =============================================================================
class DriverStep5Bank extends StatelessWidget {
  final String selectedBank;
  final ValueChanged<String> onBankChanged;
  final String selectedAccountType;
  final ValueChanged<String> onAccountTypeChanged;
  final TextEditingController accountNumberCtrl;
  final TextEditingController accountHolderCtrl;
  final TextEditingController cciCtrl;

  const DriverStep5Bank({
    super.key,
    required this.selectedBank,
    required this.onBankChanged,
    required this.selectedAccountType,
    required this.onAccountTypeChanged,
    required this.accountNumberCtrl,
    required this.accountHolderCtrl,
    required this.cciCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final accountTypes = const [
      'Caja de Ahorros',
      'Cuenta Corriente',
      'Billetera Móvil / QR',
    ];

    return DriverStepLayout(
      title: 'Datos de pago',
      subtitle: 'Registra tu cuenta bancaria para\nrecibir tus ingresos de manera\nsegura y rápida.',
      children: [
        // Cabecera: Selecciona tu banco
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Row(
            children: [
              Icon(Icons.account_balance_rounded, color: Color(0xFF0A1628), size: 26),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecciona tu banco',
                    style: TextStyle(
                      color: Color(0xFF0A1628),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Solo puedes registrar una cuenta.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 3 Tarjetas de Bancos (Banco Unión, Banco Ecofuturo, BCP)
        Row(
          children: [
            _bankCard(
              name: 'Banco Unión',
              titleLine1: 'BANCO',
              titleLine2: 'UNIÓN S.A.',
              brandColor: const Color(0xFF003876),
              accentColor: const Color(0xFFE50914),
            ),
            const SizedBox(width: 8),
            _bankCard(
              name: 'Banco Ecofuturo',
              titleLine1: 'Banco',
              titleLine2: 'Ecofuturo',
              brandColor: const Color(0xFF311B92),
              accentColor: const Color(0xFF16A34A),
            ),
            const SizedBox(width: 8),
            _bankCard(
              name: 'BCP',
              titleLine1: '>BCP>',
              titleLine2: '',
              brandColor: const Color(0xFF002A8D),
              accentColor: const Color(0xFFFF6D00),
            ),
          ],
        ),
        const SizedBox(height: 10),

        DriverCardDropdown(
          icon: Icons.credit_card_rounded,
          label: 'Tipo de cuenta',
          value: selectedAccountType,
          items: accountTypes,
          onChanged: (v) {
            if (v != null) onAccountTypeChanged(v);
          },
        ),
        const SizedBox(height: 10),

        DriverCardInput(
          icon: Icons.tag_rounded,
          label: 'Número de cuenta',
          hint: 'Ej. 1234567890',
          controller: accountNumberCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 10),

        // Titular de la cuenta con etiqueta informativa azul
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 54,
                child: Icon(Icons.person_outline_rounded, color: Color(0xFF0A1628), size: 24),
              ),
              Container(width: 1, height: 48, color: const Color(0xFFE2E8F0)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Titular de la cuenta',
                      style: TextStyle(
                        color: Color(0xFF0A1628),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextField(
                      controller: accountHolderCtrl,
                      style: const TextStyle(
                        color: Color(0xFF0A1628),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Tu nombre completo',
                        hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                        border: InputBorder.none,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_rounded, color: Color(0xFF1D4ED8), size: 14),
                          SizedBox(width: 5),
                          Text(
                            'La cuenta debe estar a tu nombre.',
                            style: TextStyle(
                              color: Color(0xFF1D4ED8),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
        const SizedBox(height: 10),

        DriverCardInput(
          icon: Icons.description_outlined,
          label: 'Código CCI (opcional)',
          hint: 'Ej. 2010186954321001234567',
          controller: cciCtrl,
        ),
        const SizedBox(height: 10),

        const DriverImportantBanner(
          title: 'Importante',
          text: 'Esta información es confidencial y se utiliza únicamente\npara el pago de tus ganancias.',
          isPinkBg: true,
          icon: Icons.verified_user_outlined,
        ),
      ],
    );
  }

  Widget _bankCard({
    required String name,
    required String titleLine1,
    required String titleLine2,
    required Color brandColor,
    required Color accentColor,
  }) {
    final isSelected = selectedBank == name;
    return Expanded(
      child: GestureDetector(
        onTap: () => onBankChanged(name),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFE50914)
                      : const Color(0xFFE2E8F0),
                  width: isSelected ? 1.8 : 1.1,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      titleLine1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: brandColor,
                        fontSize: titleLine2.isEmpty ? 16 : 11.5,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    if (titleLine2.isNotEmpty)
                      Text(
                        titleLine2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE50914),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 11),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// PASO 6 DE 7: TÉRMINOS Y CONDICIONES (Réplica de Paso7.png)
// =============================================================================
class DriverStep6Terms extends StatelessWidget {
  final List<bool> termsAccepted;
  final void Function(int index, bool value) onToggleTerm;

  const DriverStep6Terms({
    super.key,
    required this.termsAccepted,
    required this.onToggleTerm,
  });

  @override
  Widget build(BuildContext context) {
    final items = const [
      (
        Icons.description_outlined,
        'Términos y condiciones de uso',
        'Acepto los términos y condiciones de\nla plataforma YAVÁ Driver.',
      ),
      (
        Icons.verified_user_outlined,
        'Política de privacidad',
        'Autorizo el tratamiento de mis datos personales\nconforme a la política de privacidad.',
      ),
      (
        Icons.groups_outlined,
        'Uso de la plataforma',
        'Me comprometo a brindar un servicio seguro,\nresponsable y de calidad a los usuarios.',
      ),
      (
        Icons.directions_car_outlined,
        'Cumplimiento de normativa',
        'Declaro cumplir con la normativa vigente de\ntransporte, tránsito y regulaciones locales.',
      ),
      (
        Icons.edit_note_rounded,
        'Veracidad de la información',
        'Declaro que toda la información y documentos\npresentada son verdaderos y actuales.',
      ),
      (
        Icons.handshake_outlined,
        'Código de conducta',
        'Me comprometo a mantener un comportamiento\nrespetuoso, profesional y ético.',
      ),
    ];

    return DriverStepLayout(
      title: 'Términos y\ncondiciones',
      subtitle: 'Lee y acepta los términos para\ncompletar tu registro como Driver en YAVÁ.',
      children: [
        ...List.generate(items.length, (i) {
          final item = items[i];
          final checked = termsAccepted[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => onToggleTerm(i, !checked),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                        color: const Color(0xFFFEE2E2).withValues(alpha: 0.65),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.$1, color: const Color(0xFF0A1628), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$2,
                            style: const TextStyle(
                              color: Color(0xFF0A1628),
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.$3,
                            style: const TextStyle(
                              color: Color(0xFF4A5568),
                              fontSize: 11.5,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: checked ? const Color(0xFFE50914) : Colors.white,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: checked
                              ? const Color(0xFFE50914)
                              : const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                      ),
                      child: checked
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
        const DriverImportantBanner(
          title: 'Importante',
          text: 'Al continuar, confirmas que has leído y aceptado todos los términos y condiciones\npara ser parte de YAVÁ Driver.',
          isPinkBg: true,
        ),
      ],
    );
  }
}

// =============================================================================
// PASO 7 DE 7: EN PROCESO DE REVISIÓN / ¡REGISTRO COMPLETADO! (Paso8 y Paso9)
// =============================================================================
class DriverStep7ReviewStatus extends StatelessWidget {
  final bool isApprovedPreview;
  final VoidCallback onTogglePreviewMode;
  final VoidCallback onBackToStart;
  final VoidCallback onGoToDriverPanel;

  const DriverStep7ReviewStatus({
    super.key,
    required this.isApprovedPreview,
    required this.onTogglePreviewMode,
    required this.onBackToStart,
    required this.onGoToDriverPanel,
  });

  @override
  Widget build(BuildContext context) {
    if (isApprovedPreview) {
      return _buildApprovedView();
    }
    return _buildInReviewView();
  }

  /// Vista 1: Registro en proceso de revisión (Réplica de Paso8.png)
  Widget _buildInReviewView() {
    return DriverStepLayout(
      topBadge: GestureDetector(
        onTap: onTogglePreviewMode, // Toque en el icono para previsualizar la pantalla "¡Registro completado!" en el demo
        child: Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: Color(0xFFFEF3C7),
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.assignment_outlined, size: 38, color: Color(0xFF0A1628)),
              Positioned(
                right: 12,
                bottom: 12,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.access_time_rounded, size: 15, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      title: 'Registro en proceso\nde revisión',
      underlineColor: const Color(0xFFF59E0B),
      subtitle:
          'Tu información y documentos han sido enviados\ncorrectamente y se encuentran en proceso de\nrevisión por el área de Jurídica de YAVÁ.',
      children: [
        // Tarjeta crema de Jurídica
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF9E7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDE68A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.balance_rounded, color: Color(0xFFD97706), size: 26),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'El equipo de Jurídica verificará la información\ny los documentos que presentaste para validar\ntu registro como Driver.',
                  style: TextStyle(
                    color: Color(0xFF0A1628),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Timeline de 3 etapas
        _timelineRow(
          isActive: true,
          isLast: false,
          title: 'Revisión de documentos',
          subtitle: 'El área de Jurídica está verificando tu información.',
          badgeText: 'En proceso',
        ),
        _timelineRow(
          isActive: false,
          isLast: false,
          title: 'Aprobación de registro',
          subtitle:
              'Una vez revisada y validada la información\ny documentos, tu cuenta será dada de alta.',
          badgeText: 'Pendiente',
        ),
        _timelineRow(
          isActive: false,
          isLast: true,
          title: 'Notificación',
          subtitle:
              'Te comunicaremos por la aplicación y/o\ncorreo registrado cuando tu cuenta haya sido\naprobada y esté lista para iniciar.',
          badgeText: 'Pendiente',
        ),
        const SizedBox(height: 16),

        // Botón Rojo: Volver al inicio
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: onBackToStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE50914),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 22),
            label: const Text(
              'Volver al inicio',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: onTogglePreviewMode,
            child: const Text(
              'Ver vista de Registro Aprobado (Demo) →',
              style: TextStyle(
                color: Color(0xFF16A34A),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Vista 2: ¡Registro completado! (Réplica de Paso9.png)
  Widget _buildApprovedView() {
    final checks = const [
      (
        Icons.badge_outlined,
        'Verificación de identidad',
        'Tu identidad ha sido verificada correctamente.',
      ),
      (
        Icons.description_outlined,
        'Revisión de documentos',
        'Tus documentos cumplen con los requisitos\nde YAVÁ y la normativa vigente.',
      ),
      (
        Icons.balance_rounded,
        'Evaluación del área de Jurídica',
        'Tu información ha sido revisada y aprobada\npor el área de Jurídica de YAVÁ.',
      ),
      (
        Icons.directions_car_outlined,
        'Cuenta activa',
        'Tu cuenta como Driver está habilitada\ny lista para recibir solicitudes de viaje.',
      ),
    ];

    return DriverStepLayout(
      topBadge: GestureDetector(
        onTap: onTogglePreviewMode,
        child: Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: Color(0xFF16A34A),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, size: 44, color: Colors.white),
        ),
      ),
      title: '¡Registro completado!',
      underlineColor: const Color(0xFF16A34A),
      subtitle: 'Tu registro como Driver en YAVÁ ha sido aprobado.',
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFBBF7D0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_rounded, color: Color(0xFF15803D), size: 26),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Tu información y documentos han CUMPLIDO\ncon las normativas y requisitos de YAVÁ.',
                  style: TextStyle(
                    color: Color(0xFF14532D),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        ...checks.map((c) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(c.$1, color: const Color(0xFF0A1628), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.$2,
                        style: const TextStyle(
                          color: Color(0xFF0A1628),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        c.$3,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 17),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),

        // Botón Rojo: Ir a mi panel de Driver ->
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: onGoToDriverPanel,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE50914),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 24),
                Text(
                  'Ir a mi panel de Driver',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                Icon(Icons.arrow_forward_rounded, size: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _timelineRow({
    required bool isActive,
    required bool isLast,
    required String title,
    required String subtitle,
    required String badgeText,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                    width: 2,
                  ),
                ),
                child: isActive
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
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
                      fontSize: 11.5,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: isActive ? const Color(0xFFD97706) : const Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// COMPONENTES REUTILIZABLES (INPUTS, DROPDOWNS Y BANNERS DEL MOCKUP)
// =============================================================================
class DriverCardInput extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final bool readOnly;
  final bool compact;
  final VoidCallback? onTap;
  final Widget? trailing;
  final TextInputType? keyboardType;

  const DriverCardInput({
    super.key,
    required this.icon,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.readOnly = false,
    this.compact = false,
    this.onTap,
    this.trailing,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 58 : 62,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: compact ? 44 : 52,
            child: Icon(icon, color: const Color(0xFF0A1628), size: 22),
          ),
          Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                TextField(
                  controller: controller,
                  obscureText: obscureText,
                  readOnly: readOnly,
                  onTap: onTap,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    color: Color(0xFF0A1628),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13.5,
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
          if (trailing != null) trailing!,
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class DriverCardDropdown extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool compact;

  const DriverCardDropdown({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 58 : 62,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: compact ? 44 : 52,
            child: Icon(icon, color: const Color(0xFF0A1628), size: 22),
          ),
          Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isDense: true,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF64748B),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF0A1628),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                    items: items
                        .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                        .toList(),
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}

class DriverImportantBanner extends StatelessWidget {
  final String title;
  final String text;
  final bool isPinkBg;
  final IconData icon;

  const DriverImportantBanner({
    super.key,
    required this.title,
    required this.text,
    this.isPinkBg = false,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isPinkBg ? const Color(0xFFFFF5F5) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPinkBg ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE50914), size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isPinkBg
                        ? const Color(0xFFE50914)
                        : const Color(0xFF0A1628),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF4A5568),
                    fontSize: 11,
                    height: 1.25,
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