import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_widget.dart';

/// Adaptive toggle switch.
///
/// Material: [Switch] (M3 styling).
/// Cupertino: [CupertinoSwitch] with native iOS styling.
class AdaptiveSwitch extends PlatformWidget<Switch, CupertinoSwitch> {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveTrackColor;
  final Color? thumbColor;
  final DragStartBehavior dragStartBehavior;

  const AdaptiveSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveTrackColor,
    this.thumbColor,
    this.dragStartBehavior = DragStartBehavior.start,
  });

  @override
  Switch buildMaterialWidget(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeTrackColor: activeColor,
      inactiveTrackColor: inactiveTrackColor,
      thumbColor: thumbColor != null
          ? WidgetStatePropertyAll(thumbColor!)
          : null,
      dragStartBehavior: dragStartBehavior,
    );
  }

  @override
  CupertinoSwitch buildCupertinoWidget(BuildContext context) {
    return CupertinoSwitch(
      value: value,
      onChanged: onChanged,
      activeTrackColor: activeColor,
      inactiveTrackColor: inactiveTrackColor,
      thumbColor: thumbColor,
      dragStartBehavior: dragStartBehavior,
    );
  }
}
