import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_widget.dart';

/// Adaptive divider.
///
/// Material: [Divider] with standard 1px height.
/// Cupertino: [Container] with 0.5px height (iOS hairline separator).
class AdaptiveDivider extends PlatformWidget<Divider, Widget> {
  final double? indent;
  final double? endIndent;
  final Color? color;
  final double? height;

  const AdaptiveDivider({
    super.key,
    this.indent,
    this.endIndent,
    this.color,
    this.height,
  });

  @override
  Divider buildMaterialWidget(BuildContext context) {
    return Divider(
      indent: indent,
      endIndent: endIndent,
      color: color,
      height: height ?? 1,
      thickness: 1,
    );
  }

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    final resolvedColor =
        color ?? CupertinoColors.separator.resolveFrom(context);

    return Container(
      height: height ?? 0.5,
      margin: EdgeInsetsDirectional.only(
        start: indent ?? 0,
        end: endIndent ?? 0,
      ),
      color: resolvedColor,
    );
  }
}
