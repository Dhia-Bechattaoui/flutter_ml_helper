import 'models/ml_result.dart';
import 'models/ml_model_info.dart';
import 'constants/ml_constants.dart';

/// Helper class for Google ML Kit operations
/// Supports all platforms including web
class MLKitHelper {
  final Map<String, dynamic> _loadedModels = {};
  final Map<String, MLModelInfo> _modelInfo = {};

  /// Creates an ML Kit helper instance
  MLKitHelper();

  /// Gets whether ML Kit is available
  bool get isAvailable => MLConstants.supportsMLKit;

  /// Runs inference using ML Kit (platform-aware)
  Future<MLResult> runInference({
    required dynamic input,
    required String modelName,
    Map<String, dynamic>? options,
  }) async {
    try {
      if (!isAvailable) {
        throw UnsupportedError('ML Kit not supported on this platform');
      }

      final stopwatch = Stopwatch()..start();

      // Process input based on model type and platform
      dynamic result;
      String backend = MLConstants.backendMLKit;

      if (MLConstants.isWeb) {
        // Web implementation
        result = await _runWebInference(modelName, input, options);
        backend = MLConstants.backendMLKit;
      } else {
        // Mobile implementation
        result = await _runMobileInference(modelName, input, options);
        backend = MLConstants.backendMLKit;
      }

      stopwatch.stop();
      final inferenceTime = stopwatch.elapsedMicroseconds / 1000.0;

      return MLResult.success(
        rawOutput: result,
        predictions: _extractPredictions(result),
        confidences: _extractConfidences(result),
        modelName: modelName,
        backend: backend,
        inferenceTime: inferenceTime,
        metadata: {
          'modelType': modelName,
          'mlKitVersion': '0.20.0',
          'platform': MLConstants.isWeb ? 'web' : 'mobile',
        },
      );
    } catch (e) {
      return MLResult.error(
        error: e.toString(),
        modelName: modelName,
        backend: MLConstants.backendMLKit,
      );
    }
  }

  /// Gets information about available models
  Future<List<MLModelInfo>> getAvailableModels() async {
    if (!isAvailable) return [];

    final models = <MLModelInfo>[];

    // Add platform-specific models
    if (MLConstants.isWeb) {
      models.addAll(_getWebModels());
    } else {
      models.addAll(_getMobileModels());
    }

    return models;
  }

  /// Disposes all resources
  Future<void> dispose() async {
    _loadedModels.clear();
    _modelInfo.clear();
  }

  // Platform-specific implementations

  /// Runs inference on web platform
  Future<dynamic> _runWebInference(
      String modelName, dynamic input, Map<String, dynamic>? options) async {
    switch (modelName.toLowerCase()) {
      case 'text_recognition':
        return await _runWebTextRecognition(input);
      case 'face_detection':
        return await _runWebFaceDetection(input);
      case 'object_detection':
        return await _runWebObjectDetection(input);
      case 'image_labeling':
        return await _runWebImageLabeling(input);
      case 'pose_detection':
        return await _runWebPoseDetection(input);
      default:
        throw Exception('Unknown ML Kit model: $modelName');
    }
  }

  /// Runs inference on mobile platforms
  Future<dynamic> _runMobileInference(
      String modelName, dynamic input, Map<String, dynamic>? options) async {
    switch (modelName.toLowerCase()) {
      case 'text_recognition':
        return await _runMobileTextRecognition(input);
      case 'face_detection':
        return await _runMobileFaceDetection(input);
      case 'object_detection':
        return await _runMobileObjectDetection(input);
      case 'image_labeling':
        return await _runMobileImageLabeling(input);
      case 'pose_detection':
        return await _runMobilePoseDetection(input);
      default:
        throw Exception('Unknown ML Kit model: $modelName');
    }
  }

  // Web-specific model implementations
  Future<dynamic> _runWebTextRecognition(dynamic input) async {
    // Simulate web text recognition
    await Future.delayed(const Duration(milliseconds: 30));
    return {'text': 'Sample text from web', 'blocks': [], 'confidence': 0.95};
  }

  Future<dynamic> _runWebFaceDetection(dynamic input) async {
    // Simulate web face detection
    await Future.delayed(const Duration(milliseconds: 40));
    return {
      'faces': [
        {'confidence': 0.92}
      ],
      'count': 1
    };
  }

  Future<dynamic> _runWebObjectDetection(dynamic input) async {
    // Simulate web object detection
    await Future.delayed(const Duration(milliseconds: 35));
    return {
      'objects': [
        {'label': 'person', 'confidence': 0.89}
      ],
      'count': 1
    };
  }

  Future<dynamic> _runWebImageLabeling(dynamic input) async {
    // Simulate web image labeling
    await Future.delayed(const Duration(milliseconds: 25));
    return {
      'labels': [
        {'text': 'person', 'confidence': 0.91}
      ],
      'count': 1
    };
  }

  Future<dynamic> _runWebPoseDetection(dynamic input) async {
    // Simulate web pose detection
    await Future.delayed(const Duration(milliseconds: 50));
    return {
      'poses': [
        {'confidence': 0.88}
      ],
      'count': 1
    };
  }

  // Mobile-specific model implementations
  Future<dynamic> _runMobileTextRecognition(dynamic input) async {
    // Simulate mobile text recognition
    await Future.delayed(const Duration(milliseconds: 50));
    return {
      'text': 'Sample text from mobile',
      'blocks': [],
      'confidence': 0.98
    };
  }

  Future<dynamic> _runMobileFaceDetection(dynamic input) async {
    // Simulate mobile face detection
    await Future.delayed(const Duration(milliseconds: 60));
    return {
      'faces': [
        {'confidence': 0.95}
      ],
      'count': 1
    };
  }

  Future<dynamic> _runMobileObjectDetection(dynamic input) async {
    // Simulate mobile object detection
    await Future.delayed(const Duration(milliseconds: 55));
    return {
      'objects': [
        {'label': 'person', 'confidence': 0.93}
      ],
      'count': 1
    };
  }

  Future<dynamic> _runMobileImageLabeling(dynamic input) async {
    // Simulate mobile image labeling
    await Future.delayed(const Duration(milliseconds: 45));
    return {
      'labels': [
        {'text': 'person', 'confidence': 0.96}
      ],
      'count': 1
    };
  }

  Future<dynamic> _runMobilePoseDetection(dynamic input) async {
    // Simulate mobile pose detection
    await Future.delayed(const Duration(milliseconds: 70));
    return {
      'poses': [
        {'confidence': 0.94}
      ],
      'count': 1
    };
  }

  // Model information
  List<MLModelInfo> _getWebModels() {
    return [
      MLModelInfo(
        name: 'text_recognition',
        version: '1.0.0',
        backend: MLConstants.backendMLKit,
        path: 'web_builtin',
        sizeBytes: 0,
        inputShape: [1, 224, 224, 3],
        outputShape: [1, 100],
        dataType: 'float32',
        isLoaded: true,
        metadata: {'platform': 'web'},
      ),
      MLModelInfo(
        name: 'face_detection',
        version: '1.0.0',
        backend: MLConstants.backendMLKit,
        path: 'web_builtin',
        sizeBytes: 0,
        inputShape: [1, 224, 224, 3],
        outputShape: [1, 100],
        dataType: 'float32',
        isLoaded: true,
        metadata: {'platform': 'web'},
      ),
      MLModelInfo(
        name: 'object_detection',
        version: '1.0.0',
        backend: MLConstants.backendMLKit,
        path: 'web_builtin',
        sizeBytes: 0,
        inputShape: [1, 224, 224, 3],
        outputShape: [1, 100],
        dataType: 'float32',
        isLoaded: true,
        metadata: {'platform': 'web'},
      ),
      MLModelInfo(
        name: 'image_labeling',
        version: '1.0.0',
        backend: MLConstants.backendMLKit,
        path: 'web_builtin',
        sizeBytes: 0,
        inputShape: [1, 224, 224, 3],
        outputShape: [1, 100],
        dataType: 'float32',
        isLoaded: true,
        metadata: {'platform': 'web'},
      ),
      MLModelInfo(
        name: 'pose_detection',
        version: '1.0.0',
        backend: MLConstants.backendMLKit,
        path: 'web_builtin',
        sizeBytes: 0,
        inputShape: [1, 224, 224, 3],
        outputShape: [1, 100],
        dataType: 'float32',
        isLoaded: true,
        metadata: {'platform': 'web'},
      ),
    ];
  }

  List<MLModelInfo> _getMobileModels() {
    return [
      MLModelInfo(
        name: 'text_recognition',
        version: '1.0.0',
        backend: MLConstants.backendMLKit,
        path: 'mobile_builtin',
        sizeBytes: 0,
        inputShape: [1, 224, 224, 3],
        outputShape: [1, 100],
        dataType: 'float32',
        isLoaded: true,
        metadata: {'platform': 'mobile'},
      ),
      MLModelInfo(
        name: 'face_detection',
        version: '1.0.0',
        backend: MLConstants.backendMLKit,
        path: 'mobile_builtin',
        sizeBytes: 0,
        inputShape: [1, 224, 224, 3],
        outputShape: [1, 100],
        dataType: 'float32',
        isLoaded: true,
        metadata: {'platform': 'mobile'},
      ),
      MLModelInfo(
        name: 'object_detection',
        version: '1.0.0',
        backend: MLConstants.backendMLKit,
        path: 'mobile_builtin',
        sizeBytes: 0,
        inputShape: [1, 224, 224, 3],
        outputShape: [1, 100],
        dataType: 'float32',
        isLoaded: true,
        metadata: {'platform': 'mobile'},
      ),
      MLModelInfo(
        name: 'image_labeling',
        version: '1.0.0',
        backend: MLConstants.backendMLKit,
        path: 'mobile_builtin',
        sizeBytes: 0,
        inputShape: [1, 224, 224, 3],
        outputShape: [1, 100],
        dataType: 'float32',
        isLoaded: true,
        metadata: {'platform': 'mobile'},
      ),
      MLModelInfo(
        name: 'pose_detection',
        version: '1.0.0',
        backend: MLConstants.backendMLKit,
        path: 'mobile_builtin',
        sizeBytes: 0,
        inputShape: [1, 224, 224, 3],
        outputShape: [1, 100],
        dataType: 'float32',
        isLoaded: true,
        metadata: {'platform': 'mobile'},
      ),
    ];
  }

  /// Extracts predictions from ML Kit result
  List<dynamic> _extractPredictions(dynamic result) {
    if (result is Map) {
      if (result.containsKey('text')) {
        return [result['text']];
      } else if (result.containsKey('faces')) {
        return result['faces'];
      } else if (result.containsKey('objects')) {
        return result['objects'];
      } else if (result.containsKey('labels')) {
        return result['labels'];
      } else if (result.containsKey('poses')) {
        return result['poses'];
      }
    }
    return [];
  }

  /// Extracts confidence scores from ML Kit result
  List<double> _extractConfidences(dynamic result) {
    if (result is Map) {
      if (result.containsKey('confidence')) {
        return [result['confidence']];
      } else if (result.containsKey('faces') && result['faces'] is List) {
        return result['faces']
            .map((f) => f['confidence'] ?? 0.9)
            .cast<double>()
            .toList();
      } else if (result.containsKey('objects') && result['objects'] is List) {
        return result['objects']
            .map((o) => o['confidence'] ?? 0.9)
            .cast<double>()
            .toList();
      } else if (result.containsKey('labels') && result['labels'] is List) {
        return result['labels']
            .map((l) => l['confidence'] ?? 0.9)
            .cast<double>()
            .toList();
      } else if (result.containsKey('poses') && result['poses'] is List) {
        return result['poses']
            .map((p) => p['confidence'] ?? 0.9)
            .cast<double>()
            .toList();
      }
    }
    // Default confidence scores
    return [0.95, 0.85, 0.75];
  }
}
