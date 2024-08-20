import 'package:color/color.dart';
import 'package:wurm_atlas/src/color_convert.dart';
import 'package:wurm_atlas/src/tile_info_repository.dart';
import 'package:yaml/yaml.dart';

/// Tile information class
/// 
/// The tile information class contains the [id], [name], and [color] of a tile.
/// 
/// Example usage:
/// ```dart
/// var tileInfo = TileInfo(0, "Rock", Color.hex("#808080"));
/// print("Tile: $tileInfo");
/// ```
/// 
/// See Also:
/// - [TileInfoRepository] for the tile info repository class
/// - [ColorConvert] for the color conversion class
/// 
class TileInfo {
  /// The tile id
  final int id;
  /// The tile name
  String name;
  /// The tile [Color]
  Color color;

  /// Create a [TileInfo] with an [id], [name], and [color].
  TileInfo(this.id, this.name, this.color);

  /// Create a [TileInfo] with a [color] string.
  /// 
  /// The [color] string can be in hex or rgb(r,g,b) format.
  /// 
  /// Example usage:
  /// ```dart
  /// var tileInfo = TileInfo.parseColor(0, "Rock", "#808080");
  /// print("Tile: $tileInfo");
  /// ```
  /// 
  /// See Also:
  /// - [ColorConvert] for the color conversion class
  /// - [ColorConvert.from] for creating a color from a string
  ///
  TileInfo.parseColor(this.id, this.name, String color)
      : color = ColorConvert.from(color);

  /// Create a [TileInfo] from a [yaml] map.
  /// 
  /// The [yaml] map should contain the keys `id`, `name`, and `color`.
  /// 
  /// Example usage:
  /// ```dart
  /// var yaml = loadYaml("id: 0\nname: Rock\ncolor: #808080") as YamlMap;
  /// var tileInfo = TileInfo.fromYaml(yaml);
  /// print("Tile: $tileInfo");
  /// ```
  /// 
  /// See Also:
  /// - [ColorConvert] for the color conversion class
  /// - [ColorConvert.from] for creating a color from a string
  /// - [loadYaml] for loading a yaml map
  /// 
  factory TileInfo.fromYaml(YamlMap yaml) {
    return TileInfo(
      yaml['id'],
      yaml['name'] ?? "",
      ColorConvert.from(yaml['color']),
    );
  }

  @override
  String toString() {
    return 'TileInfo(id: $id, name: $name, color: $color)';
  }
}
