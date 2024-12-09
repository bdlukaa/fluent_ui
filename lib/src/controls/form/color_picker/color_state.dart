import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';

part "color_names.dart";

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
  ColorState(this._red, this._green, this._blue, this._alpha, this._hue,
      this._saturation, this._value) {
    _validateColorValues();
  }

  /// Creates a [ColorState] from a [Color].
  static ColorState fromColor(Color color) {
    final r = color.red.toDouble() / 255;
    final g = color.green.toDouble() / 255;
    final b = color.blue.toDouble() / 255;
    final a = color.alpha.toDouble() / 255;

    final (h, s, v) = rgbToHsv(r, g, b);
    return ColorState(r, g, b, a, h, s, v);
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
      final (r, g, b) = hsvToRgb(_hue, _saturation, _value);
      _red = r;
      _green = g;
      _blue = b;
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

      _red = color.red / 255;
      _green = color.green / 255;
      _blue = color.blue / 255;
      _alpha = color.alpha / 255;

      final (h, s, v) = rgbToHsv(_red, _green, _blue);
      _hue = h;
      _saturation = s;
      _value = v;

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
      final rgb1 = (red: _red, green: _green, blue: _blue);
      final hsl1 = rgbToHsl(_red, _green, _blue);

      double minDistance = double.infinity;
      String closestColorName = '';

      for (final entry in _ColorNames._values.entries) {
        final hexColor = entry.key;
        final name = entry.value;

        final r = ((hexColor >> 16) & 0xFF) / 255.0;
        final g = ((hexColor >> 8) & 0xFF) / 255.0;
        final b = (hexColor & 0xFF) / 255.0;

        final rgb2 = (red: r, green: g, blue: b);
        final hsl2 = rgbToHsl(r, g, b);

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
    final colorValue =
        toColor().value.toRadixString(16).padLeft(8, '0').toUpperCase();
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
    assert(minHue >= 0 && minHue <= maxHue && maxHue <= 360,
        'Hue values must be between 0 and 360');
    assert(
        minSaturation >= 0 &&
            minSaturation <= maxSaturation &&
            maxSaturation <= 100,
        'Saturation values must be between 0 and 100');
    assert(minValue >= 0 && minValue <= maxValue && maxValue <= 100,
        'Value/brightness values must be between 0 and 100');

    // Clamp values to allowed ranges
    final clampedHue = _hue.clamp(minHue.toDouble(), maxHue.toDouble());
    final clampedSaturation =
        _saturation.clamp(minSaturation / 100, maxSaturation / 100);
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

      final (h, s, tempV) = rgbToHsv(scaledR, scaledG, scaledB);
      _hue = h;
      _saturation = s;
    }
    _value = v;
  }

  /// Updates the RGB values based on the current HSV values.
  void _recalculateRGBFromHSV() {
    final (r, g, b) = hsvToRgb(_hue, _saturation, _value);
    _red = r;
    _green = g;
    _blue = b;
  }

  /// Validates that all color values are within their valid ranges.
  void _validateColorValues() {
    assert(_red >= 0 && _red <= 1, "Red must be between 0 and 1");
    assert(_green >= 0 && _green <= 1, "Green must be between 0 and 1");
    assert(_blue >= 0 && _blue <= 1, "Blue must be between 0 and 1");
    assert(_alpha >= 0 && _alpha <= 1, "Alpha must be between 0 and 1");
    assert(_hue >= 0 && _hue <= 360, "Hue must be between 0 and 360");
    assert(_saturation >= 0 && _saturation <= 1,
        "Saturation must be between 0 and 1");
    assert(_value >= 0 && _value <= 1, "Value must be between 0 and 1");
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
    ColorState cs = ColorState(
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
  static (double h, double s, double l) colorToHsv(Color color) {
    final red = color.red / 255;
    final green = color.green / 255;
    final blue = color.blue / 255;

    return rgbToHsv(red, green, blue);
  }

  /// Converts Color to HSL.
  static (double h, double s, double l) colorToHsl(Color color) {
    final red = color.red / 255;
    final green = color.green / 255;
    final blue = color.blue / 255;

    return rgbToHsl(red, green, blue);
  }

  /// Converts RGB values to HSV.
  static (double h, double s, double v) rgbToHsv(double r, double g, double b) {
    final min = math.min(r, math.min(g, b));
    final max = math.max(r, math.max(g, b));
    final delta = max - min;

    final v = max;
    final s = max == 0 ? 0.0 : delta / max;

    if (delta == 0) {
      return (0, s, v);
    }

    double h;
    if (max == r) {
      h = (g - b) / delta;
    } else if (max == g) {
      h = 2 + (b - r) / delta;
    } else {
      h = 4 + (r - g) / delta;
    }
    h *= 60;
    if (h < 0) h += 360;

    return (h, s, v);
  }

  /// Converts RGB values to HSL.
  static (double h, double s, double l) rgbToHsl(double r, double g, double b) {
    final max = math.max(r, math.max(g, b));
    final min = math.min(r, math.min(g, b));
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
      if (max == r) {
        h = ((g - b) / delta) % 6;
      } else if (max == g) {
        h = (b - r) / delta + 2.0;
      } else {
        // max == b
        h = (r - g) / delta + 4.0;
      }
      h *= 60;
      if (h < 0) h += 360;
    }

    return (h, s, l);
  }

  /// Converts HSV values to RGB.
  static (double r, double g, double b) hsvToRgb(double h, double s, double v) {
    if (s <= 0) return (v, v, v); // achromatic (grey)

    h = (h % 360) / 60; // Normalize hue
    final i = h.floor();
    final f = h - i.toDouble();
    final p = v * (1.0 - s);
    final q = v * (1.0 - s * f);
    final t = v * (1.0 - s * (1.0 - f));

    switch (i % 6) {
      case 0: // 0 <= h < 60
        return (v, t, p);
      case 1:
        return (q, v, p);
      case 2:
        return (p, v, t);
      case 3:
        return (p, q, v);
      case 4:
        return (t, p, v);
      default:
        return (v, p, q);
    }
  }

  /// Converts HSL values to RGB.
  static (double r, double g, double b) hslToRgb(double h, double s, double l) {
    if (s == 0) return (l, l, l); // achromatic (grey)

    final q = l < 0.5 ? l * (1.0 + s) : l + s - l * s;
    final p = 2.0 * l - q;
    final r = _hueToRgb(p, q, h + 1.0 / 3.0);
    final g = _hueToRgb(p, q, h);
    final b = _hueToRgb(p, q, h - 1.0 / 3.0);

    return (r, g, b);
  }

  /// Converts HSV values to HSL.
  static (double h, double s, double l) hsvToHsl(double h, double s, double v) {
    final hslH = h;
    final hslL = v - v * s / 2.0;
    final hslS =
        (hslL == 0 || hslL == 1) ? 0.0 : (v - hslL) / math.min(hslL, 1 - hslL);
    return (hslH, hslS, hslL);
  }

  /// Converts HSL values to HSV.
  static (double h, double s, double v) hslToHsv(double h, double s, double l) {
    final hsvH = h;
    final hsvV = l + s * math.min(l, 1 - l);
    final hsvS = hsvV == 0 ? 0.0 : 2 * (1 - l / hsvV);
    return (hsvH, hsvS, hsvV);
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
    final fromRgb =
        (red: from.red / 255, green: from.green / 255, blue: from.blue / 255);
    final toRgb =
        (red: to.red / 255, green: to.green / 255, blue: to.blue / 255);

    // Convert RGB to HSL
    final fromHsl = rgbToHsl(fromRgb.red, fromRgb.green, fromRgb.blue);
    final toHsl = rgbToHsl(toRgb.red, toRgb.green, toRgb.blue);

    // Calculate distance using _distanceBetween
    return _rgbHslDistance(fromRgb, fromHsl, toRgb, toHsl);
  }

  /// Get distance between two ColorState objects considering both RGB and HSL spaces
  static double colorStateDistance(ColorState from, ColorState to) {
    // Extract RGB values from ColorState objects
    final fromRgb = (red: from.red, green: from.green, blue: from.blue);
    final toRgb = (red: to.red, green: to.green, blue: to.blue);

    // Extract HSL values from ColorState objects
    final fromHsl = rgbToHsl(from.red, from.green, from.blue);
    final toHsl = rgbToHsl(to.red, to.green, to.blue);

    // Calculate distance using _distanceBetween method
    return _rgbHslDistance(fromRgb, fromHsl, toRgb, toHsl);
  }

  /// Distance calculation between two colors in RGB and HSL spaces.
  static double _rgbHslDistance(
      ({double red, double green, double blue}) rgb1,
      (double h, double s, double l) hsl1,
      ({double red, double green, double blue}) rgb2,
      (double h, double s, double l) hsl2) {
    // RGB distance = (R1 - R2)^2 + (G1 - G2)^2 + (B1 - B2)^2
    final rgbDiff = math.pow((rgb1.red - rgb2.red) * 255, 2) +
        math.pow((rgb1.green - rgb2.green) * 255, 2) +
        math.pow((rgb1.blue - rgb2.blue) * 255, 2);

    // HSL distance = ((H1 - H2)/360)^2 + (S1 - S2)^2 + (L1 - L2)^2
    final hslDiff = math.pow((hsl1.$1 - hsl2.$1) / 360, 2) +
        math.pow(hsl1.$2 - hsl2.$2, 2) +
        math.pow(hsl1.$3 - hsl2.$3, 2);

    return rgbDiff + (hslDiff * 2);
  }
}
