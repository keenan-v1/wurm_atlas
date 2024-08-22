import 'package:image/image.dart';
import 'package:test/test.dart';
import 'package:wurm_atlas/src/color_convert.dart';

void main() async {
  // ColorConvert Tests
  group('ColorConvert', () {
    test('test happy path string color from', () {
      var expected = ColorUint8.rgb(0, 255, 0);
      expect(ColorConvert.from("#00ff00"), expected);
      expect(ColorConvert.from("#0f0"), expected);
      expect(ColorConvert.from("00ff00"), expected);
      expect(ColorConvert.from("0f0"), expected);
      expect(ColorConvert.from("rgb(0,255,0)"), expected);
    });
    test('test sad path string color from', () {
      expect(() => ColorConvert.from("rgb(0,255,0,0)"), throwsFormatException);
      expect(() => ColorConvert.from("rgb(0,255,0"), throwsFormatException);
      expect(() => ColorConvert.from("#badColor"), throwsFormatException);
      expect(() => ColorConvert.from("badColor"), throwsFormatException);
    });

    test('test happy path string color fromRGB', () {
      expect(ColorConvert.fromRGB("rgb(0,255,0)"), ColorUint8.rgb(0, 255, 0));
    });

    test('test sad path string color fromRGB', () {
      expect(
          () => ColorConvert.fromRGB("rgb(0,255,0,0)"), throwsFormatException);
      expect(() => ColorConvert.fromRGB("rgb(0,255,0"), throwsFormatException);
      expect(() => ColorConvert.fromRGB("badColor"), throwsFormatException);
    });

    test('test happy path string color fromHex', () {
      var expected = ColorUint8.rgb(0, 255, 0);
      expect(ColorConvert.fromHex("#00ff00"), expected);
      expect(ColorConvert.fromHex("#0f0"), expected);
    });

    test('test sad path string color fromHex', () {
      expect(() => ColorConvert.fromHex("#badColor"), throwsFormatException);
      expect(() => ColorConvert.fromHex("badColor"), throwsFormatException);
    });
  });
}
