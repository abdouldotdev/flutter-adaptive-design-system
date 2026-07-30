import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Platform-adaptive type scale.
///
/// One scale, two outputs: [material] builds the Material 3 [TextTheme] and
/// [cupertino] builds a complete [CupertinoTextThemeData]. Both come from the
/// same numbers, so iOS and Android stay typographically in sync while each
/// renders with its own conventions.
///
/// ## Never scale type by screen width
///
/// This is the single most common mistake in cross-platform Flutter, and it is
/// the reason this file exists.
///
/// Native apps do **not** resize text based on device size. Body text is 17pt
/// on an iPhone SE and 17pt on a 16 Pro Max. A larger screen shows *more
/// content*, not bigger text — the same holds on Android, where the Material
/// type scale is fixed and window size classes drive layout, not type.
///
/// The only axis that legitimately changes text size is the user's own
/// accessibility setting (Dynamic Type on iOS, font size on Android). Flutter
/// honours it automatically through [MediaQuery.textScalerOf].
///
/// Packages that compute font size from screen width — `flutter_screenutil`
/// (`.sp`), `sizer`, `responsive_sizer` — therefore do two kinds of damage:
/// they **override the user's accessibility choice**, and they produce a
/// rendering that is neither iOS nor Android. Do not use them for type.
///
/// Use [AdaptiveTextScale] when a dense screen genuinely needs a bound, and
/// breakpoints (see `templates/responsive/`) to adapt *layout* to device size.
///
/// ## Fonts
///
/// [fontFamily] defaults to `null`, which means the platform's system font —
/// San Francisco on iOS, Roboto on Android. That default is what makes text
/// feel native; override it only for a deliberate brand decision.
///
/// Note on San Francisco: its licence covers iOS, macOS and tvOS only. Forcing
/// a Cupertino rendering on Android (a design-system gallery with a platform
/// toggle, for instance) falls back to another font. That is expected, not a
/// bug.
abstract final class AdaptiveTypography {
  /// Material 3 role ↔ iOS text style ↔ size ↔ weight.
  ///
  /// | Material 3       | iOS          | Size | Weight |
  /// |------------------|--------------|------|--------|
  /// | `displayLarge`   | largeTitle   | 34   | w700   |
  /// | `displayMedium`  | title1       | 28   | w700   |
  /// | `displaySmall`   | title1       | 26   | w700   |
  /// | `headlineLarge`  | title1       | 28   | w700   |
  /// | `headlineMedium` | title1       | 28   | w700   |
  /// | `headlineSmall`  | title2       | 24   | w700   |
  /// | `titleLarge`     | title2       | 22   | w700   |
  /// | `titleMedium`    | headline     | 17   | w600   |
  /// | `titleSmall`     | subheadline  | 15   | w600   |
  /// | `bodyLarge`      | body         | 17   | w400   |
  /// | `bodyMedium`     | callout      | 16   | w400   |
  /// | `bodySmall`      | footnote     | 13   | w400   |
  /// | `labelLarge`     | subheadline  | 15   | w400   |
  /// | `labelMedium`    | footnote     | 13   | w400   |
  /// | `labelSmall`     | caption1     | 12   | w400   |
  static const double displayLargeSize = 34;
  static const double displayMediumSize = 28;
  static const double displaySmallSize = 26;
  static const double headlineLargeSize = 28;
  static const double headlineMediumSize = 28;
  static const double headlineSmallSize = 24;
  static const double titleLargeSize = 22;
  static const double titleMediumSize = 17;
  static const double titleSmallSize = 15;
  static const double bodyLargeSize = 17;
  static const double bodyMediumSize = 16;
  static const double bodySmallSize = 13;
  static const double labelLargeSize = 15;
  static const double labelMediumSize = 13;
  static const double labelSmallSize = 12;

  /// Builds the Material 3 [TextTheme].
  ///
  /// [color] applies to every role; pass the theme's `onSurface` so text
  /// follows light/dark mode. [secondaryColor] applies to the de-emphasised
  /// roles (`bodySmall`, `labelMedium`, `labelSmall`) and falls back to
  /// [color] when omitted.
  static TextTheme material({
    String? fontFamily,
    Color? color,
    Color? secondaryColor,
  }) {
    final Color? secondary = secondaryColor ?? color;

    TextStyle style(double size, FontWeight weight, {Color? c}) => TextStyle(
          fontFamily: fontFamily,
          fontSize: size,
          fontWeight: weight,
          color: c ?? color,
        );

    return TextTheme(
      displayLarge: style(displayLargeSize, FontWeight.w700),
      displayMedium: style(displayMediumSize, FontWeight.w700),
      displaySmall: style(displaySmallSize, FontWeight.w700),
      headlineLarge: style(headlineLargeSize, FontWeight.w700),
      headlineMedium: style(headlineMediumSize, FontWeight.w700),
      headlineSmall: style(headlineSmallSize, FontWeight.w700),
      titleLarge: style(titleLargeSize, FontWeight.w700),
      titleMedium: style(titleMediumSize, FontWeight.w600),
      titleSmall: style(titleSmallSize, FontWeight.w600),
      bodyLarge: style(bodyLargeSize, FontWeight.w400),
      bodyMedium: style(bodyMediumSize, FontWeight.w400),
      bodySmall: style(bodySmallSize, FontWeight.w400, c: secondary),
      labelLarge: style(labelLargeSize, FontWeight.w400),
      labelMedium: style(labelMediumSize, FontWeight.w400, c: secondary),
      labelSmall: style(labelSmallSize, FontWeight.w400, c: secondary),
    );
  }

  /// Builds the complete [CupertinoTextThemeData].
  ///
  /// Every slot is filled — not just `textStyle` and the two navigation
  /// styles. A partially filled Cupertino text theme silently falls back to
  /// Flutter's defaults, which is how an app ends up with two different fonts
  /// on the same iOS screen.
  static CupertinoTextThemeData cupertino({
    String? fontFamily,
    Color? primaryColor,
    Color? color,
  }) {
    TextStyle style(double size, FontWeight weight, {Color? c}) => TextStyle(
          fontFamily: fontFamily,
          fontSize: size,
          fontWeight: weight,
          color: c ?? color,
        );

    return CupertinoTextThemeData(
      primaryColor: primaryColor ?? CupertinoColors.activeBlue,
      textStyle: style(bodyLargeSize, FontWeight.w400),
      actionTextStyle: style(bodyLargeSize, FontWeight.w400, c: primaryColor),
      tabLabelTextStyle: style(10, FontWeight.w500),
      navTitleTextStyle: style(titleMediumSize, FontWeight.w600),
      navLargeTitleTextStyle: style(displayLargeSize, FontWeight.w700),
      navActionTextStyle: style(bodyLargeSize, FontWeight.w400, c: primaryColor),
      pickerTextStyle: style(21, FontWeight.w400),
      dateTimePickerTextStyle: style(21, FontWeight.w400),
    );
  }

  /// Resolves the body text style for the current platform.
  ///
  /// On Cupertino this reads [CupertinoTheme], which already respects Dynamic
  /// Type; on Material it reads the [TextTheme].
  static TextStyle body(BuildContext context) {
    final TargetPlatform platform = Theme.of(context).platform;
    final bool isCupertino =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    if (isCupertino) {
      return CupertinoTheme.of(context).textTheme.textStyle;
    }
    return Theme.of(context).textTheme.bodyLarge ?? const TextStyle();
  }
}

/// Policy for the user's text-scaling preference.
///
/// The default is to respect it in full: pass nothing, do nothing, and Flutter
/// applies [MediaQuery.textScalerOf] as the user configured it.
///
/// [clamp] exists for the narrow case where a screen is dense enough that an
/// unbounded scale breaks it — a money-entry screen where the amount and its
/// confirm button must stay visible together. Bounding text scale is an
/// accessibility trade-off: apply it per screen, with a reason, never globally.
abstract final class AdaptiveTextScale {
  /// The user's scale, unmodified. This is the default and the right choice
  /// for content screens (lists, history, profile, help).
  static TextScaler of(BuildContext context) =>
      MediaQuery.textScalerOf(context);

  /// The user's scale, bounded to [min]…[max].
  ///
  /// [max] defaults to 1.3, which keeps most dense layouts intact while still
  /// giving a meaningful increase to users who asked for one.
  static TextScaler clamped(
    BuildContext context, {
    double min = 1.0,
    double max = 1.3,
  }) {
    return MediaQuery.textScalerOf(context)
        .clamp(minScaleFactor: min, maxScaleFactor: max);
  }

  /// Wraps [child] in a [MediaQuery] whose text scale is bounded.
  ///
  /// ```dart
  /// AdaptiveTextScale.clamp(
  ///   context: context,
  ///   max: 1.3,
  ///   child: const AmountEntryForm(),
  /// )
  /// ```
  static Widget clamp({
    required BuildContext context,
    required Widget child,
    double min = 1.0,
    double max = 1.3,
  }) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: clamped(context, min: min, max: max),
      ),
      child: child,
    );
  }
}
