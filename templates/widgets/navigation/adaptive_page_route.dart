import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_utils.dart';

/// Provides platform-adaptive page routes.
///
/// Returns [MaterialPageRoute] on Material platforms and
/// [CupertinoPageRoute] on Cupertino platforms.
class AdaptivePageRoute {
  const AdaptivePageRoute._();

  /// Creates a platform-adaptive [PageRoute].
  static PageRoute<T> create<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
    String? title,
  }) {
    if (PlatformUtils.isCupertino) {
      return CupertinoPageRoute<T>(
        builder: builder,
        settings: settings,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
        title: title,
      );
    }
    return MaterialPageRoute<T>(
      builder: builder,
      settings: settings,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
    );
  }

  /// Pushes a new route using the platform-adaptive page route.
  static Future<T?> push<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
    String? title,
  }) {
    return Navigator.of(context).push<T>(
      create<T>(
        builder: builder,
        settings: settings,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
        title: title,
      ),
    );
  }

  /// Pushes a new route and removes all previous routes.
  static Future<T?> pushAndRemoveAll<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
    String? title,
  }) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      create<T>(
        builder: builder,
        settings: settings,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
        title: title,
      ),
      (_) => false,
    );
  }

  /// Replaces the current route with a new platform-adaptive page route.
  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context, {
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
    String? title,
    TO? result,
  }) {
    return Navigator.of(context).pushReplacement<T, TO>(
      create<T>(
        builder: builder,
        settings: settings,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
        title: title,
      ),
      result: result,
    );
  }
}
