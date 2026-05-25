import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_widget.dart';

/// Adaptive slider.
///
/// Material: [Slider] with M3 styling.
/// Cupertino: [CupertinoSlider] with native iOS styling.
class AdaptiveSlider extends PlatformWidget<Slider, CupertinoSlider> {
  final double value;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;
  final int? divisions;
  final Color? activeColor;
  final Color? thumbColor;

  const AdaptiveSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.activeColor,
    this.thumbColor,
  });

  @override
  Slider buildMaterialWidget(BuildContext context) {
    return Slider(
      value: value,
      onChanged: onChanged,
      onChangeStart: onChangeStart,
      onChangeEnd: onChangeEnd,
      min: min,
      max: max,
      divisions: divisions,
      activeColor: activeColor,
      thumbColor: thumbColor,
    );
  }

  @override
  CupertinoSlider buildCupertinoWidget(BuildContext context) {
    return CupertinoSlider(
      value: value,
      onChanged: onChanged ?? (_) {},
      onChangeStart: onChangeStart,
      onChangeEnd: onChangeEnd,
      min: min,
      max: max,
      divisions: divisions,
      activeColor: activeColor,
      thumbColor: thumbColor ?? CupertinoColors.white,
    );
  }
}
