import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_widget.dart';

/// Adaptive list tile.
///
/// Material: [ListTile] with M3 styling.
/// Cupertino: [CupertinoListTile] with iOS styling.
class AdaptiveListTile extends PlatformWidget<ListTile, CupertinoListTile> {
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final EdgeInsetsGeometry? contentPadding;
  final bool dense;

  const AdaptiveListTile({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.contentPadding,
    this.dense = false,
  });

  @override
  ListTile buildMaterialWidget(BuildContext context) {
    return ListTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      onTap: onTap,
      onLongPress: onLongPress,
      enabled: enabled,
      contentPadding: contentPadding,
      dense: dense,
    );
  }

  @override
  CupertinoListTile buildCupertinoWidget(BuildContext context) {
    return CupertinoListTile(
      title: title ?? const SizedBox.shrink(),
      subtitle: subtitle,
      leading: leading,
      trailing: trailing ??
          (onTap != null ? const CupertinoListTileChevron() : null),
      onTap: onTap,
      padding: contentPadding as EdgeInsets?,
    );
  }
}
