import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'platform_utils.dart';

class AdaptiveThemeScope extends StatelessWidget {
  final ThemeData materialTheme;
  final CupertinoThemeData cupertinoTheme;
  final Widget child;

  const AdaptiveThemeScope({
    super.key,
    required this.materialTheme,
    required this.cupertinoTheme,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return CupertinoTheme(
        data: cupertinoTheme,
        child: child,
      );
    }
    return Theme(
      data: materialTheme,
      child: child,
    );
  }
}
