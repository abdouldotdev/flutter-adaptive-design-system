import 'package:flutter/widgets.dart';

import '../foundation/adaptive_tokens.dart';

/// Window size classes for the adaptive design system.
///
/// The three thresholds match the Material 3 window size classes, which in
/// practice also line up with the iPad form factors: below 600 is a phone,
/// 600–840 a tablet in portrait or an unfolded foldable, 840–1200 a tablet in
/// landscape, and beyond that a desktop-class window.
///
/// ## Breakpoints drive LAYOUT, never type size
///
/// This is the rule the whole file exists to enforce. A wider screen shows
/// **more content** — more grid columns, a permanent sidebar, a detail pane
/// next to the list — it does **not** show bigger text. Body text is 17pt on
/// an iPhone SE and 17pt on a 13" iPad, exactly as it is in every first-party
/// app on both platforms.
///
/// The only thing that legitimately changes text size is the user's own
/// accessibility setting (Dynamic Type on iOS, font size on Android), which
/// Flutter applies for you. For anything typographic go to
/// `AdaptiveTypography` in `templates/foundation/adaptive_typography.dart`;
/// never derive a `fontSize` from a value in this file.
///
/// ## Window width vs. available width
///
/// [of] reads the window through [MediaQuery], which is the right measure for
/// a full-screen page. A widget that occupies only part of the window — an
/// iPad Slide Over pane, a detail pane, a dialog — must instead measure its
/// own box with a [LayoutBuilder] and call [fromWidth]; otherwise a 300pt-wide
/// pane on a 1200pt window believes it is a desktop.
abstract final class Breakpoints {
  /// Upper bound of [ScreenSize.compact] — phones in portrait.
  static const double compact = 600;

  /// Upper bound of [ScreenSize.medium] — tablets in portrait, foldables.
  static const double medium = 840;

  /// Upper bound of [ScreenSize.expanded] — tablets in landscape, small
  /// desktop windows. Anything wider is [ScreenSize.large].
  static const double expanded = 1200;

  /// The size class of the current window.
  ///
  /// ```dart
  /// switch (Breakpoints.of(context)) {
  ///   case ScreenSize.compact:
  ///     return const _PhoneLayout();
  ///   case ScreenSize.medium:
  ///     return const _TabletLayout();
  ///   case ScreenSize.expanded:
  ///   case ScreenSize.large:
  ///     return const _DesktopLayout();
  /// }
  /// ```
  static ScreenSize of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  /// The size class of an arbitrary [width], in logical pixels.
  ///
  /// Pair it with a [LayoutBuilder] whenever the widget is not full-screen:
  ///
  /// ```dart
  /// LayoutBuilder(
  ///   builder: (BuildContext context, BoxConstraints constraints) {
  ///     final ScreenSize screen = Breakpoints.fromWidth(constraints.maxWidth);
  ///     ...
  ///   },
  /// )
  /// ```
  static ScreenSize fromWidth(double width) {
    if (width < compact) return ScreenSize.compact;
    if (width < medium) return ScreenSize.medium;
    if (width < expanded) return ScreenSize.expanded;
    return ScreenSize.large;
  }
}

/// The four window size classes produced by [Breakpoints].
///
/// Ordering is meaningful: [isAtLeast] compares declaration order, so a test
/// written once for [medium] keeps holding on [expanded] and [large].
enum ScreenSize {
  /// Below 600pt. Phone in portrait, iPad Slide Over pane.
  compact,

  /// 600–840pt. Tablet in portrait, unfolded foldable, half-screen split view.
  medium,

  /// 840–1200pt. Tablet in landscape, small desktop window.
  expanded,

  /// 1200pt and above. Desktop, full-screen external display.
  large;

  /// Whether this is the phone-sized class.
  bool get isCompact => this == ScreenSize.compact;

  /// Whether this class is [other] or anything wider.
  ///
  /// ```dart
  /// if (Breakpoints.of(context).isAtLeast(ScreenSize.medium)) {
  ///   // Room for a permanent sidebar.
  /// }
  /// ```
  bool isAtLeast(ScreenSize other) => index >= other.index;

  /// Page padding for this class, built from `AdaptiveSpacing`.
  ///
  /// Padding grows up to [expanded] and then stops: past that width the extra
  /// room should go to a content constraint (`AdaptiveConstrainedContent`) or
  /// to a second pane, not to an ever-thicker margin.
  EdgeInsets get pagePadding => switch (this) {
        ScreenSize.compact => const EdgeInsets.all(AdaptiveSpacing.page),
        ScreenSize.medium => const EdgeInsets.symmetric(
            horizontal: AdaptiveSpacing.xl,
            vertical: AdaptiveSpacing.lg,
          ),
        ScreenSize.expanded => const EdgeInsets.symmetric(
            horizontal: AdaptiveSpacing.xxxl,
            vertical: AdaptiveSpacing.xl,
          ),
        ScreenSize.large => const EdgeInsets.symmetric(
            horizontal: AdaptiveSpacing.xxxl,
            vertical: AdaptiveSpacing.xxl,
          ),
      };
}

/// Convenience accessors for the current window.
///
/// ```dart
/// if (context.isAtLeastMedium) {
///   return Row(children: <Widget>[list, Expanded(child: detail)]);
/// }
/// ```
///
/// These read the window, exactly like [Breakpoints.of]. Inside a widget that
/// is not full-screen, prefer a [LayoutBuilder] plus [Breakpoints.fromWidth].
extension ResponsiveContext on BuildContext {
  /// The size class of the current window.
  ScreenSize get screenSize => Breakpoints.of(this);

  /// Whether the window is phone-sized.
  bool get isCompact => screenSize.isCompact;

  /// Whether the window is at least [ScreenSize.medium].
  bool get isAtLeastMedium => screenSize.isAtLeast(ScreenSize.medium);

  /// Whether the window is at least [ScreenSize.expanded].
  bool get isAtLeastExpanded => screenSize.isAtLeast(ScreenSize.expanded);

  /// Page padding for the current size class.
  EdgeInsets get pagePadding => screenSize.pagePadding;

  /// Whether the window is currently in landscape.
  ///
  /// Orientation is a layout signal like any other: use it to move a column
  /// into a row, never to change a font size.
  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;
}
