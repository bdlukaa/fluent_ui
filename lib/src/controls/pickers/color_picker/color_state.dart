import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';

part 'color_names.dart';

/// Represents components of a color in the HSV (Hue, Saturation, Value) color space.
final class HsvComponents {
  /// Creates a HSV components.
  const HsvComponents(this.h, this.s, this.v);

  /// The hue component (0-360).
  final double h;

  /// The saturation component (0-1).
  final double s;

  /// The value component (0-1).
  final double v;
}

/// Represents components of a color in the HSL (Hue, Saturation, Lightness) color space.
final class HslComponents {
  /// Creates a HSL components.
  const HslComponents(this.h, this.s, this.l);

  /// The hue component (0-360).
  final double h;

  /// The saturation component (0-1).
  final double s;

  /// The lightness component (0-1).
  final double l;
}

/// Represents components of a color in the RGB (Red, Green, Blue) color space.
final class RgbComponents {
  /// Creates a RGB components.
  const RgbComponents(this.r, this.g, this.b);

  /// The red component (0-1).
  final double r;

  /// The green component (0-1).
  final double g;

  /// The blue component (0-1).
  final double b;
}

/// A stateful representation of a color in both RGB and HSV color spaces.
class ColorState extends ChangeNotifier {
  // RGB components (0-1)
  late double _red; // 0–1
  late double _green; // 0–1
  late double _blue; // 0–1
  late double _alpha; // 0–1

  // HSV components
  late double _hue; // 0–360
  late double _saturation; // 0–1
  late double _value; // 0–1

  /// Gets the red component (0–1).
  double get red => _red;

  /// Gets the green component (0–1).
  double get green => _green;

  /// Gets the blue component (0–1).
  double get blue => _blue;

  /// Gets the alpha (transparency) component (0–1).
  double get alpha => _alpha;

  /// Gets the hue (0–360).
  double get hue => _hue;

  /// Gets the saturation (0–1).
  double get saturation => _saturation;

  /// Gets the value/brightness (0–1).
  double get value => _value;

  /// Constructs a [ColorState] with the given components.
  ///
  /// All components must be within their valid ranges:
  /// - [red], [green], [blue], [alpha], [saturation], [value]: 0–1
  /// - [hue]: 0–360
  ColorState(
    this._red,
    this._green,
    this._blue,
    this._alpha,
    this._hue,
    this._saturation,
    this._value,
  ) {
    _validateColorValues();
  }

  /// Creates a [ColorState] from a [Color].
  static ColorState fromColor(Color color) {
    final r = color.r;
    final g = color.g;
    final b = color.b;
    final a = color.a;

    final hsv = rgbToHsv(RgbComponents(r, g, b));
    return ColorState(r, g, b, a, hsv.h, hsv.s, hsv.v);
  }

  /// Sets the hue and updates the RGB values accordingly.
  void setHue(double newValue) {
    _hue = (newValue + 360) % 360;
    _recalculateRGBFromHSV();
    notifyListeners();
  }

  /// Sets the saturation and updates the RGB values accordingly.
  void setSaturation(double newValue) {
    _saturation = newValue.clamp(0, 1);
    _recalculateRGBFromHSV();
    notifyListeners();
  }

  /// Sets the value and updates the RGB values accordingly.
  void setValue(double newValue) {
    _value = newValue.clamp(0, 1);

    if (_value == 0) {
      _red = 0;
      _green = 0;
      _blue = 0;
    } else {
      final rgb = hsvToRgb(HsvComponents(_hue, _saturation, _value));
      _red = rgb.r;
      _green = rgb.g;
      _blue = rgb.b;
    }

    notifyListeners();
  }

  /// Sets the red component and updates the HSV values accordingly.
  void setRed(double newValue) {
    _red = newValue.clamp(0, 1);
    _recalculateHSVFromRGB();
    notifyListeners();
  }

  /// Sets the green component and updates the HSV values accordingly.
  void setGreen(double newValue) {
    _green = newValue.clamp(0, 1);
    _recalculateHSVFromRGB();
    notifyListeners();
  }

  /// Sets the blue component and updates the HSV values accordingly.
  void setBlue(double newValue) {
    _blue = newValue.clamp(0, 1);
    _recalculateHSVFromRGB();
    notifyListeners();
  }

  /// Sets the alpha component (0–1).
  void setAlpha(double newValue) {
    _alpha = newValue.clamp(0, 1);
    notifyListeners();
  }

  /// Sets the color from a hexadecimal color string.
  void setHex(String hexText) {
    try {
      final text = hexText.startsWith('#') ? hexText.substring(1) : hexText;

      // check if the text has an alpha channel
      final colorText = text.length == 6 ? 'FF$text' : text;
      final color = Color(int.parse(colorText, radix: 16));

      _red = color.r;
      _green = color.g;
      _blue = color.b;
      _alpha = color.a;

      final hsv = rgbToHsv(RgbComponents(_red, _green, _blue));
      _hue = hsv.h;
      _saturation = hsv.s;
      _value = hsv.v;

      notifyListeners();
    } catch (e) {
      return;
    }
  }

  /// Converts the current state to a [Color] object.
  Color toColor() {
    final a = (_alpha * 255).round();

    if (_value == 0) {
      return Color.fromARGB(a, 0, 0, 0);
    }

    final r = (_red * 255).round();
    final g = (_green * 255).round();
    final b = (_blue * 255).round();
    return Color.fromARGB(a, r, g, b);
  }

  /// Guess the name of the color based on the current RGB values.
  String guessColorName() {
    try {
      final rgb1 = RgbComponents(_red, _green, _blue);
      final hsl1 = rgbToHsl(rgb1);

      var minDistance = double.infinity;
      var closestColorName = '';

      for (final entry in _ColorNames._values.entries) {
        final hexColor = entry.key;
        final name = entry.value;

        final r = ((hexColor >> 16) & 0xFF) / 255.0;
        final g = ((hexColor >> 8) & 0xFF) / 255.0;
        final b = (hexColor & 0xFF) / 255.0;

        final rgb2 = RgbComponents(r, g, b);
        final hsl2 = rgbToHsl(rgb2);

        final distance = _rgbHslDistance(rgb1, hsl1, rgb2, hsl2);
        if (distance < minDistance) {
          minDistance = distance;
          closestColorName = name;
        }
      }

      return closestColorName;
    } catch (e) {
      debugPrint('Error guessing color name: $e');
      return '';
    }
  }

  /// Converts the current state to a hexadecimal color string.
  ///
  /// If [includeAlpha] is true, the alpha channel will be included in the string.
  String toHexString(bool includeAlpha) {
    final colorValue = toColor().colorValue
        .toRadixString(16)
        .padLeft(8, '0')
        .toUpperCase();
    return includeAlpha ? '#$colorValue' : '#${colorValue.substring(2)}';
  }

  /// Clamps the color components to the specified ranges
  ///
  /// Updates the current HSV values to be within the given ranges:
  /// - hue: between [minHue] and [maxHue] (0-360)
  /// - saturation: between [minSaturation] and [maxSaturation] (0-1)
  /// - value: between [minValue] and [maxValue] (0-1)
  ///
  /// RGB values are automatically recalculated when HSV values are clamped.
  void clampToBounds({
    int minHue = 0,
    int maxHue = 360,
    int minSaturation = 0,
    int maxSaturation = 100,
    int minValue = 0,
    int maxValue = 100,
  }) {
    assert(
      minHue >= 0 && minHue <= maxHue && maxHue <= 360,
      'Hue values must be between 0 and 360',
    );
    assert(
      minSaturation >= 0 &&
          minSaturation <= maxSaturation &&
          maxSaturation <= 100,
      'Saturation values must be between 0 and 100',
    );
    assert(
      minValue >= 0 && minValue <= maxValue && maxValue <= 100,
      'Value/brightness values must be between 0 and 100',
    );

    // Clamp values to allowed ranges
    final clampedHue = _hue.clamp(minHue.toDouble(), maxHue.toDouble());
    final clampedSaturation = _saturation.clamp(
      minSaturation / 100,
      maxSaturation / 100,
    );
    final clampedValue = _value.clamp(minValue / 100, maxValue / 100);

    // Only update and recalculate if values actually changed
    if (clampedHue != _hue ||
        clampedSaturation != _saturation ||
        clampedValue != _value) {
      _hue = clampedHue;
      _saturation = clampedSaturation;
      _value = clampedValue;
      _recalculateRGBFromHSV();
    }
  }

  /// Updates the HSV values based on the current RGB values.
  void _recalculateHSVFromRGB() {
    if (_red == 0 && _green == 0 && _blue == 0) {
      _value = 0;
      return;
    }

    final v = math.max(_red, math.max(_green, _blue));
    if (v > 0) {
      final scaledR = _red / v;
      final scaledG = _green / v;
      final scaledB = _blue / v;

      final hsv = rgbToHsv(RgbComponents(scaledR, scaledG, scaledB));
      _hue = hsv.h;
      _saturation = hsv.s;
    }
    _value = v;
  }

  /// Updates the RGB values based on the current HSV values.
  void _recalculateRGBFromHSV() {
    final rgb = hsvToRgb(HsvComponents(_hue, _saturation, _value));
    _red = rgb.r;
    _green = rgb.g;
    _blue = rgb.b;
  }

  /// Validates that all color values are within their valid ranges.
  void _validateColorValues() {
    assert(_red >= 0 && _red <= 1, 'Red must be between 0 and 1');
    assert(_green >= 0 && _green <= 1, 'Green must be between 0 and 1');
    assert(_blue >= 0 && _blue <= 1, 'Blue must be between 0 and 1');
    assert(_alpha >= 0 && _alpha <= 1, 'Alpha must be between 0 and 1');
    assert(_hue >= 0 && _hue <= 360, 'Hue must be between 0 and 360');
    assert(
      _saturation >= 0 && _saturation <= 1,
      'Saturation must be between 0 and 1',
    );
    assert(_value >= 0 && _value <= 1, 'Value must be between 0 and 1');
  }

  /// Creates a copy of this [ColorState] but with the given fields replaced with the new values.
  ColorState copyWith({
    double? red,
    double? green,
    double? blue,
    double? alpha,
    double? hue,
    double? saturation,
    double? value,
  }) {
    final cs = ColorState(
      _red,
      _green,
      _blue,
      _alpha,
      _hue,
      _saturation,
      _value,
    );

    if (red != null && red != cs._red) cs.setRed(red);
    if (green != null && green != cs._green) cs.setGreen(green);
    if (blue != null && blue != cs._blue) cs.setBlue(blue);
    if (alpha != null && alpha != cs._alpha) cs.setAlpha(alpha);
    if (hue != null && hue != cs._hue) cs.setHue(hue);
    if (saturation != null && saturation != cs._saturation) {
      cs.setSaturation(saturation);
    }
    if (value != null && value != cs._value) cs.setValue(value);

    return cs;
  }

  /// Converts Color to HSV.
  static HsvComponents colorToHsv(Color color) {
    final red = color.r;
    final green = color.g;
    final blue = color.b;

    return rgbToHsv(RgbComponents(red, green, blue));
  }

  /// Converts Color to HSL.
  static HslComponents colorToHsl(Color color) {
    final red = color.r;
    final green = color.g;
    final blue = color.b;

    return rgbToHsl(RgbComponents(red, green, blue));
  }

  /// Converts RGB values to HSV.
  static HsvComponents rgbToHsv(RgbComponents rgb) {
    final min = math.min(rgb.r, math.min(rgb.g, rgb.b));
    final max = math.max(rgb.r, math.max(rgb.g, rgb.b));
    final delta = max - min;

    final v = max;
    final s = max == 0 ? 0.0 : delta / max;

    if (delta == 0) {
      return HsvComponents(0, s, v);
    }

    double h;
    if (max == rgb.r) {
      h = (rgb.g - rgb.b) / delta;
    } else if (max == rgb.g) {
      h = 2 + (rgb.b - rgb.r) / delta;
    } else {
      h = 4 + (rgb.r - rgb.g) / delta;
    }
    h *= 60;
    if (h < 0) h += 360;

    return HsvComponents(h, s, v);
  }

  /// Converts RGB values to HSL.
  static HslComponents rgbToHsl(RgbComponents rgb) {
    final max = math.max(rgb.r, math.max(rgb.g, rgb.b));
    final min = math.min(rgb.r, math.min(rgb.g, rgb.b));
    final delta = max - min;

    // Calculate lightness
    final l = (max + min) / 2.0;

    // Calculate saturation
    final s = delta == 0 ? 0.0 : delta / (1.0 - (2 * l - 1).abs());

    // Calculate hue
    double h;
    if (delta == 0) {
      h = 0.0; // achromatic (gray)
    } else {
      if (max == rgb.r) {
        h = ((rgb.g - rgb.b) / delta) % 6;
      } else if (max == rgb.g) {
        h = (rgb.b - rgb.r) / delta + 2.0;
      } else {
        // max == b
        h = (rgb.r - rgb.g) / delta + 4.0;
      }
      h *= 60;
      if (h < 0) h += 360;
    }

    return HslComponents(h, s, l);
  }

  /// Converts HSV values to RGB.
  static RgbComponents hsvToRgb(HsvComponents hsv) {
    if (hsv.s <= 0) {
      return RgbComponents(hsv.v, hsv.v, hsv.v); // achromatic (grey)
    }

    final angle = (hsv.h % 360) / 60; // Normalize hue
    final i = angle.floor();
    final f = angle - i.toDouble();
    final p = hsv.v * (1.0 - hsv.s);
    final q = hsv.v * (1.0 - hsv.s * f);
    final t = hsv.v * (1.0 - hsv.s * (1.0 - f));

    switch (i % 6) {
      case 0: // 0 <= h < 60
        return RgbComponents(hsv.v, t, p);
      case 1:
        return RgbComponents(q, hsv.v, p);
      case 2:
        return RgbComponents(p, hsv.v, t);
      case 3:
        return RgbComponents(p, q, hsv.v);
      case 4:
        return RgbComponents(t, p, hsv.v);
      default:
        return RgbComponents(hsv.v, p, q);
    }
  }

  /// Converts HSL values to RGB.
  static RgbComponents hslToRgb(HslComponents hsl) {
    if (hsl.s == 0) {
      return RgbComponents(hsl.l, hsl.l, hsl.l); // achromatic (grey)
    }

    final q = hsl.l < 0.5
        ? hsl.l * (1.0 + hsl.s)
        : hsl.l + hsl.s - hsl.l * hsl.s;
    final p = 2.0 * hsl.l - q;
    final r = _hueToRgb(p, q, hsl.h + 1.0 / 3.0);
    final g = _hueToRgb(p, q, hsl.h);
    final b = _hueToRgb(p, q, hsl.h - 1.0 / 3.0);

    return RgbComponents(r, g, b);
  }

  /// Converts HSV values to HSL.
  static HslComponents hsvToHsl(HsvComponents hsv) {
    final h = hsv.h;
    final l = hsv.v - hsv.v * hsv.s / 2.0;
    final s = (l == 0 || l == 1) ? 0.0 : (hsv.v - l) / math.min(l, 1 - l);
    return HslComponents(h, s, l);
  }

  /// Converts HSL values to HSV.
  static HsvComponents hslToHsv(HslComponents hsl) {
    final h = hsl.h;
    final v = hsl.l + hsl.s * math.min(hsl.l, 1 - hsl.l);
    final s = v == 0 ? 0.0 : 2 * (1 - hsl.l / v);
    return HsvComponents(h, s, v);
  }

  /// Helper method for HSL to RGB conversion.
  static double _hueToRgb(double p, double q, double t) {
    if (t < 0.0) {
      t += 1.0;
    } else if (t > 1.0) {
      t -= 1.0;
    }

    if (t < 1.0 / 6.0) {
      return p + (q - p) * 6.0 * t;
    } else if (t < 1.0 / 2.0) {
      return q;
    } else if (t < 2.0 / 3.0) {
      return p + (q - p) * (2.0 / 3.0 - t) * 6.0;
    } else {
      return p;
    }
  }

  /// Get distance between two colors considering both RGB and HSL spaces
  static double colorDistance(Color from, Color to) {
    // Normalize RGB values to range 0-1
    final fromRgb = RgbComponents(from.r, from.g, from.b);
    final toRgb = RgbComponents(to.r, to.g, to.b);

    // Convert RGB to HSL
    final fromHsl = rgbToHsl(fromRgb);
    final toHsl = rgbToHsl(toRgb);

    // Calculate distance using _distanceBetween
    return _rgbHslDistance(fromRgb, fromHsl, toRgb, toHsl);
  }

  /// Get distance between two ColorState objects considering both RGB and HSL spaces
  static double colorStateDistance(ColorState from, ColorState to) {
    // Extract RGB values from ColorState objects
    final fromRgb = RgbComponents(from.red, from.green, from.blue);
    final toRgb = RgbComponents(to.red, to.green, to.blue);

    // Extract HSL values from ColorState objects
    final fromHsl = rgbToHsl(fromRgb);
    final toHsl = rgbToHsl(toRgb);

    // Calculate distance using _distanceBetween method
    return _rgbHslDistance(fromRgb, fromHsl, toRgb, toHsl);
  }

  /// Distance calculation between two colors in RGB and HSL spaces.
  static double _rgbHslDistance(
    RgbComponents rgb1,
    HslComponents hsl1,
    RgbComponents rgb2,
    HslComponents hsl2,
  ) {
    final (r1, g1, b1) = (rgb1.r, rgb1.g, rgb1.b);
    final (h1, s1, l1) = (hsl1.h, hsl1.s, hsl1.l);
    final (r2, g2, b2) = (rgb2.r, rgb2.g, rgb2.b);
    final (h2, s2, l2) = (hsl2.h, hsl2.s, hsl2.l);

    // RGB distance = (R1 - R2)^2 + (G1 - G2)^2 + (B1 - B2)^2
    final rgbDiff =
        math.pow((r1 - r2) * 255, 2) +
        math.pow((g1 - g2) * 255, 2) +
        math.pow((b1 - b2) * 255, 2);

    // HSL distance = ((H1 - H2)/360)^2 + (S1 - S2)^2 + (L1 - L2)^2
    final hslDiff =
        math.pow((h1 - h2) / 360, 2) +
        math.pow(s1 - s2, 2) +
        math.pow(l1 - l2, 2);

    return rgbDiff + (hslDiff * 2);
  }

  /// Calculates the relative luminance of a color, representing its perceived brightness
  /// to the human eye.
  ///
  /// The human eye has different sensitivities to different colors. For example,
  /// blue (0, 0, 255) appears much darker than green (0, 255, 0) even though they
  /// have the same numeric intensity.
  ///
  /// Returns a value between 0 (darkest) and 1 (brightest).
  static double relativeLuminance(Color color) {
    final r = _standardToLinear(color.r);
    final g = _standardToLinear(color.g);
    final b = _standardToLinear(color.b);
    return r * 0.2126 + g * 0.7152 + b * 0.0722;
  }

  /// Converts a standard RGB color component to linear RGB color space.
  ///
  /// References:
  /// - sRGB: https://en.wikipedia.org/wiki/SRGB
  /// - WCAG 2.0: https://www.w3.org/TR/2008/REC-WCAG20-20081211/#relativeluminancedef
  static double _standardToLinear(double c) {
    // https://en.wikipedia.org/wiki/SRGB
    // https://www.w3.org/TR/2008/REC-WCAG20-20081211/#relativeluminancedef
    return c <= 0.03928
        ? c / 12.92
        : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }
}
