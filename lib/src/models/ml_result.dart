/// Represents the result of an ML inference operation
class MLResult {
  /// The raw output from the ML model
  final dynamic rawOutput;

  /// The processed/predicted results
  final List<dynamic> predictions;

  /// Confidence scores for each prediction
  final List<double> confidences;

  /// The model name used for inference
  final String modelName;

  /// The backend used (TFLite, MLKit, etc.)
  final String backend;

  /// Inference time in milliseconds
  final double inferenceTime;

  /// Any additional metadata
  final Map<String, dynamic> metadata;

  /// Error message if inference failed
  final String? error;

  /// Creates an MLResult instance
  const MLResult({
    required this.rawOutput,
    required this.predictions,
    required this.confidences,
    required this.modelName,
    required this.backend,
    required this.inferenceTime,
    this.metadata = const {},
    this.error,
  });

  /// Creates an MLResult from a successful inference
  factory MLResult.success({
    required dynamic rawOutput,
    required List<dynamic> predictions,
    required List<double> confidences,
    required String modelName,
    required String backend,
    required double inferenceTime,
    Map<String, dynamic> metadata = const {},
  }) {
    return MLResult(
      rawOutput: rawOutput,
      predictions: predictions,
      confidences: confidences,
      modelName: modelName,
      backend: backend,
      inferenceTime: inferenceTime,
      metadata: metadata,
    );
  }

  /// Creates an MLResult from a failed inference
  factory MLResult.error({
    required String error,
    required String modelName,
    required String backend,
    Map<String, dynamic> metadata = const {},
  }) {
    return MLResult(
      rawOutput: null,
      predictions: [],
      confidences: [],
      modelName: modelName,
      backend: backend,
      inferenceTime: 0.0,
      metadata: metadata,
      error: error,
    );
  }

  /// Checks if the inference was successful
  bool get isSuccess => error == null;

  /// Gets the top prediction with highest confidence
  dynamic get topPrediction {
    if (predictions.isEmpty) return null;
    if (confidences.isEmpty) return predictions.first;

    final maxIndex =
        confidences.indexOf(confidences.reduce((a, b) => a > b ? a : b));
    return predictions[maxIndex];
  }

  /// Gets the confidence of the top prediction
  double get topConfidence {
    if (confidences.isEmpty) return 0.0;
    return confidences.reduce((a, b) => a > b ? a : b);
  }

  /// Converts the result to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'rawOutput': rawOutput,
      'predictions': predictions,
      'confidences': confidences,
      'modelName': modelName,
      'backend': backend,
      'inferenceTime': inferenceTime,
      'metadata': metadata,
      'error': error,
      'isSuccess': isSuccess,
    };
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'MLResult(success: $topPrediction, confidence: ${(topConfidence * 100).toStringAsFixed(1)}%, backend: $backend, time: ${inferenceTime.toStringAsFixed(2)}ms)';
    } else {
      return 'MLResult(error: $error, backend: $backend)';
    }
  }
}
