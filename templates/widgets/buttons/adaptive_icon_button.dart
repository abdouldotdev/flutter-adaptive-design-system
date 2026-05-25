import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_utils.dart';

/// Adaptive icon button.
///
/// Material: [IconButton] with M3 styling.
/// Cupertino: [CupertinoButton] wrapping an [Icon] with no background.
class AdaptiveIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final double? iconSize;
  final Color? color;
  final String? tooltip;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraints;

  const AdaptiveIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.iconSize,
    this.color,
    this.tooltip,
    this.padding,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      Widget button = CupertinoButton(
        onPressed: onPressed,
        padding: padding ?? EdgeInsets.zero,
        child: IconTheme(
          data: IconThemeData(
            size: iconSize ?? 24,
            color: color ?? CupertinoTheme.of(context).primaryColor,
          ),
          child: icon,
        ),
      );

      if (tooltip != null) {
        button = Tooltip(message: tooltip!, child: button);
      }

      return button;
    }

    return IconButton(
      onPressed: onPressed,
      icon: icon,
      iconSize: iconSize,
      color: color,
      tooltip: tooltip,
      padding: padding,
      constraints: constraints,
    );
  }
}
