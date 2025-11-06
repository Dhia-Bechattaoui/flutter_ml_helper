import 'package:permission_handler/permission_handler.dart';
import '../constants/ml_constants.dart';
import '../constants/platform_detection.dart';

/// Utility class for handling device permissions required by ML operations
/// Supports all platforms including web with conditional permission handling
class PermissionUtils {
  // Private constructor to prevent instantiation
  PermissionUtils._();

  /// Checks if camera permission is granted (platform-aware)
  static Future<bool> isCameraPermissionGranted() async {
    if (!MLConstants.canAccessCamera) return false;

    if (MLConstants.isWeb) {
      // Web permissions are handled differently
      return await _checkWebCameraPermission();
    }

    // Mobile platforms use permission_handler
    return await _checkMobileCameraPermission();
  }

  /// Requests camera permission (platform-aware)
  static Future<bool> requestCameraPermission() async {
    if (!MLConstants.canAccessCamera) return false;

    if (MLConstants.isWeb) {
      return await _requestWebCameraPermission();
    }

    return await _requestMobileCameraPermission();
  }

  /// Checks if storage permission is granted (platform-aware)
  static Future<bool> isStoragePermissionGranted() async {
    if (!MLConstants.canAccessStorage) return false;

    if (MLConstants.isWeb) {
      // Web has limited storage access
      return true;
    }

    return await _checkMobileStoragePermission();
  }

  /// Requests storage permission (platform-aware)
  static Future<bool> requestStoragePermission() async {
    if (!MLConstants.canAccessStorage) return false;

    if (MLConstants.isWeb) {
      return true;
    }

    return await _requestMobileStoragePermission();
  }

  /// Checks if microphone permission is granted (platform-aware)
  static Future<bool> isMicrophonePermissionGranted() async {
    if (!MLConstants.canAccessMicrophone) return false;

    if (MLConstants.isWeb) {
      return await _checkWebMicrophonePermission();
    }

    return await _checkMobileMicrophonePermission();
  }

  /// Requests microphone permission (platform-aware)
  static Future<bool> requestMicrophonePermission() async {
    if (!MLConstants.canAccessMicrophone) return false;

    if (MLConstants.isWeb) {
      return await _requestWebMicrophonePermission();
    }

    return await _requestMobileMicrophonePermission();
  }

  /// Checks if location permission is granted (platform-aware)
  static Future<bool> isLocationPermissionGranted() async {
    if (!MLConstants.canAccessLocation) return false;

    if (MLConstants.isWeb) {
      return await _checkWebLocationPermission();
    }

    return await _checkMobileLocationPermission();
  }

  /// Requests location permission (platform-aware)
  static Future<bool> requestLocationPermission() async {
    if (!MLConstants.canAccessLocation) return false;

    if (MLConstants.isWeb) {
      return await _requestWebLocationPermission();
    }

    return await _requestMobileLocationPermission();
  }

  /// Checks if all required permissions for ML operations are granted
  static Future<bool> areAllMLPermissionsGranted() async {
    if (MLConstants.isWeb) {
      // Web only needs camera and microphone for ML
      return await isCameraPermissionGranted() &&
          await isMicrophonePermissionGranted();
    }

    // Mobile needs camera and storage
    return await isCameraPermissionGranted() &&
        await isStoragePermissionGranted();
  }

  /// Requests all required permissions for ML operations
  static Future<Map<String, bool>> requestAllMLPermissions() async {
    final results = <String, bool>{};

    if (MLConstants.isWeb) {
      results['camera'] = await requestCameraPermission();
      results['microphone'] = await requestMicrophonePermission();
    } else {
      results['camera'] = await requestCameraPermission();
      results['storage'] = await requestStoragePermission();
    }

    return results;
  }

  /// Opens app settings if permissions are permanently denied
  static Future<bool> openAppSettings() async {
    if (MLConstants.isWeb) {
      // Web doesn't have app settings
      return false;
    }

    return await _openMobileAppSettings();
  }

  /// Checks if a permission is permanently denied
  static Future<bool> isPermissionPermanentlyDenied(String permission) async {
    if (MLConstants.isWeb) {
      return false;
    }

    return await _checkMobilePermissionPermanentlyDenied(permission);
  }

  /// Gets a human-readable description of permission status
  static String getPermissionStatusDescription(String status) {
    switch (status.toLowerCase()) {
      case 'granted':
        return 'Granted';
      case 'denied':
        return 'Denied';
      case 'restricted':
        return 'Restricted';
      case 'limited':
        return 'Limited';
      case 'permanently_denied':
        return 'Permanently Denied';
      case 'provisional':
        return 'Provisional';
      default:
        return 'Unknown';
    }
  }

  /// Checks if permissions should be shown in settings
  static Future<bool> shouldShowRequestRationale(String permission) async {
    if (MLConstants.isWeb) {
      return false;
    }

    return await _checkMobileShouldShowRequestRationale(permission);
  }

  // Platform-specific implementations

  // Web implementations
  static Future<bool> _checkWebCameraPermission() async {
    try {
      // Check if camera is available on web
      return true; // Assume granted for now
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _requestWebCameraPermission() async {
    try {
      // Request camera permission on web
      return true; // Assume granted for now
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _checkWebMicrophonePermission() async {
    try {
      // Check if microphone is available on web
      return true; // Assume granted for now
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _requestWebMicrophonePermission() async {
    try {
      // Request microphone permission on web
      return true; // Assume granted for now
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _checkWebLocationPermission() async {
    try {
      // Check if location is available on web
      return true; // Assume granted for now
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _requestWebLocationPermission() async {
    try {
      // Request location permission on web
      return true; // Assume granted for now
    } catch (e) {
      return false;
    }
  }

  // Mobile implementations (using permission_handler)
  static Future<bool> _checkMobileCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _requestMobileCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _checkMobileStoragePermission() async {
    try {
      // On Android 13+, use photos/videos instead
      if (PlatformDetection.isAndroid) {
        final status = await Permission.photos.status;
        return status.isGranted;
      } else {
        final status = await Permission.storage.status;
        return status.isGranted;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _requestMobileStoragePermission() async {
    try {
      // On Android 13+, use photos/videos instead
      if (PlatformDetection.isAndroid) {
        final status = await Permission.photos.request();
        return status.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _checkMobileMicrophonePermission() async {
    try {
      final status = await Permission.microphone.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _requestMobileMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _checkMobileLocationPermission() async {
    try {
      final status = await Permission.location.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _requestMobileLocationPermission() async {
    try {
      final status = await Permission.location.request();
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _openMobileAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _checkMobilePermissionPermanentlyDenied(
    String permission,
  ) async {
    try {
      Permission perm;
      switch (permission.toLowerCase()) {
        case 'camera':
          perm = Permission.camera;
          break;
        case 'storage':
        case 'photos':
          perm = PlatformDetection.isAndroid
              ? Permission.photos
              : Permission.storage;
          break;
        case 'microphone':
          perm = Permission.microphone;
          break;
        case 'location':
          perm = Permission.location;
          break;
        default:
          return false;
      }

      final status = await perm.status;
      return status.isPermanentlyDenied;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _checkMobileShouldShowRequestRationale(
    String permission,
  ) async {
    try {
      Permission perm;
      switch (permission.toLowerCase()) {
        case 'camera':
          perm = Permission.camera;
          break;
        case 'storage':
        case 'photos':
          perm = PlatformDetection.isAndroid
              ? Permission.photos
              : Permission.storage;
          break;
        case 'microphone':
          perm = Permission.microphone;
          break;
        case 'location':
          perm = Permission.location;
          break;
        default:
          return false;
      }

      final status = await perm.status;
      return status.isDenied;
    } catch (e) {
      return false;
    }
  }
}
