import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_utils.dart';

/// Adaptive pull-to-refresh that renders [RefreshIndicator] on Material
/// and [CupertinoSliverRefreshControl] on Cupertino.
///
/// On Cupertino, the [child] must be a scrollable widget (e.g. [ListView]).
/// The widget wraps it in a [CustomScrollView] with a
/// [CupertinoSliverRefreshControl] prepended.
class AdaptiveRefreshIndicator extends StatelessWidget {
  /// The scrollable child widget.
  final Widget child;

  /// Callback invoked when the user triggers a refresh.
  final Future<void> Function() onRefresh;

  /// The distance the user must drag to trigger a refresh (Material only).
  final double displacement;

  /// The color of the Material refresh indicator.
  final Color? color;

  /// The background color of the Material refresh indicator.
  final Color? backgroundColor;

  const AdaptiveRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.displacement = 40.0,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return _buildCupertinoRefresh(context);
    }
    return _buildMaterialRefresh(context);
  }

  Widget _buildMaterialRefresh(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      displacement: displacement,
      color: color,
      backgroundColor: backgroundColor,
      child: child,
    );
  }

  Widget _buildCupertinoRefresh(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: onRefresh,
        ),
        SliverToBoxAdapter(child: child),
      ],
    );
  }
}
