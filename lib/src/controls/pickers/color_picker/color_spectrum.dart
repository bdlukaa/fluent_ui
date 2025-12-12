import 'dart:math' as math;
import 'dart:ui' as dart;

import 'package:fluent_ui/fluent_ui.dart';

import 'color_state.dart';

/// A widget that displays a color ring spectrum for selecting hue and saturation.
///
/// This widget allows users to select a color by interacting with a color ring.
/// The hue is selected by rotating around the ring, and the saturation is selected
/// by moving towards or away from the center of the ring.
class ColorRingSpectrum extends StatefulWidget {
  /// The current color state
  final ColorState colorState;

  /// Callback when the color changes
  final ValueChanged<ColorState> onColorChanged;

  /// The minimum allowed hue value (0-360)
  final int minHue;

  /// The maximum allowed hue value (0-360)
  final int maxHue;

  /// The minimum allowed saturation value (0-100)
  final int minSaturation;

  /// The maximum allowed saturation value (0-100)
  final int maxSaturation;

  /// Creates a new instance of [ColorRingSpectrum].
  ///
  /// - [colorState]: The current color state.
  /// - [onColorChanged]: Callback when the color changes.
  /// - [minHue]: The minimum allowed hue value (0-360).
  /// - [maxHue]: The maximum allowed hue value (0-360).
  /// - [minSaturation]: The minimum allowed saturation value (0-100).
  /// - [maxSaturation]: The maximum allowed saturation value (0-100).
  const ColorRingSpectrum({
    required this.colorState,
    required this.onColorChanged,
    super.key,
    this.minHue = 0,
    this.maxHue = 360,
    this.minSaturation = 0,
    this.maxSaturation = 100,
  }) : assert(
         minHue >= 0 && minHue <= maxHue && maxHue <= 360,
         'Hue values must be between 0 and 360',
       ),
       assert(
         minSaturation >= 0 &&
             minSaturation <= maxSaturation &&
             maxSaturation <= 100,
         'Saturation values must be between 0 and 100',
       );

  @override
  State<ColorRingSpectrum> createState() => _ColorRingSpectrumState();
}

class _ColorRingSpectrumState extends State<ColorRingSpectrum> {
  bool _showLabel = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final localizations = FluentLocalizations.of(context);

    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      child: CustomPaint(
        painter: _RingSpectrumPainter(
          colorState: widget.colorState,
          showLabel: _showLabel,
          theme: theme,
          localizations: localizations,
          minHue: widget.minHue,
          maxHue: widget.maxHue,
          minSaturation: widget.minSaturation,
          maxSaturation: widget.maxSaturation,
        ),
      ),
    );
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() => _showLabel = true);
    _updateColorFromWheel(details.localPosition);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _updateColorFromWheel(details.localPosition);
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() => _showLabel = false);
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _showLabel = true);
    _updateColorFromWheel(details.localPosition);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _showLabel = false);
  }

  void _updateColorFromWheel(Offset position) {
    final renderBox = context.findRenderObject()! as RenderBox;
    final size = renderBox.size;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Calculate distance from center
    var x = position.dx - center.dx;
    var y = position.dy - center.dy;
    var distance = math.sqrt(x * x + y * y);

    // If the point is outside the wheel, bring it back into the circle
    if (distance > radius) {
      x *= radius / distance;
      y *= radius / distance;
      distance = radius;
    }

    // Calculate angle and map it directly to minHue~maxHue range
    var angle = math.atan2(y, x) * 180 / math.pi;
    angle = (angle + 360) % 360;

    // Map the 0-360 angle range to minHue-maxHue range
    final h = widget.minHue + (angle / 360) * (widget.maxHue - widget.minHue);

    // Map the 0-1 distance range to minSaturation-maxSaturation range
    final normalizedDistance = distance / radius;
    final s =
        normalizedDistance *
            (widget.maxSaturation - widget.minSaturation) /
            100 +
        widget.minSaturation / 100;

    // Note: HSL value is not set in the box spectrum.
    widget.colorState.setHue(h);
    widget.colorState.setSaturation(s);

    widget.onColorChanged(widget.colorState);
  }
}

/// A widget that displays a color box spectrum for selecting hue and saturation.
///
/// This widget allows users to select a color by interacting with a color box.
/// The hue is selected by moving horizontally, and the saturation is selected
/// by moving vertically.
class ColorBoxSpectrum extends StatefulWidget {
  /// The current color state
  final ColorState colorState;

  /// Callback when the color changes
  final ValueChanged<ColorState> onColorChanged;

  /// The minimum allowed hue value (0-360)
  final int minHue;

  /// The maximum allowed hue value (0-360)
  final int maxHue;

  /// The minimum allowed saturation value (0-100)
  final int minSaturation;

  /// The maximum allowed saturation value (0-100)
  final int maxSaturation;

  /// Creates a new instance of [ColorBoxSpectrum].
  ///
  /// - [colorState]: The current color state.
  /// - [onColorChanged]: Callback when the color changes.
  /// - [minHue]: The minimum allowed hue value (0-360).
  /// - [maxHue]: The maximum allowed hue value (0-360).
  /// - [minSaturation]: The minimum allowed saturation value (0-100).
  /// - [maxSaturation]: The maximum allowed saturation value (0-100).
  const ColorBoxSpectrum({
    required this.colorState,
    required this.onColorChanged,
    super.key,
    this.minHue = 0,
    this.maxHue = 360,
    this.minSaturation = 0,
    this.maxSaturation = 100,
  }) : assert(
         minHue >= 0 && minHue <= maxHue && maxHue <= 360,
         'Hue values must be between 0 and 360',
       ),
       assert(
         minSaturation >= 0 &&
             minSaturation <= maxSaturation &&
             maxSaturation <= 100,
         'Saturation values must be between 0 and 100',
       );

  @override
  State<ColorBoxSpectrum> createState() => _ColorBoxSpectrumState();
}

class _ColorBoxSpectrumState extends State<ColorBoxSpectrum> {
  bool _showLabel = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final localizations = FluentLocalizations.of(context);

    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.resources.dividerStrokeColorDefault),
          borderRadius: BorderRadius.circular(4),
        ),
        child: CustomPaint(
          painter: _BoxSpectrumPainter(
            colorState: widget.colorState,
            showLabel: _showLabel,
            theme: theme,
            localizations: localizations,
            minHue: widget.minHue,
            maxHue: widget.maxHue,
            minSaturation: widget.minSaturation,
            maxSaturation: widget.maxSaturation,
          ),
        ),
      ),
    );
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() => _showLabel = true);
    _updateColorFromBox(details.localPosition);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _updateColorFromBox(details.localPosition);
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() => _showLabel = false);
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _showLabel = true);
    _updateColorFromBox(details.localPosition);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _showLabel = false);
  }

  void _updateColorFromBox(Offset position) {
    final renderBox = context.findRenderObject()! as RenderBox;
    final size = renderBox.size;

    final width = size.width;
    final height = size.height;

    // Clamp position within bounds
    final x = position.dx.clamp(0, width);
    final y = position.dy.clamp(0, height);

    // Calculate HSV values
    // Hue from left to right (minHue to maxHue)
    final h = widget.minHue + (x / width) * (widget.maxHue - widget.minHue);
    // Saturation from top (maxSaturation) to bottom (minSaturation)
    final s =
        widget.maxSaturation / 100 -
        (y / height) * (widget.maxSaturation - widget.minSaturation) / 100;

    // Note: HSL value is not set in the box spectrum.
    widget.colorState.setHue(h);
    widget.colorState.setSaturation(s);

    widget.onColorChanged(widget.colorState);
  }
}

/// Custom painter for rendering a ring-shaped color spectrum.
///
/// This painter draws a ring-shaped gradient representing a spectrum of hues
/// and saturations. It also supports displaying an indicator for the currently
/// selected color and an optional label with the color name during interaction.
class _RingSpectrumPainter extends CustomPainter {
  /// The current color state
  final ColorState colorState;

  /// Whether to show the color name label
  final bool showLabel;

  /// The theme data for styling
  final FluentThemeData theme;

  /// The localizations for color names
  final FluentLocalizations localizations;

  /// The minimum allowed hue value (0-360)
  final int minHue;

  /// The maximum allowed hue value (0-360)
  final int maxHue;

  /// The minimum allowed saturation value (0-100)
  final int minSaturation;

  /// The maximum allowed saturation value (0-100)
  final int maxSaturation;

  /// Creates a new instance of [_RingSpectrumPainter].
  _RingSpectrumPainter({
    required this.colorState,
    required this.showLabel,
    required this.theme,
    required this.localizations,
    this.minHue = 0,
    this.maxHue = 360,
    this.minSaturation = 0,
    this.maxSaturation = 1,
  }) : assert(
         minHue >= 0 && minHue <= maxHue && maxHue <= 360,
         'Hue values must be between 0 and 360',
       ),
       assert(
         minSaturation >= 0 &&
             minSaturation <= maxSaturation &&
             maxSaturation <= 100,
         'Saturation values must be between 0 and 100',
       ),
       super(repaint: colorState);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Draw color wheel with saturation
    for (double angle = 0; angle < 360; angle += 0.2) {
      final radians = angle * math.pi / 180;

      final mappedHue = minHue + (angle / 360) * (maxHue - minHue);
      final shader = RadialGradient(
        radius: 1,
        stops: const [0.0, 0.5],
        colors: [
          HSVColor.fromAHSV(1, mappedHue, minSaturation / 100, 1).toColor(),
          HSVColor.fromAHSV(1, mappedHue, maxSaturation / 100, 1).toColor(),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      final paint = Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        radians,
        0.02,
        true,
        paint,
      );
    }

    // Draw current color indicator
    final normalizedHue = (maxHue == minHue)
        ? maxHue
        : (colorState.hue - minHue) / (maxHue - minHue) * 360; // [0..360]
    final normalizedSaturation = (maxSaturation == minSaturation)
        ? maxSaturation / 100
        : (colorState.saturation * 100 - minSaturation) /
              (maxSaturation - minSaturation); // [0..1]

    final radians = normalizedHue * math.pi / 180.0;
    final distance = normalizedSaturation * radius;
    final indicatorOffset = Offset(
      center.dx + math.cos(radians) * distance,
      center.dy + math.sin(radians) * distance,
    );

    // Draw indicator with current color and border
    // Calculate perceived brightness to determine stroke color
    final rgb = ColorState.hsvToRgb(
      HsvComponents(colorState.hue, colorState.saturation, 1),
    );
    final fillColor = Color.fromARGB(
      255,
      (rgb.r * 255).round(),
      (rgb.g * 255).round(),
      (rgb.b * 255).round(),
    );

    // Compute relative luminance to determine optimal stroke color visibility
    final relativeLuminance = ColorState.relativeLuminance(fillColor);
    final brightness = (relativeLuminance + 0.05) * (relativeLuminance + 0.05);

    // Choose stroke color based on background brightness
    // Threshold: 0.30 (based on WinUI 3 ColorPicker testing)
    // - Above threshold: black stroke for light backgrounds
    // - Below threshold: white stroke for dark backgrounds
    // Reference:
    // - Flutter Material uses 0.15 threshold (https://api.flutter.dev/flutter/material/ThemeData/estimateBrightnessForColor.html)
    // - This implementation follows WinUI 3's 0.30 threshold
    final strokeColor = brightness > 0.30 ? Colors.black : Colors.white;

    // Draw white circle with black border for indicator
    canvas.drawCircle(
      indicatorOffset,
      7.5,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Draw color name label if needed
    if (showLabel) {
      final colorKey = colorState.guessColorName();
      final displayName = localizations.getColorDisplayName(colorKey);
      _drawLabel(canvas, size, displayName, indicatorOffset);
    }
  }

  @override
  bool shouldRepaint(covariant _RingSpectrumPainter oldDelegate) {
    return colorState != oldDelegate.colorState ||
        showLabel != oldDelegate.showLabel ||
        theme != oldDelegate.theme;
  }

  void _drawLabel(Canvas canvas, Size size, String text, Offset position) {
    final backgroundColor = theme.resources.controlSolidFillColorDefault;
    final textColor = theme.resources.textFillColorPrimary;
    final borderRadius = BorderRadius.circular(4);
    const labelPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);

    final textSpan = TextSpan(
      text: text,
      style: TextStyle(color: textColor),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: dart.TextDirection.ltr,
    )..layout();

    final labelWidth = textPainter.width + labelPadding.horizontal;
    final labelHeight = textPainter.height + labelPadding.vertical;
    final labelX = (position.dx - labelWidth / 2)
        .clamp(0, size.width - labelWidth)
        .toDouble();
    var labelY = (position.dy - labelHeight - 30)
        .clamp(0, size.height - labelHeight)
        .toDouble();

    // Check if label would overlap the indicator and adjust position
    final labelBottomY = labelY + labelHeight;
    if (position.dy < labelBottomY) {
      labelY = position.dy + labelHeight - 5;
    }

    final rect = Rect.fromLTWH(labelX, labelY, labelWidth, labelHeight);

    // Draw background with shadow
    final shadow = BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    );

    // Draw shadow
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rect.shift(shadow.offset).inflate(shadow.spreadRadius),
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
      ),
      Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurRadius),
    );

    // Draw background
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rect,
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
      ),
      Paint()..color = backgroundColor,
    );

    // Draw text
    textPainter.paint(
      canvas,
      Offset(labelX + labelPadding.left, labelY + labelPadding.top),
    );
  }
}

/// Custom painter for rendering a box-shaped color spectrum.
///
/// This painter draws a rectangular color spectrum with gradients representing
/// hue (left to right) and saturation (top to bottom). It also supports displaying
/// an indicator for the currently selected color and an optional label with the
/// color name during interaction.
class _BoxSpectrumPainter extends CustomPainter {
  /// The current color state
  final ColorState colorState;

  /// Whether to show the color name label
  final bool showLabel;

  /// The theme data for styling
  final FluentThemeData theme;

  /// The localizations for color names
  final FluentLocalizations localizations;

  /// The minimum allowed hue value (0-360)
  final int minHue;

  /// The maximum allowed hue value (0-360)
  final int maxHue;

  /// The minimum allowed saturation value (0-100)
  final int minSaturation;

  /// The maximum allowed saturation value (0-100)
  final int maxSaturation;

  /// Creates a new instance of [_BoxSpectrumPainter].
  _BoxSpectrumPainter({
    required this.colorState,
    required this.showLabel,
    required this.theme,
    required this.localizations,
    this.minHue = 0,
    this.maxHue = 360,
    this.minSaturation = 0,
    this.maxSaturation = 100,
  }) : assert(
         minHue >= 0 && minHue <= maxHue && maxHue <= 360,
         'Hue values must be between 0 and 360',
       ),
       assert(
         minSaturation >= 0 &&
             minSaturation <= maxSaturation &&
             maxSaturation <= 100,
         'Saturation values must be between 0 and 100',
       ),
       super(repaint: colorState);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Draw hue gradient (left to right)
    final colors = List.generate(360, (index) {
      final hue = minHue + (index / 360) * (maxHue - minHue);
      return HSVColor.fromAHSV(1, hue, 1, 1).toColor();
    });
    final hueGradient = LinearGradient(colors: colors);

    canvas.drawRect(rect, Paint()..shader = hueGradient.createShader(rect));

    // Draw brightness gradient (top to bottom)
    final saturationGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [(1 - maxSaturation / 100), (1 - minSaturation / 100)],
      colors: const [Colors.transparent, Colors.white],
    );

    canvas.drawRect(rect, Paint()..shader = hueGradient.createShader(rect));

    canvas.drawRect(
      rect,
      Paint()..shader = saturationGradient.createShader(rect),
    );

    // Draw current color indicator
    // Map the current hue and saturation to the box coordinates
    final normalizedHue = (colorState.hue - minHue) / (maxHue - minHue);
    final normalizedSaturation =
        (colorState.saturation * 100 - minSaturation) /
        (maxSaturation - minSaturation);

    final x = normalizedHue * size.width;
    final y = (1 - normalizedSaturation) * size.height;

    // Draw indicator with current color and white border
    // Calculate perceived brightness to determine stroke color
    final rgb = ColorState.hsvToRgb(
      HsvComponents(colorState.hue, colorState.saturation, 1),
    );
    final fillColor = Color.fromARGB(
      255,
      (rgb.r * 255).round(),
      (rgb.g * 255).round(),
      (rgb.b * 255).round(),
    );

    // Compute relative luminance to determine optimal stroke color visibility
    final relativeLuminance = ColorState.relativeLuminance(fillColor);
    final brightness = (relativeLuminance + 0.05) * (relativeLuminance + 0.05);

    // Choose stroke color based on background brightness
    // Threshold: 0.30 (based on WinUI 3 ColorPicker testing)
    // - Above threshold: black stroke for light backgrounds
    // - Below threshold: white stroke for dark backgrounds
    // Reference:
    // - Flutter Material uses 0.15 threshold (https://api.flutter.dev/flutter/material/ThemeData/estimateBrightnessForColor.html)
    // - This implementation follows WinUI 3's 0.30 threshold
    final strokeColor = brightness > 0.30 ? Colors.black : Colors.white;

    // Draw white circle with black border for indicator
    canvas.drawCircle(
      Offset(x, y),
      7.5,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Draw color name label if needed
    if (showLabel) {
      final colorKey = colorState.guessColorName();
      final displayName = localizations.getColorDisplayName(colorKey);
      _drawLabel(canvas, size, displayName, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant _BoxSpectrumPainter oldDelegate) {
    return colorState != oldDelegate.colorState ||
        showLabel != oldDelegate.showLabel ||
        theme != oldDelegate.theme;
  }

  void _drawLabel(Canvas canvas, Size size, String text, Offset position) {
    final backgroundColor = theme.resources.controlSolidFillColorDefault;
    final textColor = theme.resources.textFillColorPrimary;
    final borderRadius = BorderRadius.circular(4);
    const labelPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);

    final textSpan = TextSpan(
      text: text,
      style: TextStyle(color: textColor),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: dart.TextDirection.ltr,
    )..layout();

    final labelWidth = textPainter.width + labelPadding.horizontal;
    final labelHeight = textPainter.height + labelPadding.vertical;
    final labelX = (position.dx - labelWidth / 2)
        .clamp(0, size.width - labelWidth)
        .toDouble();
    var labelY = (position.dy - labelHeight - 30)
        .clamp(0, size.height - labelHeight)
        .toDouble();

    // Check if label would overlap the indicator and adjust position
    final labelBottomY = labelY + labelHeight;
    if (position.dy < labelBottomY) {
      labelY = position.dy + labelHeight - 5;
    }

    final rect = Rect.fromLTWH(labelX, labelY, labelWidth, labelHeight);

    // Draw background with shadow
    final shadow = BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    );

    // Draw shadow
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rect.shift(shadow.offset).inflate(shadow.spreadRadius),
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
      ),
      Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurRadius),
    );

    // Draw background
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rect,
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
      ),
      Paint()..color = backgroundColor,
    );

    // Draw text
    textPainter.paint(
      canvas,
      Offset(labelX + labelPadding.left, labelY + labelPadding.top),
    );
  }
}

/// Custom painter for drawing a checkerboard pattern.
///
/// This painter is used to represent transparency in the [ColorPicker]'s alpha slider and preview box.
class CheckerboardPainter extends CustomPainter {
  /// The theme data for styling
  final FluentThemeData theme;

  /// Creates a checkboard painter.
  const CheckerboardPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    const squareSize = 4; // GCF of Slider width(12) and Preview width(44)
    final paint = Paint();
    final width = size.width.toInt();
    final height = size.height.toInt();

    for (var i = 0; i < width; i += squareSize) {
      for (var j = 0; j < height; j += squareSize) {
        // Determine if this position should be a dark square
        final isDarkSquare = (i ~/ squareSize + j ~/ squareSize) % 2 != 0;

        paint.color = isDarkSquare
            ? switch (theme.brightness) {
                Brightness.light => const Color(0x20D8D8D8),
                Brightness.dark => const Color(0x20393939),
              }
            : Colors.transparent;

        canvas.drawRect(
          Rect.fromLTWH(
            i.toDouble(),
            j.toDouble(),
            squareSize.toDouble(),
            squareSize.toDouble(),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CheckerboardPainter oldDelegate) =>
      theme != oldDelegate.theme;
}
