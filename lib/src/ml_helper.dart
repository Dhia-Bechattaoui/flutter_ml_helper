import 'tflite_helper.dart';
import 'mlkit_helper.dart';
import 'image_helper.dart';
import 'models/ml_result.dart';
import 'models/ml_model_info.dart';
import 'constants/ml_constants.dart';

/// Main ML Helper class that provides a unified interface for ML operations
/// Supports all platforms including web with WASM compatibility
class MLHelper {
  final TFLiteHelper _tfLiteHelper;
  final MLKitHelper _mlKitHelper;
  final ImageHelper _imageHelper;

  /// Creates an instance of MLHelper
  ///
  /// [enableTFLite] - Whether to enable TensorFlow Lite support
  /// [enableMLKit] - Whether to enable ML Kit support
  /// [enableWASM] - Whether to enable WASM support for web platform
  MLHelper({
    bool enableTFLite = true,
    bool enableMLKit = true,
    bool enableWASM = false,
  })  : _tfLiteHelper = TFLiteHelper(enableWASM: enableWASM),
        _mlKitHelper = MLKitHelper(),
        _imageHelper = ImageHelper();

  /// Gets the TensorFlow Lite helper instance
  TFLiteHelper get tfLite => _tfLiteHelper;

  /// Gets the ML Kit helper instance
  MLKitHelper get mlKit => _mlKitHelper;

  /// Gets the image helper instance
  ImageHelper get image => _imageHelper;

  /// Checks if TensorFlow Lite is available and enabled
  bool get isTFLiteAvailable => _tfLiteHelper.isAvailable;

  /// Checks if ML Kit is available and enabled
  bool get isMLKitAvailable => _mlKitHelper.isAvailable;

  /// Checks if WASM is enabled (web platform only)
  bool get isWASMEnabled => _tfLiteHelper.isWASMEnabled;

  /// Gets the current platform information
  Map<String, dynamic> get platformInfo => {
        'isWeb': MLConstants.isWeb,
        'isMobile': MLConstants.isMobile,
        'isDesktop': MLConstants.isDesktop,
        'supportsTFLite': MLConstants.supportsTFLite,
        'supportsMLKit': MLConstants.supportsMLKit,
        'supportsWASM': MLConstants.supportsWASM,
        'canAccessCamera': MLConstants.canAccessCamera,
        'canAccessStorage': MLConstants.canAccessStorage,
      };

  /// Gets information about available ML models
  Future<List<MLModelInfo>> getAvailableModels() async {
    final models = <MLModelInfo>[];

    if (isTFLiteAvailable) {
      models.addAll(await _tfLiteHelper.getAvailableModels());
    }

    if (isMLKitAvailable) {
      models.addAll(await _mlKitHelper.getAvailableModels());
    }

    return models;
  }

  /// Performs a general ML inference using the best available backend
  Future<MLResult> performInference({
    required dynamic input,
    String? modelName,
    Map<String, dynamic>? options,
  }) async {
    // Try TensorFlow Lite first if available
    if (isTFLiteAvailable && modelName != null) {
      try {
        return await _tfLiteHelper.runInference(
          input: input,
          modelName: modelName,
          options: options,
        );
      } catch (e) {
        // Fall back to ML Kit if TFLite fails
        if (isMLKitAvailable) {
          return await _mlKitHelper.runInference(
            input: input,
            modelName: modelName,
            options: options,
          );
        }
        rethrow;
      }
    }

    // Use ML Kit if TFLite is not available
    if (isMLKitAvailable && modelName != null) {
      return await _mlKitHelper.runInference(
        input: input,
        modelName: modelName,
        options: options,
      );
    }

    throw UnsupportedError('No ML backend available on this platform');
  }

  /// Checks if the current platform supports ML operations
  bool get isPlatformSupported {
    return isTFLiteAvailable || isMLKitAvailable;
  }

  /// Gets a summary of platform capabilities
  Map<String, dynamic> get capabilities {
    return {
      'platform': MLConstants.isWeb
          ? 'web'
          : (MLConstants.isMobile ? 'mobile' : 'desktop'),
      'tflite': isTFLiteAvailable,
      'mlkit': isMLKitAvailable,
      'wasm': isWASMEnabled,
      'imageProcessing': true,
      'permissions':
          MLConstants.canAccessCamera || MLConstants.canAccessStorage,
    };
  }

  /// Disposes all resources and cleans up
  Future<void> dispose() async {
    await _tfLiteHelper.dispose();
    await _mlKitHelper.dispose();
    await _imageHelper.dispose();
  }
}
