import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// ImageNet class labels mapping (ImageNet-1K, 1000 classes)
///
/// IMPORTANT: Class indices are NOT stored in the model - they are just ARRAY POSITIONS!
///
/// How it works:
/// 1. Model outputs a vector of 1000 scores (one per class)
/// 2. We find the position (index) with the highest score: e.g., position 611
/// 3. This position (611) is what we call the "class index"
/// 4. We then look up what ImageNet class corresponds to index 611: "military uniform"
///
/// This mapping is separate from the model - it's a human-readable interpretation
/// of what each array position means in the ImageNet dataset.
class ImageNetLabels {
  ImageNetLabels._();

  /// URL to the ImageNet class labels file
  static const String _labelsUrl =
      'https://raw.githubusercontent.com/pytorch/hub/master/imagenet_classes.txt';

  /// Cached labels loaded from URL
  static Map<int, String>? _cachedLabels;

  /// Fallback hardcoded labels for common classes (used if URL fetch fails)
  static const Map<int, String> _fallbackLabels = {
    611: 'military uniform',
    794: 'park bench',
    524: 'carton',
    679: 'mortarboard',
    842: 'swing',
    653: 'pillow',
  };

  /// Whether labels are currently being loaded
  static bool _isLoading = false;

  /// Loads ImageNet class labels from the GitHub URL
  /// Returns true if successful, false otherwise
  static Future<bool> loadLabels() async {
    if (_cachedLabels != null) {
      // Already loaded
      return true;
    }

    if (_isLoading) {
      // Already loading, wait a bit and check again
      await Future.delayed(const Duration(milliseconds: 100));
      return _cachedLabels != null;
    }

    _isLoading = true;

    try {
      final response = await http
          .get(Uri.parse(_labelsUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final lines = response.body.split('\n');
        _cachedLabels = {};

        // Parse lines: each line is a class name, index is the line number (0-based)
        // Use a separate counter to ensure sequential mapping (0, 1, 2, ...) even if some lines are empty
        int classIndex = 0;
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isNotEmpty) {
            _cachedLabels![classIndex] = trimmed;
            classIndex++;
          }
          // Skip empty lines - they don't get assigned to any index
        }

        debugPrint('Loaded ${_cachedLabels!.length} ImageNet class labels');
        // Debug: verify first few labels
        if (_cachedLabels!.length >= 3) {
          debugPrint('Label 0: ${_cachedLabels![0]}');
          debugPrint('Label 1: ${_cachedLabels![1]}');
          debugPrint('Label 2: ${_cachedLabels![2]}');
        }
        _isLoading = false;
        return true;
      } else {
        debugPrint(
          'Failed to load ImageNet labels: HTTP ${response.statusCode}',
        );
        _isLoading = false;
        return false;
      }
    } catch (e) {
      debugPrint('Error loading ImageNet labels from URL: $e');
      debugPrint('Using fallback labels');
      _isLoading = false;
      return false;
    }
  }

  /// Gets the class name for a given index
  /// Returns the ImageNet label if available, otherwise returns "Class {index}"
  static String getLabel(int classIndex) {
    // Try cached labels first
    if (_cachedLabels != null && _cachedLabels!.containsKey(classIndex)) {
      return _cachedLabels![classIndex]!;
    }

    // Try fallback labels
    if (_fallbackLabels.containsKey(classIndex)) {
      return _fallbackLabels[classIndex]!;
    }

    // Return generic class name
    return 'Class $classIndex';
  }

  /// Gets a formatted display name
  static String getDisplayName(int classIndex) {
    final label = getLabel(classIndex);
    // Capitalize first letter
    if (label.startsWith('Class ')) {
      return label;
    }
    return label.split(',').first.trim();
  }

  /// Gets all loaded labels (for debugging)
  static Map<int, String>? getAllLabels() {
    return _cachedLabels != null ? Map<int, String>.from(_cachedLabels!) : null;
  }

  /// Clears the cached labels (forces reload on next access)
  static void clearCache() {
    _cachedLabels = null;
  }
}
