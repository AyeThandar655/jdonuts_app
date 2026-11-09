import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_spacing.dart';

/// Bottom sheet for features with no real integration (social log in,
/// Terms of Use, Privacy Policy).
Future<void> showPlaceholderSheet(BuildContext context, {required String title}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      final textTheme = Theme.of(context).textTheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            0,
            AppSpacing.gutter,
            AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.titleLarge),
              const SizedBox(height: AppSpacing.s),
              Text(
                AppLocalizations.of(context).placeholderBody,
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    },
  );
}
