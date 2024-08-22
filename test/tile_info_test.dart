import 'package:test/test.dart';
import 'package:wurm_atlas/wurm_atlas.dart';
import 'package:yaml/yaml.dart';

void main() async {
  group('TileInfo tests', () {
    test('test tileinfo fromYaml', () {
      var yaml = {
        'id': 10,
        'name': 'Mycelium',
        'color': '#470233',
      };
      var tileInfo = TileInfo.fromYaml(YamlMap.wrap(yaml));
      expect(tileInfo.id, 10);
      expect(tileInfo.name, 'Mycelium');
      expect(tileInfo.color, ColorConvert.from("#470233"));
    });
    test('test tileinfo fromYaml null name', () {
      var yaml = {
        'id': 10,
        'color': '#470233',
      };
      var tileInfo = TileInfo.fromYaml(YamlMap.wrap(yaml));
      expect(tileInfo.id, 10);
      expect(tileInfo.name, '');
      expect(tileInfo.color, ColorConvert.from('#470233'));
    });
  });
}
