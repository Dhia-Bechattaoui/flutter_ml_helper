import 'package:flutter/foundation.dart';
import 'platform_detection.dart';

/// Constants used throughout the ML Helper package
class MLConstants {
  // Private constructor to prevent instantiation
  MLConstants._();

  // Backend names
  /// TensorFlow Lite backend identifier
  static const String backendTFLite = 'TFLite';

  /// Google ML Kit backend identifier
  static const String backendMLKit = 'MLKit';

  /// WebAssembly backend identifier
  static const String backendWASM = 'WASM';

  // Model file extensions
  static const String tfliteExtension = '.tflite';
  static const String wasmExtension = '.wasm';
  static const String jsonExtension = '.json';

  // Default model configurations
  /// Default input size for image models (224x224 pixels)
  static const int defaultInputSize = 224;

  /// Default batch size for inference
  static const int defaultBatchSize = 1;

  /// Default data type for model tensors
  static const String defaultDataType = 'float32';

  /// Default confidence threshold for predictions (0.0 to 1.0)
  static const double defaultConfidenceThreshold = 0.5;

  // Image processing constants
  static const int maxImageDimension = 4096;
  static const int minImageDimension = 32;
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'bmp',
    'webp',
  ];

  // Performance constants
  static const int maxConcurrentInferences = 4;

  /// Default timeout for operations in milliseconds (30 seconds)
  static const int defaultTimeoutMs = 30000;

  static const int maxModelSizeBytes = 100 * 1024 * 1024; // 100MB

  // Error messages
  static const String errorModelNotFound = 'Model not found';
  static const String errorModelLoadFailed = 'Failed to load model';
  static const String errorInferenceFailed = 'Inference failed';
  static const String errorInvalidInput = 'Invalid input data';
  static const String errorUnsupportedPlatform = 'Platform not supported';
  static const String errorWASMNotSupported =
      'WASM not supported on this platform';

  // Success messages
  static const String successModelLoaded = 'Model loaded successfully';
  static const String successInferenceComplete =
      'Inference completed successfully';

  // Platform detection
  static const bool isWeb = kIsWeb;
  static bool get isMobile => PlatformDetection.isMobile;
  static bool get isDesktop => PlatformDetection.isDesktop;

  // Platform-specific support
  static bool get supportsTFLite => !isWeb || (isWeb && _supportsWASM);
  static bool get supportsMLKit => isMobile || isWeb;
  static bool get supportsWASM => isWeb && _supportsWASM;
  static bool get supportsPathProvider => !isWeb;
  static bool get supportsPermissionHandler => isMobile || isWeb;

  // WASM support detection
  static bool get _supportsWASM {
    if (!isWeb) return false;
    try {
      // Check if WebAssembly is available
      return true; // Assume WASM is available on web
    } catch (e) {
      return false;
    }
  }

  // Platform-specific features
  /// Whether the current platform can access the file system
  static bool get canAccessFileSystem => !isWeb;

  /// Whether the current platform can access the camera
  static bool get canAccessCamera => isMobile || isWeb;

  /// Whether the current platform can access storage
  static bool get canAccessStorage => !isWeb;

  /// Whether the current platform can access the microphone
  static bool get canAccessMicrophone => isMobile || isWeb;

  /// Whether the current platform can access location services
  static bool get canAccessLocation => isMobile || isWeb;
}
