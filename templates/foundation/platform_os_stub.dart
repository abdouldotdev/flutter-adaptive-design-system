/// Web implementation: `dart:io` does not exist in a browser.
///
/// None of these must drive a Material/Cupertino rendering choice — for that,
/// see [PlatformUtils.isCupertino], based on `defaultTargetPlatform`.
bool get isIOS => false;
bool get isAndroid => false;
bool get isMacOS => false;
bool get isLinux => false;
bool get isWindows => false;
