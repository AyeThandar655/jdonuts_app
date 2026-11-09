import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// White rounded input from the design, with animated focus and error states.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.focusNode,
    this.prefix,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.onTap,
    this.trailing,
    this.fieldKey,
  });

  final TextEditingController controller;
  final String hint;
  final FocusNode? focusNode;
  final String? prefix;
  final String? errorText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? trailing;

  /// Key for the inner [TextField] (used by tests).
  final Key? fieldKey;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late final FocusNode _ownFocus = FocusNode();
  FocusNode get _focus => widget.focusNode ?? _ownFocus;

  static const double _focusedBorder = 1.6;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChanged);
    _ownFocus.dispose();
    super.dispose();
  }

  void _onFocusChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = widget.errorText != null;
    final borderColor = hasError
        ? colors.error
        : _focus.hasFocus
            ? colors.primary
            : colors.surface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: context.motion(AppDurations.short),
          curve: AppCurves.standard,
          constraints: const BoxConstraints(minHeight: AppSizes.inputHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.m),
            border: Border.all(color: borderColor, width: _focusedBorder),
          ),
          alignment: Alignment.center,
          child: Row(
            children: [
              if (widget.prefix != null) ...[
                Text(
                  widget.prefix!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: colors.textMuted),
                ),
                const SizedBox(width: AppSpacing.l),
              ],
              Expanded(child: _field(context)),
              ?widget.trailing,
            ],
          ),
        ),
        _ErrorMessage(text: widget.errorText),
      ],
    );
  }

  Widget _field(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return TextField(
      key: widget.fieldKey,
      controller: widget.controller,
      focusNode: _focus,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      textCapitalization: widget.textCapitalization,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      style: textTheme.bodyLarge,
      decoration: InputDecoration(
        isCollapsed: true,
        border: InputBorder.none,
        hintText: widget.hint,
        hintStyle: textTheme.bodyLarge?.copyWith(color: context.colors.textMuted),
      ),
    );
  }
}

/// Error line that slides open under a field.
class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedSize(
      duration: context.motion(AppDurations.short),
      curve: AppCurves.standard,
      alignment: Alignment.topLeft,
      child: text == null
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.s,
                left: AppSpacing.xs,
              ),
              child: Text(
                text!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: colors.error),
              ),
            ),
    );
  }
}
