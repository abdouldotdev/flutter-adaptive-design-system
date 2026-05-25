import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_utils.dart';

/// Adaptive tooltip that renders [Tooltip] on Material platforms
/// and a custom iOS-style overlay tooltip on Cupertino platforms.
class AdaptiveTooltip extends StatefulWidget {
  /// The widget below this widget in the tree.
  final Widget child;

  /// The text to display in the tooltip.
  final String message;

  /// Whether to prefer showing the tooltip below the child.
  final bool preferBelow;

  /// The vertical gap between the child and the tooltip.
  final double verticalOffset;

  /// Optional decoration override (Material only).
  final Decoration? decoration;

  /// Duration the tooltip is shown after trigger.
  final Duration showDuration;

  /// Duration to wait before showing the tooltip on long press.
  final Duration waitDuration;

  const AdaptiveTooltip({
    super.key,
    required this.child,
    required this.message,
    this.preferBelow = true,
    this.verticalOffset = 24.0,
    this.decoration,
    this.showDuration = const Duration(seconds: 2),
    this.waitDuration = const Duration(milliseconds: 500),
  });

  @override
  State<AdaptiveTooltip> createState() => _AdaptiveTooltipState();
}

class _AdaptiveTooltipState extends State<AdaptiveTooltip> {
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showCupertinoTooltip() {
    _removeOverlay();

    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return _CupertinoTooltipOverlay(
          message: widget.message,
          targetOffset: offset,
          targetSize: size,
          preferBelow: widget.preferBelow,
          verticalOffset: widget.verticalOffset,
          onDismiss: _removeOverlay,
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);

    Future.delayed(widget.showDuration, () {
      _removeOverlay();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return GestureDetector(
        onLongPress: _showCupertinoTooltip,
        child: widget.child,
      );
    }

    return Tooltip(
      message: widget.message,
      preferBelow: widget.preferBelow,
      verticalOffset: widget.verticalOffset,
      decoration: widget.decoration,
      showDuration: widget.showDuration,
      waitDuration: widget.waitDuration,
      child: widget.child,
    );
  }
}

class _CupertinoTooltipOverlay extends StatelessWidget {
  final String message;
  final Offset targetOffset;
  final Size targetSize;
  final bool preferBelow;
  final double verticalOffset;
  final VoidCallback onDismiss;

  const _CupertinoTooltipOverlay({
    required this.message,
    required this.targetOffset,
    required this.targetSize,
    required this.preferBelow,
    required this.verticalOffset,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = CupertinoTheme.brightnessOf(context);
    final isDark = brightness == Brightness.dark;

    final tooltipTop = preferBelow
        ? targetOffset.dy + targetSize.height + verticalOffset
        : null;
    final tooltipBottom = preferBelow
        ? null
        : MediaQuery.of(context).size.height -
            targetOffset.dy +
            verticalOffset;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDismiss,
          ),
        ),
        Positioned(
          top: tooltipTop,
          bottom: tooltipBottom,
          left: 16,
          right: 16,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xE6636366)
                    : const Color(0xE6333333),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
