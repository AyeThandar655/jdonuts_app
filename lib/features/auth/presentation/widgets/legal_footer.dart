import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/placeholder_sheet.dart';
import '../../../../l10n/app_localizations.dart';

class LegalFooter extends StatefulWidget {
  const LegalFooter({super.key});

  @override
  State<LegalFooter> createState() => _LegalFooterState();
}

class _LegalFooterState extends State<LegalFooter> {
  late final TapGestureRecognizer _terms = TapGestureRecognizer()
    ..onTap = () => _open(AppLocalizations.of(context).legalTerms);
  late final TapGestureRecognizer _privacy = TapGestureRecognizer()
    ..onTap = () => _open(AppLocalizations.of(context).legalPrivacy);

  void _open(String title) => showPlaceholderSheet(context, title: title);

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final base = Theme.of(context).textTheme.labelSmall;
    final link = base?.copyWith(color: colors.accentPink);
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: l10n.legalPrefix),
          TextSpan(text: l10n.legalTerms, style: link, recognizer: _terms),
          TextSpan(text: l10n.legalAnd),
          TextSpan(text: l10n.legalPrivacy, style: link, recognizer: _privacy),
          TextSpan(text: l10n.legalSuffix),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
