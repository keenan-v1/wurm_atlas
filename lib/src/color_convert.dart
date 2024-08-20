import 'package:color/color.dart';

/// Extension methods for converting colors from various formats.
/// 
/// This extension adds methods to the [Color] class.
/// 
extension ColorConvert on Color {
  /// Creates a color from [colorString].
  /// 
  /// Throws [FormatException] if the string is not a supported color string.
  /// Supported formats are:
  /// - RGB string: "rgb(0,255,0)"
  /// - Hex string: "#00ff00", "00ff00", "#0f0", "0f0"
  /// 
  /// ```dart
  /// ColorConvert.from("rgb(0,255,0)") == Color.rgb(0, 255, 0)
  /// ColorConvert.from("#00ff00") == Color.hex("#00ff00")
  /// ```
  static Color from(String colorString) {
    if (colorString.startsWith('rgb')) {
      return fromRGB(colorString);
    } else if (colorString.startsWith('#') ||
        colorString.length == 3 ||
        colorString.length == 6) {
      return fromHex(colorString);
    } else {
      throw FormatException('Invalid color string: $colorString');
    }
  }

  /// Creates a color from an RGB string provided by [rgbString].
  /// 
  /// Throws [FormatException] if the string is not a valid RGB string.
  /// 
  /// ```dart
  /// ColorConvert.fromRGB("rgb(0,255,0)") == Color.rgb(0, 255, 0)
  /// ```
  static Color fromRGB(String rgbString) {
    final regex = RegExp(r'rgb\((\d+),(\d+),(\d+)\)');
    final match = regex.firstMatch(rgbString);
    if (match != null) {
      final red = int.parse(match.group(1)!);
      final green = int.parse(match.group(2)!);
      final blue = int.parse(match.group(3)!);
      return Color.rgb(red, green, blue);
    }
    throw FormatException('Invalid RGB string: $rgbString');
  }

  /// Creates a color from a hex string provided by [hexString].
  /// 
  /// Throws [FormatException] if the string is not a valid hex string.
  /// 
  /// ```dart
  /// ColorConvert.fromHex("#00ff00") == Color.hex("#00ff00")
  /// ```
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    hexString = hexString.toUpperCase().replaceAll('#', '');
    if (hexString.length == 3) hexString = _convert3To6(hexString);
    buffer.write(hexString);
    return Color.hex(buffer.toString());
  }

  static String _convert3To6(String hex) {
    if (hex.length == 3) {
      return hex[0] + hex[0] + hex[1] + hex[1] + hex[2] + hex[2];
    }
    return hex;
  }

  /// Converts a color to an integer.
  /// 
  /// The integer is in the format 0xAARRGGBB.
  /// 
  /// ```dart
  /// Color.hex("#00ff00").toInt() == 0xff00ff00
  /// ```
  int toInt() {
    final red = (toRgbColor().r).toInt();
    final green = (toRgbColor().g).toInt();
    final blue = (toRgbColor().b).toInt();
    return (255 << 24) | (red << 16) | (green << 8) | blue;
  }
}
