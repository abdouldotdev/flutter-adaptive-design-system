import 'package:flutter/widgets.dart';

import '../../foundation/adaptive_tokens.dart';
import '../../foundation/platform_utils.dart';

/// Dims a subtree and stops it receiving pointer events while [disabled] is
/// true.
///
/// This is for composites that have no `onPressed` of their own to nullify — a
/// form section, a card, a row of controls. A single button should be disabled
/// by passing `null` to its callback, which gives the platform's own disabled
/// rendering.
///
/// The opacity is a platform token, not a magic number: iOS dims disabled
/// controls to 0.4 (`CupertinoButton`'s own disabled opacity) while Material 3
/// specifies 0.38 for disabled content. They are close enough that using one
/// for both is invisible, and different enough that the correct one is free.
///
/// [Semantics.enabled] is set as well, so assistive technologies announce the
/// subtree as disabled instead of silently ignoring taps that never land.
///
/// ```dart
/// AdaptiveDisabled(
///   disabled: !controller.isFormValid,
///   child: const PaymentDetailsSection(),
/// )
/// ```
class AdaptiveDisabled extends StatelessWidget {
  /// Whether the subtree is dimmed and inert.
  final bool disabled;

  /// The subtree being enabled or disabled.
  final Widget child;

  /// Overrides the dimmed opacity. Defaults to the platform's value: 0.4 on
  /// Cupertino, 0.38 on Material.
  final double? disabledOpacity;

  /// Duration of the fade between the two states. Defaults to
  /// [AdaptiveMotion.micro] — this is state feedback, not a transition.
  final Duration? duration;

  const AdaptiveDisabled({
    super.key,
    required this.disabled,
    required this.child,
    this.disabledOpacity,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final double target =
        disabled ? (disabledOpacity ?? _platformOpacity) : 1.0;

    return Semantics(
      enabled: !disabled,
      child: IgnorePointer(
        ignoring: disabled,
        child: AnimatedOpacity(
          opacity: target,
          duration: duration ?? AdaptiveMotion.micro,
          // enterCurve rather than appearCurve: the Material appear curve
          // overshoots past 1.0 and Opacity asserts on values outside 0…1.
          curve: AdaptiveMotion.enterCurve,
          child: child,
        ),
      ),
    );
  }

  double get _platformOpacity => PlatformUtils.isCupertino ? 0.4 : 0.38;
}
