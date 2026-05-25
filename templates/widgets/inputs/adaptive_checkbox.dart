import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_widget.dart';

/// Adaptive checkbox.
///
/// Material: [Checkbox] with M3 styling.
/// Cupertino: [CupertinoCheckbox] with native iOS styling.
class AdaptiveCheckbox extends PlatformWidget<Checkbox, CupertinoCheckbox> {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final bool tristate;
  final Color? activeColor;
  final Color? checkColor;
  final OutlinedBorder? shape;
  final BorderSide? side;

  const AdaptiveCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.tristate = false,
    this.activeColor,
    this.checkColor,
    this.shape,
    this.side,
  });

  @override
  Checkbox buildMaterialWidget(BuildContext context) {
    return Checkbox(
      value: value,
      onChanged: onChanged,
      tristate: tristate,
      activeColor: activeColor,
      checkColor: checkColor,
      shape: shape,
      side: side,
    );
  }

  @override
  CupertinoCheckbox buildCupertinoWidget(BuildContext context) {
    return CupertinoCheckbox(
      value: value,
      onChanged: onChanged,
      tristate: tristate,
      activeColor: activeColor,
      checkColor: checkColor,
      shape: shape,
      side: side,
    );
  }
}
