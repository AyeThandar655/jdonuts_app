import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/section_states.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/controllers/auth_session_controller.dart';

/// Settings tab with the Log out row used to test the session.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const Key logOutKey = Key('settings-log-out');
  static const Key confirmKey = Key('settings-log-out-confirm');

  Future<void> _logOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsLogOutTitle),
        content: Text(l10n.settingsLogOutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            key: confirmKey,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.settingsLogOut),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await ref.read(authSessionProvider.notifier).logOut();
    final failure = result.failureOrNull;
    if (failure == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(failureMessage(l10n, failure))),
    );
    // On success the router guard returns to Onboarding.
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final user = ref.watch(authSessionProvider).user;
    final textTheme = Theme.of(context).textTheme;
    return ColoredBox(
      color: colors.scaffold,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          children: [
            Text(l10n.navSettings, style: textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xxl),
            if (user != null)
              _Tile(
                icon: Icons.person_outline_rounded,
                title: user.fullName,
                subtitle: user.phone,
              ),
            const SizedBox(height: AppSpacing.m),
            _Tile(
              key: logOutKey,
              icon: Icons.logout_rounded,
              title: l10n.settingsLogOut,
              color: colors.error,
              onTap: () => _logOut(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.color,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tint = color ?? colors.textPrimary;
    final sub = subtitle;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadii.l),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.l)),
        leading: Icon(icon, color: tint),
        title: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: tint)),
        subtitle: sub == null ? null : Text(sub),
      ),
    );
  }
}
