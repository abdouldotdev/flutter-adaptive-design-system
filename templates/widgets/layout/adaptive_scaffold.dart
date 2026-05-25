import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_widget.dart';

class AdaptiveScaffold
    extends PlatformWidget<Scaffold, CupertinoPageScaffold> {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final ObstructingPreferredSizeWidget? cupertinoNavigationBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;

  const AdaptiveScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.cupertinoNavigationBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Scaffold buildMaterialWidget(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }

  @override
  CupertinoPageScaffold buildCupertinoWidget(BuildContext context) {
    final content = Material(
      type: MaterialType.transparency,
      child: Column(
        children: [
          Expanded(child: body),
          if (bottomNavigationBar != null) bottomNavigationBar!,
        ],
      ),
    );

    // When no navigation bar is provided, use MediaQuery.removePadding
    // to avoid CupertinoPageScaffold computing a negative padding.
    if (cupertinoNavigationBar == null) {
      return CupertinoPageScaffold(
        backgroundColor: backgroundColor ?? CupertinoTheme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        child: content,
      );
    }

    return CupertinoPageScaffold(
      navigationBar: cupertinoNavigationBar,
      backgroundColor: backgroundColor ?? CupertinoTheme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      child: content,
    );
  }
}
