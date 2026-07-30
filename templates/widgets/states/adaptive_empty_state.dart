import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/adaptive_icons.dart';
import '../../foundation/adaptive_tokens.dart';
import '../../foundation/platform_utils.dart';
import '../buttons/adaptive_button.dart';

/// The "there is nothing here yet" screen: an icon, a title, an optional
/// explanation and an optional call to action.
///
/// An empty state is not an error. Phrase [title] as a fact and [subtitle] as
/// the way out — `'No transactions yet'` / `'Your transfers will show up
/// here.'` — and give the user something to do with [actionLabel] whenever
/// there is a sensible next step.
///
/// The icon is taken as an [IconData] and rendered through [AdaptiveIcon]
/// rather than as a free-form widget wrapped in an [IconTheme]. `hugeicons`
/// requires an explicit colour and ignores [IconTheme] entirely, so the
/// theme-based approach silently produces a black icon in dark mode.
///
/// ```dart
/// AdaptiveEmptyState(
///   icon: AdaptiveIcons.wallet,
///   title: 'No transactions yet',
///   subtitle: 'Your transfers will show up here.',
///   actionLabel: 'Send money',
///   onAction: controller.openTransfer,
/// )
/// ```
class AdaptiveEmptyState extends StatelessWidget {
  /// The glyph shown above the title, normally a constant from
  /// [AdaptiveIcons].
  final IconData icon;

  /// One line stating what is missing. Required — an empty state without a
  /// title is just a blank screen with an icon on it.
  final String title;

  /// Optional second line explaining how the list fills up.
  final String? subtitle;

  /// Label of the call-to-action button. The button is only built when both
  /// this and [onAction] are provided.
  final String? actionLabel;

  /// Called when the call-to-action button is tapped.
  final VoidCallback? onAction;

  /// Size of the icon in logical pixels.
  final double iconSize;

  /// Overrides the icon colour. Defaults to the platform's secondary label,
  /// which keeps the icon quiet next to the title.
  final Color? iconColor;

  /// Padding around the whole block.
  final EdgeInsetsGeometry? padding;

  const AdaptiveEmptyState({
    super.key,
    this.icon = AdaptiveIcons.info,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconSize = 64,
    this.iconColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasAction = actionLabel != null && onAction != null;

    return Center(
      // The scroll view sizes itself to its content and only scrolls when the
      // viewport is shorter than it — an icon, a title, a subtitle and a
      // button do not fit on a landscape phone. Physics are left at the
      // default on purpose: an empty state that bounces when nothing overflows
      // feels broken.
      child: SingleChildScrollView(
        padding: padding ?? const EdgeInsets.all(AdaptiveSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AdaptiveIcon(
              icon,
              size: iconSize,
              color: iconColor ?? AdaptiveColors.secondaryLabel(context),
            ),
            const SizedBox(height: AdaptiveSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: _titleStyle(context),
            ),
            if (subtitle != null) ...<Widget>[
              const SizedBox(height: AdaptiveSpacing.sm),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: _subtitleStyle(context),
              ),
            ],
            if (hasAction) ...<Widget>[
              const SizedBox(height: AdaptiveSpacing.xl),
              AdaptiveButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  TextStyle _titleStyle(BuildContext context) {
    final Color color = AdaptiveColors.label(context);
    if (PlatformUtils.isCupertino) {
      return CupertinoTheme.of(context)
          .textTheme
          .navTitleTextStyle
          .copyWith(color: color);
    }
    return Theme.of(context).textTheme.titleMedium?.copyWith(color: color) ??
        TextStyle(color: color);
  }

  TextStyle _subtitleStyle(BuildContext context) {
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
