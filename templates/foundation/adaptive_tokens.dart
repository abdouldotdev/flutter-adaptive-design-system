import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'platform_utils.dart';

/// Spacing scale.
///
/// Spacing does not change per platform — iOS and Material agree on an 8pt
/// rhythm. Use the semantic values ([page], [item], [section]) in layout code
/// and the raw steps only when nothing semantic fits.
abstract final class AdaptiveSpacing {
  /// Horizontal padding of a page's content against the screen edge.
  static const double page = 16;

  /// Gap between two adjacent items in a list or column.
  static const double item = 8;

  /// Gap between two sections of a screen.
  static const double section = 24;

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Symmetric page padding, the most common wrapper in a screen build.
  static const EdgeInsets pagePadding = EdgeInsets.all(page);

  /// Horizontal-only page padding, for content that scrolls under a nav bar.
  static const EdgeInsets pagePaddingHorizontal =
      EdgeInsets.symmetric(horizontal: page);
}

/// Corner radii, branched per platform.
///
/// This is the token group that genuinely differs between the two design
/// languages: Material 3 rounds far more aggressively than iOS, and a pill
/// button is idiomatic on Android while a 10pt rounded rectangle is idiomatic
/// on iOS. Reading these getters is what keeps a screen from looking like an
/// Android app running on an iPhone.
///
/// | Element   | Material 3   | iOS |
/// |-----------|--------------|-----|
/// | card      | 12           | 10  |
/// | button    | 20 (pill)    | 10  |
/// | dialog    | 28           | 14  |
/// | textField | 4            | 8   |
/// | chip      | 8            | 6   |
abstract final class AdaptiveRadius {
  static double get card => PlatformUtils.isCupertino ? 10 : 12;
  static double get button => PlatformUtils.isCupertino ? 10 : 20;
  static double get dialog => PlatformUtils.isCupertino ? 14 : 28;
  static double get textField => PlatformUtils.isCupertino ? 8 : 4;
  static double get chip => PlatformUtils.isCupertino ? 6 : 8;

  /// Bottom sheets: iOS uses a shallower corner than Material 3.
  static double get sheet => PlatformUtils.isCupertino ? 12 : 28;

  static BorderRadius get cardBorder => BorderRadius.circular(card);
  static BorderRadius get buttonBorder => BorderRadius.circular(button);
  static BorderRadius get dialogBorder => BorderRadius.circular(dialog);
  static BorderRadius get textFieldBorder => BorderRadius.circular(textField);
  static BorderRadius get chipBorder => BorderRadius.circular(chip);

  /// Top-only radius, for bottom sheets and drawers.
  static BorderRadius get sheetBorder => BorderRadius.vertical(
        top: Radius.circular(sheet),
      );
}

/// Semantic colours, resolved per platform.
///
/// On Cupertino these resolve from [CupertinoColors] via
/// `resolveFrom(context)` — that call is what makes dark mode work, since iOS
/// system colours are dynamic. On Material they read the [ColorScheme].
///
/// [success] and [warning] have no Material 3 role, so they are defined
/// explicitly with a dark variant.
abstract final class AdaptiveColors {
  static bool _isCupertino(BuildContext context) {
    final TargetPlatform platform = Theme.of(context).platform;
    return PlatformUtils.isCupertino ||
        platform == TargetPlatform.iOS ||
        platform == TargetPlatform.macOS;
  }

  static bool _isDark(BuildContext context) =>
      MediaQuery.platformBrightnessOf(context) == Brightness.dark;

  /// Primary accent. iOS `systemBlue` (#007AFF) ↔ `colorScheme.primary`.
  static Color primary(BuildContext context) => _isCupertino(context)
      ? CupertinoColors.systemBlue.resolveFrom(context)
      : Theme.of(context).colorScheme.primary;

  /// Destructive actions. iOS `systemRed` (#FF3B30) ↔ `colorScheme.error`.
  static Color destructive(BuildContext context) => _isCupertino(context)
      ? CupertinoColors.systemRed.resolveFrom(context)
      : Theme.of(context).colorScheme.error;

  /// Success. iOS `systemGreen` (#34C759); no Material 3 equivalent.
  static Color success(BuildContext context) => _isCupertino(context)
      ? CupertinoColors.systemGreen.resolveFrom(context)
      : (_isDark(context) ? const Color(0xFF30D158) : const Color(0xFF34C759));

  /// Warning. iOS `systemOrange` (#FF9500); no Material 3 equivalent.
  static Color warning(BuildContext context) => _isCupertino(context)
      ? CupertinoColors.systemOrange.resolveFrom(context)
      : (_isDark(context) ? const Color(0xFFFF9F0A) : const Color(0xFFFF9500));

  /// Screen background. iOS `systemGroupedBackground` ↔ `colorScheme.surface`.
  static Color background(BuildContext context) => _isCupertino(context)
      ? CupertinoColors.systemGroupedBackground.resolveFrom(context)
      : Theme.of(context).colorScheme.surface;

  /// Raised surface (cards, grouped rows).
  /// iOS `secondarySystemGroupedBackground` ↔ `surfaceContainerHighest`.
  static Color surface(BuildContext context) => _isCupertino(context)
      ? CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context)
      : Theme.of(context).colorScheme.surfaceContainerHighest;

  /// Primary text. iOS `label` ↔ `colorScheme.onSurface`.
  static Color label(BuildContext context) => _isCupertino(context)
      ? CupertinoColors.label.resolveFrom(context)
      : Theme.of(context).colorScheme.onSurface;

  /// De-emphasised text. iOS `secondaryLabel` ↔ `onSurfaceVariant`.
  static Color secondaryLabel(BuildContext context) => _isCupertino(context)
      ? CupertinoColors.secondaryLabel.resolveFrom(context)
      : Theme.of(context).colorScheme.onSurfaceVariant;

  /// Hairline separators. iOS `separator` ↔ `colorScheme.outlineVariant`.
  static Color separator(BuildContext context) => _isCupertino(context)
      ? CupertinoColors.separator.resolveFrom(context)
      : Theme.of(context).colorScheme.outlineVariant;
}

/// Animation durations and curves, branched per platform.
///
/// iOS motion is flatter and quicker to settle; Material 3 uses emphasised
/// easing with a slight overshoot. Using the wrong curve is subtle but it is
/// one of the things that makes an app feel ported rather than native.
abstract final class AdaptiveMotion {
  /// Taps, toggles, selection feedback.
  static const Duration micro = Duration(milliseconds: 120);

  /// Dialogs, sheets, expanding sections.
  static const Duration transition = Duration(milliseconds: 280);

  /// Full page transitions.
  static const Duration page = Duration(milliseconds: 380);

  /// Page transition curve.
  static Curve get pageCurve => PlatformUtils.isCupertino
      ? Curves.easeInOut
      : Curves.easeInOutCubicEmphasized;

  /// Curve for something appearing on top of the current screen.
  static Curve get appearCurve =>
      PlatformUtils.isCupertino ? Curves.easeOut : Curves.easeOutBack;

  /// Curve for an element entering within the current screen.
  static Curve get enterCurve =>
      PlatformUtils.isCupertino ? Curves.easeOut : Curves.fastOutSlowIn;
}

/// Scroll physics matching the platform's overscroll behaviour.
///
/// iOS bounces, Android shows a stretch/glow and clamps. Getting this wrong is
/// immediately noticeable to a user of either platform.
abstract final class AdaptiveScrollPhysics {
  static ScrollPhysics of() => PlatformUtils.isCupertino
      ? const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())
      : const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
}
