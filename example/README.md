# Flutter ML Helper Example

Example application demonstrating the usage of the `flutter_ml_helper` package.

## Features Demonstrated

- **TensorFlow Lite Inference**: Load and run MobileNet v3 image classification models
- **ML Kit Text Recognition**: Extract text from images using Google ML Kit
- **ML Kit Face Detection**: Detect faces in images
- **ML Kit Image Labeling**: Classify images into categories
- **Image Processing**: Preprocess images for ML models (resize, normalize)
- **HEIC Image Support**: Load and process HEIC images on iOS/Android
- **Cross-Platform Compatibility**: Works on iOS, Android, and other platforms

## Getting Started

### Prerequisites

- Flutter SDK 3.32.0+
- Dart SDK 3.8.0+
- iOS 11+ or Android 9+ (for HEIC support)

### Running the Example

1. **Navigate to the example directory:**
   ```bash
   cd example
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## Usage

### Image Processing Tab

- Select an image from gallery or camera
- Process the image to see format detection and image information
- Supports JPEG, PNG, BMP, WebP, and HEIC formats

### ML Kit Tab

- Use text recognition to extract text from images
- Detect faces in images
- Classify images using image labeling

### TFLite Tab

- Run MobileNet v3 image classification
- See top 5 predictions with confidence scores
- Automatic ImageNet label loading

### Permissions Tab

- Check and request necessary permissions
- View permission status for camera, storage, microphone, and location

## Assets

The example includes a sample TFLite model (`assets/model.tflite`) for testing image classification.

## Notes

- HEIC images are automatically decoded on iOS/Android (no setup required)
- Text recognition shows "No text detected" when no text is found in images
- The app demonstrates cross-platform compatibility
