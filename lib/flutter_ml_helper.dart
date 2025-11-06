/// Flutter ML Helper - Easy integration with TensorFlow Lite and ML Kit
///
/// This package provides a unified interface for machine learning operations
/// in Flutter applications, supporting both TensorFlow Lite and Google ML Kit.
///
/// ## Features
///
/// - **TensorFlow Lite Integration**: Load and run TFLite models
/// - **ML Kit Support**: Access Google's ML Kit capabilities
/// - **Cross-Platform**: iOS, Android, Web, Windows, macOS, Linux
/// - **WASM Compatible**: WebAssembly support for web platform
/// - **Image Processing**: Built-in image preprocessing utilities
/// - **Permission Handling**: Automatic permission management
///
/// ## Quick Start
///
/// ```dart
/// import 'package:flutter_ml_helper/flutter_ml_helper.dart';
///
/// final mlHelper = MLHelper();
/// final result = await mlHelper.performInference(
///   input: yourData,
///   modelName: 'your_model',
/// );
/// ```
///
/// See the [README](https://github.com/Dhia-Bechattaoui/flutter_ml_helper)
/// for more detailed usage examples.
library flutter_ml_helper;

// Core ML Helper classes
export 'src/ml_helper.dart';
export 'src/tflite_helper.dart';
export 'src/mlkit_helper.dart';
export 'src/image_helper.dart';

// Models and data structures
export 'src/models/ml_result.dart';
export 'src/models/ml_model_info.dart';

// Utilities
export 'src/utils/permission_utils.dart';
export 'src/utils/path_utils.dart';
export 'src/utils/imagenet_labels.dart';

// Constants
export 'src/constants/ml_constants.dart';
