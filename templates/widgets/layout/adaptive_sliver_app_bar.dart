import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_utils.dart';

/// Adaptive sliver app bar for use inside a [CustomScrollView].
///
/// Material: [SliverAppBar] with expandable/collapsible behavior.
/// Cupertino: [CupertinoSliverNavigationBar] with large title.
class AdaptiveSliverAppBar extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final bool pinned;
  final bool floating;
  final double? expandedHeight;
  final Widget? flexibleSpace;
  final bool stretch;
  final String? previousPageTitle;

  const AdaptiveSliverAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.pinned = true,
    this.floating = false,
    this.expandedHeight,
    this.flexibleSpace,
    this.stretch = false,
    this.previousPageTitle,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return CupertinoSliverNavigationBar(
        largeTitle: titleWidget ?? (title != null ? Text(title!) : null),
        leading: leading,
        trailing: actions != null && actions!.isNotEmpty
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: actions!,
              )
            : null,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: backgroundColor,
        previousPageTitle: previousPageTitle,
        stretch: stretch,
      );
    }

    return SliverAppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      leading: leading,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor,
      pinned: pinned,
      floating: floating,
      expandedHeight: expandedHeight,
      flexibleSpace: flexibleSpace,
      stretch: stretch,
    );
  }
}
