import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'constants/ml_constants.dart';

/// Helper class for image processing operations
/// Supports all platforms including web with WASM
class ImageHelper {
  /// Creates an image helper instance
  ImageHelper();

  /// Loads an image from bytes (platform-aware)
  Future<img.Image?> loadImageFromBytes(dynamic bytes) async {
    try {
      Uint8List imageBytes;

      if (bytes is Uint8List) {
        imageBytes = bytes;
      } else if (bytes is List<int>) {
        imageBytes = Uint8List.fromList(bytes);
      } else {
        throw Exception('Invalid image bytes format');
      }

      final image = img.decodeImage(imageBytes);
      return image;
    } catch (e) {
      debugPrint('Failed to decode image: $e');
      return null;
    }
  }

  /// Resizes an image to the specified dimensions (platform-aware)
  Future<img.Image?> resizeImage(
    img.Image? image,
    int width,
    int height, {
    bool maintainAspectRatio = true,
  }) async {
    try {
      if (image == null) return null;

      if (maintainAspectRatio) {
        return img.copyResize(
          image,
          width: width,
          height: height,
          interpolation: img.Interpolation.linear,
        );
      } else {
        return img.copyResize(
          image,
          width: width,
          height: height,
          interpolation: img.Interpolation.linear,
        );
      }
    } catch (e) {
      debugPrint('Failed to resize image: $e');
      return null;
    }
  }

  /// Converts an image to grayscale (platform-aware)
  Future<img.Image?> convertToGrayscale(img.Image? image) async {
    try {
      if (image == null) return null;
      return img.grayscale(image);
    } catch (e) {
      debugPrint('Failed to convert image to grayscale: $e');
      return null;
    }
  }

  /// Normalizes image pixel values to [0, 1] range (platform-aware)
  Future<List<List<List<List<double>>>>> normalizeImage(
    img.Image? image,
    int targetWidth,
    int targetHeight,
  ) async {
    try {
      if (image == null) {
        return _createZeroTensor(targetWidth, targetHeight, 3);
      }

      // Resize if needed
      img.Image processedImage = image;
      if (image.width != targetWidth || image.height != targetHeight) {
        processedImage = img.copyResize(
          image,
          width: targetWidth,
          height: targetHeight,
          interpolation: img.Interpolation.linear,
        );
      }

      // Normalize to [-1, 1] range (standard for MobileNet models)
      // Formula: (pixel / 255.0 - 0.5) / 0.5 converts [0, 255] -> [-1, 1]
      final tensor = List.generate(
        1,
        (batch) => List.generate(
          targetHeight,
          (h) => List.generate(targetWidth, (w) {
            final pixel = processedImage.getPixel(w, h);
            final r = (pixel.r / 255.0 - 0.5) / 0.5;
            final g = (pixel.g / 255.0 - 0.5) / 0.5;
            final b = (pixel.b / 255.0 - 0.5) / 0.5;
            return [r, g, b];
          }),
        ),
      );

      return tensor;
    } catch (e) {
      debugPrint('Failed to normalize image: $e');
      return _createZeroTensor(targetWidth, targetHeight, 3);
    }
  }

  /// Applies preprocessing for ML models (platform-aware)
  ///
  /// [normalizeRange] can be:
  /// - '0to1': Normalize to 0-1 range (pixel / 255.0)
  /// - '-1to1': Normalize to -1 to 1 range (pixel / 127.5 - 1.0)
  /// - null: No normalization (raw pixel values 0-255)
  Future<List<List<List<List<double>>>>> preprocessImageForML(
    img.Image? image, {
    int targetSize = MLConstants.defaultInputSize,
    bool normalize = true,
    String normalizeRange = '-1to1', // '0to1' or '-1to1'
    bool convertToGrayscale = false,
  }) async {
    try {
      if (image == null) {
        return _createZeroTensor(
          targetSize,
          targetSize,
          convertToGrayscale ? 1 : 3,
        );
      }

      // Step 1: Convert to grayscale if needed
      img.Image processedImage = image;
      if (convertToGrayscale) {
        processedImage = img.grayscale(processedImage);
      }

      // Step 2: Resize to target size
      if (processedImage.width != targetSize ||
          processedImage.height != targetSize) {
        processedImage = img.copyResize(
          processedImage,
          width: targetSize,
          height: targetSize,
          interpolation: img.Interpolation.linear,
        );
      }

      // Step 3: Normalize if needed
      if (normalize) {
        final tensor = List.generate(
          1,
          (batch) => List.generate(
            targetSize,
            (h) => List.generate(targetSize, (w) {
              final pixel = processedImage.getPixel(w, h);
              if (convertToGrayscale) {
                if (normalizeRange == '0to1') {
                  return [pixel.luminance / 255.0];
                } else if (normalizeRange == '-1to1') {
                  return [(pixel.luminance / 255.0 - 0.5) / 0.5];
                } else {
                  return [pixel.luminance.toDouble()];
                }
              } else {
                if (normalizeRange == '0to1') {
                  // Normalize to [0, 1] range
                  return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
                } else if (normalizeRange == '-1to1') {
                  // Normalize to [-1, 1] range
                  return [
                    (pixel.r / 255.0 - 0.5) / 0.5,
                    (pixel.g / 255.0 - 0.5) / 0.5,
                    (pixel.b / 255.0 - 0.5) / 0.5,
                  ];
                } else {
                  // No normalization
                  return [
                    pixel.r.toDouble(),
                    pixel.g.toDouble(),
                    pixel.b.toDouble(),
                  ];
                }
              }
            }),
          ),
        );
        return tensor;
      } else {
        // Return raw pixel values (0-255)
        final tensor = List.generate(
          1,
          (batch) => List.generate(
            targetSize,
            (h) => List.generate(targetSize, (w) {
              final pixel = processedImage.getPixel(w, h);
              if (convertToGrayscale) {
                return [pixel.luminance.toDouble()];
              } else {
                return [
                  pixel.r.toDouble(),
                  pixel.g.toDouble(),
                  pixel.b.toDouble(),
                ];
              }
            }),
          ),
        );
        return tensor;
      }
    } catch (e) {
      debugPrint('Failed to preprocess image: $e');
      return _createZeroTensor(
        targetSize,
        targetSize,
        convertToGrayscale ? 1 : 3,
      );
    }
  }

  /// Gets image information (platform-aware)
  Map<String, dynamic> getImageInfo(img.Image? image) {
    if (image == null) {
      return {
        'width': 0,
        'height': 0,
        'channels': 0,
        'format': 'unknown',
        'sizeBytes': 0,
        'hasAlpha': false,
      };
    }

    return {
      'width': image.width,
      'height': image.height,
      'channels': image.numChannels,
      'format': 'rgba', // image package uses RGBA
      'sizeBytes': image.data?.lengthInBytes ?? 0,
      'hasAlpha': image.numChannels == 4, // RGBA has 4 channels, RGB has 3
    };
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

  // Utility methods
  List<List<List<List<double>>>> _createZeroTensor(
    int width,
    int height,
    int channels,
  ) {
    return List.generate(
      1,
      (batch) => List.generate(
        height,
        (h) => List.generate(width, (w) => List.generate(channels, (c) => 0.0)),
      ),
    );
  }
}
