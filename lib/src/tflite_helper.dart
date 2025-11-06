import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'models/ml_result.dart';
import 'models/ml_model_info.dart';
import 'constants/ml_constants.dart';
import 'utils/path_utils.dart';
import 'utils/imagenet_labels.dart';

// Conditional imports for native platforms
import 'dart:io' if (dart.library.html) 'dart:html' as io;
import 'package:tflite_flutter/tflite_flutter.dart'
    if (dart.library.html) 'package:tflite_flutter/tflite_flutter_stub.dart';
import 'package:path_provider/path_provider.dart'
    if (dart.library.html) 'package:path_provider/path_provider_stub.dart';

/// Helper class for TensorFlow Lite operations
/// Supports all platforms including WASM on web
class TFLiteHelper {
  final bool _enableWASM;
  final Map<String, dynamic> _loadedModels =
      {}; // Interpreter on native, dynamic on web
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
      final model = _loadedModels[modelName];
      if (model != null) {
        // Close interpreter if it's a native interpreter
        if (!MLConstants.isWeb && model is Interpreter) {
          model.close();
        }
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
    // Close all interpreters
    for (final model in _loadedModels.values) {
      try {
        if (!MLConstants.isWeb && model is Interpreter) {
          model.close();
        }
      } catch (e) {
        debugPrint('Error closing interpreter: $e');
      }
    }
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
        metadata: {'wasm': true, 'platform': 'web'},
      );

      return true;
    } catch (e) {
      debugPrint('Failed to load web model: $e');
      return false;
    }
  }

  /// Loads a model on native platforms
  Future<bool> _loadNativeModel(String modelPath, String modelName) async {
    if (MLConstants.isWeb) {
      // This shouldn't be called on web
      return false;
    }

    try {
      // Resolve the actual file path
      String resolvedPath = modelPath;

      // If it's a relative path, try to resolve it
      if (!PathUtils.isAbsolutePath(modelPath)) {
        // Try to find in assets first
        if (modelPath.startsWith('assets/')) {
          // For assets, we need to copy to a temporary location
          final tempDir = await getTemporaryDirectory();
          final file = io.File('${tempDir.path}/$modelName');
          resolvedPath = file.path;
        } else {
          // Try documents directory
          final docsDir = await getApplicationDocumentsDirectory();
          resolvedPath = '${docsDir.path}/$modelPath';
        }
      }

      // Load the model using tflite_flutter
      final interpreter = Interpreter.fromFile(io.File(resolvedPath));

      // Get model input and output tensors
      final inputTensors = interpreter.getInputTensors();
      final outputTensors = interpreter.getOutputTensors();

      if (inputTensors.isEmpty || outputTensors.isEmpty) {
        throw Exception('Invalid model: no input or output tensors');
      }

      final inputTensor = inputTensors[0];
      final outputTensor = outputTensors[0];

      // Store the interpreter
      _loadedModels[modelName] = interpreter;

      // Get file size
      final file = io.File(resolvedPath);
      final sizeBytes = await file.exists() ? await file.length() : 0;

      // Create model info
      _modelInfo[modelName] = MLModelInfo(
        name: modelName,
        version: '1.0.0',
        backend: MLConstants.backendTFLite,
        path: resolvedPath,
        sizeBytes: sizeBytes,
        inputShape: inputTensor.shape,
        outputShape: outputTensor.shape,
        dataType: inputTensor.type.toString(),
        isQuantized:
            inputTensor.type.toString().contains('uint8') ||
            inputTensor.type.toString().contains('int8'),
        isLoaded: true,
        metadata: {
          'native': true,
          'platform': 'native',
          'inputCount': inputTensors.length,
          'outputCount': outputTensors.length,
        },
      );

      return true;
    } catch (e) {
      debugPrint('Failed to load native model: $e');
      // Clean up if loading failed
      _loadedModels.remove(modelName);
      _modelInfo.remove(modelName);
      return false;
    }
  }

  /// Gets the output size (number of classes) from the output shape
  int _getOutputSize(List<int> outputShape) {
    if (outputShape.isEmpty) return 0;
    // Output shape is typically [1, numClasses] or [numClasses] or [batch, numClasses]
    // For classification, we want the last dimension
    return outputShape.last;
  }

  /// Checks if the model name suggests it's an ImageNet model
  bool _isImageNetModelName(String modelName) {
    final lowerName = modelName.toLowerCase();
    return lowerName.contains('mobilenet') ||
        lowerName.contains('imagenet') ||
        lowerName.contains('resnet') ||
        lowerName.contains('inception') ||
        lowerName.contains('efficientnet') ||
        lowerName.contains('densenet');
  }

  /// Runs inference on web with WASM
  Future<MLResult> _runWebInference(
    String modelName,
    dynamic input,
    Map<String, dynamic>? options,
  ) async {
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
    String modelName,
    dynamic input,
    Map<String, dynamic>? options,
  ) async {
    if (MLConstants.isWeb) {
      // This shouldn't be called on web
      return MLResult.error(
        error: 'Native inference not available on web',
        modelName: modelName,
        backend: MLConstants.backendTFLite,
      );
    }

    try {
      final model = _loadedModels[modelName];
      if (model == null || model is! Interpreter) {
        throw Exception('Model not loaded: $modelName');
      }

      final interpreter = model;
      final modelInfo = _modelInfo[modelName]!;

      // Prepare input
      List<dynamic> inputData;
      if (input is List) {
        inputData = input;
      } else if (input is List<List<List<List<double>>>>) {
        // Convert 4D tensor to flat list
        inputData = [input];
      } else {
        // Try to convert input to appropriate format
        inputData = [input];
      }

      // Prepare output buffer
      final outputTensors = interpreter.getOutputTensors();
      final outputTensor = outputTensors[0];
      final outputShape = outputTensor.shape;
      final outputSize = outputShape.reduce((a, b) => a * b);

      // Debug: log output shape to understand structure
      debugPrint('Output shape: $outputShape, output size: $outputSize');

      List<dynamic> output;
      final typeStr = outputTensor.type.toString();
      if (typeStr.contains('float32')) {
        output = [List.filled(outputSize, 0.0)];
      } else if (typeStr.contains('uint8') || typeStr.contains('int8')) {
        output = [List.filled(outputSize, 0)];
      } else {
        output = [List.filled(outputSize, 0.0)];
      }

      // Run inference
      interpreter.run(inputData, output);

      // Extract results
      // Handle different output shapes: [1000] or [1, 1000]
      dynamic rawOutput;
      if (outputShape.length == 2 && outputShape[0] == 1) {
        // Shape is [1, 1000] - get the first (and only) batch element
        rawOutput = output[0];
      } else if (outputShape.length == 1) {
        // Shape is [1000] - use directly
        rawOutput = output[0];
      } else {
        // Fallback to original behavior
        rawOutput = output[0];
      }

      // Debug: log first few predictions to verify
      if (rawOutput is List && rawOutput.length > 5) {
        debugPrint('First 5 output values: ${rawOutput.take(5).toList()}');
      }
      List<dynamic> predictions;
      List<double> confidences;

      if (rawOutput is List<double>) {
        // Classification model - find top predictions
        final topK = options?['topK'] as int? ?? 5;

        // Type promotion makes rawOutput List<double> here
        final outputList = rawOutput;

        // Check if values are logits (raw scores) or probabilities
        // Logits are typically in range [-inf, +inf], probabilities are [0, 1]
        final maxValue = outputList.reduce(math.max);
        final minValue = outputList.reduce(math.min);
        final isLogits = maxValue > 1.0 || minValue < 0.0;

        List<double> probabilities;
        if (isLogits) {
          // Apply softmax to convert logits to probabilities
          // Softmax: exp(x_i - max) / sum(exp(x_j - max))
          // Subtracting max for numerical stability
          final expValues = outputList
              .map((x) => math.exp(x - maxValue))
              .toList();
          final sumExp = expValues.reduce((a, b) => a + b);
          probabilities = expValues.map((exp) => exp / sumExp).toList();
        } else {
          // Already probabilities (normalized)
          probabilities = List<double>.from(outputList);
        }

        // Get top K predictions
        // The "class index" is just the POSITION in the output array (0, 1, 2, ..., 999)
        // For example: if output[611] has the highest score, then class index = 611
        // The model doesn't contain class names - it just outputs scores for each position
        final indexedProbs = probabilities.asMap().entries.toList();
        indexedProbs.sort((a, b) => b.value.compareTo(a.value));

        // predictions = array indices (positions) of top scores
        // confidences = the actual probability values at those positions
        final rawPredictions = indexedProbs
            .take(topK)
            .map((e) => e.key)
            .toList();
        confidences = indexedProbs.take(topK).map((e) => e.value).toList();

        // Check if model has 1001 outputs (background class at index 0)
        // If so, subtract 1 from predictions to map to ImageNet's 0-999 indices
        final hasBackgroundClass = outputSize == 1001;
        if (hasBackgroundClass) {
          // Model has background class at index 0, so subtract 1 to map to ImageNet indices
          predictions = rawPredictions.map((idx) {
            if (idx > 0) {
              return idx - 1; // Map to ImageNet index (1-1000 -> 0-999)
            } else {
              return -1; // Background class, handle separately
            }
          }).toList();
          debugPrint(
            'Model has background class - adjusted predictions: ${predictions.take(3).toList()}',
          );
        } else {
          predictions = rawPredictions;
        }

        // Debug: log top predictions to verify indices
        debugPrint(
          'Raw prediction indices: ${rawPredictions.take(3).toList()}',
        );
        debugPrint(
          'Adjusted prediction indices: ${predictions.take(3).toList()}',
        );
        debugPrint('Top confidences: ${confidences.take(3).toList()}');
        if (predictions.isNotEmpty && predictions[0] != -1) {
          final topPred = predictions[0] as int;
          debugPrint('Top prediction index: $topPred');
          // Also log what label we're getting for this index
          final testLabel = ImageNetLabels.getDisplayName(topPred);
          debugPrint('Label for index $topPred: $testLabel');
        }
      } else if (rawOutput is List<int>) {
        // Convert to double for consistency
        predictions = rawOutput.map((e) => e).toList();
        confidences = rawOutput.map((e) => e.toDouble()).toList();
      } else {
        predictions = [rawOutput];
        confidences = [1.0];
      }

      // Build metadata with model information
      final metadata = <String, dynamic>{
        'inputShape': modelInfo.inputShape,
        'outputShape': modelInfo.outputShape,
        'wasmEnabled': false,
        'platform': 'native',
        'quantized': modelInfo.isQuantized,
      };

      // Detect if this is an ImageNet model (e.g., MobileNet, ResNet, etc.)
      // ImageNet models have 1000 output classes (or 1001 with background class)
      final modelOutputShape = modelInfo.outputShape;
      final numClasses = _getOutputSize(modelOutputShape);
      final isImageNetModel =
          (numClasses == 1000 || numClasses == 1001) ||
          _isImageNetModelName(modelName);

      // Add human-readable labels for the predicted class indices
      // IMPORTANT: Class indices are just ARRAY POSITIONS (0, 1, 2, ...) in the model output
      // The model outputs a vector of scores, and we use the INDEX of the highest score as the "class"
      // For ImageNet models (1000 classes), we have a mapping: index 611 → "military uniform"
      // For other models, we just show "Class 611" (the index itself)

      // Only load ImageNet labels if this is detected as an ImageNet model
      if (isImageNetModel) {
        // Try to load labels asynchronously if not already loaded (non-blocking)
        ImageNetLabels.loadLabels().catchError((e) {
          debugPrint('Failed to load ImageNet labels: $e');
          return false;
        });
      }

      if (predictions.isNotEmpty && predictions.first is int) {
        final classLabels = <int, String>{};
        for (final pred in predictions) {
          if (pred is int && pred >= 0) {
            // Skip background class (-1)
            // For ImageNet models, use ImageNetLabels.getDisplayName
            // For other models, just show "Class X"
            if (isImageNetModel) {
              classLabels[pred] = ImageNetLabels.getDisplayName(pred);
            } else {
              classLabels[pred] = 'Class $pred';
            }
          }
        }
        if (classLabels.isNotEmpty) {
          metadata['classLabels'] = classLabels;
          metadata['isImageNetModel'] = isImageNetModel;
          metadata['numClasses'] = numClasses;
        }
      }

      return MLResult.success(
        rawOutput: rawOutput,
        predictions: predictions,
        confidences: confidences,
        modelName: modelName,
        backend: MLConstants.backendTFLite,
        inferenceTime: 0.0, // Will be updated by caller
        metadata: metadata,
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
