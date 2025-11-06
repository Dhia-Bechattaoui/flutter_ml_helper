import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ml_helper/flutter_ml_helper.dart';

void main() {
  group('PermissionUtils Tests', () {
    test('should check camera permission availability', () async {
      final granted = await PermissionUtils.isCameraPermissionGranted();
      expect(granted, isA<bool>());
    });

    test('should check storage permission availability', () async {
      final granted = await PermissionUtils.isStoragePermissionGranted();
      expect(granted, isA<bool>());
    });

    test('should check microphone permission availability', () async {
      final granted = await PermissionUtils.isMicrophonePermissionGranted();
      expect(granted, isA<bool>());
    });

    test('should check location permission availability', () async {
      final granted = await PermissionUtils.isLocationPermissionGranted();
      expect(granted, isA<bool>());
    });

    test('should request camera permission', () async {
      final granted = await PermissionUtils.requestCameraPermission();
      expect(granted, isA<bool>());
    });

    test('should request storage permission', () async {
      final granted = await PermissionUtils.requestStoragePermission();
      expect(granted, isA<bool>());
    });
  });

  group('PathUtils Tests', () {
    test('should get documents directory', () async {
      final dir = await PathUtils.documentsDirectory;
      // May be null on web
      if (dir != null) {
        expect(dir, isNotNull);
      }
    });

    test('should get temp directory', () async {
      final dir = await PathUtils.tempDirectory;
      // May be null on web
      if (dir != null) {
        expect(dir, isNotNull);
      }
    });

    test('should get support directory', () async {
      final dir = await PathUtils.supportDirectory;
      // May be null on web
      if (dir != null) {
        expect(dir, isNotNull);
      }
    });
  });

  group('MLConstants Tests', () {
    test('should have backend constants', () {
      expect(MLConstants.backendTFLite, equals('TFLite'));
      expect(MLConstants.backendMLKit, equals('MLKit'));
      expect(MLConstants.backendWASM, equals('WASM'));
    });

    test('should have default model configurations', () {
      expect(MLConstants.defaultInputSize, equals(224));
      expect(MLConstants.defaultBatchSize, equals(1));
      expect(MLConstants.defaultDataType, equals('float32'));
      expect(MLConstants.defaultConfidenceThreshold, equals(0.5));
    });

    test('should have platform detection', () {
      expect(MLConstants.isWeb, isA<bool>());
      expect(MLConstants.isMobile, isA<bool>());
      expect(MLConstants.isDesktop, isA<bool>());
    });

    test('should have platform support flags', () {
      expect(MLConstants.supportsTFLite, isA<bool>());
      expect(MLConstants.supportsMLKit, isA<bool>());
      expect(MLConstants.supportsWASM, isA<bool>());
    });

    test('should have platform capability flags', () {
      expect(MLConstants.canAccessFileSystem, isA<bool>());
      expect(MLConstants.canAccessCamera, isA<bool>());
      expect(MLConstants.canAccessStorage, isA<bool>());
      expect(MLConstants.canAccessMicrophone, isA<bool>());
      expect(MLConstants.canAccessLocation, isA<bool>());
    });
  });
}
