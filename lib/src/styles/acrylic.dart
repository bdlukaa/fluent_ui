import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'dart:ui' as ui show Image;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as m;

import 'package:fluent_ui/fluent_ui.dart';

const double kBlurAmount = 30.0;

const double kDefaultAcrylicAlpha = 0.8;

/// Acrylic is a type of Brush that creates a translucent texture.
/// You can apply acrylic to app surfaces to add depth and help
/// establish a visual hierarchy.
///
/// ![Acrylic Example](https://docs.microsoft.com/en-us/windows/uwp/design/style/images/acrylic_lighttheme_base.png)
class Acrylic extends StatefulWidget {
  const Acrylic({
    Key? key,
    this.tint,
    this.child,
    this.tintAlpha,
    this.luminosityAlpha,
    this.blurAmount,
    this.shape,
    this.shadowColor,
    this.elevation = 0.0,
  }) : super(key: key);

  /// The tint to apply to the acrylic layers.
  ///
  /// Defaults to the acrylicBackgroundColor from the nearest [FluentTheme].
  final Color? tint;

  /// The opacity applied to the [tint] from 0.0 to 1.0.
  ///
  /// Defaults to 0.8.
  final double? tintAlpha;

  /// The child contained by this box
  final Widget? child;

  /// The opacity applied to the luminosity layer of the acrylic, from 0.0 to 1.0.
  ///
  /// Defaults to 0.8.
  final double? luminosityAlpha;

  /// The amount of blur to apply to the content behind the acrylic.
  ///
  /// Defaults to 30.
  final double? blurAmount;

  /// The shape of the acrylic.
  ///
  /// Defaults to a square [RoundedRectangleBorder].
  final ShapeBorder? shape;

  /// The color of the elevation
  ///
  /// Defaults to the shadowColor from the nearest [FluentTheme].
  final Color? shadowColor;

  /// The z-coordinate relative to the parent at which to place this physical object.
  ///
  /// The value is non-negative. Defaults to 0.
  final double elevation;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('tint', tint));
    properties.add(DoubleProperty('tintAlpha', tintAlpha));
    properties.add(DoubleProperty('luminosityAlpha', luminosityAlpha));
    properties.add(DoubleProperty('blurAmount', blurAmount));
    properties.add(DiagnosticsProperty<ShapeBorder>('shape', shape));
    properties.add(ColorProperty('shadowColor', shadowColor));
    properties.add(DoubleProperty('elevation', elevation));
  }

  @override
  State<Acrylic> createState() => _AcrylicState();
}

class _AcrylicState extends State<Acrylic> {
  AcrylicProperties _properties = const AcrylicProperties.empty();

  @override
  void initState() {
    super.initState();
    _NoiseTextureCacher._instance ??= _NoiseTextureCacher._new();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _updateProperties();
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(Acrylic old) {
    super.didUpdateWidget(old);

    if (_compareAcrylics(old)) {
      _updateProperties();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateProperties();
  }

  bool _compareAcrylics(Acrylic other) {
    return widget.blurAmount != other.blurAmount ||
        widget.elevation != other.elevation ||
        widget.luminosityAlpha != other.luminosityAlpha ||
        widget.shape != other.shape ||
        widget.tint != other.tint ||
        widget.tintAlpha != other.tintAlpha;
  }

  void _updateProperties() {
    _properties = AcrylicProperties(
      tint: widget.tint ?? FluentTheme.of(context).acrylicBackgroundColor,
      tintAlpha: widget.tintAlpha ?? kDefaultAcrylicAlpha,
      luminosityAlpha: widget.luminosityAlpha ?? kDefaultAcrylicAlpha,
      blurAmount: widget.blurAmount ?? 30,
      shape: widget.shape ?? const RoundedRectangleBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(widget.elevation >= 0, "The elevation must be always positive");
    assert(_properties.tintAlpha >= 0, "The tintAlpha must be always positive");
    assert(_properties.luminosityAlpha >= 0,
        "The luminosityAlpha must be always positive");

    final Color _shadowColor =
        widget.shadowColor ?? FluentTheme.of(context).shadowColor;

    return _AcrylicInheritedWidget(
      state: this,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: _properties.shape,
          shadows: [
            /* The shadows were taken from the official FluentUI design kit on Figma */
            BoxShadow(
              color: _shadowColor.withOpacity(0.13),
              blurRadius: 0.9 * widget.elevation,
              offset: Offset(0, 0.4 * widget.elevation),
            ),
            BoxShadow(
              color: _shadowColor.withOpacity(0.11),
              blurRadius: 0.225 * widget.elevation,
              offset: Offset(0, 0.085 * widget.elevation),
            ),
          ],
        ),
        child: _AcrylicGuts(
          child: m.Material(
            type: m.MaterialType.transparency,
            shape: widget.shape,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class AnimatedAcrylic extends ImplicitlyAnimatedWidget {
  const AnimatedAcrylic({
    Key? key,
    this.tint,
    this.child,
    this.tintAlpha,
    this.luminosityAlpha,
    this.blurAmount,
    this.shape,
    this.shadowColor,
    this.elevation = 0.0,
    Curve curve = Curves.linear,
    required Duration duration,
  }) : super(key: key, curve: curve, duration: duration);

  /// The tint to apply to the acrylic layers.
  ///
  /// Defaults to the acrylicBackgroundColor from the nearest [FluentTheme].
  final Color? tint;

  /// The opacity applied to the [tint] from 0.0 to 1.0.
  ///
  /// Defaults to 0.8.
  final double? tintAlpha;

  /// The child contained by this box
  final Widget? child;

  /// The opacity applied to the luminosity layer of the acrylic, from 0.0 to 1.0.
  ///
  /// Defaults to 0.8.
  final double? luminosityAlpha;

  /// The amount of blur to apply to the content behind the acrylic.
  ///
  /// Defaults to 30.
  final double? blurAmount;

  /// The shape of the acrylic.
  ///
  /// Defaults to a square [RoundedRectangleBorder].
  final ShapeBorder? shape;

  /// The color of the elevation
  ///
  /// Defaults to the shadowColor from the nearest [FluentTheme].
  final Color? shadowColor;

  /// The z-coordinate relative to the parent at which to place this physical object.
  ///
  /// The value is non-negative. Defaults to 0.
  final double elevation;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('tint', tint));
    properties.add(DoubleProperty('tintAlpha', tintAlpha));
    properties.add(DoubleProperty('luminosityAlpha', luminosityAlpha));
    properties.add(DoubleProperty('blurAmount', blurAmount));
    properties.add(DiagnosticsProperty<ShapeBorder>('shape', shape));
    properties.add(ColorProperty('shadowColor', shadowColor));
    properties.add(DoubleProperty('elevation', elevation));
  }

  @override
  _AnimatedAcrylicState createState() => _AnimatedAcrylicState();
}

class _AnimatedAcrylicState extends AnimatedWidgetBaseState<AnimatedAcrylic> {
  ColorTween? _tint;
  Tween<double?>? _tintAlpha;
  Tween<double?>? _luminosityAlpha;
  Tween<double?>? _blurAmount;
  m.ShapeBorderTween? _shape;
  ColorTween? _shadowColor;
  Tween<double?>? _elevation;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _tint = visitor(_tint, widget.tint,
        (dynamic value) => ColorTween(begin: value as Color)) as ColorTween?;
    _tintAlpha = visitor(_tintAlpha, widget.tintAlpha,
            (dynamic value) => Tween<double>(begin: value as double))
        as Tween<double>?;
    _luminosityAlpha = visitor(_luminosityAlpha, widget.luminosityAlpha,
            (dynamic value) => Tween<double>(begin: value as double))
        as Tween<double>?;
    _blurAmount = visitor(_blurAmount, widget.blurAmount,
            (dynamic value) => Tween<double>(begin: value as double))
        as Tween<double>?;
    _shape = visitor(_shape, widget.shape,
            (dynamic value) => m.ShapeBorderTween(begin: value as ShapeBorder))
        as m.ShapeBorderTween?;
    _shadowColor = visitor(_shadowColor, widget.shadowColor,
        (dynamic value) => ColorTween(begin: value as Color)) as ColorTween?;
    _elevation = visitor(_elevation, widget.elevation,
            (dynamic value) => Tween<double>(begin: value as double))
        as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return Acrylic(
      tint: _tint?.evaluate(animation),
      tintAlpha: _tintAlpha?.evaluate(animation),
      luminosityAlpha: _luminosityAlpha?.evaluate(animation),
      blurAmount: _blurAmount?.evaluate(animation),
      shape: _shape?.evaluate(animation),
      shadowColor: _shadowColor?.evaluate(animation),
      elevation: _elevation?.evaluate(animation) ?? 0,
      child: widget.child,
    );
  }
}

/// Represents the properties of an Acrylic material
@immutable
class AcrylicProperties {
  final Color tint;
  final double tintAlpha;
  final double luminosityAlpha;
  final double blurAmount;
  final ShapeBorder shape;

  const AcrylicProperties({
    required this.tint,
    required this.tintAlpha,
    required this.luminosityAlpha,
    required this.blurAmount,
    required this.shape,
  });

  const AcrylicProperties.empty()
      : tint = Colors.black,
        tintAlpha = kDefaultAcrylicAlpha,
        luminosityAlpha = kDefaultAcrylicAlpha,
        blurAmount = kBlurAmount,
        shape = const RoundedRectangleBorder();

  @override
  int get hashCode => hashValues(
        tint,
        tintAlpha,
        luminosityAlpha,
        blurAmount,
        shape,
      );

  @override
  bool operator ==(Object other) {
    if (other is AcrylicProperties) {
      return tint == other.tint &&
          tintAlpha == other.tintAlpha &&
          luminosityAlpha == other.luminosityAlpha &&
          blurAmount == other.blurAmount &&
          shape == other.shape;
    }

    return false;
  }

  static AcrylicProperties of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_AcrylicInheritedWidget>()!
        .state
        ._properties;
  }
}

class _AcrylicInheritedWidget extends InheritedWidget {
  final _AcrylicState state;

  const _AcrylicInheritedWidget({
    required this.state,
    required Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(_AcrylicInheritedWidget old) {
    return state != old.state;
  }
}

class _AcrylicGuts extends StatelessWidget {
  final Widget child;

  const _AcrylicGuts({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final properties = AcrylicProperties.of(context);
    final _tint = AcrylicHelper.getEffectiveTintColor(
      properties.tint,
      AcrylicHelper.getTintOpacityModifier(properties.tint),
    );

    final disabled = DisableAcrylic.of(context) != null;

    return ClipPath(
      clipper: ShapeBorderClipper(shape: properties.shape),
      child: CustomPaint(
        painter: _AcrylicPainter(
          tintColor: _tint,
          luminosityColor: AcrylicHelper.getLuminosityColor(
            _tint,
            properties.luminosityAlpha,
          ),
        ),
        child: disabled
            ? child
            : BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: properties.blurAmount,
                  sigmaY: properties.blurAmount,
                ),
                child: Stack(children: [
                  const Opacity(
                    opacity: 0.02,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            "assets/AcrylicNoise.png",
                            package: "fluent_ui",
                          ),
                          alignment: Alignment.topLeft,
                          repeat: ImageRepeat.repeat,
                        ),
                        backgroundBlendMode: BlendMode.srcOver,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  child,
                ]),
              ),
      ),
    );
  }
}

class _AcrylicPainter extends CustomPainter {
  static final Color red = const Color(0xFFFF0000).withOpacity(0.12);
  static final Color blue = const Color(0xFF00FF00).withOpacity(0.12);
  static final Color green = const Color(0xFF0000FF).withOpacity(0.12);

  final Color luminosityColor;
  final Color tintColor;

  _AcrylicPainter({
    required this.luminosityColor,
    required this.tintColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(luminosityColor, BlendMode.luminosity);
    canvas.drawColor(red, BlendMode.saturation);
    canvas.drawColor(blue, BlendMode.saturation);
    canvas.drawColor(green, BlendMode.saturation);
    canvas.drawColor(
      tintColor,
      tintColor.opacity == 1 ? BlendMode.srcIn : BlendMode.color,
    );
  }

  @override
  bool shouldRepaint(_AcrylicPainter old) {
    return luminosityColor != old.luminosityColor || tintColor != old.tintColor;
  }
}

// Credits: @HrX03 (https://github.com/hrx03)
/// Microsoft utils converted from C# to dart
class AcrylicHelper {
  static Color getEffectiveTintColor(Color color, double opacity) {
    // Update tintColor's alpha with the combined opacity value
    // If LuminosityOpacity was specified, we don't intervene into users parameters
    return color.withOpacity(opacity);
  }

  static Color getLuminosityColor(Color tintColor, double? luminosityOpacity) {
    // If luminosity opacity is specified, just use the values as is
    if (luminosityOpacity != null) {
      return Color.fromRGBO(
        tintColor.red,
        tintColor.green,
        tintColor.blue,
        luminosityOpacity.clamp(0.0, 1.0),
      );
    } else {
      // To create the Luminosity blend input color without luminosity opacity,
      // we're taking the TintColor input, converting to HSV, and clamping the V between these values
      const double minHsvV = 0.125;
      const double maxHsvV = 0.965;

      HSVColor hsvTintColor = HSVColor.fromColor(tintColor);

      double clampedHsvV = hsvTintColor.value.clamp(minHsvV, maxHsvV);

      HSVColor hsvLuminosityColor = hsvTintColor.withValue(clampedHsvV);
      Color rgbLuminosityColor = hsvLuminosityColor.toColor();

      // Now figure out luminosity opacity
      // Map original *tint* opacity to this range
      const double minLuminosityOpacity = 0.15;
      const double maxLuminosityOpacity = 1.03;

      const double luminosityOpacityRangeMax =
          maxLuminosityOpacity - minLuminosityOpacity;
      double mappedTintOpacity =
          ((tintColor.alpha / 255.0) * luminosityOpacityRangeMax) +
              minLuminosityOpacity;

      // Finally, combine the luminosity opacity and the HsvV-clamped tint color
      return Color.fromRGBO(
        rgbLuminosityColor.red,
        rgbLuminosityColor.green,
        rgbLuminosityColor.blue,
        math.min(mappedTintOpacity, 1.0),
      );
    }
  }

  static double getTintOpacityModifier(Color color) {
    // Mid point of HsvV range that these calculations are based on. This is here for easy tuning.
    const double midPoint = 0.50;

    const double whiteMaxOpacity = 0.45; // 100% luminosity
    const double midPointMaxOpacity = 0.90; // 50% luminosity
    const double blackMaxOpacity = 0.85; // 0% luminosity

    HSVColor hsv = HSVColor.fromColor(color);

    double opacityModifier = midPointMaxOpacity;

    if (hsv.value != midPoint) {
      // Determine maximum suppression amount
      double lowestMaxOpacity = midPointMaxOpacity;
      double maxDeviation = midPoint;

      if (hsv.value > midPoint) {
        lowestMaxOpacity = whiteMaxOpacity; // At white (100% hsvV)
        maxDeviation = 1 - maxDeviation;
      } else if (hsv.value < midPoint) {
        lowestMaxOpacity = blackMaxOpacity; // At black (0% hsvV)
      }

      double maxOpacitySuppression = midPointMaxOpacity - lowestMaxOpacity;

      // Determine normalized deviation from the midpoint
      double deviation = (hsv.value - midPoint);
      double normalizedDeviation = deviation / maxDeviation;

      // If we have saturation, reduce opacity suppression to allow that color to come through more
      if (hsv.saturation > 0) {
        // Dampen opacity suppression based on how much saturation there is
        maxOpacitySuppression *= math.max(1 - (hsv.saturation * 2), 0.0);
      }

      double opacitySuppression = maxOpacitySuppression * normalizedDeviation;

      opacityModifier = midPointMaxOpacity - opacitySuppression;
    }

    return opacityModifier;
  }
}

class _NoiseTextureCacher {
  static _NoiseTextureCacher? _instance;

  ui.Image? texture;

  _NoiseTextureCacher._new() {
    _computeImage();
  }

  void _computeImage() async {
    const ImageProvider provider = AssetImage(
      "assets/AcrylicNoise.png",
      package: "fluent_ui",
    );

    provider.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((image, synchronousCall) {
        texture = image.image;
      }),
    );
  }
}

class DisableAcrylic extends InheritedWidget {
  const DisableAcrylic({
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  static DisableAcrylic? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DisableAcrylic>();
  }

  @override
  bool updateShouldNotify(DisableAcrylic oldWidget) {
    return true;
  }
}
