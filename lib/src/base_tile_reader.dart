import 'package:wurm_atlas/src/exceptions.dart';
import 'package:wurm_atlas/src/tile.dart';
import 'package:wurm_atlas/src/tile_info_repository.dart';
import 'package:wurm_atlas/src/layer.dart';
import 'package:wurm_atlas/src/file_tile_reader.dart';
import 'package:wurm_atlas/src/memory_tile_reader.dart';

/// Tile reader abstract class
///
/// The tile reader class reads tiles from a Wurm Unlimited map file.
///
/// See Also:
/// - [Tile] for the tile class
/// - [TileInfoRepository] for the tile info repository class
/// - [Layer] for the layer class which uses the tile reader
/// - [FileTileReader] for the file-based map tile reader
/// - [MemoryTileReader] for the memory-based map tile reader
///
abstract class BaseTileReader {
  static const _headerBytes = 1024;
  static const _tileDataSize = 4;

  /// The header bytes of the map file
  static int get headerBytes => _headerBytes;

  /// The tile data size in bytes of a tile
  static int get tileDataSize => _tileDataSize;

  /// The size of the map
  int get size;

  /// The version of the map
  int get version;

  /// The magic number of the map
  BigInt get magicNumber;

  /// Open a map file synchronously
  ///
  /// The [layerFilePath] is the path to the map file.
  /// Only available in file-based tile readers.
  ///
  /// See Also:
  /// - [open] for opening a map file asynchronously
  /// - [closeSync] for closing the map file synchronously
  /// - [close] for closing the map file asynchronously
  ///
  void openSync(String layerFilePath) {}

  /// Open a map file asynchronously
  ///
  /// The [layerFilePath] is the path to the map file.
  /// Only available in file-based tile readers.
  ///
  /// See Also:
  /// - [openSync] for opening a map file synchronously
  /// - [close] for closing the map file asynchronously
  /// - [closeSync] for closing the map file synchronously
  ///
  Future<void> open(String layerFilePath) async {}

  /// Closes the map file asynchronously and resets state.
  /// Memory-based tile readers clear the memory buffer.
  ///
  /// See Also:
  /// - [open] for opening a map file asynchronously
  /// - [openSync] for opening a map file synchronously
  /// - [closeSync] for closing the map file synchronously
  ///
  Future<void> close() async {}

  /// Closes the map file synchronously and resets state.
  /// Memory-based tile readers clear the memory buffer.
  ///
  /// See Also:
  /// - [openSync] for opening a map file synchronously
  /// - [open] for opening a map file asynchronously
  /// - [close] for closing the map file asynchronously
  ///
  void closeSync() {}

  /// Get the tile position for [x],[y] in the map data.
  /// The position is the byte offset in the map data.
  int tilePosition(int x, int y) {
    return _headerBytes + (x + y * size) * _tileDataSize;
  }

  /// Get the tile x and y position from the [position] in the map data.
  /// The position is the byte offset in the map data.
  /// Returns a [Record] with the x and y position.
  (int, int) tilePositionToXY(int position) {
    final offset = position - _headerBytes;
    if (offset < 0) {
      throw OutOfBoundsException("Tile position out of data bounds",
          position: position);
    }
    final x = offset ~/ _tileDataSize % size;
    final y = offset ~/ _tileDataSize ~/ size;
    return (x, y);
  }

  /// Get the tile info ID from the [tileData].
  /// The tile info ID is the first byte of the tile data.
  static int tileInfoId(int tileData) {
    return (tileData >> 24) & 0xff;
  }

  /// Get the tile height from the [tileData].
  /// The tile height is the last two bytes of the tile data.
  /// The height is a signed 16-bit integer.
  static int tileHeight(int tileData) {
    return (tileData & 0xffff).toSigned(16);
  }

  /// Read a tile synchronously
  ///
  /// Reads a tile at the given [x] and [y] position.
  ///
  /// Returns a [Tile] object.
  ///
  /// See Also:
  /// - [readTile] for reading a tile asynchronously
  /// - [readTileRowSync] for reading a row of tiles synchronously
  /// - [readTileRow] for reading a row of tiles asynchronously
  /// - [Tile] for the tile class
  ///
  Tile readTileSync(int x, int y);

  /// Read a tile asynchronously
  ///
  /// Reads a tile at the given [x] and [y] position.
  ///
  /// Returns a [Future] of a [Tile] object.
  ///
  /// See Also:
  /// - [readTileSync] for reading a tile synchronously
  /// - [readTileRowSync] for reading a row of tiles synchronously
  /// - [readTileRow] for reading a row of tiles asynchronously
  /// - [Tile] for the tile class
  ///
  Future<Tile> readTile(int x, int y);

  /// Read a row of tiles synchronously
  ///
  /// Reads a row of tiles starting at the given [startY] position.
  /// Optionally, the [startX] position and [width] can be specified.
  /// If [width] is not provided then the full row is read.
  ///
  /// Returns a [List] of [Tile] objects.
  ///
  /// See Also:
  /// - [readTileRow] for reading a row of tiles asynchronously
  /// - [readTileSync] for reading a tile synchronously
  /// - [readTile] for reading a tile asynchronously
  /// - [Tile] for the tile class
  ///
  List<Tile> readTileRowSync(int startY, {int startX = 0, int? width});

  /// Read a row of tiles asynchronously
  ///
  /// Reads a row of tiles starting at the given [startY] position.
  /// Optionally, the [startX] position and [width] can be specified.
  /// If [width] is not provided then the full row is read.
  ///
  /// Returns a [Stream] of [Tile] objects.
  ///
  /// See Also:
  /// - [readTileRowSync] for reading a row of tiles synchronously
  /// - [readTileSync] for reading a tile synchronously
  /// - [readTile] for reading a tile asynchronously
  /// - [Tile] for the tile class
  ///
  Stream<Tile> readTileRow(int startY, {int startX = 0, int? width});
}
