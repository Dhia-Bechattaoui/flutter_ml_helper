import 'package:flutter/material.dart';
import 'package:flutter_ml_helper/flutter_ml_helper.dart';

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

class _MLHelperExamplePageState extends State<MLHelperExamplePage> {
  late MLHelper _mlHelper;
  String _status = 'Initializing...';
  List<MLModelInfo> _availableModels = [];

  @override
  void initState() {
    super.initState();
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
        enableWASM: true,
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

  @override
  void dispose() {
    _mlHelper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter ML Helper Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Available Models',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _availableModels.length,
                itemBuilder: (context, index) {
                  final model = _availableModels[index];
                  return Card(
                    child: ListTile(
                      title: Text(model.name),
                      subtitle:
                          Text('${model.backend} - ${model.sizeDescription}'),
                      trailing: Icon(
                        model.isLoaded
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: model.isLoaded ? Colors.green : Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
