import 'package:flutter/material.dart';

import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

final class NavItem {
  const NavItem({required this.icon, required this.label, required this.key});

  final IconData icon;
  final String label;
  final Key key;
}

/// Blue bar whose pink "active" pill slides between tabs.
class JDonutsNavBar extends StatelessWidget {
  const JDonutsNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// The active slot is this many times wider than an inactive one.
  static const double _activeWeight = 2.4;
  static const double _iconSize = 22;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final duration = context.motion(AppDurations.navPill);
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        child: Container(
          height: AppSizes.bottomNavHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(AppRadii.xxl),
            boxShadow: [BoxShadow(color: colors.shadow, blurRadius: AppSpacing.xl)],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final unit = constraints.maxWidth / (items.length - 1 + _activeWeight);
              double widthOf(int i) => i == currentIndex ? unit * _activeWeight : unit;
              final left = List<double>.generate(
                items.length,
                (i) => List.generate(i, widthOf).fold<double>(0, (a, b) => a + b),
              );
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  AnimatedPositioned(
                    duration: duration,
                    curve: AppCurves.emphasized,
                    left: left[currentIndex] + AppSpacing.xs,
                    width: widthOf(currentIndex) - AppSpacing.s,
                    top: (AppSizes.bottomNavHeight - AppSizes.bottomNavPill) / 2,
                    height: AppSizes.bottomNavPill,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.accentPink,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        border: Border.all(color: colors.surface, width: 2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < items.length; i++)
                        AnimatedContainer(
                          duration: duration,
                          curve: AppCurves.emphasized,
                          width: widthOf(i),
                          child: _NavButton(
                            item: items[i],
                            selected: i == currentIndex,
                            iconSize: _iconSize,
                            onTap: () => onTap(i),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.iconSize,
    required this.onTap,
  });

  final NavItem item;
  final bool selected;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      child: GestureDetector(
        key: item.key,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: AppSizes.bottomNavHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: iconSize, color: colors.onPrimary),
              Flexible(
                child: AnimatedSize(
                  duration: context.motion(AppDurations.navPill),
                  curve: AppCurves.emphasized,
                  child: selected
                      ? Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.xs),
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colors.onPrimary),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
