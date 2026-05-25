import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_utils.dart';

/// Adaptive floating action button.
///
/// Material: [FloatingActionButton] with M3 styling.
/// Cupertino: Circular [CupertinoButton] that visually approximates a FAB.
///
/// Set [showOnCupertino] to `false` (default) to hide the FAB entirely
/// on iOS/macOS, which is the standard iOS convention.
class AdaptiveFab extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool mini;
  final bool showOnCupertino;
  final ShapeBorder? shape;

  const AdaptiveFab({
    super.key,
    required this.onPressed,
    required this.child,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.mini = false,
    this.showOnCupertino = false,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      if (!showOnCupertino) return const SizedBox.shrink();

      final cupertinoTheme = CupertinoTheme.of(context);
      final resolvedBackground =
          backgroundColor ?? cupertinoTheme.primaryColor;
      final resolvedForeground = foregroundColor ?? CupertinoColors.white;
      final size = mini ? 40.0 : 56.0;

      Widget button = GestureDetector(
        onTap: onPressed,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: resolvedBackground,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconTheme(
            data: IconThemeData(color: resolvedForeground, size: 24),
            child: Center(child: child),
          ),
        ),
      );

      if (tooltip != null) {
        button = Tooltip(message: tooltip!, child: button);
      }

      return button;
    }

    if (mini) {
      return FloatingActionButton.small(
        onPressed: onPressed,
        tooltip: tooltip,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: elevation,
        shape: shape,
        child: child,
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      shape: shape,
      child: child,
    );
  }
}
