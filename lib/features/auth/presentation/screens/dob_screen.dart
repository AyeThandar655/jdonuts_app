import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/domain/validation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/validators/dob_validator.dart';
import '../auth_error_text.dart';
import '../controllers/profile_step_controller.dart';
import '../controllers/registration_draft.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/inline_flow_switch.dart';
import '../widgets/month_picker_sheet.dart';
import '../widgets/touched_field.dart';

/// Screen 6: month, day and year. Continue creates the account.
class DobScreen extends ConsumerStatefulWidget {
  const DobScreen({super.key});

  static const Key monthKey = Key('dob-month');
  static const Key dayKey = Key('dob-day');
  static const Key yearKey = Key('dob-year');
  static const Key continueKey = Key('dob-continue');

  @override
  ConsumerState<DobScreen> createState() => _DobScreenState();
}

class _DobScreenState extends ConsumerState<DobScreen> {
  late final RegistrationDraft _initial = ref.read(registrationDraftProvider);
  late final TextEditingController _month = TextEditingController();
  late final TouchedField _day = TouchedField(text: _initial.birthDay, onChanged: _sync);
  late final TouchedField _year = TouchedField(text: _initial.birthYear, onChanged: _sync);
  late int? _monthValue = _initial.birthMonth;

  static const int _dayDigits = 2;
  static const int _yearDigits = 4;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _month.text = _monthLabel(_monthValue);
  }

  @override
  void dispose() {
    _month.dispose();
    _day.dispose();
    _year.dispose();
    super.dispose();
  }

  String _monthLabel(int? month) => month == null
      ? ''
      : DateFormat.MMMM(Localizations.localeOf(context).toString())
          .format(DateTime(DateTime.now().year, month));

  void _sync() {
    if (!mounted) return;
    ref.read(registrationDraftProvider.notifier).update(
          (d) => d.copyWith(
            birthMonth: _monthValue,
            birthDay: _day.controller.text,
            birthYear: _year.controller.text,
          ),
        );
    setState(() {});
  }

  Future<void> _pickMonth() async {
    FocusScope.of(context).unfocus();
    final picked = await showMonthPicker(context, selected: _monthValue);
    if (picked == null || !mounted) return;
    _monthValue = picked;
    _month.text = _monthLabel(picked);
    _sync();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    // Success changes the session; the router guard then opens Welcome.
    await ref.read(profileStepControllerProvider.notifier).submit();
  }

  Validation<DateTime, DobError> _validate() => validateDateOfBirth(
        year: int.tryParse(_year.controller.text),
        month: _monthValue,
        day: int.tryParse(_day.controller.text),
        today: ref.read(clockProvider)(),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final submit = ref.watch(profileStepControllerProvider);
    final validation = _validate();
    final showError = _year.touched || _year.controller.text.length == _yearDigits;
    return AuthScaffold(
      step: 4,
      title: l10n.dobTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            fieldKey: DobScreen.monthKey,
            controller: _month,
            hint: l10n.dobMonthHint,
            readOnly: true,
            onTap: _pickMonth,
            trailing: Icon(Icons.expand_more_rounded, color: context.colors.textMuted),
          ),
          const SizedBox(height: AppSpacing.m),
          _numberField(_day, DobScreen.dayKey, l10n.dobDayHint, _dayDigits),
          const SizedBox(height: AppSpacing.m),
          _numberField(_year, DobScreen.yearKey, l10n.dobYearHint, _yearDigits),
          _DobError(
            text: showError ? dobErrorText(l10n, validation.errorOrNull) : null,
          ),
          if (submit.failure case final failure?)
            InlineFlowSwitch(message: authFailureText(l10n, failure)),
        ],
      ),
      action: PrimaryButton(
        key: DobScreen.continueKey,
        label: l10n.commonContinue,
        isLoading: submit.isSubmitting,
        onPressed: validation.isValid ? _submit : null,
      ),
    );
  }

  Widget _numberField(TouchedField field, Key key, String hint, int digits) =>
      AuthTextField(
        fieldKey: key,
        controller: field.controller,
        focusNode: field.focus,
        hint: hint,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(digits),
        ],
      );
}

class _DobError extends StatelessWidget {
  const _DobError({required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    final message = text;
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.m, left: AppSpacing.xs),
      child: Text(
        message,
        key: const Key('dob-error'),
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: context.colors.error),
      ),
    );
  }
}
