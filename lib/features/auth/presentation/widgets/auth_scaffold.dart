import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../l10n/app_localizations.dart';
import 'legal_footer.dart';
import 'registration_progress_ring.dart';

/// Shared layout for the phone, OTP, name and date-of-birth steps:
/// pink gradient, back arrow, progress ring, title, body, bottom action and
/// legal footer.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.action,
    this.subtitle,
    this.step,
    this.onBack,
  });

  final String title;
  final Widget? subtitle;
  final Widget body;
  final Widget action;

  /// Registration step for the ring; `null` hides it (log in flow).
  final int? step;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.m),
                _TopBar(step: step, onBack: onBack),
                const SizedBox(height: AppSpacing.xxl),
                Expanded(child: _content(context)),
                action,
                const SizedBox(height: AppSpacing.xxl),
                const LegalFooter(),
                const SizedBox(height: AppSpacing.l),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeSlideIn(
              child: Text(title, style: Theme.of(context).textTheme.headlineLarge),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.s),
              subtitle!,
            ],
            const SizedBox(height: AppSpacing.xxl),
            body,
          ],
        ),
      );
}

/// Pink-to-white wash behind onboarding and auth screens.
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.authGradientTop, colors.authGradientBottom],
        ),
      ),
      child: child,
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.step, required this.onBack});

  final int? step;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BackSquareButton(onTap: onBack ?? () => Navigator.of(context).maybePop()),
        const Spacer(),
        if (step != null) RegistrationProgressRing(step: step!),
      ],
    );
  }
}

/// The white rounded square with a back arrow.
class BackSquareButton extends StatelessWidget {
  const BackSquareButton({super.key, required this.onTap, this.filled = true});

  final VoidCallback onTap;
  final bool filled;

  static const double _iconSize = 20;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Pressable(
      onTap: onTap,
      semanticLabel: AppLocalizations.of(context).commonBack,
      child: Container(
        width: AppSizes.iconButton,
        height: AppSizes.iconButton,
        decoration: filled
            ? BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadii.s),
              )
            : null,
        child: Icon(Icons.arrow_back_rounded, size: _iconSize, color: colors.textPrimary),
      ),
    );
  }
}
