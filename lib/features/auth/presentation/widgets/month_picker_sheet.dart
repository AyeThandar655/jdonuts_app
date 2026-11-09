import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';

const int _monthsPerYear = 12;

/// Lets the user pick a month; returns 1..12 or `null` if dismissed.
Future<int?> showMonthPicker(BuildContext context, {int? selected}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _MonthPicker(selected: selected),
  );
}

class _MonthPicker extends StatelessWidget {
  const _MonthPicker({required this.selected});

  final int? selected;

  static const double _maxHeightFraction = 0.7;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final format = DateFormat.MMMM(locale);
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * _maxHeightFraction,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context).dobMonthHint, style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _monthsPerYear,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final isSelected = month == selected;
                  return ListTile(
                    key: Key('month-$month'),
                    title: Text(
                      format.format(DateTime(DateTime.now().year, month)),
                      style: textTheme.bodyLarge?.copyWith(
                        color: isSelected ? colors.accentPink : colors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : null,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_rounded, color: colors.accentPink)
                        : null,
                    onTap: () => Navigator.of(context).pop(month),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
