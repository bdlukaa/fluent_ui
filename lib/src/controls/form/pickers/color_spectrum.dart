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
    super.key,
    required this.colorState,
    required this.onColorChanged,
    this.minHue = 0,
    this.maxHue = 360,
    this.minSaturation = 0,
    this.maxSaturation = 100,
  })  : assert(minHue >= 0 && minHue <= maxHue && maxHue <= 360,
            'Hue values must be between 0 and 360'),
        assert(
            minSaturation >= 0 &&
                minSaturation <= maxSaturation &&
                maxSaturation <= 100,
            'Saturation values must be between 0 and 100');

  @override
  State<ColorRingSpectrum> createState() => _ColorRingSpectrumState();
}

class _ColorRingSpectrumState extends State<ColorRingSpectrum> {
  bool _showLabel = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      child: CustomPaint(
        painter: ColorWheelPainter(
          colorState: widget.colorState,
          showLabel: _showLabel,
          theme: FluentTheme.of(context),
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
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width, size.height) / 2;

    // Calculate distance from center
    double x = position.dx - center.dx;
    double y = position.dy - center.dy;
    double distance = math.sqrt(x * x + y * y);

    // If the point is outside the wheel, bring it back into the circle
    if (distance > radius) {
      x *= (radius / distance);
      y *= (radius / distance);
      distance = radius;
    }

    // Calculate angle and map it directly to minHue~maxHue range
    double angle = math.atan2(y, x) * 180 / math.pi;
    angle = (angle + 360) % 360;

    // Map the 0-360 angle range to minHue-maxHue range
    final h = widget.minHue + (angle / 360) * (widget.maxHue - widget.minHue);

    // Map the 0-1 distance range to minSaturation-maxSaturation range
    final normalizedDistance = distance / radius;
    final s = normalizedDistance *
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
    super.key,
    required this.colorState,
    required this.onColorChanged,
    this.minHue = 0,
    this.maxHue = 360,
    this.minSaturation = 0,
    this.maxSaturation = 100,
  })  : assert(minHue >= 0 && minHue <= maxHue && maxHue <= 360,
            'Hue values must be between 0 and 360'),
        assert(
            minSaturation >= 0 &&
                minSaturation <= maxSaturation &&
                maxSaturation <= 100,
            'Saturation values must be between 0 and 100');

  @override
  State<ColorBoxSpectrum> createState() => _ColorBoxSpectrumState();
}

class _ColorBoxSpectrumState extends State<ColorBoxSpectrum> {
  bool _showLabel = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.resources.dividerStrokeColorDefault,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: CustomPaint(
          painter: ColorBoxPainter(
            colorState: widget.colorState,
            showLabel: _showLabel,
            theme: theme,
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
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;

    final double width = size.width;
    final double height = size.height;

    // Clamp position within bounds
    final double x = position.dx.clamp(0, width);
    final double y = position.dy.clamp(0, height);

    // Calculate HSV values
    // Hue from left to right (minHue to maxHue)
    final double h =
        widget.minHue + (x / width) * (widget.maxHue - widget.minHue);
    // Saturation from top (maxSaturation) to bottom (minSaturation)
    final double s = widget.maxSaturation / 100 -
        (y / height) * (widget.maxSaturation - widget.minSaturation) / 100;

    // Note: HSL value is not set in the box spectrum.
    widget.colorState.setHue(h);
    widget.colorState.setSaturation(s);

    widget.onColorChanged(widget.colorState);
  }
}

/// Custom painter for the color wheel in the [ColorPicker].
///
/// This painter draws a color wheel with saturation and hue gradients,
/// and an indicator for the currently selected color. It also displays
/// a label with the color name when the user interacts with the wheel.
class ColorWheelPainter extends CustomPainter {
  /// The current color state
  final ColorState colorState;

  /// Whether to show the color name label
  final bool showLabel;

  /// The theme data for styling
  final FluentThemeData theme;

  /// The minimum allowed hue value (0-360)
  final int minHue;

  /// The maximum allowed hue value (0-360)
  final int maxHue;

  /// The minimum allowed saturation value (0-100)
  final int minSaturation;

  /// The maximum allowed saturation value (0-100)
  final int maxSaturation;

  /// Creates a new instance of [ColorWheelPainter].
  ///
  /// - [colorState]: The current color state.
  /// - [showLabel]: Whether to show the color name label.
  /// - [theme]: The theme data for styling.
  /// - [minHue]: The minimum allowed hue value (0-360).
  /// - [maxHue]: The maximum allowed hue value (0-360).
  /// - [minSaturation]: The minimum allowed saturation value (0-100).
  /// - [maxSaturation]: The maximum allowed saturation value (0-100).
  ColorWheelPainter({
    required this.colorState,
    required this.showLabel,
    required this.theme,
    this.minHue = 0,
    this.maxHue = 360,
    this.minSaturation = 0,
    this.maxSaturation = 1,
  })  : assert(minHue >= 0 && minHue <= maxHue && maxHue <= 360,
            'Hue values must be between 0 and 360'),
        assert(
            minSaturation >= 0 &&
                minSaturation <= maxSaturation &&
                maxSaturation <= 100,
            'Saturation values must be between 0 and 100'),
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
        center: Alignment.center,
        radius: 1.0,
        stops: const [0.0, 0.5],
        colors: [
          HSVColor.fromAHSV(1.0, mappedHue, minSaturation / 100, 1.0).toColor(),
          HSVColor.fromAHSV(1.0, mappedHue, maxSaturation / 100, 1.0).toColor(),
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
    final rgb = ColorState.hsvToRgb(colorState.hue, colorState.saturation, 1.0);
    final fillColor = Color.fromARGB(255, (rgb.$1 * 255).round(),
        (rgb.$2 * 255).round(), (rgb.$3 * 255).round());
    final double brightness = 0.299 * rgb.$1 + 0.587 * rgb.$2 + 0.114 * rgb.$3;
    final strokeColor = brightness > 0.5 ? Colors.black : Colors.white;

    // Draw white circle with black border for indicator
    canvas.drawCircle(
      indicatorOffset,
      8,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawCircle(
      indicatorOffset,
      7,
      Paint()..color = fillColor,
    );

    // Draw color name label if needed
    if (showLabel) {
      final colorName = colorState.guessColorName();
      _drawLabel(canvas, size, colorName, indicatorOffset);
    }
  }

  @override
  bool shouldRepaint(covariant ColorWheelPainter oldDelegate) {
    return colorState != oldDelegate.colorState ||
        showLabel != oldDelegate.showLabel ||
        theme != oldDelegate.theme;
  }

  void _drawLabel(Canvas canvas, Size size, String text, Offset position) {
    final backgroundColor = theme.resources.controlSolidFillColorDefault;
    final textColor = theme.resources.textFillColorPrimary;
    final borderRadius = BorderRadius.circular(4.0);
    const labelPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);

    final textSpan = TextSpan(
      text: text,
      style: TextStyle(color: textColor),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.left,
      textDirection: dart.TextDirection.ltr,
    )..layout();

    final labelWidth = textPainter.width + labelPadding.horizontal;
    final labelHeight = textPainter.height + labelPadding.vertical;
    final labelX = (position.dx - labelWidth / 2)
        .clamp(0, size.width - labelWidth)
        .toDouble();
    final labelY = (position.dy - labelHeight - 30)
        .clamp(0, size.height - labelHeight)
        .toDouble();

    final rect = Rect.fromLTWH(labelX, labelY, labelWidth, labelHeight);

    // Draw background with shadow
    final shadow = BoxShadow(
      color: Colors.black.withOpacity(0.1),
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
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          shadow.blurRadius,
        ),
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
      Offset(
        labelX + labelPadding.left,
        labelY + labelPadding.top,
      ),
    );
  }
}

/// Custom painter for the color box in the [ColorPicker].
///
/// This painter draws a color box with hue and saturation gradients,
/// and an indicator for the currently selected color. It also displays
/// a label with the color name when the user interacts with the box.
class ColorBoxPainter extends CustomPainter {
  /// The current color state
  final ColorState colorState;

  /// Whether to show the color name label
  final bool showLabel;

  /// The theme data for styling
  final FluentThemeData theme;

  /// The minimum allowed hue value (0-360)
  final int minHue;

  /// The maximum allowed hue value (0-360)
  final int maxHue;

  /// The minimum allowed saturation value (0-100)
  final int minSaturation;

  /// The maximum allowed saturation value (0-100)
  final int maxSaturation;

  /// Creates a new instance of [ColorBoxPainter].
  ///
  /// - [colorState]: The current color state.
  /// - [showLabel]: Whether to show the color name label.
  /// - [theme]: The theme data for styling.
  /// - [minHue]: The minimum allowed hue value (0-360).
  /// - [maxHue]: The maximum allowed hue value (0-360).
  /// - [minSaturation]: The minimum allowed saturation value (0-100).
  /// - [maxSaturation]: The maximum allowed saturation value (0-100).
  ColorBoxPainter({
    required this.colorState,
    required this.showLabel,
    required this.theme,
    this.minHue = 0,
    this.maxHue = 360,
    this.minSaturation = 0,
    this.maxSaturation = 100,
  })  : assert(minHue >= 0 && minHue <= maxHue && maxHue <= 360,
            'Hue values must be between 0 and 360'),
        assert(
            minSaturation >= 0 &&
                minSaturation <= maxSaturation &&
                maxSaturation <= 100,
            'Saturation values must be between 0 and 100'),
        super(repaint: colorState);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Draw hue gradient (left to right)
    final colors = List.generate(360, (index) {
      final hue = minHue + (index / 360) * (maxHue - minHue);
      return HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();
    });
    final hueGradient = LinearGradient(
      colors: colors,
    );

    canvas.drawRect(
      rect,
      Paint()..shader = hueGradient.createShader(rect),
    );

    // Draw brightness gradient (top to bottom)
    final saturationGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [(1 - maxSaturation / 100), (1 - minSaturation / 100)],
      colors: const [
        Colors.transparent,
        Colors.white,
      ],
    );

    canvas.drawRect(
      rect,
      Paint()..shader = hueGradient.createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()..shader = saturationGradient.createShader(rect),
    );

    // Draw current color indicator
    // Map the current hue and saturation to the box coordinates
    final normalizedHue = (colorState.hue - minHue) / (maxHue - minHue);
    final normalizedSaturation = (colorState.saturation * 100 - minSaturation) /
        (maxSaturation - minSaturation);

    final x = normalizedHue * size.width;
    final y = (1 - normalizedSaturation) * size.height;

    // Draw indicator with current color and white border
    // Calculate perceived brightness to determine stroke color
    final rgb = ColorState.hsvToRgb(colorState.hue, colorState.saturation, 1.0);
    final fillColor = Color.fromARGB(255, (rgb.$1 * 255).round(),
        (rgb.$2 * 255).round(), (rgb.$3 * 255).round());
    final double brightness = 0.299 * rgb.$1 + 0.587 * rgb.$2 + 0.114 * rgb.$3;
    final strokeColor = brightness > 0.5 ? Colors.black : Colors.white;

    // Draw white circle with black border for indicator
    canvas.drawCircle(
      Offset(x, y),
      8,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawCircle(
      Offset(x, y),
      7,
      Paint()..color = fillColor,
    );

    // Draw color name label if needed
    if (showLabel) {
      final colorName = colorState.guessColorName();
      _drawLabel(canvas, size, colorName, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant ColorBoxPainter oldDelegate) {
    return colorState != oldDelegate.colorState ||
        showLabel != oldDelegate.showLabel ||
        theme != oldDelegate.theme;
  }

  void _drawLabel(Canvas canvas, Size size, String text, Offset position) {
    final backgroundColor = theme.resources.controlSolidFillColorDefault;
    final textColor = theme.resources.textFillColorPrimary;
    final borderRadius = BorderRadius.circular(4.0);
    const labelPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);

    final textSpan = TextSpan(
      text: text,
      style: TextStyle(color: textColor),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.left,
      textDirection: dart.TextDirection.ltr,
    )..layout();

    final labelWidth = textPainter.width + labelPadding.horizontal;
    final labelHeight = textPainter.height + labelPadding.vertical;
    final labelX = (position.dx - labelWidth / 2)
        .clamp(0, size.width - labelWidth)
        .toDouble();
    final labelY = (position.dy - labelHeight - 30)
        .clamp(0, size.height - labelHeight)
        .toDouble();

    final rect = Rect.fromLTWH(labelX, labelY, labelWidth, labelHeight);

    // Draw background with shadow
    final shadow = BoxShadow(
      color: Colors.black.withOpacity(0.1),
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
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          shadow.blurRadius,
        ),
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
      Offset(
        labelX + labelPadding.left,
        labelY + labelPadding.top,
      ),
    );
  }
}

/// Custom painter for drawing a checkerboard pattern.
///
/// This painter is used to represent transparency in the [ColorPicker]'s alpha slider.
class CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const squareSize = 5;
    final paint = Paint();
    final width = size.width.toInt();
    final height = size.height.toInt();

    for (int i = 0; i < width; i += (squareSize * 2)) {
      for (int j = 0; j < height; j += (squareSize * 2)) {
        // Draw dark squares
        paint.color = const Color(0xFFD3D3D3); // Light gray
        canvas.drawRect(
          Rect.fromLTWH(i.toDouble(), j.toDouble(), squareSize.toDouble(),
              squareSize.toDouble()),
          paint,
        );
        canvas.drawRect(
          Rect.fromLTWH(
              (i + squareSize).toDouble(),
              (j + squareSize).toDouble(),
              squareSize.toDouble(),
              squareSize.toDouble()),
          paint,
        );

        // Draw light squares
        paint.color = Colors.white;
        canvas.drawRect(
          Rect.fromLTWH((i + squareSize).toDouble(), j.toDouble(),
              squareSize.toDouble(), squareSize.toDouble()),
          paint,
        );
        canvas.drawRect(
          Rect.fromLTWH(i.toDouble(), (j + squareSize).toDouble(),
              squareSize.toDouble(), squareSize.toDouble()),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
