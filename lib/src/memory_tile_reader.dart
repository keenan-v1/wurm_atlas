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
/// var reader = MemoryTileReader(File("assets/happy_map/top_layer.map").readAsBytesSync());
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
  final Uint8List _bytes;
  final int _size;
  final int _version;
  final BigInt _magicNumber;

  /// The size of the map
  @override
  int get size => _size;

  /// The version of the map
  @override
  int get version => _version;

  /// The magic number of the map
  @override
  BigInt get magicNumber => _magicNumber;

  /// Memory-based map tile reader constructor
  MemoryTileReader(this._bytes)
      : _size = 1 << _bytes.buffer.asByteData(9).getInt8(0),
        _version = _bytes.buffer.asByteData(8).getInt8(0),
        _magicNumber = BigInt.parse(
            _bytes
                .sublist(0, 8)
                .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
                .join(''),
            radix: 16);

  /// Reads a tile at the given [x] and [y] position.
  ///
  /// Returns a [Tile] object.
  ///
  /// Example usage:
  /// ```dart
  /// var reader = MemoryTileReader(File("assets/happy_map/top_layer.map").readAsBytesSync());
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
    final position = tilePosition(x, y);
    if (position < 0 || position >= _bytes.length) {
      throw Exception("Tile position out of map bounds");
    }
    final tileData = _bytes.buffer
        .asByteData(position, tileDataSize)
        .getInt32(0, Endian.big);
    var height = tileHeight(tileData);
    var tileInfo = TileInfoRepository().getTileInfo(tileInfoId(tileData))!;
    _logger.fine("Read tile: $x, $y, $height, $tileInfo");
    return Tile(x, y, height, tileInfo);
  }

  /// Reads a tile at the given [x] and [y] position.
  ///
  /// Returns a [Future] of a [Tile] object.
  ///
  /// Example usage:
  /// ```dart
  /// var reader = MemoryTileReader(File("assets/happy_map/top_layer.map").readAsBytesSync());
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
  Future<Tile> readTile(int x, int y) => Future.value(readTileSync(x, y));

  /// Reads a row of tiles starting at the given [startY] position.
  /// Optionally, the [startX] position and [width] can be specified.
  /// If [width] is not provided then the full row is read.
  ///
  /// Returns a [List] of [Tile] objects.
  ///
  /// Example usage:
  /// ```dart
  /// var reader = MemoryTileReader(File("assets/happy_map/top_layer.map").readAsBytesSync());
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
    width ??= size;
    final position = tilePosition(startX, startY);
    if (position < 0 || position >= _bytes.length) {
      throw Exception("Row position out of map bounds");
    }
    final data = _bytes.buffer.asUint8List(position, width * tileDataSize);
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

  /// Reads a row of tiles starting at the given [startY] position.
  /// Optionally, the [startX] position and [width] can be specified.
  /// If [width] is not provided then the full row is read.
  ///
  /// Returns a [Stream] of [Tile] objects.
  ///
  /// Example usage:
  /// ```dart
  /// var reader = MemoryTileReader(File("assets/happy_map/top_layer.map").readAsBytesSync());
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
  Stream<Tile> readTileRow(int startY, {int startX = 0, int? width}) =>
      Stream.fromIterable(
          readTileRowSync(startY, startX: startX, width: width));
}
