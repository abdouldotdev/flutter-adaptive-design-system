import 'package:flutter/widgets.dart';

import '../../foundation/adaptive_tokens.dart';
import '../layout/adaptive_card.dart';
import 'adaptive_shimmer.dart';

/// A rectangular content placeholder — one line of text, an image slot, a
/// button-shaped hole.
///
/// Paints [AdaptiveShimmer.baseColorOf], so it is legible on its own and does
/// not require a shimmer above it. Its corner radius comes from
/// [AdaptiveRadius.textField], which is 4 on Material and 8 on iOS: the same
/// difference the real text fields have.
///
/// Give the placeholder the size of the content it stands in for. A skeleton
/// that does not match the layout it precedes causes a jump the moment the
/// data lands, which is the exact thing skeletons exist to avoid.
///
/// ```dart
/// const AdaptiveSkeletonBox(width: 160, height: 14)
/// ```
class AdaptiveSkeletonBox extends StatelessWidget {
  /// Width in logical pixels. Defaults to filling the available width, which
  /// requires a bounded parent — inside a [Row], wrap it in an [Expanded].
  final double width;

  /// Height in logical pixels. Match the line height of the text it replaces.
  final double height;

  /// Overrides the corner radius. Defaults to [AdaptiveRadius.textField].
  final double? borderRadius;

  /// Overrides the fill. Defaults to [AdaptiveShimmer.baseColorOf].
  final Color? color;

  const AdaptiveSkeletonBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? AdaptiveShimmer.baseColorOf(context),
        borderRadius:
            BorderRadius.circular(borderRadius ?? AdaptiveRadius.textField),
      ),
    );
  }
}

/// A circular content placeholder, for avatars and round icon buttons.
///
/// ```dart
/// const AdaptiveSkeletonCircle(size: 44)
/// ```
class AdaptiveSkeletonCircle extends StatelessWidget {
  /// Diameter in logical pixels.
  final double size;

  /// Overrides the fill. Defaults to [AdaptiveShimmer.baseColorOf].
  final Color? color;

  const AdaptiveSkeletonCircle({
    super.key,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? AdaptiveShimmer.baseColorOf(context),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Placeholder for a list row: a round avatar, a full-width title line and a
/// shorter subtitle line.
///
/// Set [shimmer] to false when the list itself is already wrapped in an
/// [AdaptiveShimmer] — otherwise every row runs its own animation controller
/// and the sweep restarts at each row's left edge instead of crossing the
/// screen.
///
/// ```dart
/// AdaptiveShimmer(
///   child: ListView.builder(
///     itemCount: 8,
///     itemBuilder: (_, __) => const AdaptiveSkeletonListTile(shimmer: false),
///   ),
/// )
/// ```
class AdaptiveSkeletonListTile extends StatelessWidget {
  /// Whether this row animates on its own. Turn it off when an ancestor
  /// [AdaptiveShimmer] already covers the list.
  final bool shimmer;

  /// Diameter of the leading circle. 44 matches the iOS minimum touch target
  /// and the Material list avatar.
  final double avatarSize;

  /// Whether the trailing subtitle line is drawn.
  final bool hasSubtitle;

  /// Padding around the row. Defaults to the platform's list row inset.
  final EdgeInsetsGeometry? padding;

  const AdaptiveSkeletonListTile({
    super.key,
    this.shimmer = true,
    this.avatarSize = 44,
    this.hasSubtitle = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AdaptiveSpacing.page,
            vertical: AdaptiveSpacing.md,
          ),
      child: Row(
        children: <Widget>[
          AdaptiveSkeletonCircle(size: avatarSize),
          const SizedBox(width: AdaptiveSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const AdaptiveSkeletonBox(height: 14),
                if (hasSubtitle) ...<Widget>[
                  const SizedBox(height: AdaptiveSpacing.sm),
                  const AdaptiveSkeletonBox(width: 120, height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return shimmer ? AdaptiveShimmer(child: content) : content;
  }
}

/// Placeholder for a media card: an image slot, a title line and a shorter
/// caption line, inside an [AdaptiveCard].
///
/// Set [shimmer] to false when a grid or list of these is already wrapped in a
/// single [AdaptiveShimmer].
///
/// ```dart
/// const AdaptiveSkeletonCard()
/// ```
class AdaptiveSkeletonCard extends StatelessWidget {
  /// Whether this card animates on its own. Turn it off when an ancestor
  /// [AdaptiveShimmer] already covers the collection.
  final bool shimmer;

  /// Height of the image slot in logical pixels.
  final double mediaHeight;

  /// Padding inside the card.
  final EdgeInsetsGeometry? padding;

  const AdaptiveSkeletonCard({
    super.key,
    this.shimmer = true,
    this.mediaHeight = 160,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = AdaptiveCard(
      padding: padding ?? const EdgeInsets.all(AdaptiveSpacing.md),
      borderRadius: AdaptiveRadius.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AdaptiveSkeletonBox(
            height: mediaHeight,
            borderRadius: AdaptiveRadius.card,
          ),
          const SizedBox(height: AdaptiveSpacing.md),
          const AdaptiveSkeletonBox(height: 16),
          const SizedBox(height: AdaptiveSpacing.sm),
          const AdaptiveSkeletonBox(width: 200, height: 14),
        ],
      ),
    );

    return shimmer ? AdaptiveShimmer(child: content) : content;
  }
}
