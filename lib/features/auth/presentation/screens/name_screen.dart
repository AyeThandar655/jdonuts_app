import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/validators/name_validator.dart';
import '../auth_error_text.dart';
import '../controllers/registration_draft.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/touched_field.dart';

/// Screens 4 and 5: first and last name.
class NameScreen extends ConsumerStatefulWidget {
  const NameScreen({super.key});

  static const Key firstNameKey = Key('first-name-field');
  static const Key lastNameKey = Key('last-name-field');
  static const Key continueKey = Key('name-continue');

  @override
  ConsumerState<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends ConsumerState<NameScreen> {
  late final TouchedField _first = TouchedField(
    text: ref.read(registrationDraftProvider).firstName,
    onChanged: _rebuild,
  );
  late final TouchedField _last = TouchedField(
    text: ref.read(registrationDraftProvider).lastName,
    onChanged: _rebuild,
  );

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  void _rebuild() {
    if (!mounted) return;
    ref.read(registrationDraftProvider.notifier).update(
          (d) => d.copyWith(
            firstName: _first.controller.text,
            lastName: _last.controller.text,
          ),
        );
    setState(() {});
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.push(Routes.dateOfBirth);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final first = validateFirstName(_first.controller.text);
    final last = validateLastName(_last.controller.text);
    return AuthScaffold(
      step: 3,
      title: l10n.nameTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            fieldKey: NameScreen.firstNameKey,
            controller: _first.controller,
            focusNode: _first.focus,
            hint: l10n.nameFirstHint,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.givenName],
            errorText: _first.touched ? nameErrorText(l10n, first.errorOrNull) : null,
          ),
          const SizedBox(height: AppSpacing.m),
          AuthTextField(
            fieldKey: NameScreen.lastNameKey,
            controller: _last.controller,
            focusNode: _last.focus,
            hint: l10n.nameLastHint,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.familyName],
            errorText: _last.touched ? nameErrorText(l10n, last.errorOrNull) : null,
          ),
        ],
      ),
      action: PrimaryButton(
        key: NameScreen.continueKey,
        label: l10n.commonContinue,
        onPressed: first.isValid && last.isValid ? _submit : null,
      ),
    );
  }
}
