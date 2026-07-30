import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/adaptive_icons.dart';
import '../../foundation/adaptive_tokens.dart';
import '../../foundation/platform_utils.dart';

/// Non-blocking error, shown as a strip above the content that stays on
/// screen.
///
/// Use it when the screen still has something to show — a cached list, a form
/// mid-edit — and taking that away would lose the user's work. When the
/// failure left nothing to display, use `AdaptiveErrorState` instead.
///
/// The two platforms genuinely diverge here, which is why this is not a single
/// styled container:
///
/// * **Material** renders a real [MaterialBanner], the M3 component for
///   exactly this job, tinted with `errorContainer` and with its actions in
///   the banner's own overflow bar.
/// * **Cupertino** renders a tinted strip with a hairline separator
///   underneath. iOS has no banner component; a system red wash under the
///   navigation bar is the platform's idiom.
///
/// ```dart
/// AdaptiveErrorBanner(
///   message: 'Offline — showing your last known balance.',
///   onRetry: controller.reload,
///   onDismiss: controller.clearError,
/// )
/// ```
class AdaptiveErrorBanner extends StatelessWidget {
  /// What went wrong, in the user's language. Keep it to one or two lines:
  /// the banner is a strip, not a dialog.
  final String message;

  /// Called when the dismiss action is tapped. The action is only built when
  /// this is non-null.
  final VoidCallback? onDismiss;

  /// Label of the dismiss action on Material. Cupertino uses a close glyph
  /// instead, which is the iOS convention.
  final String dismissLabel;

  /// Called when the retry action is tapped. The action is only built when
  /// this is non-null.
  final VoidCallback? onRetry;

  /// Label of the retry action.
  final String retryLabel;

  /// The glyph shown before the message.
  final IconData icon;

  const AdaptiveErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.dismissLabel = 'Dismiss',
    this.onRetry,
    this.retryLabel = 'Retry',
    this.icon = AdaptiveIcons.error,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return _buildCupertino(context);
    }
    return _buildMaterial(context);
  }

  Widget _buildCupertino(BuildContext context) {
    final Color accent = AdaptiveColors.destructive(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        border: Border(
          // Width 0 asks for a hairline: one physical pixel, the iOS
          // separator, rather than one logical pixel.
          bottom: BorderSide(color: AdaptiveColors.separator(context), width: 0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AdaptiveSpacing.page,
          vertical: AdaptiveSpacing.sm,
        ),
        child: Row(
          children: <Widget>[
            AdaptiveIcon(icon, size: 18, color: accent),
            const SizedBox(width: AdaptiveSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: CupertinoTheme.of(context)
                    .textTheme
                    .textStyle
                    .copyWith(color: AdaptiveColors.label(context)),
              ),
            ),
            if (onRetry != null)
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onRetry,
                child: Text(
                  retryLabel,
                  style: CupertinoTheme.of(context)
                      .textTheme
                      .actionTextStyle
                      .copyWith(color: AdaptiveColors.primary(context)),
                ),
              ),
            if (onDismiss != null)
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onDismiss,
                child: AdaptiveIcon(
                  AdaptiveIcons.close,
                  size: 18,
                  color: AdaptiveColors.secondaryLabel(context),
                  semanticLabel: dismissLabel,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterial(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final ButtonStyle actionStyle = TextButton.styleFrom(
      foregroundColor: scheme.onErrorContainer,
    );

    final List<Widget> actions = <Widget>[
      if (onRetry != null)
        TextButton(
          onPressed: onRetry,
          style: actionStyle,
          child: Text(retryLabel),
        ),
      if (onDismiss != null)
        TextButton(
          onPressed: onDismiss,
          style: actionStyle,
          child: Text(dismissLabel),
        ),
    ];

    // MaterialBanner asserts that it has at least one action, so a banner with
    // neither retry nor dismiss has to be built by hand. Same tokens, same
    // geometry, no actions.
    if (actions.isEmpty) {
      return _buildMaterialStatic(context, scheme);
    }

    return MaterialBanner(
      backgroundColor: scheme.errorContainer,
      contentTextStyle: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(color: scheme.onErrorContainer),
      leading: AdaptiveIcon(icon, size: 24, color: scheme.onErrorContainer),
      content: Text(message),
      actions: actions,
    );
  }

  Widget _buildMaterialStatic(BuildContext context, ColorScheme scheme) {
    return Material(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AdaptiveSpacing.page,
          vertical: AdaptiveSpacing.md,
        ),
        child: Row(
          children: <Widget>[
            AdaptiveIcon(icon, size: 24, color: scheme.onErrorContainer),
            const SizedBox(width: AdaptiveSpacing.md),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: scheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
