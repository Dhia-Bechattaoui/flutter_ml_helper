import 'dart:async';
import 'package:flutter/foundation.dart';
import 'models/ml_result.dart';
import 'models/ml_model_info.dart';
import 'constants/ml_constants.dart';
import 'utils/path_utils.dart';

/// Helper class for TensorFlow Lite operations
/// Supports all platforms including WASM on web
class TFLiteHelper {
  final bool _enableWASM;
  final Map<String, dynamic> _loadedModels = {};
  final Map<String, MLModelInfo> _modelInfo = {};

  /// Creates a TFLite helper instance
  TFLiteHelper({bool enableWASM = false}) : _enableWASM = enableWASM;

  /// Gets whether TFLite is available
  bool get isAvailable => MLConstants.supportsTFLite;

  /// Gets whether WASM is enabled
  bool get isWASMEnabled => _enableWASM && MLConstants.supportsWASM;

  /// Loads a TFLite model from the given path (platform-aware)
  Future<bool> loadModel(String modelPath) async {
    try {
      if (!isAvailable) {
        throw UnsupportedError('TFLite not supported on this platform');
      }

      final modelName = PathUtils.getFileNameWithoutExtension(modelPath);

      if (MLConstants.isWeb && isWASMEnabled) {
        // Web with WASM support
        return await _loadWebModel(modelPath, modelName);
      } else if (!MLConstants.isWeb) {
        // Native platforms
        return await _loadNativeModel(modelPath, modelName);
      } else {
        // Web without WASM
        throw UnsupportedError('WASM not enabled for web platform');
      }
    } catch (e) {
      debugPrint('Failed to load TFLite model: $e');
      return false;
    }
  }

  /// Runs inference using a loaded model (platform-aware)
  Future<MLResult> runInference({
    required dynamic input,
    required String modelName,
    Map<String, dynamic>? options,
  }) async {
    try {
      if (!isAvailable) {
        throw UnsupportedError('TFLite not supported on this platform');
      }

      final model = _loadedModels[modelName];
      if (model == null) {
        throw Exception('Model not loaded: $modelName');
      }

      final stopwatch = Stopwatch()..start();

      MLResult result;

      if (MLConstants.isWeb && isWASMEnabled) {
        // Web with WASM
        result = await _runWebInference(modelName, input, options);
      } else {
        // Native platforms
        result = await _runNativeInference(modelName, input, options);
      }

      stopwatch.stop();
      final inferenceTime = stopwatch.elapsedMicroseconds / 1000.0;

      // Update inference time
      if (result.isSuccess) {
        return MLResult.success(
          rawOutput: result.rawOutput,
          predictions: result.predictions,
          confidences: result.confidences,
          modelName: result.modelName,
          backend: result.backend,
          inferenceTime: inferenceTime,
          metadata: {
            ...result.metadata,
            'wasmEnabled': isWASMEnabled,
            'platform': MLConstants.isWeb ? 'web' : 'native',
          },
        );
      }

      return result;
    } catch (e) {
      return MLResult.error(
        error: e.toString(),
        modelName: modelName,
        backend: MLConstants.backendTFLite,
      );
    }
  }

  /// Gets information about available models
  Future<List<MLModelInfo>> getAvailableModels() async {
    return _modelInfo.values.toList();
  }

  /// Unloads a specific model
  Future<bool> unloadModel(String modelName) async {
    try {
      if (_loadedModels.containsKey(modelName)) {
        _loadedModels.remove(modelName);
        _modelInfo.remove(modelName);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Failed to unload model: $e');
      return false;
    }
  }

  /// Disposes all resources
  Future<void> dispose() async {
    _loadedModels.clear();
    _modelInfo.clear();
  }

  // Platform-specific implementations

  /// Loads a model on web with WASM support
  Future<bool> _loadWebModel(String modelPath, String modelName) async {
    try {
      // Simulate WASM model loading
      _loadedModels[modelName] = {
        'loaded': true,
        'wasm': true,
        'path': modelPath,
      };

      // Create model info for web
      _modelInfo[modelName] = MLModelInfo(
        name: modelName,
        version: '1.0.0',
        backend: MLConstants.backendWASM,
        path: modelPath,
        sizeBytes: 1024 * 1024, // 1MB estimate
        inputShape: [1, 224, 224, 3],
        outputShape: [1, 1000],
        dataType: 'float32',
        isLoaded: true,
        metadata: {
          'wasm': true,
          'platform': 'web',
        },
      );

      return true;
    } catch (e) {
      debugPrint('Failed to load web model: $e');
      return false;
    }
  }

  /// Loads a model on native platforms
  Future<bool> _loadNativeModel(String modelPath, String modelName) async {
    try {
      // Simulate native model loading
      _loadedModels[modelName] = {
        'loaded': true,
        'native': true,
        'path': modelPath,
      };

      // Create model info for native platforms
      _modelInfo[modelName] = MLModelInfo(
        name: modelName,
        version: '1.0.0',
        backend: MLConstants.backendTFLite,
        path: modelPath,
        sizeBytes: 1024 * 1024, // 1MB estimate
        inputShape: [1, 224, 224, 3],
        outputShape: [1, 1000],
        dataType: 'float32',
        isLoaded: true,
        metadata: {
          'native': true,
          'platform': 'native',
        },
      );

      return true;
    } catch (e) {
      debugPrint('Failed to load native model: $e');
      return false;
    }
  }

  /// Runs inference on web with WASM
  Future<MLResult> _runWebInference(
      String modelName, dynamic input, Map<String, dynamic>? options) async {
    try {
      // Simulate WASM inference
      await Future.delayed(const Duration(milliseconds: 50)); // Faster on web

      // Placeholder output for web
      final outputTensor = List.filled(1000, 0.0);
      outputTensor[0] = 0.95; // High confidence for first class
      outputTensor[1] = 0.03; // Lower confidence for second class

      final predictions = [0, 1];
      final confidences = [0.95, 0.03];

      return MLResult.success(
        rawOutput: outputTensor,
        predictions: predictions,
        confidences: confidences,
        modelName: modelName,
        backend: MLConstants.backendWASM,
        inferenceTime: 0.0, // Will be updated by caller
        metadata: {
          'inputShape': [1, 224, 224, 3],
          'outputShape': [1, 1000],
          'wasmEnabled': true,
          'platform': 'web',
        },
      );
    } catch (e) {
      return MLResult.error(
        error: e.toString(),
        modelName: modelName,
        backend: MLConstants.backendWASM,
      );
    }
  }

  /// Runs inference on native platforms
  Future<MLResult> _runNativeInference(
      String modelName, dynamic input, Map<String, dynamic>? options) async {
    try {
      // Simulate native inference
      await Future.delayed(const Duration(milliseconds: 100));

      // Placeholder output for native
      final outputTensor = List.filled(1000, 0.0);
      outputTensor[0] = 0.9; // High confidence for first class
      outputTensor[1] = 0.05; // Lower confidence for second class

      final predictions = [0, 1];
      final confidences = [0.9, 0.05];

      return MLResult.success(
        rawOutput: outputTensor,
        predictions: predictions,
        confidences: confidences,
        modelName: modelName,
        backend: MLConstants.backendTFLite,
        inferenceTime: 0.0, // Will be updated by caller
        metadata: {
          'inputShape': [1, 224, 224, 3],
          'outputShape': [1, 1000],
          'wasmEnabled': false,
          'platform': 'native',
        },
      );
    } catch (e) {
      return MLResult.error(
        error: e.toString(),
        modelName: modelName,
        backend: MLConstants.backendTFLite,
      );
    }
  }
}
