import 'dart:math' as math;
import 'dart:ui' as ui show Image;
import 'dart:ui' show ImageFilter;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as m;

/// The default blur amount applied to [Acrylic] widgets.
const double kBlurAmount = 30;

/// The default tint alpha for [Acrylic] widgets.
const double kDefaultAcrylicAlpha = 0.8;

/// The default opacity of the [FluentThemeData.menuColor]
const double kMenuColorOpacity = 0.65;

/// A translucent material that applies a blur effect to content behind it.
///
/// Acrylic is a Fluent Design material that creates depth and visual hierarchy
/// by allowing background content to show through with a blur and tint effect.
/// It's commonly used for navigation panes, command bars, and other surfaces
/// that overlay content.
///
/// ![Acrylic Example](https://learn.microsoft.com/en-us/windows/apps/design/style/images/acrylic_lighttheme_base.png)
///
/// {@tool snippet}
/// This example shows a basic acrylic surface:
///
/// ```dart
/// Acrylic(
///   tint: Colors.blue,
///   tintAlpha: 0.8,
///   child: Padding(
///     padding: EdgeInsetsDirectional.all(16),
///     child: Text('Acrylic content'),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// ## Acrylic recipe
///
/// The acrylic effect is created by layering several elements:
///
/// 1. **Blur** - Applies a Gaussian blur to background content
/// 2. **Tint** - A semi-transparent color overlay
/// 3. **Luminosity** - Adjusts the luminosity of the tinted background
/// 4. **Noise texture** - Adds subtle visual texture
///
/// ## Performance considerations
///
/// Acrylic uses [BackdropFilter] which can be expensive. Consider:
///
/// * Using [Mica] instead for large surfaces
/// * Reducing [blurAmount] on lower-end devices
/// * Avoiding nested acrylic surfaces
///
/// See also:
///
///  * [Mica], a lighter-weight material effect
///  * [Card], a surface that doesn't blur background content
///  * <https://learn.microsoft.com/en-us/windows/apps/design/style/acrylic>
class Acrylic extends StatefulWidget {
  /// Creates an acrylic surface.
  const Acrylic({
    super.key,
    this.tint,
    this.child,
    this.tintAlpha,
    this.luminosityAlpha,
    this.blurAmount,
    this.shape,
    this.shadowColor,
    this.elevation = 0.0,
  });

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
    properties
      ..add(ColorProperty('tint', tint))
      ..add(DoubleProperty('tintAlpha', tintAlpha))
      ..add(DoubleProperty('luminosityAlpha', luminosityAlpha))
      ..add(DoubleProperty('blurAmount', blurAmount))
      ..add(DiagnosticsProperty<ShapeBorder>('shape', shape))
      ..add(ColorProperty('shadowColor', shadowColor))
      ..add(DoubleProperty('elevation', elevation));
  }

  @override
  State<Acrylic> createState() => _AcrylicState();
}

class _AcrylicState extends State<Acrylic> {
  AcrylicProperties _properties = const AcrylicProperties.empty();
  ImageFilter? _cachedBlurFilter;
  double _cachedBlurAmount = kBlurAmount;

  @override
  void initState() {
    super.initState();
    _NoiseTextureCacher._instance ??= _NoiseTextureCacher._new();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        _updateProperties();
        setState(() {});
      }
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
    final blurAmount = widget.blurAmount ?? 30;
    _properties = AcrylicProperties(
      tint: widget.tint ?? FluentTheme.of(context).acrylicBackgroundColor,
      tintAlpha: widget.tintAlpha ?? kDefaultAcrylicAlpha,
      luminosityAlpha: widget.luminosityAlpha ?? kDefaultAcrylicAlpha,
      blurAmount: blurAmount,
      shape: widget.shape ?? const RoundedRectangleBorder(),
    );
    // Only recreate the filter when blur amount changes
    if (_cachedBlurFilter == null || _cachedBlurAmount != blurAmount) {
      _cachedBlurAmount = blurAmount;
      _cachedBlurFilter = ImageFilter.blur(
        sigmaX: blurAmount,
        sigmaY: blurAmount,
      );
    }
  }

  ImageFilter get blurFilter =>
      _cachedBlurFilter ??
      ImageFilter.blur(sigmaX: _cachedBlurAmount, sigmaY: _cachedBlurAmount);

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(widget.elevation >= 0, 'The elevation must be always positive');
    assert(_properties.tintAlpha >= 0, 'The tintAlpha must be always positive');
    assert(
      _properties.luminosityAlpha >= 0,
      'The luminosityAlpha must be always positive',
    );

    final shadowColor =
        widget.shadowColor ?? FluentTheme.of(context).shadowColor;

    return _AcrylicInheritedWidget(
      state: this,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: _properties.shape,
          shadows: [
            /* The shadows were taken from the official FluentUI design kit on Figma */
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.13),
              blurRadius: 0.9 * widget.elevation,
              offset: Offset(0, 0.4 * widget.elevation),
            ),
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.11),
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

/// An animated acrylic widget.
///
/// See also:
///
///  * [Acrylic], the non-animated version of this widget
///  * [ImplicitlyAnimatedWidget], the base class for this widget
class AnimatedAcrylic extends ImplicitlyAnimatedWidget {
  /// Creates an animated acrylic widget.
  const AnimatedAcrylic({
    required super.duration,
    super.key,
    this.tint,
    this.child,
    this.tintAlpha,
    this.luminosityAlpha,
    this.blurAmount,
    this.shape,
    this.shadowColor,
    this.elevation = 0.0,
    super.curve,
  });

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
    properties
      ..add(ColorProperty('tint', tint))
      ..add(DoubleProperty('tintAlpha', tintAlpha))
      ..add(DoubleProperty('luminosityAlpha', luminosityAlpha))
      ..add(DoubleProperty('blurAmount', blurAmount))
      ..add(DiagnosticsProperty<ShapeBorder>('shape', shape))
      ..add(ColorProperty('shadowColor', shadowColor))
      ..add(DoubleProperty('elevation', elevation, defaultValue: 0.0));
  }

  @override
  AnimatedWidgetBaseState<AnimatedAcrylic> createState() =>
      _AnimatedAcrylicState();
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
    _tint =
        visitor(
              _tint,
              widget.tint,
              (dynamic value) => ColorTween(begin: value as Color),
            )
            as ColorTween?;
    _tintAlpha =
        visitor(
              _tintAlpha,
              widget.tintAlpha,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
    _luminosityAlpha =
        visitor(
              _luminosityAlpha,
              widget.luminosityAlpha,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
    _blurAmount =
        visitor(
              _blurAmount,
              widget.blurAmount,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
    _shape =
        visitor(
              _shape,
              widget.shape,
              (dynamic value) =>
                  m.ShapeBorderTween(begin: value as ShapeBorder),
            )
            as m.ShapeBorderTween?;
    _shadowColor =
        visitor(
              _shadowColor,
              widget.shadowColor,
              (dynamic value) => ColorTween(begin: value as Color),
            )
            as ColorTween?;
    _elevation =
        visitor(
              _elevation,
              widget.elevation,
              (dynamic value) => Tween<double>(begin: value as double),
            )
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
  /// The tint color of the acrylic.
  final Color tint;

  /// The opacity of the tint color.
  final double tintAlpha;

  /// The opacity of the luminosity color.
  final double luminosityAlpha;

  /// The amount of blur to apply to the content behind the acrylic.
  final double blurAmount;

  /// The shape of the acrylic.
  final ShapeBorder shape;

  /// Creates a new instance of [AcrylicProperties].
  const AcrylicProperties({
    required this.tint,
    required this.tintAlpha,
    required this.luminosityAlpha,
    required this.blurAmount,
    required this.shape,
  });

  /// Creates a new instance of [AcrylicProperties] with default values.
  const AcrylicProperties.empty()
    : tint = Colors.black,
      tintAlpha = kDefaultAcrylicAlpha,
      luminosityAlpha = kDefaultAcrylicAlpha,
      blurAmount = kBlurAmount,
      shape = const RoundedRectangleBorder();

  @override
  int get hashCode =>
      Object.hash(tint, tintAlpha, luminosityAlpha, blurAmount, shape);

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

  /// Gets the properties of the acrylic from the context.
  static AcrylicProperties of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_AcrylicInheritedWidget>()!
        .state
        ._properties;
  }
}

class _AcrylicInheritedWidget extends InheritedWidget {
  final _AcrylicState state;

  const _AcrylicInheritedWidget({required this.state, required super.child});

  @override
  bool updateShouldNotify(_AcrylicInheritedWidget old) {
    return state != old.state;
  }
}

class _AcrylicGuts extends StatelessWidget {
  final Widget child;

  const _AcrylicGuts({required this.child});

  @override
  Widget build(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<_AcrylicInheritedWidget>()!;
    final properties = inherited.state._properties;
    final tint = AcrylicHelper.getEffectiveTintColor(
      properties.tint,
      AcrylicHelper.getTintOpacityModifier(properties.tint),
    );

    final disabled = DisableAcrylic.of(context) != null;

    return ClipPath(
      clipper: ShapeBorderClipper(shape: properties.shape),
      child: CustomPaint(
        isComplex: true,
        painter: _AcrylicPainter(
          tintColor: disabled ? tint.withValues(alpha: 1) : tint,
          luminosityColor: AcrylicHelper.getLuminosityColor(
            tint,
            disabled ? 1.0 : properties.luminosityAlpha,
          ),
        ),
        child: disabled
            ? child
            : BackdropFilter(
                filter: inherited.state.blurFilter,
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    const Opacity(
                      opacity: 0.02,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/AcrylicNoise.png',
                              package: 'fluent_ui',
                            ),
                            alignment: AlignmentDirectional.topStart,
                            repeat: ImageRepeat.repeat,
                          ),
                          backgroundBlendMode: BlendMode.srcOver,
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                    child,
                  ],
                ),
              ),
      ),
    );
  }
}

class _AcrylicPainter extends CustomPainter {
  static final Color red = const Color(0xFFFF0000).withValues(alpha: 0.12);
  static final Color blue = const Color(0xFF00FF00).withValues(alpha: 0.12);
  static final Color green = const Color(0xFF0000FF).withValues(alpha: 0.12);

  final Color luminosityColor;
  final Color tintColor;

  const _AcrylicPainter({
    required this.luminosityColor,
    required this.tintColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..drawColor(luminosityColor, BlendMode.luminosity)
      ..drawColor(red, BlendMode.saturation)
      ..drawColor(blue, BlendMode.saturation)
      ..drawColor(green, BlendMode.saturation)
      ..drawColor(
        tintColor,
        tintColor.a == 1 ? BlendMode.srcIn : BlendMode.color,
      );
  }

  @override
  bool shouldRepaint(covariant _AcrylicPainter old) {
    return luminosityColor != old.luminosityColor || tintColor != old.tintColor;
  }
}

// Credits: @HrX03 (https://github.com/hrx03)
/// Microsoft utils converted from C# to dart
class AcrylicHelper {
  /// Gets the effective tint color of the acrylic.
  static Color getEffectiveTintColor(Color color, double opacity) {
    // Update tintColor's alpha with the combined opacity value
    // If LuminosityOpacity was specified, we don't intervene into users parameters
    return color.withValues(alpha: opacity);
  }

  /// Gets the luminosity color of the acrylic.
  static Color getLuminosityColor(Color tintColor, double? luminosityOpacity) {
    // If luminosity opacity is specified, just use the values as is
    if (luminosityOpacity != null) {
      return tintColor.withValues(alpha: luminosityOpacity.clamp(0.0, 1.0));
    } else {
      // To create the Luminosity blend input color without luminosity opacity,
      // we're taking the TintColor input, converting to HSV, and clamping the V between these values
      const minHsvV = 0.125;
      const maxHsvV = 0.965;

      final hsvTintColor = HSVColor.fromColor(tintColor);

      final clampedHsvV = hsvTintColor.value.clamp(minHsvV, maxHsvV);

      final hsvLuminosityColor = hsvTintColor.withValue(clampedHsvV);
      final rgbLuminosityColor = hsvLuminosityColor.toColor();

      // Now figure out luminosity opacity
      // Map original *tint* opacity to this range
      const minLuminosityOpacity = 0.15;
      const maxLuminosityOpacity = 1.03;

      const luminosityOpacityRangeMax =
          maxLuminosityOpacity - minLuminosityOpacity;
      final mappedTintOpacity =
          ((tintColor.a / 255.0) * luminosityOpacityRangeMax) +
          minLuminosityOpacity;

      return rgbLuminosityColor.withValues(
        alpha: math.min(mappedTintOpacity, 1),
      );
    }
  }

  /// Gets the opacity modifier of the tint color.
  static double getTintOpacityModifier(Color color) {
    // Mid point of HsvV range that these calculations are based on. This is here for easy tuning.
    const midPoint = 0.50;

    const whiteMaxOpacity = 0.45; // 100% luminosity
    const midPointMaxOpacity = 0.90; // 50% luminosity
    const blackMaxOpacity = 0.85; // 0% luminosity

    final hsv = HSVColor.fromColor(color);

    var opacityModifier = midPointMaxOpacity;

    if (hsv.value != midPoint) {
      // Determine maximum suppression amount
      var lowestMaxOpacity = midPointMaxOpacity;
      var maxDeviation = midPoint;

      if (hsv.value > midPoint) {
        lowestMaxOpacity = whiteMaxOpacity; // At white (100% hsvV)
        maxDeviation = 1 - maxDeviation;
      } else if (hsv.value < midPoint) {
        lowestMaxOpacity = blackMaxOpacity; // At black (0% hsvV)
      }

      var maxOpacitySuppression = midPointMaxOpacity - lowestMaxOpacity;

      // Determine normalized deviation from the midpoint
      final deviation = hsv.value - midPoint;
      final normalizedDeviation = deviation / maxDeviation;

      // If we have saturation, reduce opacity suppression to allow that color to come through more
      if (hsv.saturation > 0) {
        // Dampen opacity suppression based on how much saturation there is
        maxOpacitySuppression *= math.max(1 - (hsv.saturation * 2), 0.0);
      }

      final opacitySuppression = maxOpacitySuppression * normalizedDeviation;

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

  Future<void> _computeImage() async {
    const ImageProvider provider = AssetImage(
      'assets/AcrylicNoise.png',
      package: 'fluent_ui',
    );

    provider
        .resolve(ImageConfiguration.empty)
        .addListener(
          ImageStreamListener((image, synchronousCall) {
            texture = image.image;
          }),
        );
  }
}

/// A widget that disables the acrylic effect for its descendants.
///
/// See also:
///
///   * [Acrylic], the widget that applies the acrylic effect
class DisableAcrylic extends InheritedWidget {
  /// Creates a new instance of [DisableAcrylic].
  const DisableAcrylic({required super.child, super.key});

  /// Gets the nearest [DisableAcrylic] ancestor, if any.
  static DisableAcrylic? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DisableAcrylic>();
  }

  @override
  bool updateShouldNotify(DisableAcrylic oldWidget) {
    return true;
  }
}
