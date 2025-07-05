import 'package:flutter/material.dart';
import '../../../../core/extensions/localization_extension.dart';
import '../../../../core/theme/app_colors.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.photo_library_outlined, size: 80, color: AppColors.neutral),
        const SizedBox(height: 16),
        Text(
          l10n.noImage,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
