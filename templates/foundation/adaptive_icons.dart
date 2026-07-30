import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'platform_utils.dart';

/// Semantic icon registry.
///
/// Icons are named by **purpose**, not by shape: [back] rather than
/// `arrowLeft01`. Call sites then read as intent, and swapping the underlying
/// glyph is a one-line change here instead of a repo-wide search.
///
/// ## About stroke and solid variants
///
/// `hugeicons` ships a single variant family: every one of its ~4,470
/// constants is `strokeRounded*`. There are **no** `solid*` constants. A
/// registry that branches `stroke` on Android and `solid` on iOS therefore
/// cannot compile against this package, however appealing the idea is on
/// paper (iOS SF Symbols do lean filled).
///
/// So icon adaptation here is done through **colour and size**, not fill — see
/// [AdaptiveIcon]. If you bring a second icon set that does have a filled
/// family, [resolve] is the escape hatch to branch between two glyphs.
///
/// All constants below are verified against `hugeicons` 0.0.11.
abstract final class AdaptiveIcons {
  // Navigation
  static const IconData home = HugeIcons.strokeRoundedHome01;
  static const IconData back = HugeIcons.strokeRoundedArrowLeft01;
  static const IconData forward = HugeIcons.strokeRoundedArrowRight01;
  static const IconData chevronDown = HugeIcons.strokeRoundedArrowDown01;
  static const IconData menu = HugeIcons.strokeRoundedMenu01;
  static const IconData more = HugeIcons.strokeRoundedMoreHorizontal;
  static const IconData close = HugeIcons.strokeRoundedCancel01;

  // Identity & account
  static const IconData user = HugeIcons.strokeRoundedUser;
  static const IconData lock = HugeIcons.strokeRoundedLock;
  static const IconData password = HugeIcons.strokeRoundedLockPassword;
  static const IconData logout = HugeIcons.strokeRoundedLogout01;
  static const IconData visibility = HugeIcons.strokeRoundedView;
  static const IconData visibilityOff = HugeIcons.strokeRoundedViewOff;

  // Actions
  static const IconData add = HugeIcons.strokeRoundedAdd01;
  static const IconData edit = HugeIcons.strokeRoundedEdit01;
  static const IconData delete = HugeIcons.strokeRoundedDelete01;
  static const IconData copy = HugeIcons.strokeRoundedCopy01;
  static const IconData share = HugeIcons.strokeRoundedShare01;
  static const IconData download = HugeIcons.strokeRoundedDownload01;
  static const IconData upload = HugeIcons.strokeRoundedUpload01;
  static const IconData refresh = HugeIcons.strokeRoundedRefresh;
  static const IconData search = HugeIcons.strokeRoundedSearch01;
  static const IconData filter = HugeIcons.strokeRoundedFilter;

  // Status & feedback
  static const IconData success = HugeIcons.strokeRoundedCheckmarkCircle01;
  static const IconData check = HugeIcons.strokeRoundedTick01;
  static const IconData info = HugeIcons.strokeRoundedInformationCircle;
  static const IconData warning = HugeIcons.strokeRoundedAlert01;
  static const IconData error = HugeIcons.strokeRoundedAlertCircle;
  static const IconData help = HugeIcons.strokeRoundedHelpCircle;

  // Content
  static const IconData settings = HugeIcons.strokeRoundedSettings01;
  static const IconData notification = HugeIcons.strokeRoundedNotification01;
  static const IconData book = HugeIcons.strokeRoundedBook01;
  static const IconData wallet = HugeIcons.strokeRoundedWallet01;
  static const IconData analytics = HugeIcons.strokeRoundedAnalytics01;
  static const IconData calendar = HugeIcons.strokeRoundedCalendar01;
  static const IconData clock = HugeIcons.strokeRoundedClock01;

  /// Branches between two glyphs by platform.
  ///
  /// Unused with `hugeicons` alone, since it has one variant family. Reach for
  /// it when you add an icon set that provides both an outlined and a filled
  /// family:
  ///
  /// ```dart
  /// AdaptiveIcons.resolve(
  ///   material: MyIcons.outlinedHome,
  ///   cupertino: MyIcons.filledHome,
  /// )
  /// ```
  static IconData resolve({
    required IconData material,
    required IconData cupertino,
  }) =>
      PlatformUtils.isCupertino ? cupertino : material;
}

/// An icon that picks up the platform's default foreground colour.
///
/// [HugeIcon] requires an explicit colour, which in practice means call sites
/// hard-code one and dark mode breaks. This wrapper resolves it instead:
/// `CupertinoColors.label` on Cupertino — dynamic, so it follows the system
/// appearance — and `colorScheme.onSurface` on Material.
///
/// ```dart
/// const AdaptiveIcon(AdaptiveIcons.wallet)
/// AdaptiveIcon(AdaptiveIcons.delete, color: AdaptiveColors.destructive(context))
/// ```
class AdaptiveIcon extends StatelessWidget {
  /// The glyph to render, normally a constant from [AdaptiveIcons].
  final IconData icon;

  /// Size in logical pixels. 24 matches both the Material and the iOS default.
  final double size;

  /// Overrides the resolved foreground colour.
  final Color? color;

  /// Announced by screen readers. Provide it whenever the icon carries meaning
  /// that is not already in adjacent text.
  final String? semanticLabel;

  const AdaptiveIcon(
    this.icon, {
    super.key,
    this.size = 24,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final Color resolved = color ?? _defaultColor(context);

    final Widget glyph = HugeIcon(
      icon: icon,
      color: resolved,
      size: size,
    );

    if (semanticLabel == null) return glyph;

    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(child: glyph),
    );
  }

  Color _defaultColor(BuildContext context) {
    final TargetPlatform platform = Theme.of(context).platform;
    final bool isCupertino = PlatformUtils.isCupertino ||
        platform == TargetPlatform.iOS ||
        platform == TargetPlatform.macOS;

    if (isCupertino) {
      return CupertinoColors.label.resolveFrom(context);
    }
    return Theme.of(context).colorScheme.onSurface;
  }
}
