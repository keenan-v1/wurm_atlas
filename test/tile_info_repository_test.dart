import 'package:color/color.dart';
import 'package:test/test.dart';
import 'package:wurm_atlas/wurm_atlas.dart';

void main() async {
  group('TileInfoRepository', () {
    TileInfoRepository tileInfoRepository = TileInfoRepository();

    setUp(() {
      tileInfoRepository = TileInfoRepository();
    });

    test('test loading default tiles', () async {
      await tileInfoRepository.loadAll(clear: true);
      Color color = Color.hex("#470233");
      expect(tileInfoRepository.getTileInfo(10), isNotNull);
      expect(tileInfoRepository.getTileInfo(10)!.color, color);
      expect(tileInfoRepository.getTileInfo(10)!.name, "Mycelium");
    });

    test('test loading override tiles', () async {
      await tileInfoRepository
          .loadAll(filePaths: ["assets/test_tiles.yaml"], clear: true);
      Color color = Color.hex("#00ff00");
      expect(tileInfoRepository.getTileInfo(38), isNotNull);
      expect(tileInfoRepository.getTileInfo(38)!.color, color);
      expect(tileInfoRepository.getTileInfo(38)!.name, "Lawn");
    });

    test('test updating tile color', () async {
      await tileInfoRepository.loadAll(clear: true);
      Color color = Color.hex("#00ff00");
      tileInfoRepository.updateColor(10, color);
      expect(tileInfoRepository.getTileInfo(10)!.color, color);
    });
  });
}
