import 'dart:io' as io;

/// Native implementation: reflects the real host OS.
///
/// Reserved for NON-UI concerns (permissions, store links, file paths). To pick
/// a Material/Cupertino rendering, use [PlatformUtils.isCupertino].
bool get isIOS => io.Platform.isIOS;
bool get isAndroid => io.Platform.isAndroid;
bool get isMacOS => io.Platform.isMacOS;
bool get isLinux => io.Platform.isLinux;
bool get isWindows => io.Platform.isWindows;
