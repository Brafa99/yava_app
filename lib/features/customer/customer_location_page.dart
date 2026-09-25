import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:yava_delivery_driver/app/theme/app_colors.dart';

class CustomerLocationsPage extends StatefulWidget {
  static const routePath = '/customer/locations';

  const CustomerLocationsPage({super.key});

  @override
  State<CustomerLocationsPage> createState() => _CustomerLocationsPageState();
}

class _CustomerLocationsPageState extends State<CustomerLocationsPage> {
  final List<_SavedLocation> _locations = [
    const _SavedLocation(
      title: 'Casa',
      address: 'Av. Principal, La Paz',
      icon: Icons.home_rounded,
      type: _LocationType.home,
    ),
    const _SavedLocation(
      title: 'Trabajo',
      address: 'Zona Central',
      icon: Icons.work_rounded,
      type: _LocationType.work,
    ),
  ];

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/customer/home');
    }
  }

  Future<void> _addLocation() async {
    final result = await showModalBottomSheet<_SavedLocation>(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return const _AddLocationSheet();
      },
    );

    if (result == null || !mounted) return;

    setState(() {
      _locations.add(result);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${result.title} fue agregada a tus ubicaciones.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _selectLocation(_SavedLocation location) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${location.title}: ${location.address}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _editLocation(int index) async {
    final location = _locations[index];

    final result = await showModalBottomSheet<_SavedLocation>(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return _AddLocationSheet(initialLocation: location, editing: true);
      },
    );

    if (result == null || !mounted) return;

    setState(() {
      _locations[index] = result;
    });
  }

  Future<void> _deleteLocation(int index) async {
    final location = _locations[index];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: const Text(
            'Eliminar ubicación',
            style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
          ),
          content: Text(
            '¿Quieres eliminar "${location.title}"?',
            style: const TextStyle(color: AppColors.mutedInk),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.mutedInk),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _locations.removeAt(index);
    });
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
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
          ),
          title: const Text(
            'Mis ubicaciones',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeader(),
                    const SizedBox(height: 22),
                    _buildCurrentLocationCard(),
                    const SizedBox(height: 26),
                    _buildSectionTitle(),
                    const SizedBox(height: 12),
                  ]),
                ),
              ),
              _buildLocationsList(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                sliver: SliverToBoxAdapter(child: _buildAddButton()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tus lugares frecuentes',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 27,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Guarda tus destinos habituales para solicitar un viaje más rápido.',
          style: TextStyle(
            color: AppColors.mutedInk,
            fontSize: 14,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentLocationCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.navyLight.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.my_location_rounded,
              color: AppColors.navyLight,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ubicación actual',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Usaremos tu ubicación al solicitar un viaje.',
                  style: TextStyle(
                    color: AppColors.mutedInk,
                    fontSize: 12,
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

  Widget _buildSectionTitle() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Ubicaciones guardadas',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          '${_locations.length}',
          style: const TextStyle(
            color: AppColors.navyLight,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationsList() {
    if (_locations.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.location_off_rounded,
                  size: 42,
                  color: AppColors.mutedInk,
                ),
                SizedBox(height: 14),
                Text(
                  'Aún no tienes ubicaciones guardadas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Agrega Casa, Trabajo u otro lugar frecuente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.mutedInk,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList.builder(
        itemCount: _locations.length,
        itemBuilder: (context, index) {
          final location = _locations[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _locationCard(location: location, index: index),
          );
        },
      ),
    );
  }

  Widget _locationCard({required _SavedLocation location, required int index}) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _selectLocation(location),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.mist,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(location.icon, color: AppColors.navyLight),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.title,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.mutedInk,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                color: AppColors.white,
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.mutedInk,
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    _editLocation(index);
                  } else if (value == 'delete') {
                    _deleteLocation(index);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      height: 54,
      child: FilledButton.icon(
        onPressed: _addLocation,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text(
          'Agregar ubicación',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _AddLocationSheet extends StatefulWidget {
  final _SavedLocation? initialLocation;
  final bool editing;

  const _AddLocationSheet({this.initialLocation, this.editing = false});

  @override
  State<_AddLocationSheet> createState() => _AddLocationSheetState();
}

class _AddLocationSheetState extends State<_AddLocationSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _addressController;

  _LocationType _type = _LocationType.other;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.initialLocation?.title ?? '',
    );

    _addressController = TextEditingController(
      text: widget.initialLocation?.address ?? '',
    );

    _type = widget.initialLocation?.type ?? _LocationType.other;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    final address = _addressController.text.trim();

    if (title.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa el nombre y la dirección.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      _SavedLocation(
        title: title,
        address: address,
        icon: _iconForType(_type),
        type: _type,
      ),
    );
  }

  IconData _iconForType(_LocationType type) {
    switch (type) {
      case _LocationType.home:
        return Icons.home_rounded;
      case _LocationType.work:
        return Icons.work_rounded;
      case _LocationType.other:
        return Icons.location_on_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset + 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.mist,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              widget.editing ? 'Editar ubicación' : 'Nueva ubicación',
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Guarda un lugar para encontrarlo rápidamente.',
              style: TextStyle(color: AppColors.mutedInk, fontSize: 13),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Nombre',
                hintText: 'Ej. Casa',
                prefixIcon: const Icon(Icons.bookmark_outline_rounded),
                filled: true,
                fillColor: AppColors.sand,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Dirección',
                hintText: 'Ej. Av. Principal #123',
                prefixIcon: const Icon(Icons.location_on_outlined),
                filled: true,
                fillColor: AppColors.sand,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Tipo de ubicación',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _typeChip(
                  type: _LocationType.home,
                  label: 'Casa',
                  icon: Icons.home_rounded,
                ),
                _typeChip(
                  type: _LocationType.work,
                  label: 'Trabajo',
                  icon: Icons.work_rounded,
                ),
                _typeChip(
                  type: _LocationType.other,
                  label: 'Otro',
                  icon: Icons.location_on_rounded,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  widget.editing ? 'Guardar cambios' : 'Guardar ubicación',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip({
    required _LocationType type,
    required String label,
    required IconData icon,
  }) {
    final selected = _type == type;

    return ChoiceChip(
      selected: selected,
      onSelected: (_) {
        setState(() {
          _type = type;
        });
      },
      avatar: Icon(
        icon,
        size: 18,
        color: selected ? AppColors.white : AppColors.navyLight,
      ),
      label: Text(label),
      selectedColor: AppColors.navy,
      backgroundColor: AppColors.mist,
      labelStyle: TextStyle(
        color: selected ? AppColors.white : AppColors.navy,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide.none,
    );
  }
}

class _SavedLocation {
  final String title;
  final String address;
  final IconData icon;
  final _LocationType type;

  const _SavedLocation({
    required this.title,
    required this.address,
    required this.icon,
    required this.type,
  });
}

enum _LocationType { home, work, other }
