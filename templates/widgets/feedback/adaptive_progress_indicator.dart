import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_widget.dart';

/// Adaptive progress indicator that renders [CircularProgressIndicator]
/// on Material platforms and [CupertinoActivityIndicator] on Cupertino.
class AdaptiveProgressIndicator
    extends PlatformWidget<CircularProgressIndicator, CupertinoActivityIndicator> {
  /// The progress value (0.0 to 1.0). If null, an indeterminate indicator
  /// is shown.
  final double? value;

  /// The color of the indicator.
  final Color? color;

  /// The radius of the Cupertino activity indicator.
  /// Defaults to [CupertinoActivityIndicator]'s default (10.0).
  final double cupertinoRadius;

  /// The stroke width of the Material circular progress indicator.
  final double materialStrokeWidth;

  const AdaptiveProgressIndicator({
    super.key,
    this.value,
    this.color,
    this.cupertinoRadius = 10.0,
    this.materialStrokeWidth = 4.0,
  });

  @override
  CircularProgressIndicator buildMaterialWidget(BuildContext context) {
    return CircularProgressIndicator(
      value: value,
      color: color,
      strokeWidth: materialStrokeWidth,
    );
  }

  @override
  CupertinoActivityIndicator buildCupertinoWidget(BuildContext context) {
    return CupertinoActivityIndicator(
      radius: cupertinoRadius,
      color: color,
    );
  }
}
