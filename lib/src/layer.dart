import 'dart:async';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:image/image.dart';
import 'package:wurm_atlas/src/file_tile_reader.dart';
import 'package:wurm_atlas/src/layer_type.dart';
import 'package:wurm_atlas/src/memory_tile_reader.dart';
import 'package:wurm_atlas/src/tile.dart';
import 'package:wurm_atlas/src/base_tile_reader.dart';
import 'package:wurm_atlas/src/exceptions.dart';

/// Function signature for the progress callback.
typedef ProgressCallback = void Function(int count, int total);

/// Represents a layer in the map.
///
/// This class provides methods for reading tiles from a layer in the map.
///
/// Example usage:
/// ```dart
/// Layer layer = Layer(LayerType.top, "maps");
/// layer.openSync();
/// layer.validateSync();
/// var tiles = layer.tilesSync(0, 0, 10, 10);
/// layer.closeSync();
/// ```
///
/// See also:
/// - [LayerType], the type of the layer.
/// - [Tile], the class representing a tile in the map.
/// - [BaseTileReader], the class for reading tiles from a layer file.
/// - [ValidationException], the exception thrown when validation fails.
class Layer {
  static final Logger _logger = Logger('Layer');
  static final BigInt _magicNumber = BigInt.parse("0x474A2198B2781B9D");

  /// The [LayerType] of the layer, e.g. [LayerType.top].
  final LayerType type;

  /// The path to the map folder.
  final String mapFolder;

  /// The [BaseTileReader] for reading tiles from the layer file.
  final BaseTileReader _reader;

  /// The size of the layer in bytes.
  int get size => _reader.size;

  /// The path to the layer file.
  String get layerFilePath => "$mapFolder/${type.fileName}";

  /// Creates a new layer with the given [type] and [mapFolder].
  Layer.file(this.type, this.mapFolder) : _reader = FileTileReader();

  /// Creates a new layer with the given [type] and a stream of bytes.
  Layer.memory(this.type, Uint8List bytes)
      : mapFolder = "",
        _reader = MemoryTileReader(bytes);
  
  Layer.stream(this.type) : mapFolder = "", _reader = MemoryTileReader.empty();

  /// Creates a new layer with the given [type] and a [MemoryTileReader].
  Layer(this.type, this._reader) : mapFolder = "";

  Future<Uint8List> streamImage(Stream<Uint8List> stream, {ProgressCallback? onProgress}) async{
    if (_reader is! MemoryTileReader) {
      throw Exception("streamImage is only available for MemoryTileReader");
    }
    return await _reader.streamImage(stream, onProgress: onProgress);
  }

  /// Opens the layer file synchronously.
  ///
  /// This method should be called before any other methods.
  ///
  /// **Note:** You are responsible for closing the layer file after you are done with it.
  ///
  /// Example usage:
  /// ```dart
  /// Layer layer = Layer(LayerType.top, "maps");
  /// layer.openSync();
  /// layer.validateSync();
  /// var tiles = layer.tilesSync(0, 0, 10, 10);
  /// layer.closeSync();
  /// ```
  ///
  /// See also:
  /// - [open], the asynchronous version of this method.
  /// - [closeSync], the method for closing the layer file synchronously.
  /// - [close], the asynchronous version of the method for closing the layer file.
  void openSync() {
    _reader.openSync(layerFilePath);
  }

  /// Opens the layer file asynchronously.
  ///
  /// This method should be called before any other methods.
  ///
  /// **Note:** You are responsible for closing the layer file after you are done with it.
  ///
  /// Example usage:
  /// ```dart
  /// Layer layer = Layer(LayerType.top, "maps");
  /// await layer.open();
  /// await layer.validate();
  /// var tiles = layer.tiles(0, 0, 10, 10);
  /// await layer.close();
  /// ```
  ///
  /// See also:
  /// - [openSync], the synchronous version of this method.
  /// - [close], the method for closing the layer file asynchronously.
  /// - [closeSync], the synchronous version of the method for closing the layer file.
  Future<void> open() async {
    await _reader.open(layerFilePath);
  }

  /// Closes the layer file synchronously.
  ///
  /// This method should be called after you are done with the layer file.
  ///
  /// Example usage:
  /// ```dart
  /// Layer layer = Layer(LayerType.top, "maps");
  /// layer.openSync();
  /// layer.validateSync();
  /// var tiles = layer.tilesSync(0, 0, 10, 10);
  /// layer.closeSync();
  /// ```
  ///
  /// See also:
  /// - [close], the asynchronous version of this method.
  /// - [openSync], the method for opening the layer file synchronously.
  /// - [open], the asynchronous version of the method for opening the layer file.
  ///
  void closeSync() {
    _reader.closeSync();
  }

  /// Closes the layer file asynchronously.
  ///
  /// This method should be called after you are done with the layer file.
  ///
  /// Example usage:
  /// ```dart
  /// Layer layer = Layer(LayerType.top, "maps");
  /// await layer.open();
  /// await layer.validate();
  /// var tiles = layer.tiles(0, 0, 10, 10);
  /// await layer.close();
  /// ```
  ///
  /// See also:
  /// - [closeSync], the synchronous version of this method.
  /// - [open], the method for opening the layer file asynchronously.
  /// - [openSync], the synchronous version of the method for opening the layer file.
  ///
  Future<void> close() async {
    await _reader.close();
  }

  /// Validates the layer synchronously.
  ///
  /// This method checks if the magic number and version of the layer match the expected values.
  /// Returns true if the validation is successful. Otherwise, it throws a [ValidationException].
  ///
  /// Example usage:
  /// ```dart
  /// Layer layer = Layer(LayerType.top, "maps");
  /// layer.openSync();
  /// layer.validateSync();
  /// var tiles = layer.tilesSync(0, 0, 10, 10);
  /// layer.closeSync();
  /// ```
  ///
  /// See also:
  /// - [validate], the asynchronous version of this method.
  /// - [openSync], the method for opening the layer file synchronously.
  /// - [open], the asynchronous version of the method for opening the layer file.
  ///
  bool validateSync() {
    if (_reader.magicNumber != _magicNumber) {
      var msg =
          "Magic number mismatch. Expected: $_magicNumber, got: ${_reader.magicNumber}";
      _logger.severe(msg);
      throw ValidationException(msg);
    }
    if (_reader.version != type.version) {
      var msg =
          "Version mismatch. Expected: ${type.version}, got: ${_reader.version}";
      _logger.severe(msg);
      throw ValidationException(msg);
    }
    return true;
  }

  /// Validates the layer asynchronously.
  ///
  /// This method checks if the magic number and version of the layer match the expected values.
  /// Returns true if the validation is successful. Otherwise, it throws a [ValidationException].
  ///
  /// Example usage:
  /// ```dart
  /// Layer layer = Layer(LayerType.top, "maps");
  /// await layer.open();
  /// await layer.validate();
  /// var tiles = layer.tiles(0, 0, 10, 10);
  /// await layer.close();
  /// ```
  ///
  /// See also:
  /// - [validateSync], the synchronous version of this method.
  /// - [open], the method for opening the layer file asynchronously.
  /// - [openSync], the synchronous version of the method for opening the layer file.
  ///
  Future<bool> validate() async => validateSync();

  /// Reads tiles synchronously.
  ///
  /// This method reads tiles from [x],[y] to [x] + [width], [y] + [height].
  ///
  /// Example usage:
  /// ```dart
  /// Layer layer = Layer(LayerType.top, "maps");
  /// layer.openSync();
  /// layer.validateSync();
  /// var tiles = layer.tilesSync(0, 0, 10, 10);
  /// layer.closeSync();
  /// ```
  ///
  /// See also:
  /// - [tiles], the asynchronous version of this method.
  /// - [tileSync], the method for reading a single tile synchronously.
  /// - [tile], the method for reading a single tile asynchronously.
  ///
  List<Tile> tilesSync(int x, int y, int width, int height) {
    validateSync();
    var tiles = <Tile>[];
    for (var h = y; h < y + height; h++) {
      tiles.addAll(_reader.readTileRowSync(h, startX: x, width: width));
    }
    return tiles;
  }

  /// Reads tiles asynchronously.
  ///
  /// This method reads tiles from [x],[y] to [x] + [width], [y] + [height].
  ///
  /// Example usage:
  /// ```dart
  /// Layer layer = Layer(LayerType.top, "maps");
  /// await layer.open();
  /// await layer.validate();
  /// var tiles = layer.tiles(0, 0, 10, 10);
  /// await layer.close();
  /// ```
  ///
  /// See also:
  /// - [tilesSync], the synchronous version of this method.
  /// - [tileSync], the method for reading a single tile synchronously.
  /// - [tile], the method for reading a single tile asynchronously.
  ///
  Stream<Tile> tiles(int x, int y, int width, int height) async* {
    await validate();
    for (var h = y; h < y + height; h++) {
      yield* _reader.readTileRow(h, startX: x, width: width);
    }
  }

  /// Reads a single tile synchronously.
  ///
  /// This method reads a single tile at [x],[y].
  ///
  /// Example usage:
  /// ```dart
  /// Layer layer = Layer(LayerType.top, "maps");
  /// layer.openSync();
  /// layer.validateSync();
  /// var tile = layer.tileSync(0, 0);
  /// layer.closeSync();
  /// ```
  ///
  /// See also:
  /// - [tile], the asynchronous version of this method.
  /// - [tilesSync], the method for reading multiple tiles synchronously.
  /// - [tiles], the method for reading multiple tiles asynchronously.
  ///
  Tile tileSync(int x, int y) {
    validateSync();
    return _reader.readTileSync(x, y);
  }

  /// Reads a single tile asynchronously.
  ///
  /// This method reads a single tile at [x],[y].
  ///
  /// Example usage:
  /// ```dart
  /// Layer layer = Layer(LayerType.top, "maps");
  /// await layer.open();
  /// await layer.validate();
  /// var tile = await layer.tile(0, 0);
  /// await layer.close();
  /// ```
  ///
  /// See also:
  /// - [tileSync], the synchronous version of this method.
  /// - [tilesSync], the method for reading multiple tiles synchronously.
  /// - [tiles], the method for reading multiple tiles asynchronously.
  ///
  Future<Tile> tile(int x, int y) async {
    await validate();
    return await _reader.readTile(x, y);
  }

  /// Creates an image of the layer asynchronously.
  ///
  /// This method creates an image of the layer from [x],[y] to [x] + [width], [y] + [height].
  /// Optionally, you can set [showWater] to true to show water tiles as water and provide
  /// a [onProgress] callback to track the progress of the image creation.
  ///
  /// It returns a [ByteBuffer] containing the image data in ABGR format.
  ///
  /// Example usage:
  /// ```dart
  /// Layer layer = Layer(LayerType.top, "maps");
  /// await layer.open();
  /// await layer.validate();
  /// var image = await layer.image(width: 10, height: 10);
  /// await layer.close();
  /// ```
  ///
  /// See also:
  /// - [imageSync], the synchronous version of this method.
  ///
  Future<Uint8List> image(
      {int x = 0,
      int y = 0,
      int? width,
      int? height,
      bool showWater = false,
      bool clearCache = false,
      ProgressCallback? onProgress}) async {
    await validate();
    width ??= size;
    height ??= size;
    var img = Image(width: width, height: height);
    var count = 0;
    var total = width * height;
    if (onProgress != null) {
      Timer.periodic(Duration(milliseconds: 100), (timer) {
        onProgress(count, total);
        if (count >= total) {
          timer.cancel();
        }
      });
    }
    for (var y = 0; y < height; y++) {
      await _reader.readTileRow(y, startX: x, width: width).forEach((tile) {
        img.setPixel(tile.x, tile.y, tile.color(showWater: showWater));
        count++;
      });
    }
    return encodePng(img);
  }

  /// Creates an image of the layer synchronously.
  ///
  /// This method creates an image of the layer from [x],[y] to [x] + [width], [y] + [height].
  /// The [showWater] parameter overlays water tiles with water color if set to true.
  /// All parameters are optional and default to 0 in the case of [x] and [y],
  /// and the size of the layer for [width] and [height].
  ///
  /// It returns a [ByteBuffer] containing the image data in ABGR format.
  ///
  /// Example usage:
  /// ```dart
  /// Layer layer = Layer(LayerType.top, "maps");
  /// layer.openSync();
  /// layer.validateSync();
  /// var image = layer.imageSync(width: 10, height: 10);
  /// layer.closeSync();
  /// ```
  ///
  /// See also:
  /// - [image], the asynchronous version of this method.
  ///
  Uint8List imageSync(
      {int x = 0, int y = 0, int? width, int? height, bool showWater = false, bool clearCache = false}) {
    validateSync();
    width ??= size;
    height ??= size;
    var img = Image(width: width, height: height);
    for (var y = 0; y < height; y++) {
      _reader.readTileRowSync(y, startX: x, width: width).forEach((tile) {
        img.setPixel(tile.x, tile.y, tile.color(showWater: showWater));
      });
    }
    return encodePng(img);
  }
}
