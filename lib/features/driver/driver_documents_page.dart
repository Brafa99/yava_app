import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:yava_delivery_driver/app/theme/app_colors.dart';

class DriverDocumentsPage extends StatelessWidget {
  const DriverDocumentsPage({super.key});

  static const routePath = '/driver/documents';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/driver/home');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.sand,
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          foregroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/driver/home');
              }
            },
          ),
          title: const Text(
            'Mis documentos',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19),
          ),
        ),
        body: user == null
            ? const _DocumentsEmptyState()
            : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('driver_documents')
                    .doc(user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const _DocumentsMockView();
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.navy),
                    );
                  }

                  final data = snapshot.data?.data();

                  if (data == null) {
                    return const _DocumentsMockView();
                  }

                  return _DocumentsRealView(data: data);
                },
              ),
      ),
    );
  }
}

class _DocumentsRealView extends StatelessWidget {
  const _DocumentsRealView({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        const _DocumentsHeader(),
        const SizedBox(height: 20),
        _DocumentTile(
          title: 'Cédula de identidad',
          subtitle: _value(data['identityStatus']),
          icon: Icons.badge_rounded,
          status: _status(data['identityStatus']),
        ),
        _DocumentTile(
          title: 'Licencia de conducir',
          subtitle: _value(data['licenseStatus']),
          icon: Icons.credit_card_rounded,
          status: _status(data['licenseStatus']),
        ),
        _DocumentTile(
          title: 'SOAT',
          subtitle: _value(data['soatStatus']),
          icon: Icons.health_and_safety_rounded,
          status: _status(data['soatStatus']),
        ),
        _DocumentTile(
          title: 'Revisión técnica',
          subtitle: _value(data['technicalStatus']),
          icon: Icons.fact_check_rounded,
          status: _status(data['technicalStatus']),
        ),
        const SizedBox(height: 16),
        const _DocumentsInfo(),
      ],
    );
  }
}

class _DocumentsMockView extends StatelessWidget {
  const _DocumentsMockView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: const [
        _DocumentsHeader(),
        SizedBox(height: 20),
        _DocumentTile(
          title: 'Cédula de identidad',
          subtitle: 'Documento verificado',
          icon: Icons.badge_rounded,
          status: _DocumentStatus.approved,
        ),
        _DocumentTile(
          title: 'Licencia de conducir',
          subtitle: 'Vigente',
          icon: Icons.credit_card_rounded,
          status: _DocumentStatus.approved,
        ),
        _DocumentTile(
          title: 'SOAT',
          subtitle: 'Vigente hasta diciembre',
          icon: Icons.health_and_safety_rounded,
          status: _DocumentStatus.approved,
        ),
        _DocumentTile(
          title: 'Revisión técnica',
          subtitle: 'Pendiente de cargar',
          icon: Icons.fact_check_rounded,
          status: _DocumentStatus.pending,
        ),
        SizedBox(height: 16),
        _DocumentsInfo(),
      ],
    );
  }
}

class _DocumentsHeader extends StatelessWidget {
  const _DocumentsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.mist,
            child: Icon(
              Icons.folder_copy_rounded,
              color: AppColors.navy,
              size: 25,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Documentación',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Mantén tus documentos actualizados para operar.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.4,
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

enum _DocumentStatus { approved, pending, rejected }

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.status,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final _DocumentStatus status;

  @override
  Widget build(BuildContext context) {
    final isApproved = status == _DocumentStatus.approved;
    final isRejected = status == _DocumentStatus.rejected;

    final color = isApproved
        ? AppColors.success
        : isRejected
        ? AppColors.error
        : AppColors.warning;

    final statusText = isApproved
        ? 'Verificado'
        : isRejected
        ? 'Rechazado'
        : 'Pendiente';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.mist),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.mist,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.navy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navyLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.mutedInk,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentsInfo extends StatelessWidget {
  const _DocumentsInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(17),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.mutedInk),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Los documentos son revisados antes de habilitar '
              'la operación del conductor.',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 11,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentsEmptyState extends StatelessWidget {
  const _DocumentsEmptyState();

  @override
  Widget build(BuildContext context) {
    return const _DocumentsMockView();
  }
}

String _value(dynamic value) {
  if (value == null) return 'Sin información';
  return value.toString();
}

_DocumentStatus _status(dynamic value) {
  final text = value?.toString().toLowerCase() ?? '';

  if (text.contains('approved') ||
      text.contains('verified') ||
      text.contains('vigente') ||
      text.contains('verificado')) {
    return _DocumentStatus.approved;
  }

  if (text.contains('rejected') || text.contains('rechaz')) {
    return _DocumentStatus.rejected;
  }

  return _DocumentStatus.pending;
}
