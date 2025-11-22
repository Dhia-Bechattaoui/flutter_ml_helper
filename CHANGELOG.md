# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2025-11-22

### Added
- **HEIC Image Format Support**: Native HEIC/HEIF image decoding on iOS and Android
  - Automatic platform-specific native decoding using platform channels
  - Efficient decoding suitable for large datasets (thousands of images)
  - No manual setup required - platform code automatically included
  - Support for iOS 11+ and Android 9+ (API 28+)
- **Image Format Detector**: New utility class `ImageFormatDetector` for automatic image format detection from bytes
  - Supports JPEG, PNG, BMP, WebP, HEIC, and HEIF formats
  - Detects format using file signatures (magic numbers)
  - Exported in main library for public use

### Improved
- **Text Recognition Empty Text Handling**: Enhanced ML Kit text recognition to properly handle empty/no text cases
  - Filters out empty and whitespace-only text blocks
  - Returns "No text detected" message instead of empty text with high confidence
  - Better user feedback when no text is found in images
- **Face Detection Empty Face Handling**: Enhanced ML Kit face detection to properly handle empty/no face cases
  - Checks for empty face lists and zero face counts
  - Returns "No face detected" message instead of empty results
  - Consistent behavior with text recognition for better user feedback
- **Android Package Structure**: Restructured as proper Flutter plugin with native platform code
  - Platform code automatically registered - no manual integration needed
  - Proper plugin configuration in `pubspec.yaml`
  - Native iOS and Android implementations included in package

### Changed
- **Android Package Name**: Updated to `com.github.dhia_bechattaoui.flutter_ml_helper` following standard reverse-domain notation
- **Supported Image Formats**: Added 'heic' and 'heif' to `MLConstants.supportedImageFormats` list

### Fixed
- **Text Recognition Results**: Fixed issue where empty text was shown with high confidence scores
- **Android Build Configuration**: Added required `namespace` declaration in `android/build.gradle` for newer Android Gradle Plugin versions

### Technical Details
- HEIC images are decoded using native iOS ImageIO and Android BitmapFactory APIs
- Decoded HEIC images are converted to PNG format internally for compatibility with Dart `image` package
- Platform-specific native code located in `android/` and `ios/` directories
- Automatic plugin registration via Flutter's plugin system

## [0.0.3] - 2025-11-06

### Fixed
- **CI Dependency Resolution**: Fixed dependency conflicts with `test`, `mockito`, and `build_runner` packages to ensure compatibility with Flutter SDK test_api constraints

### Changed
- **Dev Dependencies**: Updated dev dependencies for better CI compatibility:
  - test: `^1.0.0` (downgraded from `^1.26.2` to resolve test_api conflicts)
  - mockito: `^5.0.0` (downgraded from `^5.5.0`)
  - build_runner: `^2.0.0` (downgraded from `^2.7.1`)

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

[Unreleased]: https://github.com/Dhia-Bechattaoui/flutter_ml_helper/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/Dhia-Bechattaoui/flutter_ml_helper/compare/v0.0.3...v0.1.0
[0.0.3]: https://github.com/Dhia-Bechattaoui/flutter_ml_helper/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/Dhia-Bechattaoui/flutter_ml_helper/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/Dhia-Bechattaoui/flutter_ml_helper/releases/tag/v0.0.1
