import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../foundation/platform_utils.dart';

/// Adaptive filter chip that renders a Material [FilterChip] on Material
/// platforms and an iOS-styled toggle container on Cupertino platforms.
class AdaptiveFilterChip extends StatelessWidget {
  /// The label text of the filter chip.
  final String label;

  /// Whether the chip is currently selected.
  final bool selected;

  /// Called when the chip's selection state changes.
  final ValueChanged<bool>? onSelected;

  /// Optional HugeIcon displayed before the label when selected.
  final IconData? selectedIcon;

  /// Optional HugeIcon displayed before the label when not selected.
  final IconData? icon;

  /// The background color when selected.
  final Color? selectedColor;

  /// The background color when not selected.
  final Color? backgroundColor;

  /// The text/icon color when selected.
  final Color? selectedForegroundColor;

  /// The text/icon color when not selected.
  final Color? foregroundColor;

  /// The border radius of the chip.
  final double borderRadius;

  /// Whether to show a checkmark when selected (Material only).
  final bool showCheckmark;

  /// The avatar widget (Material only).
  final Widget? avatar;

  const AdaptiveFilterChip({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
    this.selectedIcon,
    this.icon,
    this.selectedColor,
    this.backgroundColor,
    this.selectedForegroundColor,
    this.foregroundColor,
    this.borderRadius = 16,
    this.showCheckmark = true,
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return _buildCupertinoFilterChip(context);
    }
    return _buildMaterialFilterChip(context);
  }

  Widget _buildMaterialFilterChip(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      avatar: avatar ??
          (icon != null && !selected
              ? HugeIcon(icon: icon!, size: 18, color: foregroundColor ?? Theme.of(context).colorScheme.onSurface)
              : null),
      selectedColor: selectedColor,
      backgroundColor: backgroundColor,
      checkmarkColor: selectedForegroundColor,
      showCheckmark: showCheckmark,
      labelStyle: TextStyle(
        color: selected ? selectedForegroundColor : foregroundColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  Widget _buildCupertinoFilterChip(BuildContext context) {
    final primaryColor = CupertinoTheme.of(context).primaryColor;
    final effectiveSelectedBg =
        selectedColor ?? primaryColor.withValues(alpha: 0.15);
    final effectiveBg =
        backgroundColor ?? CupertinoColors.systemFill.resolveFrom(context);
    final effectiveSelectedFg = selectedForegroundColor ?? primaryColor;
    final effectiveFg =
        foregroundColor ?? CupertinoColors.label.resolveFrom(context);

    final currentBg = selected ? effectiveSelectedBg : effectiveBg;
    final currentFg = selected ? effectiveSelectedFg : effectiveFg;
    final border = selected
        ? Border.all(color: primaryColor.withValues(alpha: 0.3), width: 1)
        : Border.all(
            color: CupertinoColors.separator.resolveFrom(context),
            width: 0.5,
          );

    final effectiveIcon = selected ? (selectedIcon ?? icon) : icon;

    return GestureDetector(
      onTap: onSelected != null ? () => onSelected!(!selected) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: currentBg,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (effectiveIcon != null) ...[
              HugeIcon(icon: effectiveIcon, size: 16, color: currentFg),
              const SizedBox(width: 4),
            ] else if (selected) ...[
              HugeIcon(
                icon: HugeIcons.strokeRoundedCheckmarkSquare01,
                size: 14,
                color: currentFg,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: currentFg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
