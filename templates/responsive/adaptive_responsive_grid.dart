import 'package:flutter/widgets.dart';

import '../foundation/adaptive_tokens.dart';

/// A grid whose column count follows the width it is given.
///
/// The caller states the smallest acceptable width for one cell
/// ([minChildWidth]); the widget fits as many columns as that allows. This is
/// how a phone shows one or two cards per row and a tablet in landscape shows
/// four, from a single call site.
///
/// ```dart
/// AdaptiveResponsiveGrid(
///   minChildWidth: 180,
///   children: <Widget>[for (final Product p in products) ProductCard(p)],
/// )
/// ```
///
/// ## More columns, not bigger text
///
/// Extra width buys extra cells. It never buys a larger `fontSize`: the text
/// inside a cell keeps the size the user asked for, from `AdaptiveTypography`
/// and the platform's accessibility setting. A grid that also inflated its
/// type would break both design languages at once.
///
/// ## Measures its box, not the window
///
/// Column count comes from a [LayoutBuilder], so the grid is correct inside a
/// detail pane, an iPad Slide Over window or a dialog — places where the
/// window width reported by `MediaQuery` is far wider than the space actually
/// available.
class AdaptiveResponsiveGrid extends StatelessWidget {
  /// The cells, laid out in order, left to right then top to bottom.
  final List<Widget> children;

  /// Smallest width one cell may take, in logical pixels.
  ///
  /// The column count is the largest that keeps every cell at or above this
  /// width, so lowering it packs more columns in.
  final double minChildWidth;

  /// Hard ceiling on the column count.
  ///
  /// Guards against a wall of tiny cells on a desktop-class window. Six is
  /// already generous for card content.
  final int maxColumns;

  /// Horizontal gap between columns.
  final double spacing;

  /// Vertical gap between rows. Defaults to [spacing].
  final double? runSpacing;

  /// Width-to-height ratio of a cell, forwarded to [GridView.count].
  final double childAspectRatio;

  /// Padding around the grid, excluded from the width used to count columns.
  final EdgeInsets? padding;

  /// Whether the grid scrolls on its own.
  ///
  /// `false` (the default) shrink-wraps and disables scrolling, which is what
  /// you want when the grid is one section inside a page that already scrolls.
  /// `true` gives it its own viewport with the platform's overscroll
  /// behaviour, from `AdaptiveScrollPhysics`.
  final bool scrollable;

  const AdaptiveResponsiveGrid({
    super.key,
    required this.children,
    this.minChildWidth = 160,
    this.maxColumns = 6,
    this.spacing = AdaptiveSpacing.item,
    this.runSpacing,
    this.childAspectRatio = 1,
    this.padding,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double outerWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final double usableWidth = outerWidth - (padding?.horizontal ?? 0);

        return GridView.count(
          crossAxisCount: _columnsFor(usableWidth),
          shrinkWrap: !scrollable,
          physics: scrollable
              ? AdaptiveScrollPhysics.of()
              : const NeverScrollableScrollPhysics(),
          padding: padding,
          crossAxisSpacing: spacing,
          mainAxisSpacing: runSpacing ?? spacing,
          childAspectRatio: childAspectRatio,
          children: children,
        );
      },
    );
  }

  /// Columns that fit in [width], counting the gaps between them.
  ///
  /// `n` columns need `n * minChildWidth + (n - 1) * spacing`, hence the
  /// `+ spacing` on both sides of the division.
  int _columnsFor(double width) {
    if (width <= 0) return 1;
    final int fitting = ((width + spacing) / (minChildWidth + spacing)).floor();
    if (fitting < 1) return 1;
    if (fitting > maxColumns) return maxColumns;
    return fitting;
  }
}
