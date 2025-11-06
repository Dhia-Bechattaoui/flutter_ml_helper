import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ml_helper/flutter_ml_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

void main() {
  runApp(const MLHelperExampleApp());
}

class MLHelperExampleApp extends StatelessWidget {
  const MLHelperExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter ML Helper Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MLHelperExamplePage(),
    );
  }
}

class MLHelperExamplePage extends StatefulWidget {
  const MLHelperExamplePage({super.key});

  @override
  State<MLHelperExamplePage> createState() => _MLHelperExamplePageState();
}

class _MLHelperExamplePageState extends State<MLHelperExamplePage>
    with SingleTickerProviderStateMixin {
  late MLHelper _mlHelper;
  late TabController _tabController;
  String _status = 'Initializing...';
  List<MLModelInfo> _availableModels = [];
  Uint8List? _selectedImageBytes;
  img.Image? _processedImage;
  MLResult? _lastResult;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initializeMLHelper();
  }

  Future<void> _initializeMLHelper() async {
    try {
      setState(() {
        _status = 'Creating ML Helper...';
      });

      _mlHelper = MLHelper(
        enableTFLite: true,
        enableMLKit: true,
        enableWASM: false, // Set to true for web
      );

      setState(() {
        _status = 'Getting available models...';
      });

      _availableModels = await _mlHelper.getAvailableModels();

      setState(() {
        _status = 'Ready! ${_availableModels.length} models available';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _processedImage = null;
          _lastResult = null;
        });
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  Future<void> _processImage() async {
    if (_selectedImageBytes == null) {
      _showError('Please select an image first');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Load and process image
      final image =
          await _mlHelper.image.loadImageFromBytes(_selectedImageBytes!);
      if (image != null) {
        // Preprocess for ML (you can use this tensor for TFLite inference)
        await _mlHelper.image.preprocessImageForML(
          image,
          targetSize: 224,
          normalize: true,
          convertToGrayscale: false,
        );

        setState(() {
          _processedImage = image;
          _isProcessing = false;
        });

        _showSuccess('Image processed successfully!');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showError('Error processing image: $e');
    }
  }

  Future<void> _testTextRecognition() async {
    if (_selectedImageBytes == null) {
      _showError('Please select an image first');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // For ML Kit, we need InputImage format
      // This is a simplified demo - in production you'd convert properly
      final result = await _mlHelper.mlKit.runInference(
        input: _selectedImageBytes!,
        modelName: 'text_recognition',
      );

      setState(() {
        _lastResult = result;
        _isProcessing = false;
      });

      if (result.isSuccess) {
        _showSuccess('Text recognition completed!');
      } else {
        _showError('Text recognition failed: ${result.error}');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showError('Error: $e');
    }
  }

  Future<void> _testFaceDetection() async {
    if (_selectedImageBytes == null) {
      _showError('Please select an image first');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await _mlHelper.mlKit.runInference(
        input: _selectedImageBytes!,
        modelName: 'face_detection',
      );

      setState(() {
        _lastResult = result;
        _isProcessing = false;
      });

      if (result.isSuccess) {
        _showSuccess(
            'Face detection completed! Found ${result.predictions.length} face(s)');
      } else {
        _showError('Face detection failed: ${result.error}');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showError('Error: $e');
    }
  }

  Future<void> _testImageLabeling() async {
    if (_selectedImageBytes == null) {
      _showError('Please select an image first');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await _mlHelper.mlKit.runInference(
        input: _selectedImageBytes!,
        modelName: 'image_labeling',
      );

      setState(() {
        _lastResult = result;
        _isProcessing = false;
      });

      if (result.isSuccess) {
        _showSuccess('Image labeling completed!');
      } else {
        _showError('Image labeling failed: ${result.error}');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showError('Error: $e');
    }
  }

  Future<void> _testTFLite() async {
    if (_selectedImageBytes == null) {
      _showError('Please select an image first (Image Processing tab)');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Load model from assets first
      setState(() {
        _status = 'Loading TFLite model...';
      });

      // Copy asset to app directory
      final ByteData data = await rootBundle.load('assets/model.tflite');
      final List<int> bytes = data.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final modelFile = File('${tempDir.path}/model.tflite');
      await modelFile.writeAsBytes(bytes);

      // Load the model - the model name is extracted from the filename
      // So 'model.tflite' becomes 'model' (same as PathUtils.getFileNameWithoutExtension does)
      final modelPath = modelFile.path;
      final loaded = await _mlHelper.tfLite.loadModel(modelPath);

      if (!loaded) {
        throw Exception('Failed to load TFLite model');
      }

      // Extract model name from path (same way loadModel does it)
      // 'model.tflite' -> 'model'
      final modelName = modelPath.split('/').last.split('.').first;

      // Pre-load ImageNet labels before inference (for ImageNet models)
      // This ensures labels are available when we display results
      setState(() {
        _status = 'Loading ImageNet labels...';
      });
      await ImageNetLabels.loadLabels().catchError((e) {
        debugPrint('Failed to preload ImageNet labels: $e');
        return false;
      });

      setState(() {
        _status = 'Processing image...';
      });

      // Process image for TFLite
      final image =
          await _mlHelper.image.loadImageFromBytes(_selectedImageBytes!);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Preprocess image (resize, normalize)
      // Try '0to1' normalization first - some MobileNet models expect this
      // If results are wrong, try changing to '-1to1'
      final processedTensor = await _mlHelper.image.preprocessImageForML(
        image,
        targetSize: 224, // Common size for image classification models
        normalize: true,
        normalizeRange: '0to1', // Try '0to1' or '-1to1' based on your model
        convertToGrayscale: false,
      );

      // Run inference
      final result = await _mlHelper.tfLite.runInference(
        input: processedTensor,
        modelName: modelName,
        options: {'topK': 5}, // Get top 5 predictions
      );

      setState(() {
        _lastResult = result;
        _isProcessing = false;
        _status = 'MobileNet v3 classification completed!';
      });

      if (result.isSuccess) {
        _showSuccess(
            'MobileNet v3 classification successful! Found ${result.predictions.length} predictions');
      } else {
        _showError('MobileNet v3 classification failed: ${result.error}');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _status = 'Error: $e';
      });
      _showError('TFLite error: $e');
    }
  }

  Future<void> _checkPermissions() async {
    try {
      final cameraGranted = await PermissionUtils.isCameraPermissionGranted();
      final storageGranted = await PermissionUtils.isStoragePermissionGranted();

      // Check if widget is still mounted before using context
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Permission Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Camera: ${cameraGranted ? "Granted" : "Not Granted"}'),
              Text('Storage: ${storageGranted ? "Granted" : "Not Granted"}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
            if (!cameraGranted || !storageGranted)
              TextButton(
                onPressed: () async {
                  // Capture navigator before async operation
                  final navigator = Navigator.of(dialogContext);
                  await PermissionUtils.requestAllMLPermissions();
                  // Use captured navigator to pop (avoids using BuildContext across async gap)
                  navigator.maybePop();
                  // Then check if State is still mounted before calling method that uses State's context
                  if (!mounted) return;
                  _checkPermissions();
                },
                child: const Text('Request'),
              ),
          ],
        ),
      );
    } catch (e) {
      _showError('Error checking permissions: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mlHelper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter ML Helper Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Image Processing'),
            Tab(text: 'ML Kit'),
            Tab(text: 'TFLite'),
            Tab(text: 'Permissions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildImageProcessingTab(),
          _buildMLKitTab(),
          _buildTFLiteTab(),
          _buildPermissionsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: $_status',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('TFLite Available: ${_mlHelper.isTFLiteAvailable}'),
                  Text('ML Kit Available: ${_mlHelper.isMLKitAvailable}'),
                  Text('WASM Enabled: ${_mlHelper.isWASMEnabled}'),
                  const SizedBox(height: 8),
                  Text(
                    'Platform Info:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  ..._mlHelper.platformInfo.entries.map(
                    (e) => Text('${e.key}: ${e.value}'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Available Models (${_availableModels.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ..._availableModels.map(
            (model) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(model.name),
                subtitle: Text(
                  '${model.backend} - ${model.sizeDescription}\n'
                  'Input: ${model.inputShape.join("x")} → Output: ${model.outputShape.join("x")}',
                ),
                trailing: Icon(
                  model.isLoaded
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: model.isLoaded ? Colors.green : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageProcessingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Image Selection',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedImageBytes != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Selected Image',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Image.memory(
                      _selectedImageBytes!,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isProcessing ? null : _processImage,
                      child: _isProcessing
                          ? const CircularProgressIndicator()
                          : const Text('Process Image'),
                    ),
                  ],
                ),
              ),
            ),
            if (_processedImage != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Image Info',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ..._mlHelper.image
                          .getImageInfo(_processedImage)
                          .entries
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(e.key.toString()),
                                  Text(e.value.toString()),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ] else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.image, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No image selected',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMLKitTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_selectedImageBytes == null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.image, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Please select an image first (Image Processing tab)',
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Image.memory(
                      _selectedImageBytes!,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed:
                              _isProcessing ? null : _testTextRecognition,
                          icon: const Icon(Icons.text_fields),
                          label: const Text('Text Recognition'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _testFaceDetection,
                          icon: const Icon(Icons.face),
                          label: const Text('Face Detection'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _testImageLabeling,
                          icon: const Icon(Icons.label),
                          label: const Text('Image Labeling'),
                        ),
                      ],
                    ),
                    if (_isProcessing) ...[
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
            if (_lastResult != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Results',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('Backend: ${_lastResult!.backend}'),
                      Text('Success: ${_lastResult!.isSuccess}'),
                      if (_lastResult!.isSuccess) ...[
                        Text(
                            'Inference Time: ${_lastResult!.inferenceTime.toStringAsFixed(2)}ms'),
                        Text('Top Prediction: ${_lastResult!.topPrediction}'),
                        Text(
                            'Top Confidence: ${(_lastResult!.topConfidence * 100).toStringAsFixed(1)}%'),
                        const SizedBox(height: 8),
                        const Text(
                          'All Predictions:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ..._lastResult!.predictions.asMap().entries.map(
                              (e) => Text(
                                '${e.key + 1}. ${e.value} (${(_lastResult!.confidences[e.key] * 100).toStringAsFixed(1)}%)',
                              ),
                            ),
                      ] else
                        Text(
                          'Error: ${_lastResult!.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTFLiteTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'MobileNet v3 - Image Classification',
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Available: ${_mlHelper.isTFLiteAvailable}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  // Model Info Card
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 20, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              const Text(
                                'About MobileNet v3',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'MobileNet v3 is a lightweight neural network designed for mobile devices. It can classify images into 1000 different categories (ImageNet classes) including objects, animals, and scenes.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (_selectedImageBytes == null)
                    Card(
                      color: Colors.orange[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Icon(Icons.image_not_supported,
                                size: 48, color: Colors.orange[700]),
                            const SizedBox(height: 8),
                            Text(
                              'No Image Selected',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[900],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Go to "Image Processing" tab to select an image',
                              style: TextStyle(color: Colors.orange[800]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              'Selected Image',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  _selectedImageBytes!,
                                  height: 200,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _isProcessing ? null : _testTFLite,
                              icon: _isProcessing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.play_arrow),
                              label: Text(
                                _isProcessing
                                    ? 'Processing...'
                                    : 'Run Classification',
                                style: const TextStyle(fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Model Specifications
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.settings,
                                  size: 20, color: Colors.grey[700]),
                              const SizedBox(width: 8),
                              const Text(
                                'Model Specifications',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildSpecRow('Model Type', 'MobileNet v3'),
                          _buildSpecRow('Model Size', '15 MB'),
                          _buildSpecRow('Input Size', '224 × 224 pixels'),
                          _buildSpecRow('Input Format', 'RGB (Normalized 0-1)'),
                          _buildSpecRow('Output Classes', '1000 (ImageNet)'),
                          _buildSpecRow('Platform', 'TensorFlow Lite'),
                        ],
                      ),
                    ),
                  ),

                  // Results
                  if (_lastResult != null &&
                      _lastResult!.backend == 'TFLite') ...[
                    const SizedBox(height: 16),
                    Card(
                      color: _lastResult!.isSuccess
                          ? Colors.green[50]
                          : Colors.red[50],
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _lastResult!.isSuccess
                                      ? Icons.check_circle
                                      : Icons.error,
                                  color: _lastResult!.isSuccess
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Classification Results',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_lastResult!.isSuccess) ...[
                              _buildResultRow('Backend', _lastResult!.backend),
                              _buildResultRow(
                                'Inference Time',
                                '${_lastResult!.inferenceTime.toStringAsFixed(2)} ms',
                              ),
                              const Divider(),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Top Prediction',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getClassName(_lastResult!.topPrediction),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                    Text(
                                      '${(_lastResult!.topConfidence * 100).toStringAsFixed(2)}% confidence',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Top 5 Predictions',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ..._lastResult!.predictions
                                  .take(5)
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map(
                                    (e) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: e.key == 0
                                                  ? Colors.green[100]
                                                  : Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${e.key + 1}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: e.key == 0
                                                      ? Colors.green[900]
                                                      : Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              _getClassName(e.value),
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[100],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '${(_lastResult!.confidences[e.key] * 100).toStringAsFixed(1)}%',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.blue[900],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            ] else
                              Text(
                                'Error: ${_lastResult!.error}',
                                style: const TextStyle(color: Colors.red),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[700]),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  /// Gets a human-readable class name for the class index
  String _getClassName(dynamic classIndex) {
    if (classIndex is! int) {
      return 'Class $classIndex';
    }

    // Always check ImageNetLabels first (it will use cached labels if available)
    // This ensures we get the latest labels even if they loaded after inference
    final label = ImageNetLabels.getDisplayName(classIndex);
    if (!label.startsWith('Class ')) {
      return label; // Found a real label
    }

    // Try to get from result metadata as fallback
    if (_lastResult != null &&
        _lastResult!.metadata.containsKey('classLabels')) {
      final labels = _lastResult!.metadata['classLabels'] as Map<int, String>?;
      if (labels != null && labels.containsKey(classIndex)) {
        final metadataLabel = labels[classIndex]!;
        if (!metadataLabel.startsWith('Class ')) {
          return metadataLabel;
        }
      }
    }

    // Final fallback: return the generic class name
    return label; // This will be "Class X" if no label found
  }

  Widget _buildPermissionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Permission Management',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _checkPermissions,
                    icon: const Icon(Icons.security),
                    label: const Text('Check Permissions'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Available Permission Methods:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildPermissionMethod(
                      'Camera', 'PermissionUtils.isCameraPermissionGranted()'),
                  _buildPermissionMethod('Storage',
                      'PermissionUtils.isStoragePermissionGranted()'),
                  _buildPermissionMethod('Microphone',
                      'PermissionUtils.isMicrophonePermissionGranted()'),
                  _buildPermissionMethod('Location',
                      'PermissionUtils.isLocationPermissionGranted()'),
                  const SizedBox(height: 16),
                  const Text(
                    'Request Permissions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildPermissionMethod('All ML Permissions',
                      'PermissionUtils.requestAllMLPermissions()'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionMethod(String name, String method) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  method,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
