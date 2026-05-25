import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_utils.dart';

/// Adaptive text / borderless button.
///
/// Material: [TextButton].
/// Cupertino: [CupertinoButton] (unfilled, text-only appearance).
class AdaptiveTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const AdaptiveTextButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding,
    this.color,
  });

  /// Convenience constructor with a text label.
  factory AdaptiveTextButton.label({
    Key? key,
    required VoidCallback? onPressed,
    required String label,
    EdgeInsetsGeometry? padding,
    Color? color,
  }) {
    return AdaptiveTextButton(
      key: key,
      onPressed: onPressed,
      padding: padding,
      color: color,
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return CupertinoButton(
        onPressed: onPressed,
        padding: padding ?? EdgeInsets.zero,
        color: null,
        child: DefaultTextStyle.merge(
          style: TextStyle(color: color),
          child: child,
        ),
      );
    }

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: padding,
        foregroundColor: color,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      child: child,
    );
  }
}
