import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';

/// "What's this?" label, a divider and the product description.
class ProductDescription extends StatelessWidget {
  const ProductDescription({super.key, required this.text});

  final String text;

  static const double _labelWidth = 72;
  static const double _iconSize = 18;
  static const double _dividerWidth = 1;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _labelWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: _iconSize,
                  height: _iconSize,
                  decoration: BoxDecoration(color: colors.accentGreen, shape: BoxShape.circle),
                  child: Icon(Icons.question_mark_rounded, size: _iconSize * 0.7, color: colors.onPrimary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  AppLocalizations.of(context).productWhatsThis,
                  style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Container(
            width: _dividerWidth,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            color: colors.border,
          ),
          Expanded(child: Text(text, style: textTheme.bodySmall)),
        ],
      ),
    );
  }
}
