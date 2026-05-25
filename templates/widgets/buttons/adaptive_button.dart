import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_utils.dart';

/// Adaptive primary button.
///
/// Material: [FilledButton] (M3 filled variant).
/// Cupertino: [CupertinoButton.filled] with native iOS styling.
class AdaptiveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final BorderRadius? borderRadius;

  const AdaptiveButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius,
  });

  /// Convenience constructor with a text label.
  factory AdaptiveButton.label({
    Key? key,
    required VoidCallback? onPressed,
    required String label,
    EdgeInsetsGeometry? padding,
    Color? color,
    BorderRadius? borderRadius,
  }) {
    return AdaptiveButton(
      key: key,
      onPressed: onPressed,
      padding: padding,
      color: color,
      borderRadius: borderRadius,
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return CupertinoButton.filled(
        onPressed: onPressed,
        padding: padding,
        borderRadius:
            borderRadius ?? const BorderRadius.all(Radius.circular(16)),
        child: child,
      );
    }

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: padding,
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(16)),
        ),
      ),
      child: child,
    );
  }
}
