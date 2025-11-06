# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.2] - 2025-11-05

### Added
- **ImageNet Class Labels Support**: Automatic loading of ImageNet-1K class labels (1000 classes) from PyTorch Hub
- **Smart Model Detection**: Automatic detection of ImageNet models (MobileNet, ResNet, Inception, etc.) by output shape and model name
- **Flexible Image Normalization**: Support for both `[0, 1]` and `[-1, 1]` normalization ranges in `preprocessImageForML()`
- **ImageNetLabels Public API**: Exported `ImageNetLabels` utility class for accessing ImageNet class labels
- **Enhanced TFLite Inference**: Automatic softmax application for logits-to-probabilities conversion
- **HTTP Package**: Added `http: ^1.0.0` dependency for fetching ImageNet labels from URL

### Improved
- **Better Classification Results**: Fixed normalization to use `[-1, 1]` range by default for MobileNet models
- **Automatic Label Loading**: ImageNet labels are automatically loaded when ImageNet models are detected
- **Fallback Support**: Falls back to hardcoded labels if network request fails
- **Example App**: Fixed BuildContext async usage issues in example application
- **Code Quality**: Improved linting compliance and error handling

### Technical Details
- ImageNet labels are cached in memory after first load for fast subsequent access
- Labels are loaded asynchronously and non-blocking
- Supports both quantized and float32 TFLite models
- Automatic detection based on 1000-class output shape or model name keywords

### Dependencies
- http: ^1.0.0 (new)

## [0.0.1] - 2024-12-19

### Added
- Initial release of Flutter ML Helper package
- Support for TensorFlow Lite integration
- Support for Google ML Kit integration
- Cross-platform compatibility (iOS, Android, Web, Windows, macOS, Linux)
- WASM compatibility for web platform
- Core ML helper utilities and classes
- Image processing capabilities
- Permission handling for device access
- Path management for model files

### Technical Features
- Flutter SDK 3.32.0+ compatibility
- Dart SDK 3.8.0+ compatibility
- Comprehensive test coverage (>90%)
- Pana score: 160/160
- Linting and code quality tools
- Build runner support for code generation

### Platform Support
- ✅ iOS
- ✅ Android  
- ✅ Web (with WASM support)
- ✅ Windows
- ✅ macOS
- ✅ Linux

### Dependencies
- tflite_flutter: ^0.10.4
- google_ml_kit: ^0.16.3
- image: ^4.1.7
- path_provider: ^2.1.2
- permission_handler: ^11.3.1
