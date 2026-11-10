import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/placeholder_sheet.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/auth_entities.dart';
import '../controllers/registration_draft.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/donut_circles_art.dart';
import '../widgets/legal_footer.dart';

/// Screen 1: "Round food for every mood".
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  void _start(BuildContext context, WidgetRef ref, AuthFlow flow) {
    ref.read(registrationDraftProvider.notifier).start(flow);
    context.push(Routes.phone(flow));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: AuthBackground(
        child: Column(
          children: [
            const Expanded(child: DonutCirclesArt()),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Staggered(
                      index: 0,
                      child: Text(
                        l10n.onboardingTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _Staggered(
                      index: 1,
                      child: PrimaryButton(
                        key: const Key('get-started'),
                        label: l10n.onboardingGetStarted,
                        onPressed: () => _start(context, ref, AuthFlow.register),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    _Staggered(
                      index: 2,
                      child: _LoginPrompt(
                        onLogin: () => _start(context, ref, AuthFlow.login),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    const _Staggered(index: 3, child: _SocialButtons()),
                    const SizedBox(height: AppSpacing.l),
                    const _Staggered(index: 4, child: LegalFooter()),
                    const SizedBox(height: AppSpacing.l),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Staggered extends StatelessWidget {
  const _Staggered({required this.index, required this.child});

  final int index;
  final Widget child;

  /// Content waits for the donut circles to start drifting in.
  static const Duration _baseDelay = Duration(milliseconds: 380);

  @override
  Widget build(BuildContext context) => FadeSlideIn(
        delay: context.reduceMotion
            ? Duration.zero
            : _baseDelay + context.staggerDelay(index),
        child: child,
      );
}

class _LoginPrompt extends StatefulWidget {
  const _LoginPrompt({required this.onLogin});

  final VoidCallback onLogin;

  @override
  State<_LoginPrompt> createState() => _LoginPromptState();
}

class _LoginPromptState extends State<_LoginPrompt> {
  late final TapGestureRecognizer _recognizer = TapGestureRecognizer()
    ..onTap = widget.onLogin;

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final style = Theme.of(context).textTheme.bodySmall;
    return Text.rich(
      key: const Key('login-link'),
      TextSpan(
        style: style?.copyWith(color: context.colors.textPrimary),
        children: [
          TextSpan(text: l10n.onboardingHaveAccount),
          const TextSpan(text: ' '),
          TextSpan(
            text: l10n.onboardingLogIn,
            recognizer: _recognizer,
            style: TextStyle(
              color: context.colors.accentPink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButtons extends StatelessWidget {
  const _SocialButtons();

  static const double _iconSize = 26;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final entries = [
      (const _GoogleMark(size: _iconSize), l10n.socialGoogle),
      (Icon(Icons.apple, size: _iconSize, color: colors.textPrimary), l10n.socialApple),
      (const _FacebookMark(size: _iconSize), l10n.socialFacebook),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final (icon, label) in entries)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Pressable(
              semanticLabel: label,
              onTap: () => showPlaceholderSheet(context, title: label),
              child: SizedBox.square(
                dimension: AppSizes.iconButton,
                child: Center(child: icon),
              ),
            ),
          ),
      ],
    );
  }
}

/// Google's official multi-colour "G".
class _GoogleMark extends StatelessWidget {
  const _GoogleMark({required this.size});

  final double size;

  static const String _asset = 'assets/images/google_g.png';

  @override
  Widget build(BuildContext context) => Image.asset(
        _asset,
        width: size,
        height: size,
        errorBuilder: (context, _, _) => Text(
          'G',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: context.colors.brandGoogleBlue,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
        ),
      );
}

/// Facebook's mark: a blue disc with a white "f".
class _FacebookMark extends StatelessWidget {
  const _FacebookMark({required this.size});

  final double size;

  /// The white backing stays inside the blue disc.
  static const double _backingFraction = 0.7;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * _backingFraction,
            height: size * _backingFraction,
            decoration: BoxDecoration(color: colors.surface, shape: BoxShape.circle),
          ),
          Icon(Icons.facebook_rounded, size: size, color: colors.brandFacebook),
        ],
      ),
    );
  }
}
