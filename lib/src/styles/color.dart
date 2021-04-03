import 'package:fluent_ui/fluent_ui.dart';

class Colors {
  static const Color transparent = Color(0x00000000);
  static const Color black = Color(0xFF000000);
  static const ShadedColor grey = ShadedColor(
    0xFF323130, // grey160
    <int, Color>{
      220: Color(0xFF11100F),
      210: Color(0xFF161514),
      200: Color(0XFF1B1A19),
      190: Color(0XFF201F1E),
      180: Color(0XFF252423),
      170: Color(0XFF292827),
      160: Color(0XFF323130),
      150: Color(0XFF3B3A39),
      140: Color(0XFF484644),
      130: Color(0XFF605E5C),
      120: Color(0XFF797775),
      110: Color(0XFF8A8886),
      100: Color(0XFF979593),
      90: Color(0XFFA19F9D),
      80: Color(0XFFB3B0AD),
      70: Color(0XFFBEBBB8),
      60: Color(0XFFC8C6C4),
      50: Color(0XFFD2D0CE),
      40: Color(0XFFE1DFDD),
      30: Color(0XFFEDEBE9),
      20: Color(0XFFF3F2F1),
      10: Color(0XFFFAF9F8),
    },
  );
  static const Color white = Color(0XFFFFFFFF);

  static final AccentColor yellow = AccentColor('normal', <String, Color>{
    'dark': Color(0XFFd29200),
    'normal': Color(0XFFffb900),
    'light': Color(0XFFfff100),
  });

  static final AccentColor orange = AccentColor('normal', <String, Color>{
    'normal': Color(0XFFd83b01),
    'light': Color(0XFFea4300),
    'lighter': Color(0XFFff8c00),
  });

  static final AccentColor red = AccentColor('normal', <String, Color>{
    'darkest': Color(0XFF750b1c),
    'dark': Color(0XFFa4262c),
    'normal': Color(0XFFd13438),
  });

  static final AccentColor magenta = AccentColor('normal', <String, Color>{
    'dark': Color(0XFF5c995c), // magenta dark
    'normal': Color(0XFFb4009e), // magenta
    'light': Color(0XFFe3008c), // magenta light
  });

  // Magenta is purple :)
  static final AccentColor purple = AccentColor('normal', <String, Color>{
    'dark': Color(0XFF32145a), // purple dark
    'normal': Color(0XFF5c2d91), // purple
    'light': Color(0XFFb4a0ff), // purple light
  });

  static final ShadedColor blue = ShadedColor(
    0xFF0078d4, // primary
    <int, Color>{
      90: Color(0xFF004578), // darker
      80: Color(0xFF005a9e), // dark
      70: Color(0xFF106ebe), // dark alt
      60: Color(0xFF0078d4), // primary
      50: Color(0xFF2b88d8), // secondary
      40: Color(0xFF71afe5), // tertiary
      30: Color(0xFFc7e0f4), // light
      20: Color(0xFFdeecf9), // lighter
      10: Color(0xFFeff6fc), // lighter alt
    },
  );

  static final AccentColor teal = AccentColor('normal', <String, Color>{
    'dark': Color(0XFF004b50),
    'normal': Color(0XFF008272),
    'light': Color(0XFF00b294),
  });

  static final AccentColor green = AccentColor('normal', <String, Color>{
    'dark': Color(0XFF004b1c),
    'normal': Color(0XFF107c10),
    'light': Color(0XFFbad80a),
  });

  static final List<ShadedColor> accentColors = [
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

class AccentColor extends ShadedColor {
  /// The default shade for this color. This can't be null
  final String primary;

  /// The avaiable shades for this color. This can't be null nor empty
  final Map<String, Color> swatch;

  AccentColor(this.primary, this.swatch)
      : super(swatch[primary]!.value, swatch.convertStringtoInt());

  /// The darkest shade of the color. This can be not avaiable in some colors
  Color get darkest => swatch['darkest'] ?? dark;

  /// The dark shade of the color. This can be not avaiable in some colors
  Color get dark => swatch['dark'] ?? normal;

  /// The default shade of the color. This is avaiable for all supported colors
  Color get normal => swatch['normal']!;

  /// The light shade of the color. This can be not avaiable in some colors
  Color get light => swatch['light'] ?? normal;

  /// The lighter shade of the color. This can be not avaiable in some colors
  Color get lighter => swatch['lighter'] ?? light;
}

extension _sToInt on Map<String, Color> {
  /// Convert a Map<String, Color> to a Map<int, Color>
  Map<int, Color> convertStringtoInt() {
    Map<int, Color> map = {};
    int currentValue = 10;
    this.forEach((key, value) {
      map.addAll({currentValue: value});
      currentValue += 10;
    });
    return map;
  }
}
