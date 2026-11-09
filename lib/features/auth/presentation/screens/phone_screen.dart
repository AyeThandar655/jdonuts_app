import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../core/domain/failure.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/auth_entities.dart';
import '../../domain/validators/phone_validator.dart';
import '../auth_error_text.dart';
import '../controllers/phone_step_controller.dart';
import '../controllers/registration_draft.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/inline_flow_switch.dart';

/// Screen 2: phone number, shared by register and log in.
class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key, required this.flow});

  final AuthFlow flow;

  static const Key fieldKey = Key('phone-field');
  static const Key continueKey = Key('phone-continue');

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  late final TextEditingController _controller =
      TextEditingController(text: ref.read(registrationDraftProvider).rawPhone);
  final FocusNode _focus = FocusNode();
  bool _touched = false;

  /// Longest input we accept, including spaces and dashes.
  static const int _maxInputLength = 16;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChanged);
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focus.hasFocus && _controller.text.isNotEmpty) {
      setState(() => _touched = true);
    }
  }

  void _onChanged(String value) {
    ref
        .read(registrationDraftProvider.notifier)
        .update((d) => d.copyWith(rawPhone: value));
    ref.read(phoneStepControllerProvider.notifier).clearFailure();
    setState(() {});
  }

  Future<void> _submit() async {
    _focus.unfocus();
    final ok = await ref
        .read(phoneStepControllerProvider.notifier)
        .submit(widget.flow);
    if (ok && mounted) await context.push(Routes.otp(widget.flow));
  }

  void _switchFlow(AuthFlow flow) {
    ref.read(phoneStepControllerProvider.notifier).clearFailure();
    ref.read(registrationDraftProvider.notifier).switchFlow(flow);
    context.pushReplacement(Routes.phone(flow));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final submit = ref.watch(phoneStepControllerProvider);
    final validation = validatePhone(_controller.text);
    final showError = _touched && !validation.isValid;
    return AuthScaffold(
      step: widget.flow == AuthFlow.register ? 1 : null,
      title: l10n.phoneTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            fieldKey: PhoneScreen.fieldKey,
            controller: _controller,
            focusNode: _focus,
            prefix: kMyanmarCountryCode,
            hint: l10n.phoneHint,
            keyboardType: TextInputType.phone,
            autofillHints: const [AutofillHints.telephoneNumberNational],
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9\s-]')),
              LengthLimitingTextInputFormatter(_maxInputLength),
            ],
            onChanged: _onChanged,
            errorText:
                showError ? phoneErrorText(l10n, validation.errorOrNull) : null,
          ),
          if (submit.failure case final failure?)
            _ServerError(failure: failure, onSwitchFlow: _switchFlow),
        ],
      ),
      action: PrimaryButton(
        key: PhoneScreen.continueKey,
        label: l10n.commonContinue,
        isLoading: submit.isSubmitting,
        onPressed: validation.isValid ? _submit : null,
      ),
    );
  }
}

class _ServerError extends StatelessWidget {
  const _ServerError({required this.failure, required this.onSwitchFlow});

  final Failure failure;
  final ValueChanged<AuthFlow> onSwitchFlow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (failure) {
      UserNotFoundFailure() => InlineFlowSwitch(
          key: const Key('not-registered'),
          message: l10n.phoneNotRegistered,
          actionLabel: l10n.phoneRegisterInstead,
          onAction: () => onSwitchFlow(AuthFlow.register),
        ),
      UserAlreadyExistsFailure() => InlineFlowSwitch(
          message: l10n.phoneAlreadyRegistered,
          actionLabel: l10n.phoneLogInInstead,
          onAction: () => onSwitchFlow(AuthFlow.login),
        ),
      _ => InlineFlowSwitch(message: authFailureText(l10n, failure)),
    };
  }
}
