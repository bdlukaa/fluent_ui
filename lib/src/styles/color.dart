import 'package:fluent_ui/fluent_ui.dart';

/// All the fluent colors
class Colors {
  /// The transparent color. This should not be used in animations
  /// because it'll cause a weird effect.
  static const Color transparent = Color(0x00000000);

  /// A black opaque color.
  static const Color black = Color(0xFF000000);

  /// The grey color.
  ///
  /// It's a shaded color with the following available shades:
  ///   - 220
  ///   - 210
  ///   - 200
  ///   - 190
  ///   - 180
  ///   - 170
  ///   - 160
  ///   - 150
  ///   - 140
  ///   - 130
  ///   - 120
  ///   - 110
  ///   - 100
  ///   - 90
  ///   - 80
  ///   - 70
  ///   - 60
  ///   - 50
  ///   - 40
  ///   - 30
  ///   - 20
  ///   - 10
  ///
  /// To use any of these shades, call `Colors.grey[SHADE]`,
  /// where `SHADE` is the number of the sade you want
  static const ShadedColor grey = ShadedColor(
    0xFF323130, // grey160
    <int, Color>{
      220: Color(0xFF11100F),
      210: Color(0xFF161514),
      200: Color(0xFF1B1A19),
      190: Color(0xFF201F1E),
      180: Color(0xFF252423),
      170: Color(0xFF292827),
      160: Color(0xFF323130),
      150: Color(0xFF3B3A39),
      140: Color(0xFF484644),
      130: Color(0xFF605E5C),
      120: Color(0xFF797775),
      110: Color(0xFF8A8886),
      100: Color(0xFF979593),
      90: Color(0xFFA19F9D),
      80: Color(0xFFB3B0AD),
      70: Color(0xFFBEBBB8),
      60: Color(0xFFC8C6C4),
      50: Color(0xFFD2D0CE),
      40: Color(0xFFE1DFDD),
      30: Color(0xFFEDEBE9),
      20: Color(0xFFF3F2F1),
      10: Color(0xFFFAF9F8),
    },
  );

  /// A opaque white color.
  static const Color white = Color(0xFFFFFFFF);

  static final AccentColor yellow = AccentColor('normal', <String, Color>{
    'darkest': Color(0xFFfbaa00),
    'dark': Color(0xFFfabb00),
    'normal': Color(0xFFfff100),
    'light': Color(0xFFffe100),
    'lighter': Color(0xFFffff00),
  });

  static final AccentColor orange = AccentColor('normal', <String, Color>{
    'darkest': Color(0xFFda3b01),
    'dark': Color(0xFFca5010),
    'normal': Color(0xFFf7630c),
    'light': Color(0xFFff8c00),
    'lighter': Color(0xFFffb900)
  });

  static final AccentColor red = AccentColor('normal', <String, Color>{
    'darkest': Color(0xFFa4262c),
    'dark': Color(0xFFd13438),
    'normal': Color(0xFFe81123),
    'light': Color(0xFFff3434),
    'lighter': Color(0xFFef6950),
  });

  static final AccentColor magenta = AccentColor('normal', <String, Color>{
    'darkest': Color(0xFF5c005c),
    'dark': Color(0xFF9a0089),
    'normal': Color(0xFFb4009e),
    'light': Color(0xFFc239b3),
    'lighter': Color(0xFFe3008c),
  });

  static final AccentColor purple = AccentColor('normal', <String, Color>{
    'darker': Color(0xFF9a0089),
    'dark': Color(0xFF881798),
    'normal': Color(0xFF744da9),
    'light': Color(0xFF8764b8),
    'lighter': Color(0xFF6b69d6),
  });

  static final AccentColor blue = AccentColor('normal', <String, Color>{
    'darkest': Color(0xFF002050),
    'dark': Color(0xFF00188f),
    'normal': Color(0xFF004e8c),
    'light': Color(0xFF0078d4),
    'lighter': Color(0xFF00bcf2),
  });

  static final AccentColor teal = AccentColor('normal', <String, Color>{
    'darkest': Color(0xFF004b50),
    'dark': Color(0xFF008272),
    'normal': Color(0xFF00b294),
    'light': Color(0xFF00b763),
    'lighter': Color(0xFF00cc6a),
  });

  static final AccentColor green = AccentColor('normal', <String, Color>{
    'darker': Color(0xFF004b1c),
    'dark': Color(0xFF0b6a0b),
    'normal': Color(0xFF107c10),
    'light': Color(0xFF8cbd18),
    'lighter': Color(0xFFbad80a),
  });

  static const Color warningPrimaryColor = Color(0xFFd83b01);
  static const Color warningSecondaryColor = Color(0xFFfff4ce);
  static const Color errorPrimaryColor = Color(0xFFa80000);
  static const Color errorSecondaryColor = Color(0xFFfde7e9);
  static const Color successPrimaryColor = Color(0xFF107c10);
  static const Color successSecondaryColor = Color(0xFFdff6dd);

  static final List<AccentColor> accentColors = [
    yellow,
    orange,
    red,
    magenta,
    purple,
    blue,
    teal,
    green,
  ];
}

class ShadedColor extends ColorSwatch<int> {
  const ShadedColor(int primary, Map<int, Color> swatch)
      : super(primary, swatch);
}

class AccentColor extends ColorSwatch<String> {
  /// The default shade for this color. This can't be null
  final String primary;

  /// The avaiable shades for this color. This can't be null nor empty
  final Map<String, Color> swatch;

  /// Create a new accent color.
  AccentColor(this.primary, this.swatch)
      : super(swatch[primary]!.value, swatch);

  /// The darkest shade of the color.
  /// 
  /// Usually used for shadows
  Color get darkest => swatch['darkest'] ?? dark;

  /// The dark shade of the color.
  /// 
  /// Usually used for the mouse press effect;
  Color get dark => swatch['dark'] ?? normal;

  /// The default shade of the color.
  Color get normal => swatch['normal']!;

  /// The light shade of the color.
  /// 
  /// Usually used for the mouse hover effect
  Color get light => swatch['light'] ?? normal;

  /// The lighter shade of the color.
  /// 
  /// Usually used for shadows
  Color get lighter => swatch['lighter'] ?? light;
}
