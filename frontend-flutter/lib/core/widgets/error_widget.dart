import 'package:auto_photo_saver_app/core/extensions/localization_extension.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../localization/app_strings.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const CustomErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 12),
          Text(
            context.tryTranslate(message),
            style: TextStyle(color: AppColors.error, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: Text(strings.retry),
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }
}
