import 'package:logging/logging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:wurm_atlas/wurm_atlas.dart';
import 'package:photo_view/photo_view.dart';

void main() {
  runApp(const MyApp());
  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen((LogRecord r) {
    // ignore: avoid_print
    print(r);
  });
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
  static final Logger _logger = Logger('WurmAtlasDemo');
  Image? image;
  bool isLoading = false;
  int count = 0;
  int total = 0;
  String? status;
  final _viewController = PhotoViewController();

  void _imageProgress(int current, int total) {
    if (current % 1000 == 0) {
      _logger.fine("Image progress: $current / $total");
      setState(() {
        count = current;
        this.total = total;
      });
    }
  }

  void _openMapFile(XFile file) async {
    var fileSize = await file.length();
    _logger.fine("Map file size: $fileSize");
    setState(() {
      isLoading = true;
      image = null;
      total = 0;
      count = 0;
      status = "Loading map file: ${file.name}";
    });
    var layerType = LayerType.values.firstWhere((t) => t.fileName == file.name,
        orElse: () => LayerType.top);
    _logger.info("Opening map from file: ${file.name}");
    var pixels = await Layer.stream(layerType).streamImage(file.openRead(), onProgress: _imageProgress);
    _logger.info("Map opened.");
    setState(() {
      status = "Loaded map.";
      isLoading = false;
      image = Image.memory(pixels);
      total = 0;
      count = 0;
    });
  }

  void _openMapInMemory() {
    setState(() {
      image = null;
      isLoading = true;
      total = 0;
      count = 0;
      status = null;
    });
    openFile(acceptedTypeGroups: [
      XTypeGroup(
        label: 'Wurm Unlimited map files',
        extensions: <String>['map'],
      )
    ]).then((file) {
      if (file != null) {
        setState(() {
          status = "Opening map file: ${file.name}";
        });
        _openMapFile(file);
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
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
        onPressed: () => isLoading ? null : _openMapInMemory(),
        tooltip: 'Open Map',
        child: const Icon(Icons.map),
      ),
    );
  }
}
