import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../foundation/platform_utils.dart';

/// Adaptive chip that renders a Material [Chip] on Material platforms
/// and an iOS-styled tag/chip [Container] on Cupertino platforms.
class AdaptiveChip extends StatelessWidget {
  /// The label text of the chip.
  final String label;

  /// Optional HugeIcon displayed before the label.
  final List<List<dynamic>>? icon;

  /// Called when the chip's delete button is tapped.
  /// If null, no delete button is shown.
  final VoidCallback? onDeleted;

  /// Called when the chip is tapped.
  final VoidCallback? onTap;

  /// The background color of the chip.
  final Color? backgroundColor;

  /// The text/icon color of the chip.
  final Color? foregroundColor;

  /// The border color of the chip. If null, a default is used.
  final Color? borderColor;

  /// The avatar widget (Material only).
  final Widget? avatar;

  /// The border radius of the chip.
  final double borderRadius;

  /// The padding inside the chip.
  final EdgeInsets? padding;

  const AdaptiveChip({
    super.key,
    required this.label,
    this.icon,
    this.onDeleted,
    this.onTap,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.avatar,
    this.borderRadius = 16,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return _buildCupertinoChip(context);
    }
    return _buildMaterialChip(context);
  }

  Widget _buildMaterialChip(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(label),
        avatar: avatar ??
            (icon != null
                ? HugeIcon(icon: icon!, size: 18, color: foregroundColor ?? Theme.of(context).colorScheme.onSurface)
                : null),
        deleteIcon: onDeleted != null
            ? HugeIcon(
                icon: HugeIcons.strokeRoundedCancelCircle,
                size: 18,
                color: foregroundColor ?? Theme.of(context).colorScheme.onSurface,
              )
            : null,
        onDeleted: onDeleted,
        backgroundColor: backgroundColor,
        labelStyle: foregroundColor != null
            ? TextStyle(color: foregroundColor)
            : null,
        side: borderColor != null
            ? BorderSide(color: borderColor!)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding,
      ),
    );
  }

  Widget _buildCupertinoChip(BuildContext context) {
    final effectiveBackground = backgroundColor ??
        CupertinoColors.systemFill.resolveFrom(context);
    final effectiveForeground = foregroundColor ??
        CupertinoColors.label.resolveFrom(context);
    final effectiveBorder = borderColor ??
        CupertinoColors.separator.resolveFrom(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: effectiveBackground,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: effectiveBorder, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              HugeIcon(icon: icon!, size: 16, color: effectiveForeground),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: effectiveForeground,
              ),
            ),
            if (onDeleted != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDeleted,
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedCancelCircle,
                  size: 16,
                  color: effectiveForeground.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
