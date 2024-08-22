import 'dart:io';

import 'package:test/test.dart';
import 'package:wurm_atlas/wurm_atlas.dart';

void main() async {
  group('MemoryTileReader: ', () {
    MemoryTileReader tileReader = MemoryTileReader(
        File("assets/happy_map/top_layer.map").readAsBytesSync());

    test('test getters', () {
      expect(tileReader.size, 256);
      expect(tileReader.version, LayerType.top.version);
      expect(tileReader.magicNumber, BigInt.parse("0x474A2198B2781B9D"));
    });

    test('test reading a tile', () {
      Tile tile = tileReader.readTileSync(0, 0);
      expect(tile, isNotNull);
      expect(tile.x, 0);
      expect(tile.y, 0);
      expect(tile.info.name, 'Rock');
    });

    test('test reading a tile outside of bounds', () {
      expect(() => tileReader.readTileSync(256, 256), throwsException);
    });

    test('test reading tile rows', () {
      List<Tile> tiles = tileReader.readTileRowSync(0, width: 2);
      expect(tiles.length, 2);
      expect(tiles[0].x, 0);
      expect(tiles[0].y, 0);
      expect(tiles[0].info.name, 'Rock');
      expect(tiles[1].x, 1);
      expect(tiles[1].y, 0);
      expect(tiles[1].info.name, 'Rock');
    });

    test('test reading tile rows outside of bounds', () {
      expect(() => tileReader.readTileRowSync(256), throwsException);
    });
  });

  group('MemoryTileReader async:', () {
    MemoryTileReader tileReader = MemoryTileReader(
        File("assets/happy_map/top_layer.map").readAsBytesSync());

    test('test reading a tile', () async {
      Tile tile = await tileReader.readTile(0, 0);
      expect(tile, isNotNull);
      expect(tile.x, 0);
      expect(tile.y, 0);
      expect(tile.info.name, 'Rock');
    });

    test('test reading a tile outside of bounds', () async {
      expect(() => tileReader.readTile(256, 256), throwsException);
    });

    test('test reading tile rows', () async {
      List<Tile> tiles = await tileReader.readTileRow(0, width: 2).toList();
      expect(tiles.length, 2);
      expect(tiles[0].x, 0);
      expect(tiles[0].y, 0);
      expect(tiles[0].info.name, 'Rock');
      expect(tiles[1].x, 1);
      expect(tiles[1].y, 0);
      expect(tiles[1].info.name, 'Rock');
    });

    test('test reading tile rows outside of bounds', () async {
      expect(() => tileReader.readTileRow(256).toList(), throwsException);
    });
  });
}
