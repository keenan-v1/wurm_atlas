import 'dart:async';
import 'package:build/build.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';
import 'package:wurm_atlas/wurm_atlas.dart';

/// Builder for generating the tile info repository from the `tile_info_repository.yaml` file
/// 
/// To regenerate `tile_info_repository.g.dart`, modify the `tile_info_repository.yaml` file
/// and run `[dart|flutter] pub run build_runner build`
/// 
/// The `tile_info_repository.yaml` file should have the following format:
/// ```yaml
/// tiles:
///  - id: 0
///    name: "Rock"
///    color: "#808080"
/// ```
/// 
/// The `id` is the tile id, `name` is the name of the tile, and `color` is the color of the tile in hex or rgb(r,g,b) format.
/// 
/// See Also:
/// - [TileInfo] for the tile info class
/// - [TileInfoRepository] for the tile info repository class
///
class TileInfoBuilder implements Builder {
  static final _logger = Logger("TileInfoBuilder");

  @override
  final buildExtensions = const {
    ".yaml": [".g.dart"],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;
    _logger.info("Building tile info from $inputId");

    final contents = await buildStep.readAsString(inputId);

    final yamlData = loadYaml(contents) as Map;

    final buffer = StringBuffer();

    buffer.writeln("// GENERATED CODE - DO NOT MODIFY BY HAND");
    buffer.writeln(
        "// To update, first modify the tile_info_repository.yaml file");
    buffer.writeln("// next, run `[flutter|dart] run build_runner build`");
    buffer.writeln();
    buffer
        .writeln("part of 'package:wurm_atlas/src/tile_info_repository.dart';");
    buffer.writeln();
    buffer.writeln('class _TileInfoRepository {');
    buffer.writeln('  static final Map<int, TileInfo> _defaultTileMap = {');

    for (var tile in yamlData['tiles']) {
      final id = tile['id'];
      final name = tile['name'];
      final color = tile['color'];
      buffer.writeln('    $id: TileInfo.parseColor($id, "$name", "$color"),');
    }

    buffer.writeln('  };');
    buffer.writeln('}');

    final outputId = inputId.changeExtension(".g.dart");
    await buildStep.writeAsString(outputId, buffer.toString());
  }
}

Builder tileInfoBuilder(BuilderOptions options) => TileInfoBuilder();
