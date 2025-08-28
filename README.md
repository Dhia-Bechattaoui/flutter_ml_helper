# Flutter ML Helper

[![Pub Version](https://img.shields.io/pub/v/flutter_ml_helper)](https://pub.dev/packages/flutter_ml_helper)
[![Flutter Version](https://img.shields.io/badge/flutter-3.10.0+-blue.svg)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/dart-3.0.0+-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

Easy integration with TensorFlow Lite and ML Kit for Flutter applications. Supports all 6 platforms with WASM compatibility.

## Features

- 🚀 **TensorFlow Lite Integration** - Load and run TFLite models
- 🔥 **ML Kit Support** - Access Google's ML Kit capabilities
- 🌐 **Cross-Platform** - iOS, Android, Web, Windows, macOS, Linux
- ⚡ **WASM Compatible** - WebAssembly support for web platform
- 🖼️ **Image Processing** - Built-in image preprocessing utilities
- 🔐 **Permission Handling** - Automatic permission management
- 📱 **Mobile Optimized** - Efficient resource management

## Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| iOS | ✅ Supported | Full TFLite and ML Kit support |
| Android | ✅ Supported | Full TFLite and ML Kit support |
| Web | ✅ Supported | WASM compatibility |
| Windows | ✅ Supported | TFLite support |
| macOS | ✅ Supported | TFLite support |
| Linux | ✅ Supported | TFLite support |

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_ml_helper: ^0.0.1
```

### Basic Usage

```dart
import 'package:flutter_ml_helper/flutter_ml_helper.dart';

void main() async {
  // Create ML Helper instance
  final mlHelper = MLHelper(
    enableTFLite: true,
    enableMLKit: true,
    enableWASM: true, // Enable for web
  );

  // Load a TFLite model
  await mlHelper.tfLite.loadModel('path/to/model.tflite');

  // Run inference
  final result = await mlHelper.performInference(
    input: yourInputData,
    modelName: 'model_name',
  );

  if (result.isSuccess) {
    print('Prediction: ${result.topPrediction}');
    print('Confidence: ${(result.topConfidence * 100).toStringAsFixed(1)}%');
  }

  // Clean up
  await mlHelper.dispose();
}
```

### TensorFlow Lite Usage

```dart
// Load and run TFLite models
final tfLiteHelper = mlHelper.tfLite;

// Load model
await tfLiteHelper.loadModel('model.tflite');

// Run inference
final result = await tfLiteHelper.runInference(
  input: imageData,
  modelName: 'model_name',
);

// Get model information
final models = await tfLiteHelper.getAvailableModels();
```

### ML Kit Usage

```dart
// Use ML Kit capabilities
final mlKitHelper = mlHelper.mlKit;

// Text recognition
final textResult = await mlKitHelper.runInference(
  input: imageData,
  modelName: 'text_recognition',
);

// Face detection
final faceResult = await mlKitHelper.runInference(
  input: imageData,
  modelName: 'face_detection',
);
```

### Image Processing

```dart
// Preprocess images for ML models
final imageHelper = mlHelper.image;

// Load image
final image = await imageHelper.loadImageFromBytes(imageBytes);

// Preprocess for ML
final processedImage = await imageHelper.preprocessImageForML(
  image!,
  targetSize: 224,
  normalize: true,
  convertToGrayscale: false,
);
```

## Dependencies

- **tflite_flutter**: ^0.10.4 - TensorFlow Lite support
- **google_ml_kit**: ^0.16.3 - ML Kit integration
- **image**: ^4.1.7 - Image processing
- **path_provider**: ^2.1.2 - File path management
- **permission_handler**: ^11.3.1 - Permission handling
- **path**: ^1.8.3 - Path utilities

## Requirements

- Flutter: 3.10.0+
- Dart: 3.0.0+
- iOS: 11.0+
- Android: API 21+
- Web: Modern browsers with WASM support

## Configuration

### Android

Add to `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for ML features</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access for ML features</string>
```

### Web

Ensure your web app supports WASM:

```html
<script>
  if (!WebAssembly.instantiateStreaming) {
    WebAssembly.instantiateStreaming = async (resp, importObject) => {
      const source = await (await resp).arrayBuffer();
      return await WebAssembly.instantiate(source, importObject);
    };
  }
</script>
```

## Examples

Check out the [example](example/) directory for complete working examples:

- Basic TFLite inference
- ML Kit text recognition
- Image preprocessing
- Cross-platform compatibility

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- 📧 Email: [your-email@example.com]
- 🐛 Issues: [GitHub Issues](https://github.com/Dhia-Bechattaoui/flutter_ml_helper/issues)
- 📖 Documentation: [API Reference](https://pub.dev/documentation/flutter_ml_helper)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes and version history.

---

Made with ❤️ by [Dhia Bechattaoui](https://github.com/Dhia-Bechattaoui)
