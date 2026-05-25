import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_utils.dart';

/// A segment definition for [AdaptiveSegmentedControl].
class AdaptiveSegment<T> {
  final T value;
  final Widget label;
  final Widget? icon;
  final bool enabled;

  const AdaptiveSegment({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });
}

/// Adaptive segmented control.
///
/// Material: [SegmentedButton<T>] with M3 styling.
/// Cupertino: [CupertinoSlidingSegmentedControl<T>] with native iOS styling.
class AdaptiveSegmentedControl<T extends Object> extends StatelessWidget {
  final List<AdaptiveSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onSelectionChanged;
  final Color? backgroundColor;
  final Color? selectedColor;
  final EdgeInsetsGeometry? padding;

  const AdaptiveSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    this.backgroundColor,
    this.selectedColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return Padding(
        padding: padding ?? EdgeInsets.zero,
        child: CupertinoSlidingSegmentedControl<T>(
          groupValue: selected,
          onValueChanged: (value) {
            if (value != null) onSelectionChanged(value);
          },
          backgroundColor:
              backgroundColor ?? CupertinoColors.tertiarySystemFill,
          thumbColor: selectedColor ??
              CupertinoColors.systemBackground.resolveFrom(context),
          children: {
            for (final segment in segments)
              segment.value: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: segment.icon != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          segment.icon!,
                          const SizedBox(width: 6),
                          segment.label,
                        ],
                      )
                    : segment.label,
              ),
          },
        ),
      );
    }

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: SegmentedButton<T>(
        segments: segments
            .map(
              (segment) => ButtonSegment<T>(
                value: segment.value,
                label: segment.label,
                icon: segment.icon,
                enabled: segment.enabled,
              ),
            )
            .toList(),
        selected: {selected},
        onSelectionChanged: (values) {
          if (values.isNotEmpty) onSelectionChanged(values.first);
        },
        style: ButtonStyle(
          backgroundColor: selectedColor != null
              ? WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return selectedColor;
                  }
                  return backgroundColor;
                })
              : null,
        ),
      ),
    );
  }
}
