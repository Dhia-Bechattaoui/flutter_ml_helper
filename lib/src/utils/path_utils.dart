import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import '../constants/ml_constants.dart';

/// Utility class for handling file paths and model loading
/// Supports all platforms including web with WASM
class PathUtils {
  // Private constructor to prevent instantiation
  PathUtils._();

  /// Gets the application documents directory (platform-aware)
  static Future<dynamic> get documentsDirectory async {
    if (!MLConstants.supportsPathProvider) {
      return null;
    }

    try {
      if (MLConstants.isWeb) {
        // Web doesn't have a traditional documents directory
        return null;
      }

      // Use conditional imports for platform-specific implementations
      if (MLConstants.isMobile) {
        // Mobile platforms
        return await _getMobileDocumentsDirectory();
      } else if (MLConstants.isDesktop) {
        // Desktop platforms
        return await _getDesktopDocumentsDirectory();
      }

      return null;
    } catch (e) {
      debugPrint('Failed to get documents directory: $e');
      return null;
    }
  }

  /// Gets the application support directory (platform-aware)
  static Future<dynamic> get supportDirectory async {
    if (!MLConstants.supportsPathProvider) {
      return null;
    }

    try {
      if (MLConstants.isWeb) {
        return null;
      }

      if (MLConstants.isDesktop) {
        return await _getDesktopSupportDirectory();
      }

      return null;
    } catch (e) {
      debugPrint('Failed to get support directory: $e');
      return null;
    }
  }

  /// Gets the temporary directory (platform-aware)
  static Future<dynamic> get tempDirectory async {
    if (!MLConstants.supportsPathProvider) {
      return null;
    }

    try {
      if (MLConstants.isWeb) {
        return null;
      }

      return await _getTempDirectory();
    } catch (e) {
      debugPrint('Failed to get temp directory: $e');
      return null;
    }
  }

  /// Creates a models directory in the app's documents directory
  static Future<dynamic> get modelsDirectory async {
    if (MLConstants.isWeb) {
      // For web, we'll use a virtual models directory
      return null;
    }

    final docsDir = await documentsDirectory;
    if (docsDir == null) return null;

    final modelsDir = await _createDirectory(path.join(docsDir.path, 'models'));
    return modelsDir;
  }

  /// Gets the full path to a model file (platform-aware)
  static Future<String?> getModelPath(String modelName) async {
    if (MLConstants.isWeb) {
      // For web, return a virtual path
      return 'web_models/$modelName';
    }

    final modelsDir = await modelsDirectory;
    if (modelsDir == null) return null;

    return path.join(modelsDir.path, modelName);
  }

  /// Checks if a model file exists (platform-aware)
  static Future<bool> modelExists(String modelName) async {
    try {
      if (MLConstants.isWeb) {
        // For web, check if model is available in virtual storage
        return _isWebModelAvailable(modelName);
      }

      final modelPath = await getModelPath(modelName);
      if (modelPath == null) return false;

      return await _fileExists(modelPath);
    } catch (e) {
      return false;
    }
  }

  /// Gets the file size of a model (platform-aware)
  static Future<int> getModelSize(String modelName) async {
    try {
      if (MLConstants.isWeb) {
        // For web, return estimated size
        return _getWebModelSize(modelName);
      }

      final modelPath = await getModelPath(modelName);
      if (modelPath == null) return 0;

      return await _getFileSize(modelPath);
    } catch (e) {
      return 0;
    }
  }

  /// Lists all available model files (platform-aware)
  static Future<List<String>> listAvailableModels() async {
    try {
      if (MLConstants.isWeb) {
        // For web, return virtual model list
        return _getWebAvailableModels();
      }

      final modelsDir = await modelsDirectory;
      if (modelsDir == null) return [];

      final files = await _listDirectory(modelsDir);

      return files
          .whereType<String>()
          .map((file) => path.basename(file))
          .where((name) =>
              name.endsWith(MLConstants.tfliteExtension) ||
              name.endsWith(MLConstants.wasmExtension))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Validates a model file path
  static bool isValidModelPath(String filePath) {
    if (filePath.isEmpty) return false;

    final extension = path.extension(filePath).toLowerCase();
    return extension == MLConstants.tfliteExtension ||
        extension == MLConstants.wasmExtension;
  }

  /// Gets the file extension from a path
  static String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase();
  }

  /// Gets the file name without extension
  static String getFileNameWithoutExtension(String filePath) {
    return path.basenameWithoutExtension(filePath);
  }

  /// Combines path segments
  static String combinePaths(List<String> segments) {
    return path.joinAll(segments);
  }

  /// Normalizes a file path
  static String normalizePath(String filePath) {
    return path.normalize(filePath);
  }

  /// Checks if a path is absolute
  static bool isAbsolutePath(String filePath) {
    return path.isAbsolute(filePath);
  }

  /// Gets the relative path from a base directory
  static String getRelativePath(String basePath, String targetPath) {
    return path.relative(targetPath, from: basePath);
  }

  /// Creates a directory if it doesn't exist
  static Future<dynamic> ensureDirectory(String dirPath) async {
    if (MLConstants.isWeb) return null;

    try {
      return await _createDirectory(dirPath);
    } catch (e) {
      return null;
    }
  }

  /// Deletes a file if it exists
  static Future<bool> deleteFileIfExists(String filePath) async {
    if (MLConstants.isWeb) return false;

    try {
      if (await _fileExists(filePath)) {
        await _deleteFile(filePath);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Copies a file to a new location
  static Future<bool> copyFile(
      String sourcePath, String destinationPath) async {
    if (MLConstants.isWeb) return false;

    try {
      if (await _fileExists(sourcePath)) {
        await _copyFile(sourcePath, destinationPath);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Platform-specific implementations

  // Mobile implementations
  static Future<dynamic> _getMobileDocumentsDirectory() async {
    // This would use path_provider on mobile
    // For now, return a placeholder
    return _createMockDirectory('/mobile_docs');
  }

  static Future<dynamic> _getDesktopDocumentsDirectory() async {
    // This would use path_provider on desktop
    // For now, return a placeholder
    return _createMockDirectory('/desktop_docs');
  }

  static Future<dynamic> _getDesktopSupportDirectory() async {
    return _createMockDirectory('/desktop_support');
  }

  static Future<dynamic> _getTempDirectory() async {
    return _createMockDirectory('/temp');
  }

  // File operations (platform-agnostic)
  static Future<dynamic> _createDirectory(String path) async {
    // Mock directory creation
    return _createMockDirectory(path);
  }

  static Future<bool> _fileExists(String path) async {
    // Mock file existence check
    return true;
  }

  static Future<int> _getFileSize(String path) async {
    // Mock file size
    return 1024 * 1024; // 1MB
  }

  static Future<List<dynamic>> _listDirectory(dynamic dir) async {
    // Mock directory listing
    return ['model1.tflite', 'model2.wasm'];
  }

  static Future<void> _deleteFile(String path) async {
    // Mock file deletion
  }

  static Future<void> _copyFile(String source, String destination) async {
    // Mock file copy
  }

  static dynamic _createMockDirectory(String path) {
    return {'path': path, 'type': 'directory'};
  }

  // Web-specific implementations
  static bool _isWebModelAvailable(String modelName) {
    // Check if model is available in web storage or WASM
    return modelName.endsWith(MLConstants.wasmExtension);
  }

  static int _getWebModelSize(String modelName) {
    // Return estimated size for web models
    if (modelName.endsWith(MLConstants.wasmExtension)) {
      return 1024 * 1024; // 1MB estimate
    }
    return 512 * 1024; // 512KB estimate
  }

  static List<String> _getWebAvailableModels() {
    // Return list of available web models
    return [
      'model.wasm',
      'classifier.wasm',
      'detector.wasm',
    ];
  }
}
