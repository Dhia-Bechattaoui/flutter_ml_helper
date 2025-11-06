import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' if (dart.library.html) 'dart:html' as platform;

/// Platform detection utilities that work on all platforms
class PlatformDetection {
  static bool get isWeb => kIsWeb;

  static bool get isAndroid {
    if (kIsWeb) return false;
    try {
      return platform.Platform.isAndroid;
    } catch (_) {
      return false;
    }
  }

  static bool get isIOS {
    if (kIsWeb) return false;
    try {
      return platform.Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  static bool get isWindows {
    if (kIsWeb) return false;
    try {
      return platform.Platform.isWindows;
    } catch (_) {
      return false;
    }
  }

  static bool get isMacOS {
    if (kIsWeb) return false;
    try {
      return platform.Platform.isMacOS;
    } catch (_) {
      return false;
    }
  }

  static bool get isLinux {
    if (kIsWeb) return false;
    try {
      return platform.Platform.isLinux;
    } catch (_) {
      return false;
    }
  }

  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => isWindows || isMacOS || isLinux;
}
