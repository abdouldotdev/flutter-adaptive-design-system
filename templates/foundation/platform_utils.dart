import 'dart:io';

import 'package:flutter/foundation.dart';

abstract final class PlatformUtils {
  static bool get isCupertino {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isMacOS;
  }

  static bool get isMaterial => !isCupertino;

  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isWeb => kIsWeb;
  static bool get isMobile => isIOS || isAndroid;
  static bool get isDesktop => isMacOS || isLinux || isWindows;
}
