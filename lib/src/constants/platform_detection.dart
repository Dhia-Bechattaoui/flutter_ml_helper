// This file provides platform detection without importing dart:io
// It will be imported conditionally based on the platform

/// Platform detection utilities that work on all platforms
class PlatformDetection {
  static bool get isWeb => false; // Will be overridden by web implementation
  static bool get isAndroid => false;
  static bool get isIOS => false;
  static bool get isWindows => false;
  static bool get isMacOS => false;
  static bool get isLinux => false;

  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => isWindows || isMacOS || isLinux;
}
