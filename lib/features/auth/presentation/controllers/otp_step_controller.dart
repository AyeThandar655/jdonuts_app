import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/failure.dart';
import '../../../../core/domain/result.dart';
import '../../auth_providers.dart';
import '../../domain/auth_entities.dart';
import '../../domain/validators/otp_validator.dart';
import 'auth_session_controller.dart';
import 'registration_draft.dart';

final class OtpState {
  const OtpState({
    this.remaining = kOtpResendCountdown,
    this.failedAttempts = 0,
    this.isSubmitting = false,
    this.isResending = false,
    this.errorCount = 0,
    this.failure,
  });

  final Duration remaining;
  final int failedAttempts;
  final bool isSubmitting;
  final bool isResending;

  /// Increments on every wrong code; the boxes shake and clear when it changes.
  final int errorCount;
  final Failure? failure;

  bool get isLocked => isOtpLocked(failedAttempts);
  bool get canResend => remaining == Duration.zero && !isResending;

  OtpState copyWith({
    Duration? remaining,
    int? failedAttempts,
    bool? isSubmitting,
    bool? isResending,
    int? errorCount,
    Failure? failure,
    bool clearFailure = false,
  }) =>
      OtpState(
        remaining: remaining ?? this.remaining,
        failedAttempts: failedAttempts ?? this.failedAttempts,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        isResending: isResending ?? this.isResending,
        errorCount: errorCount ?? this.errorCount,
        failure: clearFailure ? null : failure ?? this.failure,
      );
}

/// What the OTP screen should do after a successful verify.
enum OtpNext { profile, signedIn }

final otpStepControllerProvider =
    NotifierProvider.autoDispose<OtpStepController, OtpState>(
  OtpStepController.new,
);

class OtpStepController extends Notifier<OtpState> {
  static const Duration _tick = Duration(seconds: 1);
  Timer? _timer;

  @override
  OtpState build() {
    ref.onDispose(() => _timer?.cancel());
    _startCountdown();
    return const OtpState();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(_tick, (_) => _onTick());
  }

  void _onTick() {
    final next = state.remaining - _tick;
    if (next <= Duration.zero) {
      _timer?.cancel();
      state = state.copyWith(remaining: Duration.zero);
    } else {
      state = state.copyWith(remaining: next);
    }
  }

  /// Hides the previous error once the user starts typing again.
  void clearFailure() {
    if (state.failure != null && !state.isLocked) {
      state = state.copyWith(clearFailure: true);
    }
  }

  /// Verifies [code]. Returns where to go next, or `null` on failure.
  Future<OtpNext?> verify(String code, AuthFlow flow) async {
    if (state.isSubmitting || state.isLocked) return null;
    state = state.copyWith(isSubmitting: true, clearFailure: true);
    final draft = ref.read(registrationDraftProvider);
    final result = await ref.read(verifyOtpProvider).call(
          phone: draft.verifiedPhone ?? '',
          code: code,
          flow: flow,
        );
    if (!ref.mounted) return null;
    return switch (result) {
      Ok(:final value) => _onVerified(value),
      Err(:final failure) => _onFailed(failure),
    };
  }

  OtpNext _onVerified(OtpOutcome outcome) {
    state = state.copyWith(isSubmitting: false);
    switch (outcome) {
      case SignedIn(:final user):
        ref.read(authSessionProvider.notifier).signedIn(user, isNewUser: false);
        return OtpNext.signedIn;
      case PhoneVerified():
        return OtpNext.profile;
    }
  }

  OtpNext? _onFailed(Failure failure) {
    final wrongCode = failure is InvalidOtpFailure;
    state = state.copyWith(
      isSubmitting: false,
      failure: failure,
      failedAttempts: wrongCode ? state.failedAttempts + 1 : null,
      errorCount: state.errorCount + 1,
    );
    return null;
  }

  /// Sends a new code, restarts the countdown and unlocks entry.
  Future<void> resend(AuthFlow flow) async {
    if (!state.canResend) return;
    state = state.copyWith(isResending: true, clearFailure: true);
    final draft = ref.read(registrationDraftProvider);
    final result = await ref.read(authRepositoryProvider).requestOtp(
          phone: draft.verifiedPhone ?? '',
          flow: flow,
        );
    if (!ref.mounted) return;
    state = OtpState(failure: result.failureOrNull);
    _startCountdown();
  }
}
