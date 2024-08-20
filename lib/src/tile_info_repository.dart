import 'dart:io';

import 'package:color/color.dart';
import 'package:wurm_atlas/src/tile_info.dart';
import 'package:wurm_atlas/src/tile_info_builder.dart';
import 'package:yaml/yaml.dart';
import 'package:logging/logging.dart';

part 'package:wurm_atlas/src/tile_info_repository.g.dart';

/// Repository for tile information
/// 
/// The default tile information is loaded from the `tile_info_repository.yaml` file
/// via the [TileInfoBuilder] builder.
/// 
/// The tile information can be updated at runtime using the [updateColor] method, or
/// by loading additional tile information files using the [loadAll] method.
/// 
/// Example usage:
/// ```dart
/// var tileId = 0;
/// var tileInfo = TileInfoRepository().getTileInfo(tileId);
/// print("Tile $tileId: $tileInfo");
/// ```
/// 
/// See Also:
/// - [TileInfo] for the tile info class
/// - [TileInfoBuilder] for the tile info builder class
/// 
class TileInfoRepository {
  static TileInfoRepository? _instance;

  final Map<int, TileInfo> _tileInfoMap = {};
  final Logger _logger = Logger('TileInfoRepository');

  TileInfoRepository._();

  factory TileInfoRepository() {
    _instance ??= TileInfoRepository._();
    return _instance!;
  }

  /// Get the tile information for the given [tileId].
  /// 
  /// If the tile information is not found, a null value is returned.
  /// 
  /// Example usage:
  /// ```dart
  /// var tileId = 0;
  /// var tileInfo = TileInfoRepository().getTileInfo(tileId);
  /// print("Tile $tileId: $tileInfo");
  /// ```
  /// 
  /// See Also:
  /// - [TileInfo] for the tile info class
  /// 
  TileInfo? getTileInfo(int tileId) {
    return _tileInfoMap[tileId] ?? _TileInfoRepository._defaultTileMap[tileId];
  }

  /// Load tile information from the given [filePath].
  /// 
  /// The tile information is loaded from the given YAML file and added to the repository.
  /// Existing tile information is updated if the tile id matches.
  /// 
  Future<void> _load(String filePath) async {
    var yamlString = File(filePath).readAsStringSync();
    _logger.fine("Loaded yaml: $filePath");
    var yamlMap = loadYaml(yamlString);
    for (var tile in yamlMap["tiles"]) {
      TileInfo tileInfo = TileInfo.fromYaml(tile);
      if (_tileInfoMap.containsKey(tileInfo.id)) {
        _logger.fine("Updating tile: $tileInfo");
        tileInfo.name = _tileInfoMap[tileInfo.id]?.name ?? tileInfo.name;
      } else if (_TileInfoRepository._defaultTileMap.containsKey(tileInfo.id)) {
        tileInfo.name = _TileInfoRepository._defaultTileMap[tileInfo.id]?.name ?? tileInfo.name;
        _logger.fine("Updating default tile: $tileInfo");
      } else {
        _logger.fine("Loading tile: $tileInfo");
      }
      _tileInfoMap[tileInfo.id] = tileInfo;
    }
  }

  /// Load all tile information from the given list of [filePaths].
  /// 
  /// If [clear] is true, the existing tile information is cleared before loading.
  /// 
  /// Example usage:
  /// ```dart
  /// var filePaths = ["assets/tile_info.yaml"];
  /// await TileInfoRepository().loadAll(filePaths: filePaths, clear: true);
  /// ```
  /// 
  /// See Also:
  /// - [updateColor] for updating the color of a tile
  /// 
  Future<void> loadAll({List<String>? filePaths, bool clear = false}) async {
    if (clear) {
      _tileInfoMap.clear();
    }
    for (var filePath in filePaths ?? []) {
      await _load(filePath);
    }
  }

  /// Update the [color] of the tile with the given [tileId].
  /// 
  /// Example usage:
  /// ```dart
  /// var tileId = 0;
  /// var color = ColorConvert.from("#00ff00");
  /// TileInfoRepository().updateColor(tileId, color);
  /// ```
  /// 
  /// See Also:
  /// - [loadAll] for loading additional tile information files
  /// 
  void updateColor(int tileId, Color color) {
    if (_tileInfoMap.containsKey(tileId)) {
      _tileInfoMap[tileId]!.color = color;
    } else if (_TileInfoRepository._defaultTileMap.containsKey(tileId)) {
      var tileInfo = _TileInfoRepository._defaultTileMap[tileId]!;
      tileInfo.color = color;
      _tileInfoMap[tileId] = tileInfo;
    } else {
      _logger.warning("Tile not found: $tileId");
    }
  }
}
