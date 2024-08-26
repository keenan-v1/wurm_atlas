import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:logging/logging.dart';
import 'package:wurm_atlas/src/exceptions.dart';
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
  static final _logger = Logger('MemoryTileReader');
  Uint8List _data;

  /// The size of the map
  @override
  int get size => 1 << _data.buffer.asByteData(9).getInt8(0);

  /// The version of the map
  @override
  int get version => _data.buffer.asByteData(8).getInt8(0);

  int get length => _data.length;

  /// The magic number of the map
  @override
  BigInt get magicNumber => BigInt.parse(
      _data
          .sublist(0, 8)
          .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
          .join(''),
      radix: 16);

  MemoryTileReader.empty() : _data = Uint8List(0);

  /// Memory-based map tile reader constructor
  MemoryTileReader(this._data);

  Future<Uint8List> streamImage(Stream<List<int>> stream,
      {ProgressCallback? onProgress, bool showWater = true}) async {
    Image? image;
    var tileIndex = 0;

    await for (final chunk in stream) {
      addAll(chunk);
      var readTo = BaseTileReader.headerBytes +
          (BaseTileReader.tileDataSize * tileIndex);
      if (length < readTo) {
        continue;
      }

      image ??= Image(width: size, height: size);

      while (length > (readTo + BaseTileReader.tileDataSize)) {
        var tile = readTilePosition(readTo);
        image.setPixel(tile.x, tile.y, tile.color(showWater: showWater));
        onProgress?.call(tileIndex, size * size);
        tileIndex++;
        readTo = BaseTileReader.headerBytes +
            (BaseTileReader.tileDataSize * tileIndex);
        if (tileIndex >= size * size) {
          break;
        }
      }
    }
    _logger.info("Generating $size x $size PNG");
    return encodePng(image!);
  }

  void addAll(List<int> bytes) {
    _data = Uint8List.fromList(_data + bytes);
  }

  Tile readTilePosition(int position) {
    var (x, y) = tilePositionToXY(position);
    if (position < 0 || position >= _data.length) {
      throw OutOfBoundsException("Tile position out of map bounds",
          position: position, x: x, y: y);
    }
    var tileData = _data.buffer
        .asByteData(position, BaseTileReader.tileDataSize)
        .getInt32(0, Endian.big);
    return parseTile(tileData, x, y);
  }

  static Tile parseTile(int tileData, int x, int y) {
    var height = BaseTileReader.tileHeight(tileData);
    var tileInfo =
        TileInfoRepository().getTileInfo(BaseTileReader.tileInfoId(tileData))!;
    return Tile(x, y, height, tileInfo);
  }

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
    if (position < 0 || position >= _data.length) {
      throw OutOfBoundsException("Tile position out of map bounds",
          x: x, y: y, position: position);
    }
    final tileData = _data.buffer
        .asByteData(position, BaseTileReader.tileDataSize)
        .getInt32(0, Endian.big);
    return parseTile(tileData, x, y);
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
    if (position < 0 || position >= _data.length) {
      throw Exception("Row position out of map bounds");
    }
    final row =
        _data.buffer.asUint8List(position, width * BaseTileReader.tileDataSize);
    return List.generate(width, (x) {
      final tileDataOffset = x * BaseTileReader.tileDataSize;
      final tileData = row
          .sublist(tileDataOffset, tileDataOffset + BaseTileReader.tileDataSize)
          .buffer
          .asByteData()
          .getInt32(0, Endian.big);
      return parseTile(tileData, startX + x, startY);
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
  Stream<Tile> readTileRow(int startY, {int startX = 0, int? width}) async* {
    width ??= size;
    final position = tilePosition(startX, startY);
    if (position < 0 || position >= _data.length) {
      throw Exception("Row position out of map bounds");
    }
    final row =
        _data.buffer.asUint8List(position, width * BaseTileReader.tileDataSize);
    for (var x = 0; x < width; x++) {
      final tileDataOffset = x * BaseTileReader.tileDataSize;
      final tileData = row
          .sublist(tileDataOffset, tileDataOffset + BaseTileReader.tileDataSize)
          .buffer
          .asByteData()
          .getInt32(0, Endian.big);
      yield parseTile(tileData, startX + x, startY);
    }
  }
}
