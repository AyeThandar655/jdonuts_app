import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/validators/otp_validator.dart';

/// Six OTP boxes backed by one hidden text field.
///
/// One field gives us, for free: auto-advance per digit, backspace moving
/// back, paste filling every box, the numeric keyboard and SMS autofill.
/// When [errorCount] changes the boxes shake and clear.
class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    required this.onCompleted,
    required this.errorCount,
    this.hasError = false,
    this.enabled = true,
    this.onChanged,
  });

  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final int errorCount;
  final bool hasError;
  final bool enabled;

  static const Key fieldKey = Key('otp-field');

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  late final AnimationController _shake =
      AnimationController(vsync: this, duration: AppDurations.otpShake);

  @override
  void initState() {
    super.initState();
    _focus.addListener(_rebuild);
    _controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(OtpInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorCount != oldWidget.errorCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onWrongCode());
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  void _onWrongCode() {
    if (!mounted) return;
    _controller.clear();
    if (!context.reduceMotion) _shake.forward(from: 0);
    if (widget.enabled) _focus.requestFocus();
  }

  void _onChanged(String value) {
    widget.onChanged?.call(value);
    if (validateOtp(value).isValid) widget.onCompleted(value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) => Transform.translate(
        offset: Offset(_shakeOffset(_shake.value), 0),
        child: child,
      ),
      child: Stack(
        children: [
          _Boxes(
            code: _controller.text,
            focused: _focus.hasFocus,
            hasError: widget.hasError,
          ),
          Positioned.fill(child: _hiddenField()),
        ],
      ),
    );
  }

  double _shakeOffset(double t) =>
      math.sin(t * math.pi * 2 * AppMotionValues.shakeCycles) *
      AppMotionValues.shakeDistancePx *
      (1 - t);

  Widget _hiddenField() {
    return Opacity(
      opacity: 0,
      child: TextField(
        key: OtpInput.fieldKey,
        controller: _controller,
        focusNode: _focus,
        enabled: widget.enabled,
        autofocus: true,
        showCursor: false,
        keyboardType: TextInputType.number,
        autofillHints: const [AutofillHints.oneTimeCode],
        inputFormatters: const [_OtpFormatter()],
        onChanged: _onChanged,
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
      ),
    );
  }
}

/// Keeps digits only and caps the length, so pasted text fills the boxes.
class _OtpFormatter extends TextInputFormatter {
  const _OtpFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = sanitizeOtpInput(newValue.text);
    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}

class _Boxes extends StatelessWidget {
  const _Boxes({
    required this.code,
    required this.focused,
    required this.hasError,
  });

  final String code;
  final bool focused;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final activeIndex = math.min(code.length, kOtpLength - 1);
    return Row(
      children: [
        for (var i = 0; i < kOtpLength; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.s),
          Expanded(
            child: _Box(
              digit: i < code.length ? code[i] : '',
              isActive: focused && i == activeIndex,
              hasError: hasError,
            ),
          ),
        ],
      ],
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({
    required this.digit,
    required this.isActive,
    required this.hasError,
  });

  final String digit;
  final bool isActive;
  final bool hasError;

  static const double _borderWidth = 1.6;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final border = hasError
        ? colors.error
        : isActive
            ? colors.primary
            : colors.surface;
    return AnimatedContainer(
      duration: context.motion(AppDurations.short),
      height: MediaQuery.textScalerOf(context).scale(AppSizes.otpBoxHeight),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.s),
        border: Border.all(color: border, width: _borderWidth),
      ),
      child: AnimatedSwitcher(
        duration: context.motion(AppDurations.short),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Text(
          digit,
          key: ValueKey(digit),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
