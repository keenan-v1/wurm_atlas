import 'dart:io';

import 'package:args/args.dart';
import 'package:wurm_atlas/wurm_atlas.dart';
import 'package:image/image.dart' as img;

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addOption(
      'map',
      abbr: 'm',
      help: 'Path to the map folder to dump.',
      valueHelp: 'path',
    )
    ..addOption(
      'layer',
      abbr: 'l',
      help: 'Layer type to dump.',
      valueHelp: 'type',
      defaultsTo: 'top',
      allowed: [LayerType.top.name, LayerType.cave.name],
    )
    ..addFlag(
      'water',
      abbr: 'w',
      help: 'Show water tiles.',
      negatable: true,
      defaultsTo: true,
    )
    ..addOption(
      'output',
      abbr: 'o',
      help: 'Output file name.',
      valueHelp: 'filename',
      defaultsTo: 'output.png',
    );
}

void printUsage(ArgParser argParser) {
  print('Usage: dart dart_example.dart <flags> [arguments]');
  print(argParser.usage);
}

void dumpMap(LayerType layerType, String mapPath, String outputFileName,
    bool showWater) {
  print('Dumping ${layerType.name} map $mapPath to $outputFileName');
  var layer = Layer.file(layerType, mapPath)
    ..openSync()
    ..validateSync();
  print("Map size: ${layer.size}");
  var s = layer.size;
  var image = img.Image.fromBytes(
      width: s,
      height: s,
      bytes: layer.imageSync(0, 0, s, s, showWater: showWater),
      numChannels: 4,
      order: img.ChannelOrder.bgra);
  var bytes = img.encodePng(image);
  File(outputFileName).writeAsBytesSync(bytes);
  print("Image written to $outputFileName");
  layer.closeSync();
}

void main(List<String> arguments) {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);

    // Process the parsed arguments.
    if (results.wasParsed('help')) {
      printUsage(argParser);
      return;
    }
    if (results.option('map') == null) {
      throw FormatException('The --map option is required.');
    }
    var mapPath = results.option('map')!;
    var outputFileName = results.option('output')!;
    var showWater = results['water'];
    var layerType = LayerType.values.firstWhere(
        (e) => e.toString().split('.').last == results.option('layer'));
    dumpMap(layerType, mapPath, outputFileName, showWater);
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(argParser);
  }
}
