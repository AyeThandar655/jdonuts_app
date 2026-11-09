import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/core_providers.dart';
import '../domain/image_ref.dart';
import '../motion/app_motion.dart';
import '../theme/app_colors.dart';

/// Shows an [ImageRef]: the disk-cached network image when a server is
/// configured, with the bundled seed asset as placeholder and fallback, and a
/// visible error state if even the asset is missing.
class AppImage extends ConsumerWidget {
  const AppImage(
    this.image, {
    super.key,
    this.fit = BoxFit.contain,
    this.semanticLabel,
  });

  final ImageRef image;
  final BoxFit fit;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ref.watch(apiConfigProvider).resolveImageUrl(image.url);
    final asset = _AssetImage(
      path: image.asset,
      fit: fit,
      semanticLabel: semanticLabel,
    );
    if (url == null) return asset;
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      fadeInDuration: context.motion(AppDurations.short),
      fadeOutDuration: context.motion(AppDurations.instant),
      placeholder: (_, _) => asset,
      errorWidget: (_, _, _) => asset,
    );
  }
}

class _AssetImage extends StatelessWidget {
  const _AssetImage({required this.path, required this.fit, this.semanticLabel});

  final String path;
  final BoxFit fit;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Image.asset(
        path,
        fit: fit,
        semanticLabel: semanticLabel,
        errorBuilder: (_, _, _) => const ImageErrorPlaceholder(),
      );
}

/// Neutral tile shown when an image cannot be loaded at all.
class ImageErrorPlaceholder extends StatelessWidget {
  const ImageErrorPlaceholder({super.key});

  static const double _iconSize = 28;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ColoredBox(
      color: colors.surfaceMuted,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: _iconSize,
          color: colors.textMuted,
        ),
      ),
    );
  }
}
