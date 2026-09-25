import 'package:flutter/material.dart';

class TaxiPage extends StatefulWidget {
  const TaxiPage({super.key});

  @override
  State<TaxiPage> createState() => _TaxiPageState();
}

class _TaxiPageState extends State<TaxiPage> {
  bool automaticFare = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: Stack(
                children: [
                  _buildMap(),

                  _buildTaxiForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      height: 48,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const SizedBox(
              width: 40,
              height: 48,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 22,
                  color: Color(0xFF222222),
                ),
              ),
            ),
          ),

          const Spacer(),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icons/taxi.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 4),
              const Text(
                'Taxi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E1E1E),
                ),
              ),
            ],
          ),

          const Spacer(),

          Image.asset(
            'assets/icons/taxi.png',
            width: 31,
            height: 31,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAPA
  // ============================================================

  Widget _buildMap() {
  return Positioned.fill(
    child: LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // --------------------------------------------------
            // MAPA DE FONDO
            // --------------------------------------------------

            Positioned.fill(
              child: Image.asset(
                'assets/images/map_placeholder.png',
                fit: BoxFit.cover,
              ),
            ),

            // --------------------------------------------------
            // MARCADOR DE ORIGEN
            // --------------------------------------------------

            Positioned(
              left: constraints.maxWidth * 0.31,
              top: constraints.maxHeight * 0.37,
              child: _buildMapMarker(
                color: const Color(0xFF18A957),
              ),
            ),

            // --------------------------------------------------
            // MARCADOR DE DESTINO
            // --------------------------------------------------

            Positioned(
              left: constraints.maxWidth * 0.75,
              top: constraints.maxHeight * 0.52,
              child: _buildMapMarker(
                color: const Color(0xFFE53935),
              ),
            ),
          ],
        );
      },
    ),
  );
}

Widget _buildMapMarker({
  required Color color,
}) {
  return Icon(
    Icons.location_on,
    size: 32,
    color: color,
  );
}

  // ============================================================
  // FORMULARIO
  // ============================================================

  Widget _buildTaxiForm() {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
        child: Column(
          children: [
            _buildLocationCard(),

            const SizedBox(height: 8),

            _buildServiceType(),

            const SizedBox(height: 8),

            _buildSuggestedPrice(),

            const SizedBox(height: 8),

            _buildFareMethod(),

            const SizedBox(height: 8),

            _buildSearchButton(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ORIGEN / DESTINO
  // ============================================================

  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.10),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildLocationRow(
            color: const Color(0xFF18A957),
            title: 'Origen',
            value: 'Mi ubicación',
          ),

          const Padding(
            padding: EdgeInsets.only(
              left: 7,
              right: 3,
            ),
            child: Divider(
              height: 12,
              thickness: .6,
              color: Color(0xFFE7E7E7),
            ),
          ),

          _buildLocationRow(
            color: const Color(0xFFE84949),
            title: 'Destino',
            value: 'Av. Principal, Concepción',
          ),

          const SizedBox(height: 7),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 13,
                color: Color(0xFF999999),
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Referencia opcional',
                      style: TextStyle(
                        fontSize: 7,
                        color: Color(0xFF9B9B9B),
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Frente a la plaza',
                      style: TextStyle(
                        fontSize: 9,
                        color: Color(0xFF444444),
                        fontWeight: FontWeight.w500,
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

  Widget _buildLocationRow({
    required Color color,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 7,
                  color: Color(0xFF999999),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),

        const Icon(
          Icons.close_rounded,
          size: 15,
          color: Color(0xFF888888),
        ),
      ],
    );
  }

  // ============================================================
  // TIPO DE SERVICIO
  // ============================================================

  Widget _buildServiceType() {
    return _whiteSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tipo de servicio',
            style: TextStyle(
              fontSize: 8,
              color: Color(0xFF555555),
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 5),

          Container(
            height: 29,
            padding: const EdgeInsets.symmetric(horizontal: 9),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFD5D5D5),
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: const [
                Expanded(
                  child: Text(
                    'Taxi Estándar',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF333333),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: Color(0xFF333333),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRECIO SUGERIDO
  // ============================================================

  Widget _buildSuggestedPrice() {
    return _whiteSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Precio sugerido',
            style: TextStyle(
              fontSize: 8,
              color: Color(0xFF555555),
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Text(
                  'Bs. 18 - 22',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF222222),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    '(4.8 km - 12 min)',
                    style: TextStyle(
                      fontSize: 8,
                      color: Color(0xFF555555),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MÉTODO DE TARIFA
  // ============================================================

  Widget _buildFareMethod() {
    return _whiteSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Método de tarifa',
            style: TextStyle(
              fontSize: 8,
              color: Color(0xFF555555),
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 5),

          _buildFareOption(
            selected: automaticFare,
            title: 'Precio automático',
            subtitle: 'Tarifa sugerida según distancia',
            onTap: () {
              setState(() {
                automaticFare = true;
              });
            },
          ),

          const SizedBox(height: 4),

          _buildFareOption(
            selected: !automaticFare,
            title: 'Ofertar precio',
            subtitle: 'Tú propones el precio',
            onTap: () {
              setState(() {
                automaticFare = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFareOption({
    required bool selected,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected
                ? const Color(0xFFD5D5D5)
                : const Color(0xFFE1E1E1),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? const Color(0xFF222222)
                      : const Color(0xFFAAAAAA),
                  width: 1.2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFFC800),
                        ),
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 7),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 6.5,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BOTÓN
  // ============================================================

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: ElevatedButton(
        onPressed: () {
          // De momento solamente UI.
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFC800),
          foregroundColor: Colors.black,
          elevation: 1,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: const Text(
          'BUSCAR VEHÍCULO',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: .1,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TARJETA BLANCA
  // ============================================================

  Widget _whiteSection({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.07),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}