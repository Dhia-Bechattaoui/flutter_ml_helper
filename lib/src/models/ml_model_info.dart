/// Represents information about an ML model
class MLModelInfo {
  /// The name/identifier of the model
  final String name;

  /// The version of the model
  final String version;

  /// The backend this model supports (TFLite, MLKit, etc.)
  final String backend;

  /// The file path or URL to the model
  final String path;

  /// The size of the model in bytes
  final int sizeBytes;

  /// The input shape expected by the model
  final List<int> inputShape;

  /// The output shape produced by the model
  final List<int> outputShape;

  /// The data type of input/output (float32, int8, etc.)
  final String dataType;

  /// Whether the model is quantized
  final bool isQuantized;

  /// Additional metadata about the model
  final Map<String, dynamic> metadata;

  /// Whether the model is currently loaded in memory
  final bool isLoaded;

  /// Creates an MLModelInfo instance
  const MLModelInfo({
    required this.name,
    required this.version,
    required this.backend,
    required this.path,
    required this.sizeBytes,
    required this.inputShape,
    required this.outputShape,
    required this.dataType,
    this.isQuantized = false,
    this.metadata = const {},
    this.isLoaded = false,
  });

  /// Creates MLModelInfo from a JSON map
  factory MLModelInfo.fromJson(Map<String, dynamic> json) {
    return MLModelInfo(
      name: json['name'] as String,
      version: json['version'] as String,
      backend: json['backend'] as String,
      path: json['path'] as String,
      sizeBytes: json['sizeBytes'] as int,
      inputShape: List<int>.from(json['inputShape']),
      outputShape: List<int>.from(json['outputShape']),
      dataType: json['dataType'] as String,
      isQuantized: json['isQuantized'] as bool? ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      isLoaded: json['isLoaded'] as bool? ?? false,
    );
  }

  /// Converts the model info to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'version': version,
      'backend': backend,
      'path': path,
      'sizeBytes': sizeBytes,
      'inputShape': inputShape,
      'outputShape': outputShape,
      'dataType': dataType,
      'isQuantized': isQuantized,
      'metadata': metadata,
      'isLoaded': isLoaded,
    };
  }

  /// Creates a copy of this model info with updated fields
  MLModelInfo copyWith({
    String? name,
    String? version,
    String? backend,
    String? path,
    int? sizeBytes,
    List<int>? inputShape,
    List<int>? outputShape,
    String? dataType,
    bool? isQuantized,
    Map<String, dynamic>? metadata,
    bool? isLoaded,
  }) {
    return MLModelInfo(
      name: name ?? this.name,
      version: version ?? this.version,
      backend: backend ?? this.backend,
      path: path ?? this.path,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      inputShape: inputShape ?? this.inputShape,
      outputShape: outputShape ?? this.outputShape,
      dataType: dataType ?? this.dataType,
      isQuantized: isQuantized ?? this.isQuantized,
      metadata: metadata ?? this.metadata,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  /// Gets a human-readable description of the model
  String get description {
    final sizeMB = (sizeBytes / (1024 * 1024)).toStringAsFixed(2);
    return '$name v$version ($backend) - ${sizeMB}MB - ${inputShape.join('x')} → ${outputShape.join('x')}';
  }

  /// Gets the model size in a human-readable format
  String get sizeDescription {
    if (sizeBytes < 1024) {
      return '${sizeBytes}B';
    }
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)}KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  String toString() => description;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MLModelInfo &&
        other.name == name &&
        other.version == version &&
        other.backend == backend;
  }

  @override
  int get hashCode => Object.hash(name, version, backend);
}
