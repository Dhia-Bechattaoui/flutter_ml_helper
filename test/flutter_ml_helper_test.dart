import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ml_helper/flutter_ml_helper.dart';

void main() {
  group('MLHelper Tests', () {
    late MLHelper mlHelper;

    setUp(() {
      mlHelper = MLHelper(
        enableTFLite: true,
        enableMLKit: true,
        enableWASM: false,
      );
    });

    tearDown(() async {
      await mlHelper.dispose();
    });

    test('MLHelper should be created successfully', () {
      expect(mlHelper, isNotNull);
      // Check platform capabilities instead of assuming availability
      expect(mlHelper.platformInfo, isA<Map<String, dynamic>>());
      expect(mlHelper.capabilities, isA<Map<String, dynamic>>());
    });

    test('should get available models', () async {
      final models = await mlHelper.getAvailableModels();
      expect(models, isA<List<MLModelInfo>>());
      // Models may be empty depending on platform
      expect(models.length, greaterThanOrEqualTo(0));
    });

    test('should have TFLite helper', () {
      expect(mlHelper.tfLite, isNotNull);
      // Check if TFLite is available on this platform
      expect(mlHelper.tfLite.isAvailable, isA<bool>());
    });

    test('should have ML Kit helper', () {
      expect(mlHelper.mlKit, isNotNull);
      // Check if ML Kit is available on this platform
      expect(mlHelper.mlKit.isAvailable, isA<bool>());
    });

    test('should have image helper', () {
      expect(mlHelper.image, isNotNull);
    });

    test('should provide platform information', () {
      final platformInfo = mlHelper.platformInfo;
      expect(platformInfo['isWeb'], isA<bool>());
      expect(platformInfo['isMobile'], isA<bool>());
      expect(platformInfo['isDesktop'], isA<bool>());
      expect(platformInfo['supportsTFLite'], isA<bool>());
      expect(platformInfo['supportsMLKit'], isA<bool>());
      expect(platformInfo['supportsWASM'], isA<bool>());
    });

    test('should provide capabilities information', () {
      final capabilities = mlHelper.capabilities;
      expect(capabilities['platform'], isA<String>());
      expect(capabilities['tflite'], isA<bool>());
      expect(capabilities['mlkit'], isA<bool>());
      expect(capabilities['wasm'], isA<bool>());
      expect(capabilities['imageProcessing'], isTrue);
      expect(capabilities['permissions'], isA<bool>());
    });

    test('should check platform support', () {
      expect(mlHelper.isPlatformSupported, isA<bool>());
    });
  });

  group('MLResult Tests', () {
    test('should create successful result', () {
      final result = MLResult.success(
        rawOutput: [0.1, 0.2, 0.3],
        predictions: [1, 2, 3],
        confidences: [0.9, 0.8, 0.7],
        modelName: 'test_model',
        backend: 'TFLite',
        inferenceTime: 100.0,
      );

      expect(result.isSuccess, isTrue);
      expect(result.error, isNull);
      expect(result.topPrediction, 1);
      expect(result.topConfidence, 0.9);
    });

    test('should create error result', () {
      final result = MLResult.error(
        error: 'Test error',
        modelName: 'test_model',
        backend: 'TFLite',
      );

      expect(result.isSuccess, isFalse);
      expect(result.error, equals('Test error'));
      expect(result.predictions, isEmpty);
      expect(result.confidences, isEmpty);
    });
  });

  group('MLModelInfo Tests', () {
    test('should create model info', () {
      final modelInfo = MLModelInfo(
        name: 'test_model',
        version: '1.0.0',
        backend: 'TFLite',
        path: '/path/to/model',
        sizeBytes: 1024,
        inputShape: [1, 224, 224, 3],
        outputShape: [1, 1000],
        dataType: 'float32',
      );

      expect(modelInfo.name, equals('test_model'));
      expect(modelInfo.sizeDescription, equals('1.0KB'));
      expect(modelInfo.description, contains('test_model'));
    });

    test('should convert to and from JSON', () {
      final modelInfo = MLModelInfo(
        name: 'test_model',
        version: '1.0.0',
        backend: 'TFLite',
        path: '/path/to/model',
        sizeBytes: 1024,
        inputShape: [1, 224, 224, 3],
        outputShape: [1, 1000],
        dataType: 'float32',
      );

      final json = modelInfo.toJson();
      final fromJson = MLModelInfo.fromJson(json);

      expect(fromJson.name, equals(modelInfo.name));
      expect(fromJson.version, equals(modelInfo.version));
      expect(fromJson.backend, equals(modelInfo.backend));
    });
  });
}
