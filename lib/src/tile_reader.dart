import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:wurm_atlas/src/tile.dart';
import 'package:wurm_atlas/src/tile_info_repository.dart';
import 'package:wurm_atlas/src/layer.dart';

/// Tile reader class
///
/// The tile reader class reads tiles from a Wurm Unlimited map file.
///
/// Example usage:
/// ```dart
/// var reader = TileReader();
/// reader.openSync("assets/happy_map/top_layer.map");
/// var tile = reader.readTileSync(0, 0);
/// print("Tile: $tile");
/// reader.closeSync();
/// ```
///
/// See Also:
/// - [Tile] for the tile class
/// - [TileInfoRepository] for the tile info repository class
/// - [Layer] for the layer class which uses the tile reader
///
class TileReader {
  static final Logger _logger = Logger('TileReader');
  static const _headerBytes = 1024;
  static const _tileDataBytes = 4;
  RandomAccessFile? _raf;
  int? _size;
  int? _version;
  int? _magicNumber;

  T _checkFileOpen<T>(T? value) {
    if (_raf == null || value == null) {
      throw Exception("File not opened");
    }
    return value;
  }

  /// The size of the map
  int get size => _checkFileOpen(_size);

  /// The version of the map
  int get version => _checkFileOpen(_version);

  /// The magic number of the map
  int get magicNumber => _checkFileOpen(_magicNumber);

  /// Open a map file synchronously
  ///
  /// The [layerFilePath] is the path to the map file.
  ///
  /// Example usage:
  /// ```dart
  /// var reader = TileReader();
  /// reader.openSync("assets/happy_map/top_layer.map");
  /// var tile = reader.readTileSync(0, 0);
  /// print("Tile: $tile");
  /// reader.closeSync();
  /// ```
  ///
  /// See Also:
  /// - [open] for opening a map file asynchronously
  /// - [closeSync] for closing the map file synchronously
  /// - [close] for closing the map file asynchronously
  ///
  void openSync(String layerFilePath) {
    _raf?.closeSync();
    _raf = File(layerFilePath).openSync();
    _raf!.setPositionSync(0);
    _magicNumber = Uint8List.fromList(_raf!.readSync(8))
        .buffer
        .asByteData()
        .getInt64(0, Endian.big);
    _raf!.setPositionSync(8);
    _version = _raf!.readByteSync();
    _raf!.setPositionSync(9);
    _size = 1 << _raf!.readByteSync();
  }

  /// Open a map file asynchronously
  ///
  /// The [layerFilePath] is the path to the map file.
  ///
  /// Example usage:
  /// ```dart
  /// var reader = TileReader();
  /// await reader.open("assets/happy_map/top_layer.map");
  /// var tile = await reader.readTile(0, 0);
  /// print("Tile: $tile");
  /// await reader.close();
  /// ```
  ///
  /// See Also:
  /// - [openSync] for opening a map file synchronously
  /// - [close] for closing the map file asynchronously
  /// - [closeSync] for closing the map file synchronously
  ///
  Future<void> open(String layerFilePath) async {
    await _raf?.close();
    _raf = await File(layerFilePath).open();
    await _raf!.setPosition(0);
    _magicNumber = Uint8List.fromList(await _raf!.read(8))
        .buffer
        .asByteData()
        .getInt64(0, Endian.big);
    await _raf!.setPosition(8);
    _version = (await _raf!.read(1)).first;
    await _raf!.setPosition(9);
    _size = 1 << (await _raf!.read(1)).first;
  }

  /// Close the map file asynchronously
  ///
  /// Example usage:
  /// ```dart
  /// var reader = TileReader();
  /// await reader.open("assets/happy_map/top_layer.map");
  /// var tile = await reader.readTile(0, 0);
  /// print("Tile: $tile");
  /// await reader.close();
  /// ```
  ///
  /// See Also:
  /// - [open] for opening a map file asynchronously
  /// - [openSync] for opening a map file synchronously
  /// - [closeSync] for closing the map file synchronously
  ///
  Future<void> close() async {
    _size = null;
    _version = null;
    _magicNumber = null;
    _raf = null;
    await _raf?.close();
  }

  /// Close the map file synchronously
  ///
  /// Example usage:
  /// ```dart
  /// var reader = TileReader();
  /// reader.openSync("assets/happy_map/top_layer.map");
  /// var tile = reader.readTileSync(0, 0);
  /// print("Tile: $tile");
  /// reader.closeSync();
  /// ```
  ///
  /// See Also:
  /// - [openSync] for opening a map file synchronously
  /// - [open] for opening a map file asynchronously
  /// - [close] for closing the map file asynchronously
  ///
  void closeSync() {
    _raf?.closeSync();
    _size = null;
    _version = null;
    _magicNumber = null;
    _raf = null;
  }

  int _tilePosition(int x, int y) {
    return _headerBytes + (x + y * size) * _tileDataBytes;
  }

  int _tileInfoId(int tileData) {
    return (tileData >> 24) & 0xff;
  }

  int _tileHeight(int tileData) {
    return (tileData & 0xffff).toSigned(16);
  }

  /// Read a tile synchronously
  ///
  /// Reads a tile at the given [x] and [y] position.
  ///
  /// Returns a [Tile] object.
  ///
  /// Example usage:
  /// ```dart
  /// var reader = TileReader();
  /// reader.openSync("assets/happy_map/top_layer.map");
  /// var tile = reader.readTileSync(0, 0);
  /// print("Tile: $tile");
  /// reader.closeSync();
  /// ```
  ///
  /// See Also:
  /// - [readTile] for reading a tile asynchronously
  /// - [readTileRowSync] for reading a row of tiles synchronously
  /// - [readTileRow] for reading a row of tiles asynchronously
  /// - [Tile] for the tile class
  ///
  Tile readTileSync(int x, int y) {
    _checkFileOpen(true);
    final position = _tilePosition(x, y);
    if (position < 0 || position >= _raf!.lengthSync()) {
      throw Exception("Tile position out of file bounds");
    }
    _raf!.setPositionSync(position);
    final tileData = _raf!
        .readSync(_tileDataBytes)
        .buffer
        .asByteData()
        .getInt32(0, Endian.big);
    var height = _tileHeight(tileData);
    var tileInfo = TileInfoRepository().getTileInfo(_tileInfoId(tileData))!;
    _logger.fine("Read tile: $x, $y, $height, $tileInfo");
    return Tile(x, y, height, tileInfo);
  }

  /// Read a tile asynchronously
  ///
  /// Reads a tile at the given [x] and [y] position.
  ///
  /// Returns a [Future] of a [Tile] object.
  ///
  /// Example usage:
  /// ```dart
  /// var reader = TileReader();
  /// await reader.open("assets/happy_map/top_layer.map");
  /// var tile = await reader.readTile(0, 0);
  /// print("Tile: $tile");
  /// await reader.close();
  /// ```
  ///
  /// See Also:
  /// - [readTileSync] for reading a tile synchronously
  /// - [readTileRowSync] for reading a row of tiles synchronously
  /// - [readTileRow] for reading a row of tiles asynchronously
  /// - [Tile] for the tile class
  ///
  Future<Tile> readTile(int x, int y) async {
    _checkFileOpen(true);
    final position = _tilePosition(x, y);
    if (position < 0 || position >= await _raf!.length()) {
      throw Exception("Tile position out of file bounds");
    }
    await _raf!.setPosition(position);
    final tileData = (await _raf!.read(_tileDataBytes))
        .buffer
        .asByteData()
        .getInt32(0, Endian.big);
    return Tile(x, y, _tileHeight(tileData),
        TileInfoRepository().getTileInfo(_tileInfoId(tileData))!);
  }

  /// Read a row of tiles synchronously
  ///
  /// Reads a row of tiles starting at the given [startY] position.
  /// Optionally, the [startX] position and [width] can be specified.
  /// If [width] is not provided then the full row is read.
  ///
  /// Returns a [List] of [Tile] objects.
  ///
  /// Example usage:
  /// ```dart
  /// var reader = TileReader();
  /// reader.openSync("assets/happy_map/top_layer.map");
  /// var tiles = reader.readTileRowSync(0);
  /// print("Tiles: $tiles");
  /// reader.closeSync();
  /// ```
  ///
  /// See Also:
  /// - [readTileRow] for reading a row of tiles asynchronously
  /// - [readTileSync] for reading a tile synchronously
  /// - [readTile] for reading a tile asynchronously
  /// - [Tile] for the tile class
  ///
  List<Tile> readTileRowSync(int startY, {int startX = 0, int? width}) {
    _checkFileOpen(true);
    width ??= size;
    final position = _tilePosition(startX, startY);
    if (position < 0 || position >= _raf!.lengthSync()) {
      throw Exception("Row position out of file bounds");
    }
    _raf!.setPositionSync(position);
    final data = _raf!.readSync(width * _tileDataBytes);
    return List.generate(width, (x) {
      final tileDataOffset = x * _tileDataBytes;
      final tileData = data
          .sublist(tileDataOffset, tileDataOffset + _tileDataBytes)
          .buffer
          .asByteData()
          .getInt32(0, Endian.big);
      var height = _tileHeight(tileData);
      var tileInfo = TileInfoRepository().getTileInfo(_tileInfoId(tileData))!;
      var tileX = startX + x;
      var tileY = startY;
      _logger.fine(
          "Read tile pos: ($tileX, $tileY) height: $height info: $tileInfo");
      return Tile(tileX, tileY, height, tileInfo);
    });
  }

  /// Read a row of tiles asynchronously
  ///
  /// Reads a row of tiles starting at the given [startY] position.
  /// Optionally, the [startX] position and [width] can be specified.
  /// If [width] is not provided then the full row is read.
  ///
  /// Returns a [Stream] of [Tile] objects.
  ///
  /// Example usage:
  /// ```dart
  /// var reader = TileReader();
  /// await reader.open("assets/happy_map/top_layer.map");
  /// await for (var tile in reader.readTileRow(0)) {
  ///  print("Tile: $tile");
  /// }
  /// await reader.close();
  /// ```
  ///
  /// See Also:
  /// - [readTileRowSync] for reading a row of tiles synchronously
  /// - [readTileSync] for reading a tile synchronously
  /// - [readTile] for reading a tile asynchronously
  /// - [Tile] for the tile class
  ///
  Stream<Tile> readTileRow(int startY,
      {int startX = 0, int width = -1}) async* {
    _checkFileOpen(true);
    if (width < 0) {
      width = size;
    }
    final position = _tilePosition(startX, startY);
    if (position < 0 || position >= await _raf!.length()) {
      throw Exception("Row position out of file bounds");
    }
    await _raf!.setPosition(position);
    final data = await _raf!.read(width * _tileDataBytes);
    for (var x = 0; x < width; x++) {
      final tileDataOffset = x * _tileDataBytes;
      final tileData = data
          .sublist(tileDataOffset, tileDataOffset + _tileDataBytes)
          .buffer
          .asByteData()
          .getInt32(0, Endian.big);
      var height = _tileHeight(tileData);
      var tileInfo = TileInfoRepository().getTileInfo(_tileInfoId(tileData))!;
      var tileX = startX + x;
      var tileY = startY;
      _logger.fine(
          "Read tile pos: ($tileX, $tileY) height: $height info: $tileInfo");
      yield Tile(tileX, tileY, height, tileInfo);
    }
  }
}
