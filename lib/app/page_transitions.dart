import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/motion/app_motion.dart';

/// Shared-axis transition: the new page slides in a little and fades in
/// while the old one slides out the other way and fades out.
CustomTransitionPage<void> sharedAxisPage(
  GoRouterState state,
  Widget child, {
  bool vertical = false,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppDurations.page,
    reverseTransitionDuration: AppDurations.page,
    transitionsBuilder: (context, animation, secondary, child) {
      if (context.reduceMotion) return child;
      final axis = vertical
          ? const Offset(0, AppMotionValues.slideDistance)
          : const Offset(AppMotionValues.slideDistance, 0);
      final incoming = CurvedAnimation(parent: animation, curve: AppCurves.page);
      final outgoing = CurvedAnimation(parent: secondary, curve: AppCurves.page);
      return SlideTransition(
        position: Tween(begin: axis, end: Offset.zero).animate(incoming),
        child: FadeTransition(
          opacity: incoming,
          child: SlideTransition(
            position: Tween(begin: Offset.zero, end: -axis).animate(outgoing),
            child: FadeTransition(
              opacity: Tween<double>(begin: 1, end: 0).animate(outgoing),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}

/// A plain cross-fade, used between flows (Onboarding, Welcome, the shell).
CustomTransitionPage<void> fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppDurations.page,
    transitionsBuilder: (context, animation, _, child) => context.reduceMotion
        ? child
        : FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: AppCurves.standard),
            child: child,
          ),
  );
}
