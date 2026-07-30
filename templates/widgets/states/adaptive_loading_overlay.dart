import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/adaptive_tokens.dart';
import '../../foundation/platform_utils.dart';
import '../feedback/adaptive_progress_indicator.dart';

/// Covers its [child] with a scrim and a platform-native activity indicator
/// while [isLoading] is true.
///
/// Reach for this when an operation must block interaction with the screen
/// that is already on display — submitting a form, confirming a payment. For a
/// route that has no content yet use `AdaptiveLoadingPage`; for a single
/// action use `AdaptiveLoadingButton`.
///
/// Two details make this adaptive rather than merely cross-platform:
///
/// * the scrim resolves from [AdaptiveColors.background], which is a dynamic
///   colour on iOS (it follows the system appearance) and the surface colour
///   on Material — a hard-coded white scrim is invisible in dark mode;
/// * the indicator is [AdaptiveProgressIndicator], so it spins as a
///   `CupertinoActivityIndicator` on iOS and a `CircularProgressIndicator` on
///   Android.
///
/// Pointer events are absorbed while loading. That is the point of the widget:
/// a translucent scrim that still lets taps through is how an app ends up
/// submitting the same form twice.
///
/// ```dart
/// AdaptiveLoadingOverlay(
///   isLoading: controller.isSubmitting,
///   message: 'Signing in…',
///   child: const SignInForm(),
/// )
/// ```
class AdaptiveLoadingOverlay extends StatelessWidget {
  /// The content that the overlay covers. Always built, loading or not, so its
  /// state survives the transition.
  final Widget child;

  /// Whether the scrim and the indicator are shown.
  final bool isLoading;

  /// Optional line of text under the indicator, e.g. `'Signing in…'`.
  ///
  /// Keep it short and phrase it as an action in progress.
  final String? message;

  /// Overrides the scrim colour.
  ///
  /// When null the scrim is [AdaptiveColors.background] at [barrierOpacity].
  /// A colour passed here is used exactly as given — apply your own alpha.
  final Color? barrierColor;

  /// Alpha applied to the default scrim colour. Ignored when [barrierColor]
  /// is set.
  final double barrierOpacity;

  /// Announced by screen readers while the overlay is up.
  final String semanticsLabel;

  const AdaptiveLoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.barrierColor,
    this.barrierOpacity = 0.7,
    this.semanticsLabel = 'Loading',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        if (isLoading) Positioned.fill(child: _buildBarrier(context)),
      ],
    );
  }

  Widget _buildBarrier(BuildContext context) {
    final Color scrim = barrierColor ??
        AdaptiveColors.background(context).withValues(alpha: barrierOpacity);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: AdaptiveMotion.micro,
      // enterCurve, not appearCurve: the Material appear curve overshoots past
      // 1.0 and Opacity asserts on values outside 0…1.
      curve: AdaptiveMotion.enterCurve,
      builder: (BuildContext context, double value, Widget? child) =>
          Opacity(opacity: value, child: child),
      child: AbsorbPointer(
        child: Semantics(
          label: semanticsLabel,
          liveRegion: true,
          child: ColoredBox(
            color: scrim,
            child: Center(
              // The scroll view sizes itself to its content and only scrolls
              // when the overlay is shorter than it — a landscape phone with a
              // two-line message. Physics are left at the default on purpose:
              // an overlay that bounces when nothing overflows feels broken.
              child: SingleChildScrollView(
                padding: AdaptiveSpacing.pagePadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const AdaptiveProgressIndicator(),
                    if (message != null) ...<Widget>[
                      const SizedBox(height: AdaptiveSpacing.lg),
                      Text(
                        message!,
                        textAlign: TextAlign.center,
                        style: _messageStyle(context),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _messageStyle(BuildContext context) {
    final Color color = AdaptiveColors.secondaryLabel(context);
    if (PlatformUtils.isCupertino) {
      return CupertinoTheme.of(context)
          .textTheme
          .textStyle
          .copyWith(color: color);
    }
    return Theme.of(context).textTheme.bodyMedium?.copyWith(color: color) ??
        TextStyle(color: color);
  }
}
