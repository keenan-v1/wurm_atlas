import 'package:test/test.dart';
import 'package:wurm_atlas/wurm_atlas.dart';

void main() async {
  group('TileReader synchronous: ', () {
    TileReader tileReader = TileReader();

    setUp(() {
      tileReader = TileReader();
    });

    test('test opening an existing map', () {
      tileReader.openSync("assets/happy_map/top_layer.map");
      expect(tileReader.size, 256);
      expect(tileReader.version, LayerType.top.version);
      expect(tileReader.magicNumber, LayerType.top.magicNumber);
    });

    test('test accessing properties of unopened file', () {
      expect(() => tileReader.size, throwsException);
      expect(() => tileReader.version, throwsException);
      expect(() => tileReader.magicNumber, throwsException);
    });

    test('test closing an opened file', () {
      tileReader.openSync("assets/happy_map/top_layer.map");
      tileReader.closeSync();
      expect(() => tileReader.size, throwsException);
      expect(() => tileReader.version, throwsException);
      expect(() => tileReader.magicNumber, throwsException);
    });

    test('test opening a non-existing map', () {
      expect(() => tileReader.openSync("assets/happy_map/does_not_exist.map"),
          throwsException);
    });

    test('test reading a tile', () {
      tileReader.openSync("assets/happy_map/top_layer.map");
      Tile tile = tileReader.readTileSync(0, 0);
      expect(tile, isNotNull);
      expect(tile.x, 0);
      expect(tile.y, 0);
      expect(tile.info.name, 'Rock');
    });

    test('test reading a tile outside of bounds', () {
      tileReader.openSync("assets/happy_map/top_layer.map");
      expect(() => tileReader.readTileSync(256, 256), throwsException);
    });

    test('test reading a tile from an unopened file', () {
      expect(() => tileReader.readTileSync(0, 0), throwsException);
    });

    test('test reading tile rows', () {
      tileReader.openSync("assets/happy_map/top_layer.map");
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
      tileReader.openSync("assets/happy_map/top_layer.map");
      expect(() => tileReader.readTileRowSync(256), throwsException);
    });
  });

  group('TileReader async:', () {
    TileReader tileReader = TileReader();

    setUp(() {
      tileReader = TileReader();
    });

    test('test opening an existing map', () async {
      await tileReader.open("assets/happy_map/top_layer.map");
      expect(tileReader.size, 256);
      expect(tileReader.version, LayerType.top.version);
      expect(tileReader.magicNumber, LayerType.top.magicNumber);
    });

    test('test accessing properties of unopened file', () async {
      expect(() => tileReader.size, throwsException);
      expect(() => tileReader.version, throwsException);
      expect(() => tileReader.magicNumber, throwsException);
    });

    test('test closing an opened file', () async {
      await tileReader.open("assets/happy_map/top_layer.map");
      await tileReader.close();
      expect(() => tileReader.size, throwsException);
      expect(() => tileReader.version, throwsException);
      expect(() => tileReader.magicNumber, throwsException);
    });

    test('test opening a non-existing map', () async {
      expect(() => tileReader.open("assets/happy_map/does_not_exist.map"),
          throwsException);
    });

    test('test reading a tile', () async {
      await tileReader.open("assets/happy_map/top_layer.map");
      Tile tile = await tileReader.readTile(0, 0);
      expect(tile, isNotNull);
      expect(tile.x, 0);
      expect(tile.y, 0);
      expect(tile.info.name, 'Rock');
    });

    test('test reading a tile outside of bounds', () async {
      await tileReader.open("assets/happy_map/top_layer.map");
      expect(() => tileReader.readTile(256, 256), throwsException);
    });

    test('test reading a tile from an unopened file', () async {
      expect(() => tileReader.readTile(0, 0), throwsException);
    });

    test('test reading tile rows', ()  async {
      await tileReader.open("assets/happy_map/top_layer.map");
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
      tileReader.openSync("assets/happy_map/top_layer.map");
      expect(() => tileReader.readTileRow(256).toList(), throwsException);
    });
  });
}
