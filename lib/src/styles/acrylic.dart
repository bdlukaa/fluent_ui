import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'dart:ui' as ui show Image;
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
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
  AcrylicProperties _properties = AcrylicProperties.empty();

  @override
  void initState() {
    super.initState();
    _NoiseTextureCacher._instance ??= _NoiseTextureCacher._new();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
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
      : this.tint = Colors.black,
        this.tintAlpha = kDefaultAcrylicAlpha,
        this.luminosityAlpha = kDefaultAcrylicAlpha,
        this.blurAmount = kBlurAmount,
        this.shape = const RoundedRectangleBorder();

  @override
  int get hashCode => hashValues(
        tint,
        tintAlpha,
        luminosityAlpha,
        blurAmount,
        shape,
      );

  bool operator ==(Object other) {
    if (other is AcrylicProperties) {
      return this.tint == other.tint &&
          this.tintAlpha == other.tintAlpha &&
          this.luminosityAlpha == other.luminosityAlpha &&
          this.blurAmount == other.blurAmount &&
          this.shape == other.shape;
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
    return this.state != old.state;
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

    return ClipPath(
      clipper: ShapeBorderClipper(shape: properties.shape),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: properties.blurAmount,
          sigmaY: properties.blurAmount,
        ),
        child: CustomPaint(
          painter: _AcrylicPainter(
            tintColor: _tint,
            luminosityColor: AcrylicHelper.getLuminosityColor(
              _tint,
              properties.luminosityAlpha,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _AcrylicPainter extends CustomPainter {
  final Color luminosityColor;
  final Color tintColor;

  _AcrylicPainter({
    required this.luminosityColor,
    required this.tintColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(luminosityColor, BlendMode.luminosity);
    canvas.drawColor(
      tintColor,
      tintColor.opacity == 1 ? BlendMode.srcIn : BlendMode.color,
    );
    if (_NoiseTextureCacher._instance!.texture != null) {
      _paintImage(
        canvas: canvas,
        rect: Offset.zero & size,
        image: _NoiseTextureCacher._instance!.texture!,
        opacity: 0.02,
        alignment: Alignment.topLeft,
        repeat: ImageRepeat.repeat,
        colorFilter: ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
      );
    }
  }

  @override
  bool shouldRepaint(_AcrylicPainter old) {
    return this.luminosityColor != old.luminosityColor ||
        this.tintColor != old.tintColor;
  }

  // TODO(bdlukaa): replace the method below with [paintImage] when it lands on stable

  Set<ImageSizeInfo> _lastFrameImageSizeInfo = <ImageSizeInfo>{};

  Map<String, ImageSizeInfo> _pendingImageSizeInfo = <String, ImageSizeInfo>{};

  void _paintImage({
    required Canvas canvas,
    required Rect rect,
    required ui.Image image,
    String? debugImageLabel,
    double scale = 1.0,
    double opacity = 1.0,
    ColorFilter? colorFilter,
    BoxFit? fit,
    Alignment alignment = Alignment.center,
    Rect? centerSlice,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    bool flipHorizontally = false,
    bool invertColors = false,
    FilterQuality filterQuality = FilterQuality.low,
    bool isAntiAlias = false,
  }) {
    assert(
      image.debugGetOpenHandleStackTraces()?.isNotEmpty ?? true,
      'Cannot paint an image that is disposed.\n'
      'The caller of paintImage is expected to wait to dispose the image until '
      'after painting has completed.',
    );

    Rect _scaleRect(Rect rect, double scale) => Rect.fromLTRB(rect.left * scale,
        rect.top * scale, rect.right * scale, rect.bottom * scale);

    Iterable<Rect> _generateImageTileRects(
        Rect outputRect, Rect fundamentalRect, ImageRepeat repeat) sync* {
      int startX = 0;
      int startY = 0;
      int stopX = 0;
      int stopY = 0;
      final double strideX = fundamentalRect.width;
      final double strideY = fundamentalRect.height;

      if (repeat == ImageRepeat.repeat || repeat == ImageRepeat.repeatX) {
        startX = ((outputRect.left - fundamentalRect.left) / strideX).floor();
        stopX = ((outputRect.right - fundamentalRect.right) / strideX).ceil();
      }

      if (repeat == ImageRepeat.repeat || repeat == ImageRepeat.repeatY) {
        startY = ((outputRect.top - fundamentalRect.top) / strideY).floor();
        stopY = ((outputRect.bottom - fundamentalRect.bottom) / strideY).ceil();
      }

      for (int i = startX; i <= stopX; ++i) {
        for (int j = startY; j <= stopY; ++j)
          yield fundamentalRect.shift(Offset(i * strideX, j * strideY));
      }
    }

    if (rect.isEmpty) return;
    Size outputSize = rect.size;
    Size inputSize = Size(image.width.toDouble(), image.height.toDouble());
    Offset? sliceBorder;
    if (centerSlice != null) {
      sliceBorder = inputSize / scale - centerSlice.size as Offset;
      outputSize = outputSize - sliceBorder as Size;
      inputSize = inputSize - sliceBorder * scale as Size;
    }
    fit ??= centerSlice == null ? BoxFit.scaleDown : BoxFit.fill;
    assert(centerSlice == null || (fit != BoxFit.none && fit != BoxFit.cover));
    final FittedSizes fittedSizes =
        applyBoxFit(fit, inputSize / scale, outputSize);
    final Size sourceSize = fittedSizes.source * scale;
    Size destinationSize = fittedSizes.destination;
    if (centerSlice != null) {
      outputSize += sliceBorder!;
      destinationSize += sliceBorder;
      // We don't have the ability to draw a subset of the image at the same time
      // as we apply a nine-patch stretch.
      assert(sourceSize == inputSize,
          'centerSlice was used with a BoxFit that does not guarantee that the image is fully visible.');
    }

    if (repeat != ImageRepeat.noRepeat && destinationSize == outputSize) {
      // There's no need to repeat the image because we're exactly filling the
      // output rect with the image.
      repeat = ImageRepeat.noRepeat;
    }
    final Paint paint = Paint()..isAntiAlias = isAntiAlias;
    if (colorFilter != null) paint.colorFilter = colorFilter;
    paint.color = Color.fromRGBO(0, 0, 0, opacity);
    paint.filterQuality = filterQuality;
    paint.invertColors = invertColors;
    final double halfWidthDelta =
        (outputSize.width - destinationSize.width) / 2.0;
    final double halfHeightDelta =
        (outputSize.height - destinationSize.height) / 2.0;
    final double dx = halfWidthDelta +
        (flipHorizontally ? -alignment.x : alignment.x) * halfWidthDelta;
    final double dy = halfHeightDelta + alignment.y * halfHeightDelta;
    final Offset destinationPosition = rect.topLeft.translate(dx, dy);
    final Rect destinationRect = destinationPosition & destinationSize;

    // Set to true if we added a saveLayer to the canvas to invert/flip the image.
    bool invertedCanvas = false;
    // Output size and destination rect are fully calculated.
    if (!kReleaseMode) {
      final ImageSizeInfo sizeInfo = ImageSizeInfo(
        // Some ImageProvider implementations may not have given this.
        source: debugImageLabel ??
            '<Unknown Image(${image.width}×${image.height})>',
        imageSize: Size(image.width.toDouble(), image.height.toDouble()),
        displaySize: outputSize,
      );
      assert(() {
        if (debugInvertOversizedImages &&
            sizeInfo.decodedSizeInBytes >
                sizeInfo.displaySizeInBytes + debugImageOverheadAllowance) {
          final int overheadInKilobytes =
              (sizeInfo.decodedSizeInBytes - sizeInfo.displaySizeInBytes) ~/
                  1024;
          final int outputWidth = outputSize.width.toInt();
          final int outputHeight = outputSize.height.toInt();
          FlutterError.reportError(FlutterErrorDetails(
            exception: 'Image $debugImageLabel has a display size of '
                '$outputWidth×$outputHeight but a decode size of '
                '${image.width}×${image.height}, which uses an additional '
                '${overheadInKilobytes}KB.\n\n'
                'Consider resizing the asset ahead of time, supplying a cacheWidth '
                'parameter of $outputWidth, a cacheHeight parameter of '
                '$outputHeight, or using a ResizeImage.',
            library: 'painting library',
            context: ErrorDescription('while painting an image'),
          ));
          // Invert the colors of the canvas.
          canvas.saveLayer(
            destinationRect,
            Paint()
              ..colorFilter = const ColorFilter.matrix(<double>[
                -1,
                0,
                0,
                0,
                255,
                0,
                -1,
                0,
                0,
                255,
                0,
                0,
                -1,
                0,
                255,
                0,
                0,
                0,
                1,
                0,
              ]),
          );
          // Flip the canvas vertically.
          final double dy = -(rect.top + rect.height / 2.0);
          canvas.translate(0.0, -dy);
          canvas.scale(1.0, -1.0);
          canvas.translate(0.0, dy);
          invertedCanvas = true;
        }
        return true;
      }());
      // Avoid emitting events that are the same as those emitted in the last frame.
      if (!_lastFrameImageSizeInfo.contains(sizeInfo)) {
        final ImageSizeInfo? existingSizeInfo =
            _pendingImageSizeInfo[sizeInfo.source];
        if (existingSizeInfo == null ||
            existingSizeInfo.displaySizeInBytes < sizeInfo.displaySizeInBytes) {
          _pendingImageSizeInfo[sizeInfo.source!] = sizeInfo;
        }
        debugOnPaintImage?.call(sizeInfo);
        SchedulerBinding.instance!.addPostFrameCallback((Duration timeStamp) {
          _lastFrameImageSizeInfo = _pendingImageSizeInfo.values.toSet();
          if (_pendingImageSizeInfo.isEmpty) {
            return;
          }
          developer.postEvent(
            'Flutter.ImageSizesForFrame',
            <String, Object>{
              for (ImageSizeInfo imageSizeInfo in _pendingImageSizeInfo.values)
                imageSizeInfo.source!: imageSizeInfo.toJson(),
            },
          );
          _pendingImageSizeInfo = <String, ImageSizeInfo>{};
        });
      }
    }

    final bool needSave = centerSlice != null ||
        repeat != ImageRepeat.noRepeat ||
        flipHorizontally;
    if (needSave) canvas.save();
    if (repeat != ImageRepeat.noRepeat) canvas.clipRect(rect);
    if (flipHorizontally) {
      final double dx = -(rect.left + rect.width / 2.0);
      canvas.translate(-dx, 0.0);
      canvas.scale(-1.0, 1.0);
      canvas.translate(dx, 0.0);
    }
    if (centerSlice == null) {
      final Rect sourceRect = alignment.inscribe(
        sourceSize,
        Offset.zero & inputSize,
      );
      if (repeat == ImageRepeat.noRepeat) {
        canvas.drawImageRect(image, sourceRect, destinationRect, paint);
      } else {
        for (final Rect tileRect
            in _generateImageTileRects(rect, destinationRect, repeat))
          canvas.drawImageRect(image, sourceRect, tileRect, paint);
      }
    } else {
      canvas.scale(1 / scale);
      if (repeat == ImageRepeat.noRepeat) {
        canvas.drawImageNine(image, _scaleRect(centerSlice, scale),
            _scaleRect(destinationRect, scale), paint);
      } else {
        for (final Rect tileRect
            in _generateImageTileRects(rect, destinationRect, repeat))
          canvas.drawImageNine(image, _scaleRect(centerSlice, scale),
              _scaleRect(tileRect, scale), paint);
      }
    }
    if (needSave) canvas.restore();

    if (invertedCanvas) {
      canvas.restore();
    }
  }
}

/// Microsoft utils converted from C# to dart
class AcrylicHelper {
  static Color getEffectiveTintColor(Color color, double opacity) =>
      color.withOpacity(opacity);

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
    final ImageProvider provider = AssetImage(
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
