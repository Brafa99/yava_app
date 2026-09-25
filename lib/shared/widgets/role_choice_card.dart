import 'package:flutter/material.dart';

import 'package:yava_delivery_driver/features/auth/domain/entities/app_user.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

class RoleChoiceCard extends StatelessWidget {
  const RoleChoiceCard({
    super.key,
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final UserRole role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDriver = role == UserRole.driver;

    return Card(
      color: selected ? AppColors.mist : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? AppColors.navy : const Color(0xFFD7E0DA),
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: <Widget>[
              Icon(
                isDriver ? Icons.local_shipping : Icons.business,
                size: 32,
                color: isDriver ? AppColors.clay : AppColors.navy,
              ),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      role.displayName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      isDriver
                          ? 'Encuentra viajes y gestiona tus entregas.'
                          : 'Solicita transporte para tu estancia o negocio.',
                    ),
                  ],
                ),
              ),

              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off_outlined,
                color: selected ? AppColors.navy : AppColors.mutedInk,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
