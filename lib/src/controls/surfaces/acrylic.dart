import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// The default blur amount applied to [Acrylic] widgets.
const double kBlurAmount = 30;

/// The legacy default tint alpha for [Acrylic] widgets.
///
/// New [Acrylic] instances resolve their default from
/// [FluentThemeData.acrylicTintOpacity].
const double kDefaultAcrylicAlpha = 0.8;

/// The default opacity of the [FluentThemeData.menuColor].
const double kMenuColorOpacity = 0.65;

/// An in-app Acrylic material that blurs Flutter content behind it.
///
/// This widget corresponds to WinUI's in-app `AcrylicBrush`, not
/// `DesktopAcrylicBackdrop`. It cannot sample arbitrary windows or the desktop
/// wallpaper behind the Flutter window. The material clips the backdrop to
/// [shape], applies WinUI's luminosity and tint stages, and adds the
/// native-style tiled 2% noise layer. When effects are disabled, it paints the
/// theme's opaque fallback instead of creating a filter or noise layer.
///
/// Acrylic is intended for transient and supporting surfaces. It is more
/// expensive than [Mica] because it filters pixels behind the widget; avoid
/// stacking large or overlapping Acrylic surfaces.
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
/// When [luminosityAlpha] is null, Acrylic uses WinUI's automatic luminosity
/// calculation. Set it explicitly to use a fixed luminosity opacity.
///
/// When [DisableAcrylic] is present, the widget keeps the same layout and
/// semantics but paints only [fallbackColor], without a backdrop filter or
/// noise texture.
///
/// See also:
///
///  * [Mica], an opaque foundation material that does not blur Flutter content
///  * [Card], a surface that does not blur background content
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
    this.fallbackColor,
    this.elevation = 0.0,
  });

  /// The tint color applied by the Acrylic brush.
  ///
  /// Equivalent to WinUI `AcrylicBrush.TintColor`. Defaults to the tint
  /// resource from the nearest [FluentTheme].
  final Color? tint;

  /// The opacity applied to [tint].
  ///
  /// Equivalent to WinUI `AcrylicBrush.TintOpacity`. If null, the theme's
  /// default material opacity is used.
  final double? tintAlpha;

  /// The child contained by this box.
  final Widget? child;

  /// The opacity applied to the luminosity stage.
  ///
  /// Equivalent to WinUI `AcrylicBrush.TintLuminosityOpacity`. A null value
  /// selects WinUI's automatic luminosity behavior based on [tint] and
  /// [tintAlpha].
  final double? luminosityAlpha;

  /// The amount of Gaussian blur to apply to content behind the acrylic.
  ///
  /// WinUI uses a 30px blur for Acrylic by default. This property is a
  /// Flutter-specific adjustment for platform and density differences.
  final double? blurAmount;

  /// The shape of the acrylic.
  ///
  /// Defaults to a square [RoundedRectangleBorder].
  final ShapeBorder? shape;

  /// The color used for the elevation shadow.
  ///
  /// Defaults to the shadow color from the nearest [FluentTheme].
  final Color? shadowColor;

  /// The solid color used when Acrylic is disabled or cannot be rendered.
  ///
  /// Equivalent to WinUI `AcrylicBrush.FallbackColor`. If null, the
  /// Acrylic fallback resource from the nearest [FluentTheme] is used.
  final Color? fallbackColor;

  /// The z-coordinate relative to the parent at which to place this physical
  /// object.
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
      ..add(ColorProperty('fallbackColor', fallbackColor))
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
        widget.luminosityAlpha != other.luminosityAlpha ||
        widget.shape != other.shape ||
        widget.tint != other.tint ||
        widget.tintAlpha != other.tintAlpha ||
        widget.fallbackColor != other.fallbackColor;
  }

  void _updateProperties() {
    final theme = FluentTheme.of(context);
    final blurAmount = math.max(widget.blurAmount ?? kBlurAmount, 0).toDouble();
    _properties = AcrylicProperties(
      tint: widget.tint ?? theme.acrylicBackgroundColor,
      tintAlpha: widget.tintAlpha ?? theme.acrylicTintOpacity,
      luminosityAlpha: widget.luminosityAlpha,
      blurAmount: blurAmount,
      shape: widget.shape ?? const RoundedRectangleBorder(),
      fallbackColor: widget.fallbackColor ?? theme.acrylicFallbackColor,
    );

    if (_cachedBlurFilter == null || _cachedBlurAmount != blurAmount) {
      _cachedBlurAmount = blurAmount;
      _cachedBlurFilter = ImageFilter.blur(
        sigmaX: blurAmount,
        sigmaY: blurAmount,
      );
    }
  }

  ImageFilter get blurFilter => _cachedBlurFilter ??= ImageFilter.blur(
    sigmaX: _cachedBlurAmount,
    sigmaY: _cachedBlurAmount,
  );

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(widget.elevation >= 0, 'The elevation must be always positive');
    assert(_properties.tintAlpha >= 0, 'The tintAlpha must be always positive');
    assert(
      _properties.luminosityAlpha == null || _properties.luminosityAlpha! >= 0,
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
        child: _AcrylicGuts(child: widget.child ?? const SizedBox.shrink()),
      ),
    );
  }
}

/// An animated acrylic widget.
///
/// The animation interpolates the same material properties as [Acrylic], while
/// retaining the cached blur and noise resources between frames.
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
    this.fallbackColor,
    this.elevation = 0.0,
    super.curve,
  });

  /// The tint color applied by the Acrylic brush.
  final Color? tint;

  /// The opacity applied to [tint].
  final double? tintAlpha;

  /// The child contained by this box.
  final Widget? child;

  /// The opacity applied to the luminosity stage. Null selects automatic
  /// WinUI luminosity behavior.
  final double? luminosityAlpha;

  /// The amount of blur applied to content behind the acrylic.
  final double? blurAmount;

  /// The shape of the acrylic.
  final ShapeBorder? shape;

  /// The color of the elevation shadow.
  final Color? shadowColor;

  /// The solid fallback color used when Acrylic is disabled.
  final Color? fallbackColor;

  /// The z-coordinate relative to the parent at which to place this physical
  /// object.
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
      ..add(ColorProperty('fallbackColor', fallbackColor))
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
  _ShapeBorderTween? _shape;
  ColorTween? _shadowColor;
  ColorTween? _fallbackColor;
  Tween<double>? _elevation;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _tint =
        visitor(
              _tint,
              widget.tint,
              (dynamic value) => ColorTween(begin: value as Color?),
            )
            as ColorTween?;
    _tintAlpha =
        visitor(
              _tintAlpha,
              widget.tintAlpha,
              (dynamic value) => Tween<double?>(begin: value as double?),
            )
            as Tween<double?>?;
    _luminosityAlpha =
        visitor(
              _luminosityAlpha,
              widget.luminosityAlpha,
              (dynamic value) => Tween<double?>(begin: value as double?),
            )
            as Tween<double?>?;
    _blurAmount =
        visitor(
              _blurAmount,
              widget.blurAmount,
              (dynamic value) => Tween<double?>(begin: value as double?),
            )
            as Tween<double?>?;
    _shape =
        visitor(
              _shape,
              widget.shape,
              (dynamic value) => _ShapeBorderTween(
                begin: value as ShapeBorder?,
                end: widget.shape,
              ),
            )
            as _ShapeBorderTween?;
    _shadowColor =
        visitor(
              _shadowColor,
              widget.shadowColor,
              (dynamic value) => ColorTween(begin: value as Color?),
            )
            as ColorTween?;
    _fallbackColor =
        visitor(
              _fallbackColor,
              widget.fallbackColor,
              (dynamic value) => ColorTween(begin: value as Color?),
            )
            as ColorTween?;
    _elevation =
        visitor(
              _elevation,
              widget.elevation,
              (dynamic value) => Tween<double>(begin: value as double?),
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
      fallbackColor: _fallbackColor?.evaluate(animation),
      elevation: _elevation?.evaluate(animation) ?? 0,
      child: widget.child,
    );
  }
}

class _ShapeBorderTween extends Tween<ShapeBorder?> {
  _ShapeBorderTween({super.begin, super.end});

  @override
  ShapeBorder? lerp(double t) => ShapeBorder.lerp(begin, end, t);
}

/// Represents the resolved properties of an Acrylic material.
@immutable
class AcrylicProperties {
  /// The tint color of the acrylic.
  final Color tint;

  /// The opacity of the tint color.
  final double tintAlpha;

  /// The opacity of the luminosity color, or null for automatic behavior.
  final double? luminosityAlpha;

  /// The amount of blur to apply to the content behind the acrylic.
  final double blurAmount;

  /// The shape of the acrylic.
  final ShapeBorder shape;

  /// The solid fallback color.
  final Color fallbackColor;

  /// Creates a new instance of [AcrylicProperties].
  const AcrylicProperties({
    required this.tint,
    required this.tintAlpha,
    required this.luminosityAlpha,
    required this.blurAmount,
    required this.shape,
    this.fallbackColor = Colors.black,
  });

  /// Creates a new instance of [AcrylicProperties] with default values.
  const AcrylicProperties.empty()
    : tint = Colors.black,
      tintAlpha = kDefaultAcrylicAlpha,
      luminosityAlpha = null,
      blurAmount = kBlurAmount,
      shape = const RoundedRectangleBorder(),
      fallbackColor = Colors.black;

  @override
  int get hashCode => Object.hash(
    tint,
    tintAlpha,
    luminosityAlpha,
    blurAmount,
    shape,
    fallbackColor,
  );

  @override
  bool operator ==(Object other) {
    return other is AcrylicProperties &&
        tint == other.tint &&
        tintAlpha == other.tintAlpha &&
        luminosityAlpha == other.luminosityAlpha &&
        blurAmount == other.blurAmount &&
        shape == other.shape &&
        fallbackColor == other.fallbackColor;
  }

  /// Gets the resolved properties of the acrylic from the context.
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
  bool updateShouldNotify(_AcrylicInheritedWidget old) => state != old.state;
}

class _AcrylicGuts extends StatelessWidget {
  final Widget child;

  const _AcrylicGuts({required this.child});

  @override
  Widget build(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<_AcrylicInheritedWidget>()!;
    final properties = inherited.state._properties;
    final disabled = DisableAcrylic.of(context) != null;

    if (disabled) {
      return ClipPath(
        clipper: ShapeBorderClipper(shape: properties.shape),
        child: DecoratedBox(
          decoration: BoxDecoration(color: properties.fallbackColor),
          child: child,
        ),
      );
    }

    final tintColor = AcrylicHelper.getEffectiveTintColor(
      properties.tint,
      properties.tintAlpha,
      luminosityOpacity: properties.luminosityAlpha,
    );
    final luminosityColor = AcrylicHelper.getLuminosityColor(
      properties.tint,
      properties.luminosityAlpha,
      properties.tintAlpha,
    );

    return ClipPath(
      clipper: ShapeBorderClipper(shape: properties.shape),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: inherited.state.blurFilter,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              isComplex: true,
              painter: _AcrylicPainter(
                tintColor: tintColor,
                luminosityColor: luminosityColor,
              ),
            ),
          ),
          const Positioned.fill(child: _AcrylicNoise()),
          child,
        ],
      ),
    );
  }
}

class _AcrylicNoise extends StatelessWidget {
  const _AcrylicNoise();

  @override
  Widget build(BuildContext context) {
    return const Opacity(
      opacity: 0.02,
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/AcrylicNoise.png', package: 'fluent_ui'),
            alignment: AlignmentDirectional.topStart,
            repeat: ImageRepeat.repeat,
          ),
        ),
      ),
    );
  }
}

class _AcrylicPainter extends CustomPainter {
  final Color luminosityColor;
  final Color tintColor;

  const _AcrylicPainter({
    required this.luminosityColor,
    required this.tintColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(luminosityColor, BlendMode.luminosity);
    canvas.drawColor(
      tintColor,
      tintColor.a >= 1 ? BlendMode.src : BlendMode.color,
    );
  }

  @override
  bool shouldRepaint(covariant _AcrylicPainter old) {
    return luminosityColor != old.luminosityColor || tintColor != old.tintColor;
  }
}

/// Microsoft Acrylic helper calculations converted from WinUI's
/// `AcrylicBrush` implementation.
class AcrylicHelper {
  /// Gets the effective tint color of Acrylic.
  ///
  /// [tintOpacity] is equivalent to WinUI `TintOpacity`. When
  /// [luminosityOpacity] is null, the WinUI tint opacity modifier is applied.
  static Color getEffectiveTintColor(
    Color color,
    double tintOpacity, {
    double? luminosityOpacity,
  }) {
    final opacity = clampDouble(tintOpacity, 0, 1);
    final modifier = luminosityOpacity == null
        ? getTintOpacityModifier(color)
        : 1.0;
    return color.withValues(alpha: color.a * opacity * modifier);
  }

  /// Gets the luminosity color of Acrylic.
  ///
  /// [tintOpacity] is applied to the original tint before the luminosity
  /// calculation, matching WinUI's `GetEffectiveLuminosityColor`.
  static Color getLuminosityColor(
    Color tintColor,
    double? luminosityOpacity, [
    double tintOpacity = 1,
  ]) {
    final sourceTint = tintColor.withValues(
      alpha: tintColor.a * clampDouble(tintOpacity, 0, 1),
    );

    if (luminosityOpacity != null) {
      return sourceTint.withValues(alpha: clampDouble(luminosityOpacity, 0, 1));
    }

    const minHsvV = 0.125;
    const maxHsvV = 0.965;
    final hsvTintColor = HSVColor.fromColor(sourceTint);
    final clampedHsvV = clampDouble(hsvTintColor.value, minHsvV, maxHsvV);
    final rgbLuminosityColor = hsvTintColor.withValue(clampedHsvV).toColor();

    const minLuminosityOpacity = 0.15;
    const maxLuminosityOpacity = 1.03;
    final mappedTintOpacity =
        (sourceTint.a * (maxLuminosityOpacity - minLuminosityOpacity)) +
        minLuminosityOpacity;

    return rgbLuminosityColor.withValues(alpha: math.min(mappedTintOpacity, 1));
  }

  /// Gets WinUI's tint opacity modifier for [color].
  ///
  /// The modifier suppresses tint opacity as HSV value moves away from 50%,
  /// while saturated colors receive less suppression. The deviation is the
  /// absolute distance from the midpoint, as in WinUI's implementation.
  static double getTintOpacityModifier(Color color) {
    const midPoint = 0.50;
    const whiteMaxOpacity = 0.45;
    const midPointMaxOpacity = 0.90;
    const blackMaxOpacity = 0.85;

    final hsv = HSVColor.fromColor(color);
    var opacityModifier = midPointMaxOpacity;

    if (hsv.value != midPoint) {
      var lowestMaxOpacity = midPointMaxOpacity;
      var maxDeviation = midPoint;

      if (hsv.value > midPoint) {
        lowestMaxOpacity = whiteMaxOpacity;
        maxDeviation = 1 - maxDeviation;
      } else {
        lowestMaxOpacity = blackMaxOpacity;
      }

      var maxOpacitySuppression = midPointMaxOpacity - lowestMaxOpacity;
      final normalizedDeviation = (hsv.value - midPoint).abs() / maxDeviation;

      if (hsv.saturation > 0) {
        maxOpacitySuppression *= math.max(1 - (hsv.saturation * 2), 0.0);
      }

      opacityModifier =
          midPointMaxOpacity - (maxOpacitySuppression * normalizedDeviation);
    }

    return opacityModifier;
  }
}

/// A widget that disables the acrylic effect for its descendants.
///
/// The descendant Acrylic widgets retain their layout and paint their
/// theme-resolved [Acrylic.fallbackColor] as an opaque solid surface.
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
  bool updateShouldNotify(DisableAcrylic oldWidget) => true;
}
