import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:wurm_atlas/src/tile.dart';
import 'package:wurm_atlas/src/tile_info_repository.dart';
import 'package:wurm_atlas/src/layer.dart';
import 'package:wurm_atlas/src/base_tile_reader.dart';

/// Memory-based map tile reader class
///
/// The tile reader class reads tiles from a Wurm Unlimited map file.
///
/// Example usage:
/// ```dart
/// var bytes = Uint8List.fromList(File("assets/happy_map/top_layer.map").readAsBytesSync());
/// var reader = MemoryTileReader(bytes);
/// var tile = reader.readTileSync(0, 0);
/// print("Tile: $tile");
/// ```
///
/// See Also:
/// - [Tile] for the tile class
/// - [TileInfoRepository] for the tile info repository class
/// - [Layer] for the layer class which uses the tile reader
///
class MemoryTileReader extends BaseTileReader {
  static final Logger _logger = Logger('MemoryTileReader');
  ByteBuffer? _buffer;
  int? _size;
  int? _version;
  BigInt? _magicNumber;

  T _checkMap<T>(T? value) {
    if (_buffer == null || value == null) {
      throw Exception("Map data not loaded");
    }
    return value;
  }

  /// The size of the map
  @override
  int get size => _checkMap(_size);

  /// The version of the map
  @override
  int get version => _checkMap(_version);

  /// The magic number of the map
  @override
  BigInt get magicNumber => _checkMap(_magicNumber);

  /// Memory-based map tile reader constructor
  /// The [buffer] is the map file data.
  MemoryTileReader(Uint8List buffer) {
    _buffer = buffer.buffer;
    _magicNumber =
        BigInt.from(_buffer!.asByteData(0, 8).getUint64(0, Endian.big));
    _version = _buffer!.asByteData(8).getInt8(0);
    _size = _buffer!.asByteData(9).getInt8(0);
  }

  /// Read a tile synchronously
  ///
  /// Reads a tile at the given [x] and [y] position.
  ///
  /// Returns a [Tile] object.
  ///
  /// Example usage:
  /// ```dart
  /// var bytes = Uint8List.fromList(File("assets/happy_map/top_layer.map").readAsBytesSync());
  /// var reader = MemoryTileReader(bytes);
  /// var tile = reader.readTileSync(0, 0);
  /// print("Tile: $tile");
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
    _checkMap(true);
    final position = tilePosition(x, y);
    if (position < 0 || position >= _buffer!.lengthInBytes) {
      throw Exception("Tile position out of map bounds");
    }
    final tileData =
        _buffer!.asByteData(position, tileDataSize).getInt32(0, Endian.big);
    var height = tileHeight(tileData);
    var tileInfo = TileInfoRepository().getTileInfo(tileInfoId(tileData))!;
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
  /// var bytes = Uint8List.fromList(File("assets/happy_map/top_layer.map").readAsBytesSync());
  /// var reader = MemoryTileReader(bytes);
  /// var tile = await reader.readTile(0, 0);
  /// print("Tile: $tile");
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
    _checkMap(true);
    final position = tilePosition(x, y);
    if (position < 0 || position >= _buffer!.lengthInBytes) {
      throw Exception("Tile position out of map bounds");
    }
    final tileData =
        _buffer!.asByteData(position, tileDataSize).getInt32(0, Endian.big);
    return Tile(x, y, tileHeight(tileData),
        TileInfoRepository().getTileInfo(tileInfoId(tileData))!);
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
  /// var bytes = Uint8List.fromList(File("assets/happy_map/top_layer.map").readAsBytesSync());
  /// var reader = MemoryTileReader(bytes);
  /// var tiles = reader.readTileRowSync(0);
  /// print("Tiles: $tiles");
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
    _checkMap(true);
    width ??= size;
    final position = tilePosition(startX, startY);
    if (position < 0 || position >= _buffer!.lengthInBytes) {
      throw Exception("Row position out of map bounds");
    }
    final data = _buffer!.asUint8List(position, width * tileDataSize);
    return List.generate(width, (x) {
      final tileDataOffset = x * tileDataSize;
      final tileData = data
          .sublist(tileDataOffset, tileDataOffset + tileDataSize)
          .buffer
          .asByteData()
          .getInt32(0, Endian.big);
      var height = tileHeight(tileData);
      var tileInfo = TileInfoRepository().getTileInfo(tileInfoId(tileData))!;
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
  /// var bytes = Uint8List.fromList(File("assets/happy_map/top_layer.map").readAsBytesSync());
  /// var reader = MemoryTileReader(bytes);
  /// await for (var tile in reader.readTileRow(0)) {
  ///  print("Tile: $tile");
  /// }
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
    _checkMap(true);
    width ??= size;
    final position = tilePosition(startX, startY);
    if (position < 0 || position >= _buffer!.lengthInBytes) {
      throw Exception("Row position out of map bounds");
    }
    final data = _buffer!.asUint8List(position, width * tileDataSize);
    for (var x = 0; x < width; x++) {
      final tileDataOffset = x * tileDataSize;
      final tileData = data
          .sublist(tileDataOffset, tileDataOffset + tileDataSize)
          .buffer
          .asByteData()
          .getInt32(0, Endian.big);
      var height = tileHeight(tileData);
      var tileInfo = TileInfoRepository().getTileInfo(tileInfoId(tileData))!;
      var tileX = startX + x;
      var tileY = startY;
      _logger.fine(
          "Read tile pos: ($tileX, $tileY) height: $height info: $tileInfo");
      yield Tile(tileX, tileY, height, tileInfo);
    }
  }
}
