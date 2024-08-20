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
/// - [TileReader] for the tile reader class
/// - [Layer] for the layer class
/// - [LayerType] for the layer type enum
/// - [ValidationException] for the validation exception class
/// 
library;

import 'package:wurm_atlas/src/tile_info.dart';
import 'package:wurm_atlas/src/color_convert.dart';
import 'package:wurm_atlas/src/tile.dart';
import 'package:wurm_atlas/src/tile_info_repository.dart';
import 'package:wurm_atlas/src/tile_reader.dart';
import 'package:wurm_atlas/src/layer.dart';
import 'package:wurm_atlas/src/layer_type.dart';
import 'package:wurm_atlas/src/validation_exception.dart';

export 'src/tile_info.dart';
export 'src/color_convert.dart';
export 'src/tile.dart';
export 'src/tile_info_repository.dart';
export 'src/tile_reader.dart';
export 'src/layer.dart';
export 'src/layer_type.dart';
export 'src/validation_exception.dart';
