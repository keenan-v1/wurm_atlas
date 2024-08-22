import 'package:image/image.dart';
import 'package:wurm_atlas/wurm_atlas.dart';

/// Tile class
///
/// The tile class contains the [x], [y], [height], and [info] of a tile.
///
/// Example usage:
/// ```dart
/// var tile = Tile(0, 0, 0, TileInfo(0, "Rock", Color.hex("#808080")));
/// print("Tile: $tile");
/// ```
///
/// See Also:
/// - [TileInfo] for the tile info class
/// - [ColorConvert] for the color conversion class
/// - [Color] for the color class
///
class Tile {
  /// The x coordinate of the tile
  final int x;

  /// The y coordinate of the tile
  final int y;

  /// The height of the tile
  final int height;

  /// The [TileInfo] of the tile
  final TileInfo info;

  /// Create a [Tile] with an [x], [y], [height], and [info].
  Tile(this.x, this.y, this.height, this.info);

  /// Get the color of the tile
  ///
  /// The color of the tile is determined by [TileInfo.color] and the tile [height].
  /// If [showWater] is true and the tile height is less than or equal to 0, the color is adjusted
  /// to show water.
  ///
  /// Example usage:
  /// ```dart
  /// var tile = Tile(0, 0, 0, TileInfo(0, "Rock", Color.hex("#808080")));
  /// var color = tile.color();
  /// print("Color: $color");
  /// ```
  ///
  /// See Also:
  /// - [TileInfo] for the tile info class
  /// - [Color] for the color class
  ///
  Color color({bool showWater = false}) {
    if (!showWater || height > 0) {
      return info.color;
    }
    final r = (info.color.r * 0.2 + 0.4 * 0.4 * 256).toInt();
    final g = (info.color.g * 0.2 + 0.5 * 0.4 * 256).toInt();
    final b = (info.color.b * 0.2 + 1.0 * 0.4 * 256).toInt();
    return ColorUint8.rgb(r, g, b);
  }
}
