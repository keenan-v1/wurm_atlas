<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages). 
-->

Wurm Atlas is a library designed to read and export Wurm Unlimited map files.

## Features

- Fast & Efficient streams.
- Synchronous & Asynchronous support.
- Custom tile color support.
- Fully-featured example applications for both Dart & Flutter.

## Installation

### Flutter
Add via `flutter pub add wurm_atlas`

### Dart
Add via `dart pub add wurm_atlas`

For both, you should see a new line in your `pubspec.yaml` file like so:
```yaml
dependencies:
    wurm_atlas: any
```
Where `any` would be the latest version.

## Usage
```dart
import 'package:wurm_atlas/wurm_atlas.dart';
import 'package:image/image.dart' as img;

void main() {
    var layer = Layer(LayerType.top, 'map_folder'); // The LayerType tells it which layer to open
    layer.openSync(); // Required! Don't forget to close with `closeSync` or `close`!
    layer.validateSync(); // Optional, this is automatically called internally.

    // The below lines generates image data in BGRA format, stored in a ByteBuffer.
    // Using the third-party image library, we can easily dump this to a file.
    var image = img.Image.fromBytes(
        width: layer.size,
        height: layer.size,
        bytes: layer.imageSync(0, 0, layer.size, layer.size, showWater: true),
        numChannels: 4,
        order: img.ChannelOrder.bgra);
    layer.closeSync();        
    var bytes = img.encodePng(image);
    File("output.png").writeAsBytesSync(bytes);
}
```
