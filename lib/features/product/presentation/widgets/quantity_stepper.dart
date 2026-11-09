import 'package:flutter/material.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/cart_use_cases.dart';

/// White pill with − and + buttons; the number rolls up or down on change.
class QuantityStepper extends StatefulWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onChanged,
  });

  final int quantity;
  final ValueChanged<int> onChanged;

  static const Key incrementKey = Key('qty-increment');
  static const Key decrementKey = Key('qty-decrement');
  static const Key valueKey = Key('qty-value');

  @override
  State<QuantityStepper> createState() => _QuantityStepperState();
}

class _QuantityStepperState extends State<QuantityStepper> {
  bool _increasing = true;

  static const double _numberWidth = 44;

  @override
  void didUpdateWidget(QuantityStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    _increasing = widget.quantity >= oldWidget.quantity;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final q = widget.quantity;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: AppSpacing.l)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoundButton(
            key: QuantityStepper.decrementKey,
            icon: Icons.remove_rounded,
            label: l10n.productDecrease,
            onTap: q > kMinQuantity ? () => widget.onChanged(q - 1) : null,
          ),
          SizedBox(
            width: _numberWidth,
            child: ClipRect(
              child: AnimatedSwitcher(
                duration: context.motion(AppDurations.short),
                transitionBuilder: _roll,
                child: Text(
                  '$q',
                  key: ValueKey(q),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ),
          _RoundButton(
            key: QuantityStepper.incrementKey,
            icon: Icons.add_rounded,
            label: l10n.productIncrease,
            onTap: q < kMaxQuantity ? () => widget.onChanged(q + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _roll(Widget child, Animation<double> animation) {
    final incoming = child.key == ValueKey(widget.quantity);
    final direction = _increasing ? 1.0 : -1.0;
    final begin = Offset(0, incoming ? direction : -direction);
    return SlideTransition(
      position: Tween(begin: begin, end: Offset.zero).animate(animation),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  static const double _size = 36;
  static const double _iconSize = 22;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: AnimatedContainer(
        duration: context.motion(AppDurations.short),
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          color: onTap == null ? colors.disabled : colors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: _iconSize, color: colors.onPrimary),
      ),
    );
  }
}
