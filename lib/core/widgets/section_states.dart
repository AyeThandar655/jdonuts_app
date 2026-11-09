import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../domain/failure.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Inline error state for one section; the rest of the screen keeps working.
class SectionError extends StatelessWidget {
  const SectionError({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return _SectionMessage(
      icon: Icons.error_outline_rounded,
      iconColor: colors.error,
      message: failureMessage(l10n, error),
      action: onRetry == null
          ? null
          : TextButton(
              onPressed: onRetry,
              child: Text(
                l10n.commonRetry,
                style: TextStyle(color: colors.accentPink),
              ),
            ),
    );
  }
}

/// Inline empty state for one section.
class SectionEmpty extends StatelessWidget {
  const SectionEmpty({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => _SectionMessage(
        icon: Icons.inbox_outlined,
        iconColor: context.colors.textMuted,
        message: message,
      );
}

class _SectionMessage extends StatelessWidget {
  const _SectionMessage({
    required this.icon,
    required this.iconColor,
    required this.message,
    this.action,
  });

  final IconData icon;
  final Color iconColor;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.l),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// Maps a failure (or any error) to user-facing text.
String failureMessage(AppLocalizations l10n, Object error) => switch (error) {
      NetworkFailure() => l10n.errorNetwork,
      StorageFailure() => l10n.errorStorage,
      NotFoundFailure() => l10n.errorNotFound,
      ServerFailure() => l10n.errorServer,
      _ => l10n.errorGeneric,
    };
