import 'package:flutter/foundation.dart';

import 'platform_os_stub.dart'
    if (dart.library.io) 'platform_os_io.dart' as os;

/// Platform detection for the adaptive design system.
///
/// [isCupertino] is based on [defaultTargetPlatform] — not `dart:io` — so it is
/// overridable in widget tests.
///
/// To force a rendering **in ANY build mode** (release included, e.g. a
/// deployed web gallery), use [debugOverridePlatform]. Do NOT rely on
/// `debugDefaultTargetPlatformOverride` for that: it is debug-only — setting it
/// throws in a release build, and `defaultTargetPlatform` ignores it outside
/// debug.
///
/// The [isIOS], [isAndroid] … getters report the REAL host OS through a
/// conditional import (`dart:io` does not exist on web). A DIRECT `import
/// 'dart:io'` would break the web build even under a `kIsWeb` guard — it is the
/// import itself that is rejected, not its execution. Reserve these getters for
/// non-UI concerns (permissions, store links, file paths).
abstract final class PlatformUtils {
  /// Forces the Cupertino/Material rendering, in every build mode.
  ///
  /// `null` in production (normal behaviour). Only preview tools such as a
  /// design-system gallery set it, to toggle iOS/Android live without touching
  /// the debug-only `debugDefaultTargetPlatformOverride`.
  static TargetPlatform? debugOverridePlatform;

  static bool get isCupertino {
    final TargetPlatform p = debugOverridePlatform ?? defaultTargetPlatform;
    return p == TargetPlatform.iOS || p == TargetPlatform.macOS;
  }

  static bool get isMaterial => !isCupertino;

  static bool get isIOS => os.isIOS;
  static bool get isAndroid => os.isAndroid;
  static bool get isMacOS => os.isMacOS;
  static bool get isLinux => os.isLinux;
  static bool get isWindows => os.isWindows;
  static bool get isWeb => kIsWeb;
  static bool get isMobile => isIOS || isAndroid;
  static bool get isDesktop => isMacOS || isLinux || isWindows;
}
