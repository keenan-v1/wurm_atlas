import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:wurm_atlas/wurm_atlas.dart';
import 'package:photo_view/photo_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    TileInfoRepository().loadAll(clear: true);
    return MaterialApp(
      title: 'Wurm Atlas Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Wurm Atlas Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final Logger _logger = Logger("MyHomePage");
  Image? image;
  bool isLoading = false;
  int count = 0;
  int total = 0;
  final _viewController = PhotoViewController();

  void _imageProgress(int current, int total) {
    setState(() {
      count = current;
      this.total = total;
    });
  }

  void _openMapInMemory() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'Wurm Unlimited map files',
      extensions: <String>['map'],
    );
    var file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) {
      return;
    }
    var fileSize = await file.length();
    setState(() {
      isLoading = true;
      image = null;
      total = fileSize;
      count = 0;
    });
    var layerType = LayerType.values.firstWhere((t) => t.fileName == file.name,
        orElse: () => LayerType.top);
    _logger.info("Opening map: ${file.name}");
    var stream = file.openRead();
    var bytes = <int>[];
    stream.listen(
      (data) {
        _imageProgress(count + data.length, total);
        bytes.addAll(data);
      },
      onDone: () async {
        _logger.info("Map loaded");
        var layer = Layer.memory(layerType, Uint8List.fromList(bytes));
        var pixels =
            await layer.image(showWater: true, onProgress: _imageProgress);
        var newImage = Image.memory(pixels);
        setState(() {
          image = newImage;
          isLoading = false;
          count = 0;
          total = 0;
        });
      },
      cancelOnError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    double progressValue = 0.0;
    if (total > 0) {
      progressValue = count / total;
    }
    var imageWidget = image != null && !isLoading
        ? LayoutBuilder(
            builder: (context, constraints) => Listener(
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  final scale = (_viewController.scale ?? 0) *
                      (1.0 - event.scrollDelta.dy / 1000.0);
                  final position = _viewController.position *
                      (1.0 - event.scrollDelta.dy / 1000.0);
                  _viewController.updateMultiple(
                      position: position, scale: scale);
                }
              },
              child: PhotoView(
                imageProvider: image?.image,
                minScale: PhotoViewComputedScale.contained * 0.1,
                initialScale: PhotoViewComputedScale.contained,
                controller: _viewController,
              ),
            ),
          )
        : Center(
            child: (isLoading
                ? CircularProgressIndicator(value: progressValue)
                : const Text('Click the button to open a map')),
          );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("${widget.title}"),
      ),
      body: imageWidget,
      floatingActionButton: FloatingActionButton(
        onPressed: _openMapInMemory,
        tooltip: 'Open Map',
        child: const Icon(Icons.map),
      ),
    );
  }
}
