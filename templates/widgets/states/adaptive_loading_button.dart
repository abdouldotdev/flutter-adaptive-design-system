import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_utils.dart';
import '../buttons/adaptive_button.dart';
import '../feedback/adaptive_progress_indicator.dart';

/// An [AdaptiveButton] that swaps its label for an activity indicator while
/// [isLoading] is true, and refuses taps in the meantime.
///
/// The label stays in the tree at zero opacity instead of being replaced, so
/// the button keeps its width: a button that shrinks the moment it is tapped
/// is a layout jump under the user's finger, and it is the reason the naive
/// version of this widget feels cheap.
///
/// Two platform branches matter here. The indicator itself is
/// [AdaptiveProgressIndicator] — an iOS spinner on Cupertino, a Material
/// circular one on Android — and its default colour is resolved against the
/// filled button's own background on each platform (white on the iOS blue
/// fill, `onPrimary` on the Material fill).
///
/// ```dart
/// AdaptiveLoadingButton.label(
///   label: 'Confirm',
///   isLoading: controller.isSubmitting,
///   onPressed: controller.submit,
/// )
/// ```
class AdaptiveLoadingButton extends StatelessWidget {
  /// Called on tap. Ignored while [isLoading] is true.
  final VoidCallback? onPressed;

  /// The button's label, normally a [Text].
  final Widget child;

  /// Whether the indicator replaces the label and the button is inert.
  final bool isLoading;

  /// Background colour, forwarded to [AdaptiveButton].
  final Color? color;

  /// Inner padding, forwarded to [AdaptiveButton].
  final EdgeInsetsGeometry? padding;

  /// Corner radius, forwarded to [AdaptiveButton].
  final BorderRadius? borderRadius;

  /// Overrides the indicator colour. Set it whenever you also set [color],
  /// since the default is computed for the platform's standard fill.
  final Color? indicatorColor;

  /// Side of the square reserved for the indicator, in logical pixels.
  final double indicatorSize;

  /// Announced by screen readers while loading.
  final String loadingSemanticsLabel;

  const AdaptiveLoadingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.color,
    this.padding,
    this.borderRadius,
    this.indicatorColor,
    this.indicatorSize = 20,
    this.loadingSemanticsLabel = 'Loading',
  });

  /// Convenience constructor with a text label, mirroring
  /// [AdaptiveButton.label].
  factory AdaptiveLoadingButton.label({
    Key? key,
    required VoidCallback? onPressed,
    required String label,
    bool isLoading = false,
    Color? color,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    Color? indicatorColor,
    double indicatorSize = 20,
    String loadingSemanticsLabel = 'Loading',
  }) {
    return AdaptiveLoadingButton(
      key: key,
      onPressed: onPressed,
      isLoading: isLoading,
      color: color,
      padding: padding,
      borderRadius: borderRadius,
      indicatorColor: indicatorColor,
      indicatorSize: indicatorSize,
      loadingSemanticsLabel: loadingSemanticsLabel,
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveButton(
      onPressed: isLoading ? null : onPressed,
      color: color,
      padding: padding,
      borderRadius: borderRadius,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Kept in the tree so the button does not resize when loading
          // starts, hidden from both the eye and the screen reader.
          Opacity(
            opacity: isLoading ? 0.0 : 1.0,
            child: ExcludeSemantics(excluding: isLoading, child: child),
          ),
          if (isLoading)
            Semantics(
              label: loadingSemanticsLabel,
              liveRegion: true,
              child: SizedBox(
                width: indicatorSize,
                height: indicatorSize,
                child: Center(
                  child: AdaptiveProgressIndicator(
                    color: indicatorColor ?? _defaultIndicatorColor(context),
                    cupertinoRadius: indicatorSize / 2,
                    materialStrokeWidth: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// The foreground of the platform's standard filled button: white on the iOS
  /// blue fill, `colorScheme.onPrimary` on the Material one.
  Color _defaultIndicatorColor(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return CupertinoColors.white;
    }
    return Theme.of(context).colorScheme.onPrimary;
  }
}
