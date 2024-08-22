import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:wurm_atlas/src/utils/test_utils.dart';
import 'package:wurm_atlas/wurm_atlas.dart';

void main() async {
  TestUtils.enableLogging(Level.SEVERE);
  Tile emptyTile = Tile(
    -1,
    -1,
    0,
    TileInfo(-1, 'Unknown', ColorConvert.from("#000")),
  );

  group('Layer sync:', () {
    Layer? layer;

    tearDown(() {
      layer?.closeSync();
    });

    test('test validateSync on valid map file', () {
      layer = Layer.file(LayerType.top, "assets/happy_map");
      layer?.openSync();
      expect(layer?.validateSync(), true);
    });

    test('test validateSync throwing an exception on a bad magic number', () {
      layer = Layer.file(LayerType.top, "assets/bad_magic_number_map");
      layer?.openSync();
      expect(() {
        layer?.validateSync();
      },
          throwsA(predicate((e) =>
              e is ValidationException &&
              e.message.contains("Magic number mismatch"))));
    });

    test('test validateSync throwing an exception on a bad version', () {
      layer = Layer.file(LayerType.top, "assets/bad_version_map");
      layer?.openSync();
      expect(
          () => layer?.validateSync(),
          throwsA(predicate((e) =>
              e is ValidationException &&
              e.message.contains("Version mismatch"))));
    });

    test('test tilesSync', () {
      layer = Layer.file(LayerType.top, "assets/happy_map");
      layer?.openSync();
      var tiles = layer?.tilesSync(0, 0, 1, 1) ?? [];
      expect(tiles.length, 1);
      expect(tiles[0].x, 0);
      expect(tiles[0].y, 0);
      expect(tiles[0].info.name, 'Rock');
    });

    test('test tilesSync with multiple tiles', () {
      layer = Layer.file(LayerType.top, "assets/happy_map");
      layer?.openSync();
      var tiles = layer?.tilesSync(0, 0, 2, 2) ?? [];
      expect(tiles.length, 4);
      expect(tiles[0].x, 0);
      expect(tiles[0].y, 0);
      expect(tiles[0].info.name, 'Rock');
      expect(tiles[1].x, 1);
      expect(tiles[1].y, 0);
      expect(tiles[1].info.name, 'Rock');
      expect(tiles[2].x, 0);
      expect(tiles[2].y, 1);
      expect(tiles[2].info.name, 'Rock');
      expect(tiles[3].x, 1);
      expect(tiles[3].y, 1);
      expect(tiles[3].info.name, 'Dirt');
    });

    test('test tilesSync with a bad magic number', () {
      layer = Layer.file(LayerType.top, "assets/bad_magic_number_map");
      layer?.openSync();
      expect(
          () => layer?.tilesSync(0, 0, 1, 1),
          throwsA(predicate((e) =>
              e is ValidationException &&
              e.message.contains("Magic number mismatch"))));
    });

    test('test tilesSync with a bad version', () {
      layer = Layer.file(LayerType.top, "assets/bad_version_map");
      layer?.openSync();
      expect(
          () => layer?.tilesSync(0, 0, 1, 1),
          throwsA(predicate((e) =>
              e is ValidationException &&
              e.message.contains("Version mismatch"))));
    });

    test('test tileSync', () {
      layer = Layer.file(LayerType.top, "assets/happy_map");
      layer?.openSync();
      var tile = layer?.tileSync(0, 0) ?? emptyTile;
      expect(tile.x, 0);
      expect(tile.y, 0);
      expect(tile.info.name, 'Rock');
    });

    test('test imageSync', () {
      layer = Layer.file(LayerType.top, "assets/happy_map");
      layer?.openSync();
      var image = layer?.imageSync(0, 0, 256, 256);
      expect(image, isNotNull);
      expect(image, isA<ByteBuffer>());
      var tile = layer?.tileSync(0, 0) ?? emptyTile;
      // The image is in BGRA format
      var blue = image!.asUint8List(0, 1)[0];
      var green = image.asUint8List(1, 1)[0];
      var red = image.asUint8List(2, 1)[0];
      var alpha = image.asUint8List(3, 1)[0];
      expect(red, tile.color().toRgbColor().r);
      expect(green, tile.color().toRgbColor().g);
      expect(blue, tile.color().toRgbColor().b);
      expect(alpha, 255);
    });
  });

  group('Layer async:', () {
    Layer? layer;

    tearDown(() async {
      await layer?.close();
    });

    test('test validate on valid map file', () async {
      layer = Layer.file(LayerType.top, "assets/happy_map");
      await layer?.open();
      expect(await layer?.validate(), true);
    });

    test('test validate throwing an exception on a bad magic number', () async {
      layer = Layer.file(LayerType.top, "assets/bad_magic_number_map");
      await layer?.open();
      expect(
          () => layer?.validate(),
          throwsA(predicate((e) =>
              e is ValidationException &&
              e.message.contains("Magic number mismatch"))));
    });

    test('test validate throwing an exception on a bad version', () async {
      layer = Layer.file(LayerType.top, "assets/bad_version_map");
      await layer?.open();
      expect(
          () => layer?.validate(),
          throwsA(predicate((e) =>
              e is ValidationException &&
              e.message.contains("Version mismatch"))));
    });

    test('test tiles', () async {
      layer = Layer.file(LayerType.top, "assets/happy_map");
      await layer?.open();
      await layer?.tiles(0, 0, 1, 1).forEach((tile) {
        expect(tile.x, 0);
        expect(tile.y, 0);
        expect(tile.info.name, 'Rock');
      });
    });

    test('test tiles with multiple tiles', () async {
      layer = Layer.file(LayerType.top, "assets/happy_map");
      await layer?.open();
      var tileStream = layer?.tiles(0, 0, 2, 2);
      var count = 0;
      await tileStream?.forEach((tile) {
        count++;
        expect(tile, isNotNull);
      });
      expect(count, 4);
    });

    test('test tiles outside of bounds', () async {
      layer = Layer.file(LayerType.top, "assets/happy_map");
      await layer?.open();
      expect(() => layer?.tiles(256, 256, 1, 1).first, throwsException);
    });

    test('test tile', () async {
      layer = Layer.file(LayerType.top, "assets/happy_map");
      await layer?.open();
      var tile = await layer?.tile(0, 0) ?? emptyTile;
      expect(tile.x, 0);
      expect(tile.y, 0);
      expect(tile.info.name, 'Rock');
    });

    test('test tile outside of bounds', () async {
      layer = Layer.file(LayerType.top, "assets/happy_map");
      await layer?.open();
      expect(() => layer?.tile(256, 256), throwsException);
    });

    test('test image', () async {
      layer = Layer.file(LayerType.top, "assets/happy_map");
      await layer?.open();
      var image = await layer?.image(0, 0, 256, 256);
      expect(image, isNotNull);
      expect(image, isA<ByteBuffer>());
      var tile = await layer?.tile(0, 0) ?? emptyTile;
      // The image is in BGRA format
      var blue = image!.asUint8List(0, 1)[0];
      var green = image.asUint8List(1, 1)[0];
      var red = image.asUint8List(2, 1)[0];
      var alpha = image.asUint8List(3, 1)[0];
      expect(red, tile.color().toRgbColor().r);
      expect(green, tile.color().toRgbColor().g);
      expect(blue, tile.color().toRgbColor().b);
      expect(alpha, 255);
    });
  });

  // Only need to test the sync methods here, since the async methods
  // for in-memory layers are just wrappers around the sync methods
  group('Layer from memory', () {
    Layer layer = Layer.memory(LayerType.top,
        File("assets/happy_map/top_layer.map").readAsBytesSync());
    test('test validateSync on a valid in-memory map file', () {
      expect(layer.validateSync(), true);
    });

    test('test validateSync throwing an exception on a bad magic number', () {
      Layer layer = Layer.memory(LayerType.top,
          File("assets/bad_magic_number_map/top_layer.map").readAsBytesSync());
      expect(
          () => layer.validateSync(),
          throwsA(predicate((e) =>
              e is ValidationException &&
              e.message.contains("Magic number mismatch"))));
    });

    test('test validateSync throwing an exception on a bad version', () {
      Layer layer = Layer.memory(LayerType.top,
          File("assets/bad_version_map/top_layer.map").readAsBytesSync());
      expect(
          () => layer.validateSync(),
          throwsA(predicate((e) =>
              e is ValidationException &&
              e.message.contains("Version mismatch"))));
    });

    test('test tilesSync on a valid in-memory map file', () {
      var tiles = layer.tilesSync(0, 0, 1, 1);
      expect(tiles.length, 1);
      expect(tiles[0].x, 0);
      expect(tiles[0].y, 0);
      expect(tiles[0].info.name, 'Rock');
    });

    test('test tilesSync with multiple tiles on a valid in-memory map file',
        () {
      var tiles = layer.tilesSync(0, 0, 2, 2);
      expect(tiles.length, 4);
      expect(tiles[0].x, 0);
      expect(tiles[0].y, 0);
      expect(tiles[0].info.name, 'Rock');
      expect(tiles[1].x, 1);
      expect(tiles[1].y, 0);
      expect(tiles[1].info.name, 'Rock');
      expect(tiles[2].x, 0);
      expect(tiles[2].y, 1);
      expect(tiles[2].info.name, 'Rock');
      expect(tiles[3].x, 1);
      expect(tiles[3].y, 1);
      expect(tiles[3].info.name, 'Dirt');
    });

    test('test tilesSync with a bad magic number on an in-memory map file', () {
      Layer layer = Layer.memory(LayerType.top,
          File("assets/bad_magic_number_map/top_layer.map").readAsBytesSync());
      expect(
          () => layer.tilesSync(0, 0, 1, 1),
          throwsA(predicate((e) =>
              e is ValidationException &&
              e.message.contains("Magic number mismatch"))));
    });

    test('test tilesSync with a bad version on an in-memory map file', () {
      Layer layer = Layer.memory(LayerType.top,
          File("assets/bad_version_map/top_layer.map").readAsBytesSync());
      expect(
          () => layer.tilesSync(0, 0, 1, 1),
          throwsA(predicate((e) =>
              e is ValidationException &&
              e.message.contains("Version mismatch"))));
    });

    test('test tileSync on a valid in-memory map file', () {
      var tile = layer.tileSync(0, 0);
      expect(tile.x, 0);
      expect(tile.y, 0);
      expect(tile.info.name, 'Rock');
    });

    test('test imageSync on a valid in-memory map file', () {
      var image = layer.imageSync(0, 0, 256, 256);
      expect(image, isNotNull);
      expect(image, isA<ByteBuffer>());
      var tile = layer.tileSync(0, 0);
      // The image is in BGRA format
      var blue = image.asUint8List(0, 1)[0];
      var green = image.asUint8List(1, 1)[0];
      var red = image.asUint8List(2, 1)[0];
      var alpha = image.asUint8List(3, 1)[0];
      expect(red, tile.color().toRgbColor().r);
      expect(green, tile.color().toRgbColor().g);
      expect(blue, tile.color().toRgbColor().b);
      expect(alpha, 255);
    });
  });
}
