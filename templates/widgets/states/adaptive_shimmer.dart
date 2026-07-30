import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_utils.dart';

/// Sweeps a highlight across its subtree, the classic "content is loading"
/// effect for skeleton placeholders.
///
/// Wrap the **whole** placeholder screen in one shimmer rather than each
/// shape: a list of twenty shimmering rows means twenty
/// [AnimationController]s ticking at 60 Hz, and the sweep looks wrong anyway
/// because each row restarts it from its own left edge.
///
/// ```dart
/// AdaptiveShimmer(
///   child: ListView.builder(
///     itemCount: 8,
///     itemBuilder: (_, __) => const AdaptiveSkeletonListTile(shimmer: false),
///   ),
/// )
/// ```
///
/// Adaptation is in three places. The sweep runs horizontally on iOS and
/// diagonally on Material, matching how each platform animates highlights; the
/// period is slightly quicker on iOS; and the colours resolve from
/// [CupertinoColors] or the [ColorScheme] so the effect survives dark mode.
///
/// The animation also stops when the user has asked for reduced motion
/// (`MediaQuery.disableAnimationsOf`). The skeleton shapes paint their own
/// base colour, so the placeholder stays perfectly legible — it simply holds
/// still.
class AdaptiveShimmer extends StatefulWidget {
  /// The subtree the highlight sweeps across, normally skeleton shapes.
  final Widget child;

  /// Whether the sweep runs. When false the subtree is returned untouched,
  /// which is what you want once the real content has arrived.
  final bool enabled;

  /// Duration of one full sweep. Defaults to 1200 ms on Cupertino and 1500 ms
  /// on Material.
  final Duration? period;

  /// Overrides the resting colour. Defaults to [baseColorOf].
  final Color? baseColor;

  /// Overrides the colour of the moving highlight. Defaults to
  /// [highlightColorOf].
  final Color? highlightColor;

  const AdaptiveShimmer({
    super.key,
    required this.child,
    this.enabled = true,
    this.period,
    this.baseColor,
    this.highlightColor,
  });

  /// The resting placeholder colour for the current platform.
  ///
  /// `systemGrey5` on Cupertino — a dynamic colour, so it inverts in dark mode
  /// on its own — and `surfaceContainerHighest` on Material.
  ///
  /// Exposed so skeleton shapes can paint the same colour without depending on
  /// a shimmer being present above them.
  static Color baseColorOf(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return CupertinoColors.systemGrey5.resolveFrom(context);
    }
    return Theme.of(context).colorScheme.surfaceContainerHighest;
  }

  /// The colour of the moving highlight for the current platform.
  ///
  /// Computed from [baseColorOf] by blending towards white — strongly in light
  /// mode, gently in dark mode, where a bright sweep on a dark placeholder is
  /// glaring rather than subtle.
  static Color highlightColorOf(BuildContext context) {
    final Color base = baseColorOf(context);
    final bool isDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    return Color.lerp(base, const Color(0xFFFFFFFF), isDark ? 0.14 : 0.55) ??
        base;
  }

  @override
  State<AdaptiveShimmer> createState() => _AdaptiveShimmerState();
}

class _AdaptiveShimmerState extends State<AdaptiveShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _period);
    // Not started here: didChangeDependencies runs before the first build and
    // is the earliest place MediaQuery can be read.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _syncAnimation();
  }

  @override
  void didUpdateWidget(AdaptiveShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.period != oldWidget.period) {
      _controller.duration = _period;
    }
    _syncAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Duration get _period =>
      widget.period ??
      (PlatformUtils.isCupertino
          ? const Duration(milliseconds: 1200)
          : const Duration(milliseconds: 1500));

  bool get _shouldRun => widget.enabled && !_reduceMotion;

  void _syncAnimation() {
    if (_shouldRun && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!_shouldRun && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldRun) return widget.child;

    final Color base = widget.baseColor ?? AdaptiveShimmer.baseColorOf(context);
    final Color highlight =
        widget.highlightColor ?? AdaptiveShimmer.highlightColorOf(context);
    final bool isCupertino = PlatformUtils.isCupertino;

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double value = _controller.value;

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: isCupertino ? Alignment.centerLeft : Alignment.topLeft,
              end: isCupertino ? Alignment.centerRight : Alignment.bottomRight,
              colors: <Color>[base, highlight, base],
              stops: <double>[
                (value - 0.3).clamp(0.0, 1.0),
                value.clamp(0.0, 1.0),
                (value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      // Passed as `child` so the subtree is built once and only the shader is
      // recomputed on each tick.
      child: widget.child,
    );
  }
}
