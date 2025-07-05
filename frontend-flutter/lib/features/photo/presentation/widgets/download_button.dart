import 'package:flutter/material.dart';
import '../../../../core/extensions/localization_extension.dart';

class DownloadButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;
  const DownloadButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.download_rounded),
        label: Text(l10n.latestDownload),
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
