import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import 'app_scaffold.dart';

class PlaceholderPage extends StatelessWidget {
  final String title;
  final String? description;

  const PlaceholderPage({
    Key? key,
    required this.title,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
          child: Column(
            children: <Widget>[
              const Icon(
                Icons.construction_rounded,
                size: 56,
                color: AppColors.sunrise,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Próximamente',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                description ?? 'Esta sección está preparada para la siguiente etapa.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}