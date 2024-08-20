import 'package:color/color.dart';
import 'package:test/test.dart';
import 'package:wurm_atlas/src/color_convert.dart';

void main() async {
  // ColorConvert Tests
  group('ColorConvert', () {
    test('test happy path string color from', () {
      expect(ColorConvert.from("#00ff00"), Color.hex("#00ff00"));
      expect(ColorConvert.from("#0f0"), Color.hex("#00ff00"));
      expect(ColorConvert.from("00ff00"), Color.hex("#00ff00"));
      expect(ColorConvert.from("0f0"), Color.hex("#00ff00"));
      expect(ColorConvert.from("rgb(0,255,0)"), Color.rgb(0, 255, 0));
    });
    test('test sad path string color from', () {
      expect(() => ColorConvert.from("rgb(0,255,0,0)"), throwsFormatException);
      expect(() => ColorConvert.from("rgb(0,255,0"), throwsFormatException);
      expect(() => ColorConvert.from("#badColor"), throwsFormatException);
      expect(() => ColorConvert.from("badColor"), throwsFormatException);
    });

    test('test happy path string color fromRGB', () {
      expect(ColorConvert.fromRGB("rgb(0,255,0)"), Color.rgb(0, 255, 0));
    });

    test('test sad path string color fromRGB', () {
      expect(
          () => ColorConvert.fromRGB("rgb(0,255,0,0)"), throwsFormatException);
      expect(() => ColorConvert.fromRGB("rgb(0,255,0"), throwsFormatException);
      expect(() => ColorConvert.fromRGB("badColor"), throwsFormatException);
    });

    test('test happy path string color fromHex', () {
      expect(ColorConvert.fromHex("#00ff00"), Color.hex("#00ff00"));
      expect(ColorConvert.fromHex("#0f0"), Color.hex("#00ff00"));
    });

    test('test sad path string color fromHex', () {
      expect(() => ColorConvert.fromHex("#badColor"), throwsFormatException);
      expect(() => ColorConvert.fromHex("badColor"), throwsFormatException);
    });

    test('test happy path int toInt', () {
      expect(Color.hex("#00ff00").toInt(), 0xff00ff00);
      expect(Color.hex("#ff0000").toInt(), 0xffff0000);
      expect(Color.hex("#0000ff").toInt(), 0xff0000ff);
    });
  });
}
