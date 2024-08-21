/// Wurm Atlas is a Dart library for reading and manipulating Wurm Unlimited maps.
///
/// The library is designed to be used with the Wurm Unlimited map dumps, which are
/// in a custom binary format.
///
/// The library provides the following classes:
/// - [TileInfo] for the tile info class
/// - [ColorConvert] for the color conversion class
/// - [Tile] for the tile class
/// - [TileInfoRepository] for the tile info repository class
/// - [BaseTileReader] for the tile reader class
/// - [Layer] for the layer class
/// - [LayerType] for the layer type enum
/// - [ValidationException] for the validation exception class
/// - [FileTileReader] for the file-based map tile reader
/// - [MemoryTileReader] for the memory-based map tile reader
///
library;

import 'package:wurm_atlas/src/tile_info.dart';
import 'package:wurm_atlas/src/color_convert.dart';
import 'package:wurm_atlas/src/tile.dart';
import 'package:wurm_atlas/src/tile_info_repository.dart';
import 'package:wurm_atlas/src/base_tile_reader.dart';
import 'package:wurm_atlas/src/file_tile_reader.dart';
import 'package:wurm_atlas/src/memory_tile_reader.dart';
import 'package:wurm_atlas/src/layer.dart';
import 'package:wurm_atlas/src/layer_type.dart';
import 'package:wurm_atlas/src/validation_exception.dart';

export 'src/tile_info.dart' show TileInfo;
export 'src/color_convert.dart' show ColorConvert;
export 'src/tile.dart' show Tile;
export 'src/tile_info_repository.dart' show TileInfoRepository;
export 'src/base_tile_reader.dart' show BaseTileReader;
export 'src/file_tile_reader.dart' show FileTileReader;
export 'src/memory_tile_reader.dart' show MemoryTileReader;
export 'src/layer.dart' show Layer, ProgressCallback;
export 'src/layer_type.dart' show LayerType;
export 'src/validation_exception.dart' show ValidationException;
