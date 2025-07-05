import 'package:flutter/material.dart';
import '../../domain/entities/photo.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/utils/file_size_utils.dart';
import '../../../../core/extensions/localization_extension.dart';
import 'package:auto_photo_saver_app/core/widgets/custom_cached_image.dart';

class PhotoCard extends StatelessWidget {
  final Photo photo;
  const PhotoCard({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        child: Card(
          elevation: 2,
          color: colorScheme.surface,
          shadowColor: colorScheme.primary.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomCachedImage(
                  imageUrl: photo.image,
                  height: 270,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  borderRadius: 8,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.upload,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.latestUpload,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),

                    Text(
                      DateTimeUtils.formatDateShort(
                        photo.uploadedAt,
                        locale: Localizations.localeOf(context).languageCode,
                      ),
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.download,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.latestDownload,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),

                    Text(
                      photo.lastDownloadDate != null
                          ? DateTimeUtils.formatDateShort(
                              photo.lastDownloadDate!,
                              locale: Localizations.localeOf(
                                context,
                              ).languageCode,
                            )
                          : '-',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: colorScheme.onSurface.withValues(alpha: 0.12)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.insert_drive_file,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          photo.originalFileName,
                          style: textTheme.bodyLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sd_storage,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        FileSizeUtils.formatFileSize(
                          photo.fileSize,
                          locale: Localizations.localeOf(context).languageCode,
                          bytesUnit: l10n.sizeBytes,
                          kbUnit: l10n.sizeKilobytes,
                          mbUnit: l10n.sizeMegabytes,
                          gbUnit: l10n.sizeGigabytes,
                        ),
                        style: textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
