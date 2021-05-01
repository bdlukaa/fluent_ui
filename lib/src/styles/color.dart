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
  /// where `SHADE` is the number of the shade you want
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
    'darkest': Color(0xfff9a825),
    'darker': Color(0xfffbc02d),
    'dark': Color(0xfffdd835),
    'normal': Color(0xffffeb3b),
    'light': Color(0xffffee58),
    'lighter': Color(0xfffff176),
    'lightest': Color(0xfffff59d),
  });

  static final AccentColor orange = AccentColor('normal', <String, Color>{
    'darkest': Color(0xff993d07),
    'darker': Color(0xffac4508),
    'dark': Color(0xffd1540a),
    'normal': Color(0xfff7630c),
    'light': Color(0xfff87a30),
    'lighter': Color(0xfff99154),
    'lightest': Color(0xfffa9e68),
  });

  static final AccentColor red = AccentColor('normal', <String, Color>{
    'darkest': Color(0xff8f0a15),
    'darker': Color(0xffa20b18),
    'dark': Color(0xffb90d1c),
    'normal': Color(0xffe81123),
    'light': Color(0xffec404f),
    'lighter': Color(0xffee5865),
    'lightest': Color(0xfff06b76),
  });

  static final AccentColor magenta = AccentColor('normal', <String, Color>{
    'darkest': Color(0xff6f0061),
    'darker': Color(0xff7e006e),
    'dark': Color(0xff90007e),
    'normal': Color(0xffb4009e),
    'light': Color(0xffc333b1),
    'lighter': Color(0xffca4cbb),
    'lightest': Color(0xffd060c2),
  });

  static final AccentColor purple = AccentColor('normal', <String, Color>{
    'darkest': Color(0xff472f68),
    'darker': Color(0xff513576),
    'dark': Color(0xff644293),
    'normal': Color(0xFF744da9),
    'light': Color(0xff8664b4),
    'lighter': Color(0xff9d82c2),
    'lightest': Color(0xffa890c9),
  });

  static final AccentColor blue = AccentColor('normal', <String, Color>{
    'darkest': Color(0xff004a83),
    'darker': Color(0xff005494),
    'dark': Color(0xff0066b4),
    'normal': Color(0xff0078d4),
    'light': Color(0xff268cda),
    'lighter': Color(0xff4ca0e0),
    'lightest': Color(0xff60abe4),
  });

  static final AccentColor teal = AccentColor('normal', <String, Color>{
    'darkest': Color(0xff006e5b),
    'darker': Color(0xff007c67),
    'dark': Color(0xff00977d),
    'normal': Color(0xff00b294),
    'light': Color(0xff26bda4),
    'lighter': Color(0xff4cc9b4),
    'lightest': Color(0xff60cfbc),
  });

  static final AccentColor green = AccentColor('normal', <String, Color>{
    'darkest': Color(0xff094c09),
    'darker': Color(0xff0c5d0c),
    'dark': Color(0xff0e6f0e),
    'normal': Color(0xff107c10),
    'light': Color(0xff278927),
    'lighter': Color(0xff4b9c4b),
    'lightest': Color(0xff6aad6a),
  });

  static const Color warningPrimaryColor = Color(0xFFd83b01);
  static const Color warningSecondaryColor = Color(0xFFfff4ce);
  static const Color errorPrimaryColor = Color(0xFFa80000);
  static const Color errorSecondaryColor = Color(0xFFfde7e9);
  static const Color successPrimaryColor = Color(0xFF107c10);
  static const Color successSecondaryColor = Color(0xFFdff6dd);

  /// A list of all the accent colors provided by this library.
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

/// An accent color is a color that can have multiple shades. It's
/// similar to [ShadedColor] and [ColorSwatch], but it has helper
/// methods to help you access the shade you want easily. These
/// shades may not be accessible on every accent color.
///
/// This library already provides some accent colors by default:
///
/// - [Colors.yellow]
/// - [Colors.orange]
/// - [Colors.red]
/// - [Colors.magenta]
/// - [Colors.purple]
/// - [Colors.blue]
/// - [Colors.teal]
/// - [Colors.green]
///
/// Use [Colors.accentColors] to get all the accent colors provided
/// by default.
class AccentColor extends ColorSwatch<String> {
  /// The default shade for this color. This can't be null
  final String primary;

  /// The avaiable shades for this color. This can't be null nor empty
  final Map<String, Color> swatch;

  /// Create a new accent color.
  AccentColor(this.primary, this.swatch)
      : super(swatch[primary]!.value, swatch);

  /// The darkest shade of the color.
  Color get darkest => swatch['darkest'] ?? darker;

  /// The darker shade of the color.
  ///
  /// Usually used for shadows
  Color get darker => swatch['darker'] ?? dark;

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

  /// The lighest shade of the color
  Color get lightest => swatch['lightest'] ?? lighter;

  static Color resolve(Color resolvable, BuildContext context) {
    return (resolvable is AccentColor)
        ? resolvable.resolveFrom(context)
        : resolvable;
  }

  Color resolveFrom(BuildContext context, [Brightness? bright]) {
    final ThemeData? theme = FluentTheme.maybeOf(context);
    final brightness = bright ?? theme?.brightness ?? Brightness.light;
    return resolveFromBrightness(brightness);
  }

  Color resolveFromBrightness(Brightness brightness) {
    switch (brightness) {
      case Brightness.light:
        return light;
      case Brightness.dark:
        return dark;
    }
  }
}

/// Extension methods to help dealing with colors.
extension colorExtension on Color {
  /// Creates a new accent color based on this color. This provides
  /// the shades by lerping this color with [Colors.black] if dark
  /// or darker, and with [Colors.white] if light or lighter.
  ///
  /// See also:
  ///   - [Color.lerp]
  ///   - [lerpWith]
  ///   - [Colors.black]
  ///   - [Color.white]
  AccentColor toAccentColor({
    double darkestFactor = 0.38,
    double darkerFactor = 0.30,
    double darkFactor = 0.15,
    double lightFactor = 0.15,
    double lighterFactor = 0.30,
    double lightestFactor = 0.38,
  }) {
    // if (this is AccentColor) {
    //   return this as AccentColor;
    // }
    return AccentColor('normal', {
      'darkest': lerpWith(Colors.black, darkestFactor),
      'darker': lerpWith(Colors.black, darkerFactor),
      'dark': lerpWith(Colors.black, darkFactor),
      'normal': this,
      'light': lerpWith(Colors.white, lightFactor),
      'lighter': lerpWith(Colors.white, lighterFactor),
      'lightest': lerpWith(Colors.white, lightestFactor),
    });
  }

  /// Get a constrast color based on the luminance of this color. If
  /// the luminance is bigger than 0.5, [darkColor] is used, otherwise
  /// [lightColor] is used.
  ///
  /// This is usually used to constrast text colors with the background.
  Color basedOnLuminance({
    Color darkColor = Colors.black,
    Color lightColor = Colors.white,
  }) {
    return computeLuminance() >= 0.5 ? darkColor : lightColor;
  }

  /// Lerp this color with another color.
  ///
  /// [t] must be in range of 0.0 to 1.0
  ///
  /// See also:
  ///   - [Color.lerp]
  Color lerpWith(Color color, double t) {
    return Color.lerp(this, color, t)!;
  }

  Color resolve(BuildContext context) {
    if (this is AccentColor) {
      return AccentColor.resolve(this, context);
    }
    return this;
  }
}
