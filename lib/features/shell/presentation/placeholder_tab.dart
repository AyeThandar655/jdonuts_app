import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../l10n/app_localizations.dart';

/// Simple screen for tabs outside the scope of this build (Order, Wallet).
class PlaceholderTab extends StatelessWidget {
  const PlaceholderTab({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  static const double _iconSize = 56;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return ColoredBox(
      color: colors.scaffold,
      child: Center(
        child: FadeSlideIn(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: _iconSize, color: colors.primary),
                const SizedBox(height: AppSpacing.l),
                Text(title, style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.s),
                Text(
                  AppLocalizations.of(context).placeholderBody,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
