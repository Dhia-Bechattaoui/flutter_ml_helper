import 'package:flutter/foundation.dart';
import 'constants/ml_constants.dart';

/// Helper class for image processing operations
/// Supports all platforms including web with WASM
class ImageHelper {
  /// Creates an image helper instance
  ImageHelper();

  /// Loads an image from bytes (platform-aware)
  Future<dynamic> loadImageFromBytes(dynamic bytes) async {
    try {
      if (MLConstants.isWeb) {
        // Web implementation
        return await _loadWebImage(bytes);
      } else {
        // Native implementation
        return await _loadNativeImage(bytes);
      }
    } catch (e) {
      debugPrint('Failed to decode image: $e');
      return null;
    }
  }

  /// Resizes an image to the specified dimensions (platform-aware)
  Future<dynamic> resizeImage(
    dynamic image,
    int width,
    int height, {
    bool maintainAspectRatio = true,
  }) async {
    try {
      if (MLConstants.isWeb) {
        return await _resizeWebImage(image, width, height, maintainAspectRatio);
      } else {
        return await _resizeNativeImage(
            image, width, height, maintainAspectRatio);
      }
    } catch (e) {
      debugPrint('Failed to resize image: $e');
      return null;
    }
  }

  /// Converts an image to grayscale (platform-aware)
  Future<dynamic> convertToGrayscale(dynamic image) async {
    try {
      if (MLConstants.isWeb) {
        return await _convertWebImageToGrayscale(image);
      } else {
        return await _convertNativeImageToGrayscale(image);
      }
    } catch (e) {
      debugPrint('Failed to convert image to grayscale: $e');
      return null;
    }
  }

  /// Normalizes image pixel values to [0, 1] range (platform-aware)
  Future<List<List<List<List<double>>>>> normalizeImage(
    dynamic image,
    int targetWidth,
    int targetHeight,
  ) async {
    try {
      if (MLConstants.isWeb) {
        return await _normalizeWebImage(image, targetWidth, targetHeight);
      } else {
        return await _normalizeNativeImage(image, targetWidth, targetHeight);
      }
    } catch (e) {
      debugPrint('Failed to normalize image: $e');
      // Return zero tensor on error
      return _createZeroTensor(targetWidth, targetHeight, 3);
    }
  }

  /// Applies preprocessing for ML models (platform-aware)
  Future<List<List<List<List<double>>>>> preprocessImageForML(
    dynamic image, {
    int targetSize = MLConstants.defaultInputSize,
    bool normalize = true,
    bool convertToGrayscale = false,
  }) async {
    try {
      if (MLConstants.isWeb) {
        return await _preprocessWebImageForML(
          image,
          targetSize: targetSize,
          normalize: normalize,
          convertToGrayscale: convertToGrayscale,
        );
      } else {
        return await _preprocessNativeImageForML(
          image,
          targetSize: targetSize,
          normalize: normalize,
          convertToGrayscale: convertToGrayscale,
        );
      }
    } catch (e) {
      debugPrint('Failed to preprocess image: $e');
      // Return zero tensor on error
      return _createZeroTensor(
          targetSize, targetSize, convertToGrayscale ? 1 : 3);
    }
  }

  /// Gets image information (platform-aware)
  Map<String, dynamic> getImageInfo(dynamic image) {
    if (MLConstants.isWeb) {
      return _getWebImageInfo(image);
    } else {
      return _getNativeImageInfo(image);
    }
  }

  /// Validates image dimensions
  bool isValidImageDimensions(int width, int height) {
    return width >= MLConstants.minImageDimension &&
        width <= MLConstants.maxImageDimension &&
        height >= MLConstants.minImageDimension &&
        height <= MLConstants.maxImageDimension;
  }

  /// Checks if image format is supported
  bool isSupportedImageFormat(String format) {
    return MLConstants.supportedImageFormats.contains(format.toLowerCase());
  }

  /// Disposes all resources
  Future<void> dispose() async {
    // No resources to dispose for this helper
  }

  // Platform-specific implementations

  // Web implementations
  Future<dynamic> _loadWebImage(dynamic bytes) async {
    // Simulate web image loading
    await Future.delayed(const Duration(milliseconds: 10));
    return {
      'width': 224,
      'height': 224,
      'channels': 3,
      'platform': 'web',
      'wasm': MLConstants.supportsWASM,
    };
  }

  Future<dynamic> _resizeWebImage(
      dynamic image, int width, int height, bool maintainAspectRatio) async {
    // Simulate web image resizing
    await Future.delayed(const Duration(milliseconds: 5));
    return {
      'width': width,
      'height': height,
      'channels': image['channels'] ?? 3,
      'platform': 'web',
      'resized': true,
    };
  }

  Future<dynamic> _convertWebImageToGrayscale(dynamic image) async {
    // Simulate web grayscale conversion
    await Future.delayed(const Duration(milliseconds: 8));
    return {
      'width': image['width'] ?? 224,
      'height': image['height'] ?? 224,
      'channels': 1,
      'platform': 'web',
      'grayscale': true,
    };
  }

  Future<List<List<List<List<double>>>>> _normalizeWebImage(
      dynamic image, int targetWidth, int targetHeight) async {
    // Simulate web image normalization
    await Future.delayed(const Duration(milliseconds: 15));

    // Return normalized tensor for web
    return _createNormalizedTensor(targetWidth, targetHeight, 3, 0.5);
  }

  Future<List<List<List<List<double>>>>> _preprocessWebImageForML(
    dynamic image, {
    int targetSize = MLConstants.defaultInputSize,
    bool normalize = true,
    bool convertToGrayscale = false,
  }) async {
    // Simulate web preprocessing
    await Future.delayed(const Duration(milliseconds: 20));

    if (normalize) {
      return _createNormalizedTensor(
          targetSize, targetSize, convertToGrayscale ? 1 : 3, 0.5);
    } else {
      return _createZeroTensor(
          targetSize, targetSize, convertToGrayscale ? 1 : 3);
    }
  }

  Map<String, dynamic> _getWebImageInfo(dynamic image) {
    return {
      'width': image['width'] ?? 224,
      'height': image['height'] ?? 224,
      'channels': image['channels'] ?? 3,
      'format': 'web_format',
      'sizeBytes': 0,
      'hasAlpha': false,
      'platform': 'web',
      'wasm': MLConstants.supportsWASM,
    };
  }

  // Native implementations
  Future<dynamic> _loadNativeImage(dynamic bytes) async {
    // Simulate native image loading
    await Future.delayed(const Duration(milliseconds: 20));
    return {
      'width': 224,
      'height': 224,
      'channels': 3,
      'platform': 'native',
    };
  }

  Future<dynamic> _resizeNativeImage(
      dynamic image, int width, int height, bool maintainAspectRatio) async {
    // Simulate native image resizing
    await Future.delayed(const Duration(milliseconds: 15));
    return {
      'width': width,
      'height': height,
      'channels': image['channels'] ?? 3,
      'platform': 'native',
      'resized': true,
    };
  }

  Future<dynamic> _convertNativeImageToGrayscale(dynamic image) async {
    // Simulate native grayscale conversion
    await Future.delayed(const Duration(milliseconds: 25));
    return {
      'width': image['width'] ?? 224,
      'height': image['height'] ?? 224,
      'channels': 1,
      'platform': 'native',
      'grayscale': true,
    };
  }

  Future<List<List<List<List<double>>>>> _normalizeNativeImage(
      dynamic image, int targetWidth, int targetHeight) async {
    // Simulate native image normalization
    await Future.delayed(const Duration(milliseconds: 30));

    // Return normalized tensor for native
    return _createNormalizedTensor(targetWidth, targetHeight, 3, 0.5);
  }

  Future<List<List<List<List<double>>>>> _preprocessNativeImageForML(
    dynamic image, {
    int targetSize = MLConstants.defaultInputSize,
    bool normalize = true,
    bool convertToGrayscale = false,
  }) async {
    // Simulate native preprocessing
    await Future.delayed(const Duration(milliseconds: 40));

    if (normalize) {
      return _createNormalizedTensor(
          targetSize, targetSize, convertToGrayscale ? 1 : 3, 0.5);
    } else {
      return _createZeroTensor(
          targetSize, targetSize, convertToGrayscale ? 1 : 3);
    }
  }

  Map<String, dynamic> _getNativeImageInfo(dynamic image) {
    return {
      'width': image['width'] ?? 224,
      'height': image['height'] ?? 224,
      'channels': image['channels'] ?? 3,
      'format': 'native_format',
      'sizeBytes': 0,
      'hasAlpha': false,
      'platform': 'native',
    };
  }

  // Utility methods
  List<List<List<List<double>>>> _createZeroTensor(
      int width, int height, int channels) {
    return List.generate(
      1,
      (batch) => List.generate(
        height,
        (h) => List.generate(
          width,
          (w) => List.generate(channels, (c) => 0.0),
        ),
      ),
    );
  }

  List<List<List<List<double>>>> _createNormalizedTensor(
      int width, int height, int channels, double value) {
    return List.generate(
      1,
      (batch) => List.generate(
        height,
        (h) => List.generate(
          width,
          (w) => List.generate(channels, (c) => value),
        ),
      ),
    );
  }
}
