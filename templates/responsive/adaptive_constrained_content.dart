import 'package:flutter/widgets.dart';

import 'breakpoints.dart';

/// Caps how wide a column of content may grow, and centres it.
///
/// On a phone this is a no-op — the content is narrower than the cap already.
/// On a tablet in landscape or a desktop window it stops a form, an article or
/// a settings list from stretching edge to edge, which is both unreadable and
/// unlike anything either platform ships.
///
/// ```dart
/// AdaptiveConstrainedContent(
///   child: Column(children: <Widget>[...]),
/// )
/// ```
///
/// ## The wrong fix for wide screens is bigger text
///
/// A line stays comfortable at roughly 60 to 75 characters, which is what the
/// 680pt default buys at body size. The temptation on a wide screen is to
/// scale the type up until the line looks full; that is the one thing never to
/// do — text size belongs to `AdaptiveTypography` and to the user's
/// accessibility setting. Constrain the column instead, and spend the width
/// you reclaimed on a second pane (`AdaptiveMasterDetail`) or more grid
/// columns (`AdaptiveResponsiveGrid`).
class AdaptiveConstrainedContent extends StatelessWidget {
  /// The content to constrain.
  final Widget child;

  /// Widest the content itself may become, padding excluded.
  ///
  /// 680 suits reading and form layouts. Widen it for dense dashboards, and
  /// note it is a maximum, not a fixed width: narrow windows ignore it.
  final double maxWidth;

  /// Padding around the content.
  ///
  /// Defaults to the current size class's `pagePadding`, so margins grow with
  /// the window without the caller doing anything. Pass [EdgeInsets.zero] when
  /// an ancestor already applies page padding.
  final EdgeInsets? padding;

  /// Where the constrained column sits in the space available.
  ///
  /// [Alignment.topCenter] rather than [Alignment.center]: horizontally
  /// centred, but pinned to the top so a short form does not float in the
  /// middle of a tall window.
  final AlignmentGeometry alignment;

  const AdaptiveConstrainedContent({
    super.key,
    required this.child,
    this.maxWidth = 680,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    final EdgeInsets resolvedPadding = padding ?? context.pagePadding;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        // [maxWidth] caps the content, so the padding is added on top of it —
        // otherwise a wider padding would silently narrow the text column.
        constraints: BoxConstraints(
          maxWidth: maxWidth + resolvedPadding.horizontal,
        ),
        child: Padding(
          padding: resolvedPadding,
          child: child,
        ),
      ),
    );
  }
}
