import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../motion/app_motion.dart';

/// Renders an [AsyncValue] with explicit loading, error and data states and
/// cross-fades between them.
///
/// Data wins over loading/error: during a background refresh the last good
/// data stays on screen instead of flashing a skeleton.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.data,
    required this.loading,
    required this.error,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function() loading;
  final Widget Function(Object error) error;

  @override
  Widget build(BuildContext context) {
    final current = value;
    final Widget child;
    if (current.hasValue) {
      child = KeyedSubtree(key: const ValueKey('data'), child: data(current.requireValue));
    } else if (current.hasError) {
      child = KeyedSubtree(key: const ValueKey('error'), child: error(current.error!));
    } else {
      child = KeyedSubtree(key: const ValueKey('loading'), child: loading());
    }
    return AnimatedSwitcher(
      duration: context.motion(AppDurations.medium),
      switchInCurve: AppCurves.standard,
      layoutBuilder: (currentChild, previous) => Stack(
        alignment: Alignment.topCenter,
        children: [...previous, ?currentChild],
      ),
      child: child,
    );
  }
}
