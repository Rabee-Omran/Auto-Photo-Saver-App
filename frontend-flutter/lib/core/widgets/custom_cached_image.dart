import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'loading_widget.dart';

class CustomCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final double borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CustomCachedImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: width,
        fit: fit,
        placeholder: (context, url) =>
            placeholder ??
            Container(
              height: height,
              width: width,
              color: colorScheme.onSurface.withValues(alpha: 0.06),
              child: const Center(child: LoadingWidget()),
            ),
        errorWidget: (context, url, error) =>
            errorWidget ??
            Container(
              height: height,
              width: width,
              color: colorScheme.onSurface.withValues(alpha: 0.06),
              child: Icon(
                Icons.broken_image,
                size: 64,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
      ),
    );
  }
}
