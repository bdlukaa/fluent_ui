import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// The Fluent Design color palette.
///
/// [Colors] provides a set of predefined colors matching the Windows system
/// palette. These colors are designed to work well together and with Windows
/// UI elements.
///
/// ![Colors used in fluent_ui widgets](https://learn.microsoft.com/en-us/windows/apps/design/style/images/color/windows-controls.svg)
///
/// {@tool snippet}
/// Using standard colors:
///
/// ```dart
/// Container(
///   color: Colors.blue,
///   child: Text('Blue background'),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// Using accent color shades:
///
/// ```dart
/// // Access specific shades of accent colors
/// final lightBlue = Colors.blue.light;
/// final darkBlue = Colors.blue.dark;
/// ```
/// {@end-tool}
///
/// ## Shaded colors
///
/// Some colors like [grey] have numbered shades (e.g., `Colors.grey[120]`).
/// Accent colors like [blue], [red], [green] have named shades (e.g.,
/// `Colors.blue.light`, `Colors.blue.darker`).
///
/// See also:
///
///  * [AccentColor], for colors with light/dark shade variants
///  * [ShadedColor], for colors with numbered shade variants
///  * <https://learn.microsoft.com/en-us/windows/apps/design/style/color>
class Colors {
  /// The transparent color. This should not be used in animations
  /// because it'll cause a weird effect.
  static const Color transparent = Color(0x00000000);

  /// A black opaque color.
  static const Color black = Color(0xFF000000);

  /// The grey color.
  ///
  /// It's a shaded color with the following available shades:
  ///   * 220
  ///   * 210
  ///   * 200
  ///   * 190
  ///   * 180
  ///   * 170
  ///   * 160
  ///   * 150
  ///   * 140
  ///   * 130
  ///   * 120
  ///   * 110
  ///   * 100
  ///   * 90
  ///   * 80
  ///   * 70
  ///   * 60
  ///   * 50
  ///   * 40
  ///   * 30
  ///   * 20
  ///   * 10
  ///
  /// To use any of these shades, call `Colors.grey[SHADE]`, where `SHADE` is
  /// the number of the shade you want. For example, the darkest shade is
  /// `Colors.grey[220]`.
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

  /// The yellow accent color.
  static final AccentColor yellow = AccentColor.swatch(const <String, Color>{
    'darkest': Color(0xfff9a825),
    'darker': Color(0xfffbc02d),
    'dark': Color(0xfffdd835),
    'normal': Color(0xffffeb3b),
    'light': Color(0xffffee58),
    'lighter': Color(0xfffff176),
    'lightest': Color(0xfffff59d),
  });

  /// The orange accent color.
  static final AccentColor orange = AccentColor.swatch(const <String, Color>{
    'darkest': Color(0xff993d07),
    'darker': Color(0xffac4508),
    'dark': Color(0xffd1540a),
    'normal': Color(0xfff7630c),
    'light': Color(0xfff87a30),
    'lighter': Color(0xfff99154),
    'lightest': Color(0xfffa9e68),
  });

  /// The red accent color.
  static final AccentColor red = AccentColor.swatch(const <String, Color>{
    'darkest': Color(0xff8f0a15),
    'darker': Color(0xffa20b18),
    'dark': Color(0xffb90d1c),
    'normal': Color(0xffe81123),
    'light': Color(0xffec404f),
    'lighter': Color(0xffee5865),
    'lightest': Color(0xfff06b76),
  });

  /// The magenta accent color.
  static final AccentColor magenta = AccentColor.swatch(const <String, Color>{
    'darkest': Color(0xff6f0061),
    'darker': Color(0xff7e006e),
    'dark': Color(0xff90007e),
    'normal': Color(0xffb4009e),
    'light': Color(0xffc333b1),
    'lighter': Color(0xffca4cbb),
    'lightest': Color(0xffd060c2),
  });

  /// The purple accent color.
  static final AccentColor purple = AccentColor.swatch(const <String, Color>{
    'darkest': Color(0xff472f68),
    'darker': Color(0xff513576),
    'dark': Color(0xff644293),
    'normal': Color(0xFF744da9),
    'light': Color(0xff8664b4),
    'lighter': Color(0xff9d82c2),
    'lightest': Color(0xffa890c9),
  });

  /// The blue accent color.
  static final AccentColor blue = AccentColor.swatch(const <String, Color>{
    'darkest': Color(0xff004a83),
    'darker': Color(0xff005494),
    'dark': Color(0xff0066b4),
    'normal': Color(0xff0078d4),
    'light': Color(0xff268cda),
    'lighter': Color(0xff4ca0e0),
    'lightest': Color(0xff60abe4),
  });

  /// The teal accent color.
  static final AccentColor teal = AccentColor.swatch(const <String, Color>{
    'darkest': Color(0xff006e5b),
    'darker': Color(0xff007c67),
    'dark': Color(0xff00977d),
    'normal': Color(0xff00b294),
    'light': Color(0xff26bda4),
    'lighter': Color(0xff4cc9b4),
    'lightest': Color(0xff60cfbc),
  });

  /// The green accent color.
  static final AccentColor green = AccentColor.swatch(const <String, Color>{
    'darkest': Color(0xff094c09),
    'darker': Color(0xff0c5d0c),
    'dark': Color(0xff0e6f0e),
    'normal': Color(0xff107c10),
    'light': Color(0xff278927),
    'lighter': Color(0xff4b9c4b),
    'lightest': Color(0xff6aad6a),
  });

  /// The primary color for warning.
  static const Color warningPrimaryColor = Color(0xFFd83b01);

  /// The secondary color for warning.
  static final warningSecondaryColor = AccentColor.swatch(const <String, Color>{
    'dark': Color(0xFF433519),
    'normal': Color(0xFFfff4ce),
  });

  /// The primary color for error.
  static const Color errorPrimaryColor = Color(0xFFa80000);

  /// The secondary color for error.
  static final errorSecondaryColor = AccentColor.swatch(const <String, Color>{
    'dark': Color(0xFF442726),
    'normal': Color(0xFFfde7e9),
  });

  /// The primary color for success.
  static const Color successPrimaryColor = Color(0xFF107c10);

  /// The secondary color for success.
  static final successSecondaryColor = AccentColor.swatch(const <String, Color>{
    'dark': Color(0xFF393d1b),
    'normal': Color(0xFFdff6dd),
  });

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

/// A [ColorSwatch] with numbered shade variants.
///
/// Access shades using the index operator: `Colors.grey[120]`.
///
/// See also:
///
///  * [AccentColor], for colors with named shade variants
///  * [Colors.grey], which uses this class
class ShadedColor extends ColorSwatch<int> {
  /// Creates a shaded color with the given primary value and swatch.
  const ShadedColor(super.primary, super.swatch);

  /// Returns the shade at the given [key].
  ///
  /// Unlike the base class, this returns a non-null [Color].
  @override
  Color operator [](int key) {
    return super[key]!;
  }
}

/// An accent color is a color that can have multiple shades. It's similar to
/// [ShadedColor] and [ColorSwatch], but it has helper methods to help you
/// access the color variant you want easily. These shades may not be accessible
/// on every accent color.
///
/// The [fluent_ui] library already provides some accent colors by default:
///
///   * [Colors.yellow]
///   * [Colors.orange]
///   * [Colors.red]
///   * [Colors.magenta]
///   * [Colors.purple]
///   * [Colors.blue]
///   * [Colors.teal]
///   * [Colors.green]
///
/// Use [Colors.accentColors] to get all the accent colors provided by default.
class AccentColor extends ColorSwatch<String> {
  /// The default shade for this color. This can't be null
  final String primary;

  /// The avaiable shades for this color. This can't be null nor empty
  final Map<String, Color> swatch;

  /// Creates a new accent color.
  AccentColor(this.primary, this.swatch)
    : super(swatch[primary]!.colorValue, swatch);

  /// Creates a new accent color based on a swatch
  AccentColor.swatch(this.swatch)
    : primary = 'normal',
      super(swatch['normal']!.colorValue, swatch);

  /// The darkest shade of the color.
  Color get darkest => swatch['darkest'] ?? darker.withValues(alpha: 0.7);

  /// The darker shade of the color.
  ///
  /// Usually used for shadows
  Color get darker => swatch['darker'] ?? dark.withValues(alpha: 0.8);

  /// The dark shade of the color.
  ///
  /// Usually used for the mouse press effect;
  Color get dark => swatch['dark'] ?? normal.withValues(alpha: 0.9);

  /// The default shade of the color.
  Color get normal => swatch['normal']!;

  /// The light shade of the color.
  ///
  /// Usually used for the mouse hover effect
  Color get light => swatch['light'] ?? normal.withValues(alpha: 0.9);

  /// The lighter shade of the color.
  ///
  /// Usually used for shadows
  Color get lighter => swatch['lighter'] ?? light.withValues(alpha: 0.8);

  /// The lighest shade of the color
  Color get lightest => swatch['lightest'] ?? lighter.withValues(alpha: 0.7);

  /// Lerp between two accent colors.
  static AccentColor lerp(AccentColor a, AccentColor b, double t) {
    final darkest = Color.lerp(a.darkest, b.darkest, t);
    final darker = Color.lerp(a.darker, b.darker, t);
    final dark = Color.lerp(a.dark, b.dark, t);
    final light = Color.lerp(a.light, b.light, t);
    final lighter = Color.lerp(a.lighter, b.lighter, t);
    final lightest = Color.lerp(a.lightest, b.lightest, t);

    return AccentColor.swatch({
      if (darkest != null) 'darkest': darkest,
      if (darker != null) 'darker': darker,
      if (dark != null) 'dark': dark,
      'normal': Color.lerp(a.normal, b.normal, t)!,
      if (light != null) 'light': light,
      if (lighter != null) 'lighter': lighter,
      if (lightest != null) 'lightest': lightest,
    });
  }

  /// Get the default brush for this accent color based on the brightness.
  ///
  /// See also:
  ///  * <https://github.com/microsoft/microsoft-ui-xaml/blob/main/dev/CommonStyles/Common_themeresources_any.xaml#L163-L166>
  Color defaultBrushFor(Brightness brightness) {
    return switch (brightness) {
      Brightness.light => dark,
      Brightness.dark => lighter,
    };
  }

  /// Get the secondary brush for this accent color based on the brightness.
  ///
  /// See also:
  ///  * <https://github.com/microsoft/microsoft-ui-xaml/blob/main/dev/CommonStyles/Common_themeresources_any.xaml#L163-L166>
  Color secondaryBrushFor(Brightness brightness) {
    return defaultBrushFor(brightness).withValues(alpha: 0.9);
  }

  /// Get the tertiary brush for this accent color based on the brightness.
  ///
  /// See also:
  ///  * <https://github.com/microsoft/microsoft-ui-xaml/blob/main/dev/CommonStyles/Common_themeresources_any.xaml#L163-L166>
  Color tertiaryBrushFor(Brightness brightness) {
    return defaultBrushFor(brightness).withValues(alpha: 0.8);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AccentColor &&
        other.primary == primary &&
        mapEquals(other.swatch, swatch);
  }

  @override
  int get hashCode => primary.hashCode ^ swatch.hashCode;
}

/// Extension methods to help dealing with colors.
extension ColorExtension on Color {
  /// Creates a new accent color based on this color. This provides
  /// the shades by lerping this color with [Colors.black] if dark
  /// or darker, and with [Colors.white] if light or lighter.
  ///
  /// See also:
  ///   * [Color.lerp], a method to lerp two colors.
  ///   * [lerpWith], a helper method to lerp two colors with a factor.
  ///   * [Colors.black], the darkest color.
  ///   * [Color.white], the lightest color.
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
    return AccentColor.swatch({
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
    return computeLuminance() < 0.5 ? lightColor : darkColor;
  }

  /// Lerp this color with another color.
  ///
  /// [t] must be in range of 0.0 to 1.0
  ///
  /// See also:
  ///   * [Color.lerp]
  Color lerpWith(Color color, double t) {
    return Color.lerp(this, color, t)!;
  }

  /// Get the color value as an integer.
  @protected
  int get colorValue {
    return _floatToInt8(a) << 24 |
        _floatToInt8(r) << 16 |
        _floatToInt8(g) << 8 |
        _floatToInt8(b) << 0;
  }

  @protected
  static int _floatToInt8(double x) {
    return (x * 255.0).round() & 0xff;
  }
}
