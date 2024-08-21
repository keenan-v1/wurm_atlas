import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:wurm_atlas/src/color_convert.dart';
import 'package:wurm_atlas/src/file_tile_reader.dart';
import 'package:wurm_atlas/src/layer_type.dart';
import 'package:wurm_atlas/src/memory_tile_reader.dart';
import 'package:wurm_atlas/src/tile.dart';
import 'package:wurm_atlas/src/base_tile_reader.dart';
import 'package:wurm_atlas/src/validation_exception.dart';

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
  final BigInt _magicNumber = BigInt.parse("0x474A2198B2781B9D");

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
      _logger.severe(
          "Magic number mismatch. Expected: $_magicNumber, got: ${_reader.magicNumber}");
      throw ValidationException(
          "Magic number mismatch. Expected: $_magicNumber, got: ${_reader.magicNumber}");
    }
    if (_reader.version != type.version) {
      _logger.severe(
          "Version mismatch. Expected: ${type.version}, got: ${_reader.version}");
      throw ValidationException(
          "Version mismatch. Expected: ${type.version}, got: ${_reader.version}");
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
  Future<bool> validate() async {
    if (_reader.magicNumber != _magicNumber) {
      throw ValidationException(
          "Magic number mismatch. Expected: $_magicNumber, got: ${_reader.magicNumber}");
    }
    if (_reader.version != type.version) {
      throw ValidationException(
          "Version mismatch. Expected: ${type.version}, got: ${_reader.version}");
    }
    return true;
  }

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
  /// var image = await layer.image(0, 0, 10, 10);
  /// await layer.close();
  /// ```
  ///
  /// See also:
  /// - [imageSync], the synchronous version of this method.
  ///
  Future<ByteBuffer> image(int x, int y, int width, int height,
      {bool showWater = false, ProgressCallback? onProgress}) async {
    await validate();
    var image = Uint8List(width * height * 4).buffer;
    var count = 0;
    var total = width * height;
    for (var y = 0; y < height; y++) {
      await _reader.readTileRow(y, startX: x, width: width).forEach((tile) {
        var offset = (y * width + tile.x) * 4;
        image.asByteData().setInt32(
            offset, tile.color(showWater: showWater).toInt(), Endian.little);
        count++;
        onProgress?.call(count, total);
      });
    }
    return image;
  }

  /// Creates an image of the layer synchronously.
  ///
  /// This method creates an image of the layer from [x],[y] to [x] + [width], [y] + [height].
  /// Optionally, you can set [showWater] to true to show water tiles as water.
  ///
  /// It returns a [ByteBuffer] containing the image data in ABGR format.
  ///
  /// Example usage:
  /// ```dart
  /// Layer layer = Layer(LayerType.top, "maps");
  /// layer.openSync();
  /// layer.validateSync();
  /// var image = layer.imageSync(0, 0, 10, 10);
  /// layer.closeSync();
  /// ```
  ///
  /// See also:
  /// - [image], the asynchronous version of this method.
  ///
  ByteBuffer imageSync(int x, int y, int width, int height,
      {bool showWater = false}) {
    validateSync();
    var image = Uint8List(width * height * 4).buffer;
    for (var y = 0; y < height; y++) {
      _reader.readTileRowSync(y, startX: x, width: width).forEach((tile) {
        var offset = (y * width + tile.x) * 4;
        image.asByteData().setInt32(
            offset, tile.color(showWater: showWater).toInt(), Endian.little);
      });
    }
    return image;
  }
}
