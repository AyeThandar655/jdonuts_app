import 'package:flutter/widgets.dart';

/// A text controller + focus node that remembers whether the user has left
/// the field, so errors appear on blur and then update live.
class TouchedField {
  TouchedField({String text = '', required VoidCallback onChanged})
      : controller = TextEditingController(text: text),
        _onChanged = onChanged {
    controller.addListener(_onChanged);
    focus.addListener(_onFocus);
  }

  final TextEditingController controller;
  final FocusNode focus = FocusNode();
  final VoidCallback _onChanged;
  bool touched = false;

  void _onFocus() {
    if (!focus.hasFocus && !touched) {
      touched = true;
      _onChanged();
    }
  }

  void dispose() {
    controller.removeListener(_onChanged);
    focus.removeListener(_onFocus);
    controller.dispose();
    focus.dispose();
  }
}
