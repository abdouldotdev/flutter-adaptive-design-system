import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_utils.dart';

/// Adaptive app bar that renders [AppBar] on Material and
/// [CupertinoNavigationBar] on Cupertino.
///
/// Does not extend [PlatformWidget] because the Material and Cupertino
/// variants implement different supertype constraints
/// ([PreferredSizeWidget] vs [ObstructingPreferredSizeWidget]).
class AdaptiveAppBar extends StatelessWidget
    implements PreferredSizeWidget, ObstructingPreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final double? elevation;
  final bool centerTitle;
  final Widget? bottom;

  const AdaptiveAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.elevation,
    this.centerTitle = true,
    this.bottom,
  });

  @override
  Size get preferredSize {
    final bottomHeight = bottom != null ? kTextTabBarHeight : 0.0;
    if (PlatformUtils.isCupertino) {
      return Size.fromHeight(44.0 + bottomHeight);
    }
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }

  @override
  bool shouldFullyObstruct(BuildContext context) => true;

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return CupertinoNavigationBar(
        middle: titleWidget ?? (title != null ? Text(title!) : null),
        leading: leading,
        trailing: actions != null && actions!.isNotEmpty
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: actions!,
              )
            : null,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: backgroundColor,
      );
    }

    return AppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      leading: leading,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(kTextTabBarHeight),
              child: bottom!,
            )
          : null,
    );
  }
}
