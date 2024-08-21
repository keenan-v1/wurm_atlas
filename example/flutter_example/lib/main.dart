import 'dart:io';
import 'package:logging/logging.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wurm_atlas/wurm_atlas.dart';
import 'package:image/image.dart' as img;
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

  void _openMap() async => FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ["map"]).then((result) async {
        setState(() {
          isLoading = true;
          image = null;
        });
        var selectedFile = result!.files.first;
        var layerType =
            LayerType.values.firstWhere((t) => t.fileName == selectedFile.name);
        _logger.info("Opening map: ${selectedFile}");
        var mapFolder = selectedFile.path!.substring(
            0, selectedFile.path!.lastIndexOf(Platform.pathSeparator));
        var layer = Layer.file(layerType, mapFolder);
        await layer.open();

        var newImage = Image.memory(
          img.encodePng(
            img.Image.fromBytes(
              width: layer.size,
              height: layer.size,
              bytes: await layer.image(0, 0, layer.size, layer.size,
                  showWater: true, onProgress: _imageProgress),
              numChannels: 4,
              order: img.ChannelOrder.bgra,
            ),
          ),
        );
        setState(() {
          image = newImage;
          isLoading = false;
        });
      });

  @override
  Widget build(BuildContext context) {
    double progressValue = 0.0;
    if (total == 0) {
      progressValue = 0.0;
    } else {
      progressValue = count / total;
    }
    var imageWidget = image != null
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
        onPressed: _openMap,
        tooltip: 'Open Map',
        child: const Icon(Icons.map),
      ),
    );
  }
}
