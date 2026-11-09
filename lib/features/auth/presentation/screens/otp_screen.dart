import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/auth_entities.dart';
import '../../domain/validators/otp_validator.dart';
import '../auth_error_text.dart';
import '../controllers/otp_step_controller.dart';
import '../controllers/registration_draft.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/otp_input.dart';

/// Screen 3: six OTP boxes with a 5:00 resend countdown.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.flow});

  final AuthFlow flow;

  static const Key continueKey = Key('otp-continue');
  static const Key resendKey = Key('otp-resend');

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  String _code = '';

  void _onChanged(String code) {
    setState(() => _code = code);
    ref.read(otpStepControllerProvider.notifier).clearFailure();
  }

  Future<void> _verify(String code) async {
    final next = await ref
        .read(otpStepControllerProvider.notifier)
        .verify(code, widget.flow);
    if (!mounted) return;
    setState(() => _code = '');
    // A signed-in user is moved to Home by the router guard.
    if (next == OtpNext.profile) await context.push(Routes.name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(otpStepControllerProvider);
    final phone = ref.watch(registrationDraftProvider).verifiedPhone ?? '';
    final textTheme = Theme.of(context).textTheme;
    return AuthScaffold(
      step: widget.flow == AuthFlow.register ? 2 : null,
      title: l10n.otpTitle,
      subtitle: Text(l10n.otpSubtitle(kOtpLength, phone), style: textTheme.bodySmall),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OtpInput(
            enabled: !state.isLocked && !state.isSubmitting,
            errorCount: state.errorCount,
            hasError: state.failure != null,
            onChanged: _onChanged,
            onCompleted: _verify,
          ),
          _OtpMessage(state: state),
          const SizedBox(height: AppSpacing.xxl),
          _ResendRow(state: state, flow: widget.flow),
        ],
      ),
      action: PrimaryButton(
        key: OtpScreen.continueKey,
        label: l10n.commonContinue,
        isLoading: state.isSubmitting,
        onPressed: validateOtp(_code).isValid && !state.isLocked
            ? () => _verify(_code)
            : null,
      ),
    );
  }
}

class _OtpMessage extends StatelessWidget {
  const _OtpMessage({required this.state});

  final OtpState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final failure = state.failure;
    final text = state.isLocked
        ? l10n.otpErrorLocked(kMaxOtpAttempts)
        : failure == null
            ? null
            : authFailureText(l10n, failure);
    final remaining = kMaxOtpAttempts - state.failedAttempts;
    final detail = !state.isLocked && failure != null && state.failedAttempts > 0
        ? ' ${l10n.otpAttemptsLeft(remaining)}'
        : '';
    return AnimatedSize(
      duration: context.motion(AppDurations.short),
      alignment: Alignment.topCenter,
      child: text == null
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: AppSpacing.m),
              child: Text(
                '$text$detail',
                key: const Key('otp-error'),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: context.colors.error),
              ),
            ),
    );
  }
}

class _ResendRow extends ConsumerWidget {
  const _ResendRow({required this.state, required this.flow});

  final OtpState state;
  final AuthFlow flow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.textPrimary);
    final pink = style?.copyWith(color: colors.accentPink, fontWeight: FontWeight.w600);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.otpNotReceived, style: style),
        if (state.canResend)
          GestureDetector(
            key: OtpScreen.resendKey,
            onTap: () => ref.read(otpStepControllerProvider.notifier).resend(flow),
            child: Text(l10n.otpResend, style: pink),
          )
        else if (state.isResending)
          Text(l10n.otpSending, style: style)
        else
          Text.rich(
            TextSpan(
              style: style,
              children: [
                TextSpan(text: l10n.otpResendIn),
                TextSpan(text: formatCountdown(state.remaining), style: pink),
                TextSpan(text: l10n.otpMinutesSuffix),
              ],
            ),
          ),
      ],
    );
  }
}
