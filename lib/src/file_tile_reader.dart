import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:wurm_atlas/src/tile.dart';
import 'package:wurm_atlas/src/tile_info_repository.dart';
import 'package:wurm_atlas/src/layer.dart';
import 'package:wurm_atlas/src/base_tile_reader.dart';

/// File-based map tile reader class
///
/// The tile reader class reads tiles from a Wurm Unlimited map file.
///
/// Example usage:
/// ```dart
/// var reader = FileTileReader();
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
class FileTileReader extends BaseTileReader {
  static final Logger _logger = Logger('FileTileReader');
  RandomAccessFile? _raf;
  int? _size;
  int? _version;
  BigInt? _magicNumber;

  T _checkFileOpen<T>(T? value) {
    if (_raf == null || value == null) {
      throw Exception("File not opened");
    }
    return value;
  }

  /// The size of the map
  @override
  int get size => _checkFileOpen(_size);

  /// The version of the map
  @override
  int get version => _checkFileOpen(_version);

  /// The magic number of the map
  @override
  BigInt get magicNumber => _checkFileOpen(_magicNumber);

  /// Open a map file synchronously
  ///
  /// The [layerFilePath] is the path to the map file.
  ///
  /// Example usage:
  /// ```dart
  /// var reader = FileTileReader();
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
  @override
  void openSync(String layerFilePath) {
    _raf?.closeSync();
    _raf = File(layerFilePath).openSync();
    _raf!.setPositionSync(0);
    _magicNumber = BigInt.from(
      Uint8List.fromList(_raf!.readSync(8))
          .buffer
          .asByteData()
          .getInt64(0, Endian.big),
    );
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
  /// var reader = FileTileReader();
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
  @override
  Future<void> open(String layerFilePath) async {
    await _raf?.close();
    _raf = await File(layerFilePath).open();
    await _raf!.setPosition(0);
    _magicNumber = BigInt.from(
      Uint8List.fromList(await _raf!.read(8))
          .buffer
          .asByteData()
          .getInt64(0, Endian.big),
    );
    await _raf!.setPosition(8);
    _version = (await _raf!.read(1)).first;
    await _raf!.setPosition(9);
    _size = 1 << (await _raf!.read(1)).first;
  }

  /// Close the map file asynchronously
  ///
  /// Example usage:
  /// ```dart
  /// var reader = FileTileReader();
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
  @override
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
  /// var reader = FileTileReader();
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
  @override
  void closeSync() {
    _raf?.closeSync();
    _size = null;
    _version = null;
    _magicNumber = null;
    _raf = null;
  }

  /// Read a tile synchronously
  ///
  /// Reads a tile at the given [x] and [y] position.
  ///
  /// Returns a [Tile] object.
  ///
  /// Example usage:
  /// ```dart
  /// var reader = FileTileReader();
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
  @override
  Tile readTileSync(int x, int y) {
    _checkFileOpen(true);
    final position = tilePosition(x, y);
    if (position < 0 || position >= _raf!.lengthSync()) {
      throw Exception("Tile position out of file bounds");
    }
    _raf!.setPositionSync(position);
    final tileData = _raf!
        .readSync(BaseTileReader.tileDataSize)
        .buffer
        .asByteData()
        .getInt32(0, Endian.big);
    var height = BaseTileReader.tileHeight(tileData);
    var tileInfo = TileInfoRepository().getTileInfo(BaseTileReader.tileInfoId(tileData))!;
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
  /// var reader = FileTileReader();
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
  @override
  Future<Tile> readTile(int x, int y) async {
    _checkFileOpen(true);
    final position = tilePosition(x, y);
    if (position < 0 || position >= await _raf!.length()) {
      throw Exception("Tile position out of file bounds");
    }
    await _raf!.setPosition(position);
    final tileData = (await _raf!.read(BaseTileReader.tileDataSize))
        .buffer
        .asByteData()
        .getInt32(0, Endian.big);
    return Tile(x, y, BaseTileReader.tileHeight(tileData),
        TileInfoRepository().getTileInfo(BaseTileReader.tileInfoId(tileData))!);
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
  /// var reader = FileTileReader();
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
  @override
  List<Tile> readTileRowSync(int startY, {int startX = 0, int? width}) {
    _checkFileOpen(true);
    width ??= size;
    final position = tilePosition(startX, startY);
    if (position < 0 || position >= _raf!.lengthSync()) {
      throw Exception("Row position out of file bounds");
    }
    _raf!.setPositionSync(position);
    final data = _raf!.readSync(width * BaseTileReader.tileDataSize);
    return List.generate(width, (x) {
      final tileDataOffset = x * BaseTileReader.tileDataSize;
      final tileData = data
          .sublist(tileDataOffset, tileDataOffset + BaseTileReader.tileDataSize)
          .buffer
          .asByteData()
          .getInt32(0, Endian.big);
      var height = BaseTileReader.tileHeight(tileData);
      var tileInfo = TileInfoRepository().getTileInfo(BaseTileReader.tileInfoId(tileData))!;
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
  /// var reader = FileTileReader();
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
  @override
  Stream<Tile> readTileRow(int startY, {int startX = 0, int? width}) async* {
    _checkFileOpen(true);
    width ??= size;
    final position = tilePosition(startX, startY);
    if (position < 0 || position >= await _raf!.length()) {
      throw Exception("Row position out of file bounds");
    }
    await _raf!.setPosition(position);
    final data = await _raf!.read(width * BaseTileReader.tileDataSize);
    for (var x = 0; x < width; x++) {
      final tileDataOffset = x * BaseTileReader.tileDataSize;
      final tileData = data
          .sublist(tileDataOffset, tileDataOffset + BaseTileReader.tileDataSize)
          .buffer
          .asByteData()
          .getInt32(0, Endian.big);
      var height = BaseTileReader.tileHeight(tileData);
      var tileInfo = TileInfoRepository().getTileInfo(BaseTileReader.tileInfoId(tileData))!;
      var tileX = startX + x;
      var tileY = startY;
      _logger.fine(
          "Read tile pos: ($tileX, $tileY) height: $height info: $tileInfo");
      yield Tile(tileX, tileY, height, tileInfo);
    }
  }
}
