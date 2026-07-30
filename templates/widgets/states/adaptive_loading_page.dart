import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/adaptive_tokens.dart';
import '../../foundation/platform_utils.dart';
import '../feedback/adaptive_progress_indicator.dart';

/// Full-screen loading state, meant to be the body of a scaffold while a route
/// has nothing to show yet.
///
/// Deliberately does not paint a background: it inherits the scaffold's, so it
/// works inside both a `CupertinoPageScaffold` and a `Scaffold` without
/// fighting either. Wrap it in a [ColoredBox] with
/// [AdaptiveColors.background] if you need it standalone.
///
/// The indicator is [AdaptiveProgressIndicator] and the message picks up the
/// platform's body style and secondary label colour, so the screen reads as
/// iOS on iOS and Material on Android.
///
/// ```dart
/// AdaptiveScaffold(
///   body: controller.isLoading
///       ? const AdaptiveLoadingPage(message: 'Loading your account…')
///       : const AccountView(),
/// )
/// ```
class AdaptiveLoadingPage extends StatelessWidget {
  /// Optional line of text under the indicator.
  ///
  /// Omit it for short waits — a bare indicator is calmer. Add it when the
  /// wait is long enough that the user deserves to know what is happening.
  final String? message;

  /// Padding around the indicator and its message.
  ///
  /// Defaults to [AdaptiveSpacing.pagePadding], which keeps a long message off
  /// the screen edges.
  final EdgeInsetsGeometry? padding;

  /// Announced by screen readers when the page appears.
  ///
  /// Falls back to [message] when null, then to `'Loading'`.
  final String? semanticsLabel;

  const AdaptiveLoadingPage({
    super.key,
    this.message,
    this.padding,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel ?? message ?? 'Loading',
      liveRegion: true,
      child: Center(
        // The scroll view sizes itself to its content and only scrolls when
        // the viewport is shorter than it — a landscape phone with a two-line
        // message. Physics are left at the default on purpose: a placeholder
        // that bounces when nothing overflows feels broken.
        child: SingleChildScrollView(
          padding: padding ?? AdaptiveSpacing.pagePadding,
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
