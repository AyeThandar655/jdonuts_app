import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../di/core_providers.dart';
import '../motion/app_motion.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// A small bar that slides in while the device is offline.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  static const double _iconSize = 16;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(isOnlineProvider).value ?? true;
    final colors = context.colors;
    return AnimatedSize(
      duration: context.motion(AppDurations.offlineBanner),
      curve: AppCurves.standard,
      child: online
          ? const SizedBox(width: double.infinity)
          : Container(
              width: double.infinity,
              color: colors.offlineBanner,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.l,
                vertical: AppSpacing.s,
              ),
              child: Row(
                children: [
                  Icon(Icons.cloud_off_rounded, size: _iconSize, color: colors.surface),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).offlineBanner,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: colors.surface),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
