import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_widget.dart';

/// Adaptive card widget.
///
/// Material: [Card] with M3 styling (elevation, shape).
/// Cupertino: [Container] with rounded corners and subtle background,
/// matching the iOS grouped list section aesthetic.
class AdaptiveCard extends PlatformWidget<Card, Widget> {
  final Widget? child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;
  final ShapeBorder? shape;
  final double borderRadius;
  final VoidCallback? onTap;

  const AdaptiveCard({
    super.key,
    this.child,
    this.margin,
    this.padding,
    this.color,
    this.elevation,
    this.shape,
    this.borderRadius = 12.0,
    this.onTap,
  });

  @override
  Card buildMaterialWidget(BuildContext context) {
    final content = padding != null
        ? Padding(padding: padding!, child: child)
        : child;

    final card = Card(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: color,
      elevation: elevation,
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
      child: onTap != null
          ? InkWell(
              borderRadius: BorderRadius.circular(borderRadius),
              onTap: onTap,
              child: content,
            )
          : content,
    );

    return card;
  }

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    final brightness = CupertinoTheme.brightnessOf(context);
    final resolvedColor = color ??
        (brightness == Brightness.dark
            ? const Color(0xFF1C1C1E)
            : CupertinoColors.white);

    Widget content = Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: padding,
      decoration: BoxDecoration(
        color: resolvedColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      content = GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
