import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'color_spectrum.dart';
import 'color_state.dart';

/// Defines the shape of the color spectrum in the [ColorPicker].
enum ColorSpectrumShape {
  /// A ring-shaped color spectrum.
  ring,

  /// A box-shaped color spectrum.
  box,
}

/// Defines the color mode used in the [ColorPicker].
enum _ColorMode {
  /// RGB (Red, Green, Blue) color mode.
  rgb,

  /// HSV (Hue, Saturation, Value) color mode.
  hsv,
}

/// Color picker spacing constants
enum _ColorPickerSpacing {
  /// Small spacing between widgets
  small(12),

  /// Large spacing between widgets
  large(24);

  final double size;

  const _ColorPickerSpacing(this.size);
}

/// Color picker component sizing constants
enum _ColorPickerSizes {
  /// The size of the color spectrum widget
  spectrum(256),

  /// The width of the color preview box
  preview(44),

  /// The height of the sliders
  slider(12),

  /// The width of the input boxes
  inputBox(120);

  final double size;

  const _ColorPickerSizes(this.size);

  /// Define the computed maxWidth as a static constant
  static double get maxWidth =>
      spectrum.size + _ColorPickerSpacing.small.size + preview.size;
}

/// A control for selecting colors from a spectrum or via input.
///
/// [ColorPicker] lets users browse and select colors visually using a
/// color spectrum, or enter precise values using RGB, HSV, or hex input.
///
/// ![ColorPicker Preview](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/color-picker-default.png)
///
/// {@tool snippet}
/// This example shows a basic color picker:
///
/// ```dart
/// ColorPicker(
///   color: selectedColor,
///   onChanged: (color) => setState(() => selectedColor = color),
/// )
/// ```
/// {@end-tool}
///
/// ## Customization
///
/// The picker supports multiple configurations:
///
/// * [ColorSpectrumShape.ring] or [ColorSpectrumShape.box] spectrum shapes
/// * Show/hide color preview, sliders, and text inputs
/// * Vertical or horizontal orientation
/// * Alpha channel support via [isAlphaEnabled]
///
/// See also:
///
///  * [ColorSpectrumShape], for spectrum shape options
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/color-picker>
class ColorPicker extends StatefulWidget {
  /// The current color value
  final Color color;

  /// Called when the color value changes.
  final ValueChanged<Color> onChanged;

  /// The orientation of the color picker layout
  ///
  /// Defaults to [Axis.vertical].
  final Axis orientation;

  /// Whether the color preview is visible
  final bool isColorPreviewVisible;

  /// Whether the "More" button is visible
  final bool isMoreButtonVisible;

  /// Whether the color slider is visible
  final bool isColorSliderVisible;

  /// Whether the color channel text input is visible
  final bool isColorChannelTextInputVisible;

  /// Whether the hex input is visible
  final bool isHexInputVisible;

  /// Whether the alpha channel is enabled
  final bool isAlphaEnabled;

  /// Whether the alpha slider is visible
  final bool isAlphaSliderVisible;

  /// Whether the alpha text input is visible
  final bool isAlphaTextInputVisible;

  /// The shape of the color spectrum.
  ///
  /// Defaults to [ColorSpectrumShape.ring].
  final ColorSpectrumShape colorSpectrumShape;

  /// The minimum allowed hue value (0-359)
  final int minHue;

  /// The maximum allowed hue value (0-359)
  final int maxHue;

  /// The minimum allowed saturation value (0-100)
  final int minSaturation;

  /// The maximum allowed saturation value (0-100)
  final int maxSaturation;

  /// The minimum allowed value/brightness (0-100)
  final int minValue;

  /// The maximum allowed value/brightness (0-100)
  final int maxValue;

  /// Creates a windows-styled [ColorPicker].
  const ColorPicker({
    required this.color,
    required this.onChanged,
    super.key,
    this.orientation = Axis.vertical,
    this.colorSpectrumShape = ColorSpectrumShape.ring,
    this.isColorPreviewVisible = true,
    this.isColorSliderVisible = true,
    this.isMoreButtonVisible = true,
    this.isHexInputVisible = true,
    this.isColorChannelTextInputVisible = true,
    this.isAlphaEnabled = true,
    this.isAlphaSliderVisible = true,
    this.isAlphaTextInputVisible = true,
    this.minHue = 0,
    this.maxHue = 359,
    this.minSaturation = 0,
    this.maxSaturation = 100,
    this.minValue = 0,
    this.maxValue = 100,
  }) : assert(
         minHue >= 0 && minHue <= maxHue && maxHue <= 359,
         'Hue values must be between 0 and 359',
       ),
       assert(
         minSaturation >= 0 &&
             minSaturation <= maxSaturation &&
             maxSaturation <= 100,
         'Saturation values must be between 0 and 100',
       ),
       assert(
         minValue >= 0 && minValue <= maxValue && maxValue <= 100,
         'Value/brightness values must be between 0 and 100',
       );

  @override
  State<ColorPicker> createState() => _ColorPickerState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ColorProperty('color', color))
      ..add(EnumProperty<Axis>('orientation', orientation))
      ..add(
        EnumProperty<ColorSpectrumShape>(
          'colorSpectrumShape',
          colorSpectrumShape,
        ),
      )
      ..add(
        FlagProperty(
          'isColorPreviewVisible',
          value: isColorPreviewVisible,
          defaultValue: true,
          ifFalse: 'color preview hidden',
        ),
      )
      ..add(
        FlagProperty(
          'isColorSliderVisible',
          value: isColorSliderVisible,
          defaultValue: true,
          ifFalse: 'color slider hidden',
        ),
      )
      ..add(
        FlagProperty(
          'isMoreButtonVisible',
          value: isMoreButtonVisible,
          defaultValue: true,
          ifFalse: 'more button hidden',
        ),
      )
      ..add(
        FlagProperty(
          'isHexInputVisible',
          value: isHexInputVisible,
          defaultValue: true,
          ifFalse: 'hex input hidden',
        ),
      )
      ..add(
        FlagProperty(
          'isColorChannelTextInputVisible',
          value: isColorChannelTextInputVisible,
          defaultValue: true,
          ifFalse: 'color channel text input hidden',
        ),
      )
      ..add(
        FlagProperty(
          'isAlphaEnabled',
          value: isAlphaEnabled,
          defaultValue: true,
          ifFalse: 'alpha disabled',
        ),
      )
      ..add(
        FlagProperty(
          'isAlphaSliderVisible',
          value: isAlphaSliderVisible,
          defaultValue: true,
          ifFalse: 'alpha slider hidden',
        ),
      )
      ..add(
        FlagProperty(
          'isAlphaTextInputVisible',
          value: isAlphaTextInputVisible,
          defaultValue: true,
          ifFalse: 'alpha text input hidden',
        ),
      )
      ..add(IntProperty('minHue', minHue, defaultValue: 0))
      ..add(IntProperty('maxHue', maxHue, defaultValue: 359))
      ..add(IntProperty('minSaturation', minSaturation, defaultValue: 0))
      ..add(IntProperty('maxSaturation', maxSaturation, defaultValue: 100))
      ..add(IntProperty('minValue', minValue, defaultValue: 0))
      ..add(IntProperty('maxValue', maxValue, defaultValue: 100));
  }
}

class _ColorPickerState extends State<ColorPicker> {
  late TextEditingController _hexController;
  late FocusNode _hexFocusNode;

  late ColorState _colorState;

  bool _isMoreExpanded = false;

  @override
  void initState() {
    super.initState();
    _colorState = ColorState.fromColor(widget.color);
    _colorState.clampToBounds(
      minHue: widget.minHue,
      maxHue: widget.maxHue,
      minSaturation: widget.minSaturation,
      maxSaturation: widget.maxSaturation,
      minValue: widget.minValue,
      maxValue: widget.maxValue,
    );
    _initControllers();
    _updateControllers();
  }

  @override
  void didUpdateWidget(ColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      _updateControllers();
    }
  }

  @override
  void dispose() {
    _hexFocusNode.removeListener(_onFocusChange);
    _hexFocusNode.dispose();
    _hexController.dispose();
    _colorState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasFluentLocalizations(context));
    assert(debugCheckHasDirectionality(context));

    final theme = FluentTheme.of(context);
    final localizations = FluentLocalizations.of(context);

    final hasVisibleInputs =
        widget.isHexInputVisible ||
        widget.isColorChannelTextInputVisible ||
        (widget.isAlphaEnabled && widget.isAlphaTextInputVisible);

    final showMoreButton = widget.isMoreButtonVisible && hasVisibleInputs;

    final showInputs =
        hasVisibleInputs && (!widget.isMoreButtonVisible || _isMoreExpanded);

    // Build the color picker layout based on orientation
    if (widget.orientation == Axis.vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSpectrumAndPreview(),
          if (widget.isColorSliderVisible ||
              (widget.isAlphaEnabled && widget.isAlphaSliderVisible)) ...[
            SizedBox(height: _ColorPickerSpacing.large.size),
            _buildSliders(),
          ],
          if (showMoreButton) ...[
            SizedBox(height: _ColorPickerSpacing.large.size),
            _buildMoreButton(theme, localizations),
          ],
          if (showInputs) ...[
            if (!widget.isMoreButtonVisible) ...[
              SizedBox(height: _ColorPickerSpacing.large.size),
            ],
            _buildInputs(),
          ],
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSpectrumAndPreview(),
          if (widget.isColorSliderVisible ||
              (widget.isAlphaEnabled && widget.isAlphaSliderVisible)) ...[
            SizedBox(width: _ColorPickerSpacing.large.size),
            _buildSliders(),
          ],
          if (hasVisibleInputs) ...[
            SizedBox(width: _ColorPickerSpacing.large.size),
            _buildInputs(),
          ],
        ],
      );
    }
  }

  /// Initializes the text controllers and focus nodes.
  void _initControllers() {
    _hexController = TextEditingController();
    _hexFocusNode = FocusNode();
    _hexFocusNode.addListener(_onFocusChange);
  }

  /// Updates the text controllers with the current color state.
  void _updateControllers() {
    final oldText = _hexController.text;
    final newText = _colorState.toHexString(widget.isAlphaEnabled);
    if (oldText != newText) {
      _hexController.text = newText;
    }
  }

  /// Builds the color spectrum and color preview box.
  Widget _buildSpectrumAndPreview() {
    return _ColorSpectrumAndPreview(
      colorState: _colorState,
      orientation: widget.orientation,
      colorSpectrumShape: widget.colorSpectrumShape,
      isColorPreviewVisible: widget.isColorPreviewVisible,
      onColorChanged: _handleColorChanged,
      minHue: widget.minHue,
      maxHue: widget.maxHue,
      minSaturation: widget.minSaturation,
      maxSaturation: widget.maxSaturation,
    );
  }

  /// Builds the color sliders.
  Widget _buildSliders() {
    return _ColorSliders(
      colorState: _colorState,
      orientation: widget.orientation,
      isColorSliderVisible: widget.isColorSliderVisible,
      isAlphaSliderVisible: widget.isAlphaSliderVisible,
      isAlphaEnabled: widget.isAlphaEnabled,
      onColorChanged: _handleColorChanged,
      minValue: widget.minValue,
      maxValue: widget.maxValue,
    );
  }

  /// Builds the "More" button to expand the color picker inputs.
  Widget _buildMoreButton(
    FluentThemeData theme,
    FluentLocalizations localizations,
  ) {
    final moreButton = SizedBox(
      width: _ColorPickerSizes.inputBox.size,
      child: Button(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(
            EdgeInsetsDirectional.only(start: 8, end: 4, top: 8, bottom: 8),
          ),
          shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
          backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
          foregroundColor: WidgetStateColor.resolveWith((states) {
            if (states.isPressed) {
              return theme.resources.textFillColorTertiary;
            }
            if (states.isHovered || states.isFocused) {
              return theme.resources.textFillColorSecondary;
            }
            return theme.resources.textFillColorPrimary;
          }),
        ),
        onPressed: () => setState(() => _isMoreExpanded = !_isMoreExpanded),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              _isMoreExpanded ? localizations.lessText : localizations.moreText,
            ),
            const SizedBox(width: 8),
            Icon(
              _isMoreExpanded
                  ? FluentIcons.chevron_up
                  : FluentIcons.chevron_down,
              size: 10,
            ),
          ],
        ),
      ),
    );

    return SizedBox(
      width: _ColorPickerSizes.maxWidth,
      child: Align(alignment: Alignment.centerRight, child: moreButton),
    );
  }

  /// Builds the color inputs.
  Widget _buildInputs() {
    return _ColorInputs(
      colorState: _colorState,
      orientation: widget.orientation,
      isMoreExpanded: _isMoreExpanded,
      isMoreButtonVisible: widget.isMoreButtonVisible,
      isHexInputVisible: widget.isHexInputVisible,
      isColorChannelTextInputVisible: widget.isColorChannelTextInputVisible,
      isAlphaEnabled: widget.isAlphaEnabled,
      isAlphaTextInputVisible: widget.isAlphaTextInputVisible,
      hexController: _hexController,
      onColorChanged: _handleColorChanged,
      minHue: widget.minHue,
      maxHue: widget.maxHue,
      minSaturation: widget.minSaturation,
      maxSaturation: widget.maxSaturation,
      minValue: widget.minValue,
      maxValue: widget.maxValue,
    );
  }

  /// Handles color changes from the color spectrum, sliders, and inputs.
  void _handleColorChanged(ColorState newState) {
    newState.clampToBounds(
      minHue: widget.minHue,
      maxHue: widget.maxHue,
      minSaturation: widget.minSaturation,
      maxSaturation: widget.maxSaturation,
      minValue: widget.minValue,
      maxValue: widget.maxValue,
    );

    setState(() => _colorState = newState);
    widget.onChanged(newState.toColor());
  }

  /// Callback when the hex input field loses focus.
  void _onFocusChange() {
    if (!_hexFocusNode.hasFocus) {
      _updateHexColor(_hexController.text);
    }
  }

  /// Updates the color state based on the hex color value.
  void _updateHexColor(String text) {
    if (text.length == 7 || (widget.isAlphaEnabled && text.length == 9)) {
      try {
        _colorState.setHex(text);
        widget.onChanged(_colorState.toColor());
      } catch (_) {
        _updateControllers();
      }
    }
  }
}

/// A widget that displays the color spectrum and color preview box.
class _ColorSpectrumAndPreview extends StatelessWidget {
  /// The current color state
  final ColorState colorState;

  /// Callback when the color changes
  final ValueChanged<ColorState> onColorChanged;

  /// The orientation of the color picker layout
  final Axis orientation;

  /// The shape of the color spectrum
  final ColorSpectrumShape colorSpectrumShape;

  /// Whether the color preview is visible
  final bool isColorPreviewVisible;

  /// The minimum allowed hue value (0-359)
  final int minHue;

  /// The maximum allowed hue value (0-359)
  final int maxHue;

  /// The minimum allowed saturation value (0-100)
  final int minSaturation;

  /// The maximum allowed saturation value (0-100)
  final int maxSaturation;

  /// Creates a new instance of [_ColorSpectrumAndPreview].
  const _ColorSpectrumAndPreview({
    required this.colorState,
    required this.colorSpectrumShape,
    required this.onColorChanged,
    required this.orientation,
    required this.isColorPreviewVisible,
    required this.minHue,
    required this.maxHue,
    required this.minSaturation,
    required this.maxSaturation,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (orientation == Axis.horizontal) && !isColorPreviewVisible
          ? _ColorPickerSizes.spectrum.size
          : _ColorPickerSizes.maxWidth,
      height: _ColorPickerSizes.spectrum.size,
      child: isColorPreviewVisible
          ? Row(
              children: [
                _buildSpectrum(),
                SizedBox(width: _ColorPickerSpacing.small.size),
                _buildPreviewBox(context),
              ],
            )
          : Center(child: _buildSpectrum()),
    );
  }

  Widget _buildSpectrum() {
    return SizedBox(
      width: _ColorPickerSizes.spectrum.size,
      height: _ColorPickerSizes.spectrum.size,
      child: colorSpectrumShape == ColorSpectrumShape.ring
          ? ColorRingSpectrum(
              colorState: colorState,
              onColorChanged: onColorChanged,
              minHue: minHue,
              maxHue: maxHue,
              minSaturation: minSaturation,
              maxSaturation: maxSaturation,
            )
          : ColorBoxSpectrum(
              colorState: colorState,
              onColorChanged: onColorChanged,
              minHue: minHue,
              maxHue: maxHue,
              minSaturation: minSaturation,
              maxSaturation: maxSaturation,
            ),
    );
  }

  Widget _buildPreviewBox(BuildContext context) {
    final width = _ColorPickerSizes.preview.size;
    final height = _ColorPickerSizes.spectrum.size;
    const borderRadius = 4.0;
    const borderWidth = 2.0;

    final theme = FluentTheme.of(context);
    final color = colorState.toColor();

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // Base checkerboard pattern
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: CustomPaint(painter: CheckerboardPainter(theme: theme)),
            ),
          ),
          // Color overlay
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(color: color),
            ),
          ),
          // Border on top
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.resources.dividerStrokeColorDefault,
                width: borderWidth,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        ],
      ),
    );
  }
}

/// A widget that displays the color sliders.
class _ColorSliders extends StatelessWidget {
  /// The current color state
  final ColorState colorState;

  /// Callback when the color changes
  final ValueChanged<ColorState> onColorChanged;

  /// The orientation of the color picker layout
  final Axis orientation;

  /// Whether the color slider is visible
  final bool isColorSliderVisible;

  /// Whether the alpha slider is visible
  final bool isAlphaSliderVisible;

  /// Whether the alpha channel is enabled
  final bool isAlphaEnabled;

  /// The minimum allowed HSV value (0-100)
  final int minValue;

  /// The maximum allowed HSV value (0-100)
  final int maxValue;

  /// Creates a new instance of [_ColorSliders].
  const _ColorSliders({
    required this.colorState,
    required this.onColorChanged,
    required this.orientation,
    required this.isColorSliderVisible,
    required this.isAlphaSliderVisible,
    required this.isAlphaEnabled,
    required this.minValue,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final localizations = FluentLocalizations.of(context);

    // Determine if the sliders should be displayed horizontally or vertically
    final isVertical = orientation != Axis.vertical;

    final sliders = [
      if (isColorSliderVisible)
        _buildValueSlider(theme, localizations, isVertical),
      if (isColorSliderVisible && isAlphaSliderVisible && isAlphaEnabled)
        orientation == Axis.vertical
            ? SizedBox(height: _ColorPickerSpacing.large.size)
            : SizedBox(width: _ColorPickerSpacing.large.size),
      if (isAlphaSliderVisible && isAlphaEnabled)
        _buildAlphaSlider(theme, localizations, isVertical),
    ];

    return orientation == Axis.horizontal
        ? Row(mainAxisSize: MainAxisSize.min, children: sliders)
        : Column(mainAxisSize: MainAxisSize.min, children: sliders);
  }

  /// Builds the value slider for the color picker.
  Widget _buildValueSlider(
    FluentThemeData theme,
    FluentLocalizations localizations,
    bool isVertical,
  ) {
    final thumbColor = theme.resources.focusStrokeColorOuter;

    final colorKey = colorState.guessColorName();
    final displayName = localizations.getColorDisplayName(colorKey);

    // Format the value text with color name : "Value 100 (Color Name)"
    final valueText = localizations.valueSliderTooltip(
      (colorState.value * 100).round(),
      displayName.isNotEmpty ? displayName : '',
    );

    return SizedBox(
      width: isVertical
          ? _ColorPickerSizes.slider.size
          : _ColorPickerSizes.maxWidth,
      height: isVertical
          ? _ColorPickerSizes.spectrum.size
          : _ColorPickerSizes.slider.size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: isVertical
                    ? Alignment.bottomCenter
                    : Alignment.centerLeft,
                end: isVertical ? Alignment.topCenter : Alignment.centerRight,
                colors: [
                  const Color(0xFF000000),
                  HSVColor.fromAHSV(
                    1,
                    math.max(0, colorState.hue),
                    math.max(0, colorState.saturation),
                    1,
                  ).toColor(),
                ],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          SliderTheme(
            data: SliderThemeData(
              activeColor: WidgetStatePropertyAll(thumbColor),
              trackHeight: const WidgetStatePropertyAll(0),
              thumbRadius: const WidgetStatePropertyAll(8),
              thumbBallInnerFactor: const WidgetStatePropertyAll(0.6),
            ),
            child: Slider(
              label: valueText,
              vertical: isVertical,
              value: colorState.value,
              min: minValue / 100,
              max: maxValue / 100,
              onChanged: (value) =>
                  onColorChanged(colorState.copyWith(value: value)),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the alpha slider for the color picker.
  Widget _buildAlphaSlider(
    FluentThemeData theme,
    FluentLocalizations localizations,
    bool isVertical,
  ) {
    final thumbColor = theme.resources.focusStrokeColorOuter;

    // Format the opacity text : "100% opacity"
    final opacityText = localizations.alphaSliderTooltip(
      (colorState.alpha * 100).round(),
    );

    return SizedBox(
      width: isVertical
          ? _ColorPickerSizes.slider.size
          : _ColorPickerSizes.spectrum.size +
                _ColorPickerSpacing.small.size +
                _ColorPickerSizes.preview.size,
      height: isVertical
          ? _ColorPickerSizes.spectrum.size
          : _ColorPickerSizes.slider.size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(painter: CheckerboardPainter(theme: theme)),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: LinearGradient(
                begin: isVertical
                    ? Alignment.bottomCenter
                    : Alignment.centerLeft,
                end: isVertical ? Alignment.topCenter : Alignment.centerRight,
                colors: [
                  colorState.toColor().withAlpha(0),
                  colorState.toColor().withAlpha(255),
                ],
              ),
            ),
          ),
          SliderTheme(
            data: SliderThemeData(
              activeColor: WidgetStatePropertyAll(thumbColor),
              trackHeight: const WidgetStatePropertyAll(0),
              thumbRadius: const WidgetStatePropertyAll(8),
              thumbBallInnerFactor: const WidgetStatePropertyAll(0.6),
            ),
            child: Slider(
              label: opacityText,
              vertical: isVertical,
              value: colorState.alpha,
              max: 1,
              onChanged: (value) =>
                  onColorChanged(colorState.copyWith(alpha: value)),
            ),
          ),
        ],
      ),
    );
  }
}

/// A widget that displays the color inputs.
class _ColorInputs extends StatelessWidget {
  /// Map of color modes (RGB and HSV)
  static const Map<String, _ColorMode> colorModes = {
    'RGB': _ColorMode.rgb,
    'HSV': _ColorMode.hsv,
  };

  /// Internal ValueNotifier for color mode management
  static final _colorModeNotifier = ValueNotifier<_ColorMode>(_ColorMode.rgb);

  /// The current color state
  final ColorState colorState;

  /// Callback when the color changes
  final ValueChanged<ColorState> onColorChanged;

  /// The orientation of the color picker layout
  final Axis orientation;

  /// Whether the "More" button is expanded
  final bool isMoreExpanded;

  /// Whether the "More" button is visible
  final bool isMoreButtonVisible;

  /// Whether the hex input is visible
  final bool isHexInputVisible;

  /// Whether the color channel text input is visible
  final bool isColorChannelTextInputVisible;

  /// Whether the alpha channel is enabled
  final bool isAlphaEnabled;

  /// Whether the alpha text input is visible
  final bool isAlphaTextInputVisible;

  /// Controller for the hex input
  final TextEditingController hexController;

  /// The minimum allowed hue value (0-359)
  final int minHue;

  /// The maximum allowed hue value (0-359)
  final int maxHue;

  /// The minimum allowed saturation value (0-100)
  final int minSaturation;

  /// The maximum allowed saturation value (0-100)
  final int maxSaturation;

  /// The minimum allowed value/brightness (0-100)
  final int minValue;

  /// The maximum allowed value/brightness (0-100)
  final int maxValue;

  /// Creates a new instance of [ColorInputs].
  const _ColorInputs({
    required this.colorState,
    required this.onColorChanged,
    required this.orientation,
    required this.isMoreExpanded,
    required this.isMoreButtonVisible,
    required this.isHexInputVisible,
    required this.isColorChannelTextInputVisible,
    required this.isAlphaEnabled,
    required this.isAlphaTextInputVisible,
    required this.minHue,
    required this.maxHue,
    required this.minSaturation,
    required this.maxSaturation,
    required this.minValue,
    required this.maxValue,
    required this.hexController,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = FluentLocalizations.of(context);

    // Update hex input whenever colorState changes
    _updateHexControllerText();

    return ValueListenableBuilder<_ColorMode>(
      valueListenable: _colorModeNotifier,
      builder: (context, colorMode, _) {
        final inputsContent = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (orientation != Axis.vertical ||
                !isMoreButtonVisible ||
                isMoreExpanded) ...[
              _buildColorModeAndHexInput(colorMode),
              if (colorMode == _ColorMode.rgb)
                _buildRGBInputs(localizations)
              else
                _buildHSVInputs(localizations),
            ],
          ],
        );

        return orientation == Axis.vertical
            ? SizedBox(width: _ColorPickerSizes.maxWidth, child: inputsContent)
            : SizedBox(
                height: _ColorPickerSizes.spectrum.size,
                width: 200, // arbitrary width, but more than enough
                child: inputsContent,
              );
      },
    );
  }

  /// Updates the hex controller text based on current color state
  void _updateHexControllerText() {
    final currentHex = colorState.toHexString(isAlphaEnabled);
    if (hexController.text != currentHex) {
      // Use text setter instead of direct assignment to handle text selection
      final selection = hexController.selection;
      hexController.text = currentHex;
      // Maintain cursor position if it was in a valid range
      if (selection.isValid && selection.start <= currentHex.length) {
        hexController.selection = selection;
      }
    }
  }

  /// Builds the color mode selector and hex input.
  Widget _buildColorModeAndHexInput(_ColorMode colorMode) {
    final modeSelector = SizedBox(
      width: _ColorPickerSizes.inputBox.size,
      child: ComboBox<_ColorMode>(
        value: colorMode,
        items: colorModes.entries
            .map((e) => ComboBoxItem(value: e.value, child: Text(e.key)))
            .toList(),
        isExpanded: true,
        onChanged: (value) {
          if (value != null) _colorModeNotifier.value = value;
        },
      ),
    );

    final hexInput = SizedBox(
      width: _ColorPickerSizes.inputBox.size,
      child: TextBox(
        controller: hexController,
        placeholder: isAlphaEnabled ? '#AARRGGBB' : '#RRGGBB',
        onSubmitted: _updateHexColor,
      ),
    );

    if (orientation == Axis.vertical) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isColorChannelTextInputVisible) ...[modeSelector],
          if (isHexInputVisible) ...[hexInput],
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isHexInputVisible) ...[
            Align(alignment: Alignment.centerLeft, child: hexInput),
            SizedBox(height: _ColorPickerSpacing.small.size),
          ],
          if (isColorChannelTextInputVisible) ...[
            Align(alignment: Alignment.centerLeft, child: modeSelector),
          ],
        ],
      );
    }
  }

  /// Builds the RGB input fields.
  Widget _buildRGBInputs(FluentLocalizations localizations) {
    return Column(
      children: [
        if (isColorChannelTextInputVisible) ...{
          _buildNumberInput(
            localizations.redLabel,
            colorState.red * 255,
            (v) {
              final newState = colorState.copyWith(red: v / 255);
              onColorChanged(newState);
            },
            min: 0,
            max: 255,
          ),
          _buildNumberInput(
            localizations.greenLabel,
            colorState.green * 255,
            (v) {
              final newState = colorState.copyWith(green: v / 255);
              onColorChanged(newState);
            },
            min: 0,
            max: 255,
          ),
          _buildNumberInput(
            localizations.blueLabel,
            colorState.blue * 255,
            (v) {
              final newState = colorState.copyWith(blue: v / 255);
              onColorChanged(newState);
            },
            min: 0,
            max: 255,
          ),
        },
        if (isAlphaEnabled && isAlphaTextInputVisible) ...[
          _buildNumberInput(
            localizations.opacityLabel,
            colorState.alpha * 100,
            (v) {
              final newState = colorState.copyWith(alpha: v / 100);
              onColorChanged(newState);
            },
            min: 0,
            max: 100,
          ),
        ],
      ],
    );
  }

  /// Builds the HSV input fields.
  Widget _buildHSVInputs(FluentLocalizations localizations) {
    return Column(
      children: [
        if (isColorChannelTextInputVisible) ...{
          _buildNumberInput(
            localizations.hueLabel,
            colorState.hue,
            (v) {
              final newState = colorState.copyWith(hue: v);
              onColorChanged(newState);
            },
            min: minHue.toDouble(),
            max: maxHue.toDouble(),
          ),
          _buildNumberInput(
            localizations.saturationLabel,
            colorState.saturation * 100,
            (v) {
              final newState = colorState.copyWith(saturation: v / 100);
              onColorChanged(newState);
            },
            min: minSaturation.toDouble(),
            max: maxSaturation.toDouble(),
          ),
          _buildNumberInput(
            localizations.valueLabel,
            colorState.value * 100,
            (v) {
              final newState = colorState.copyWith(value: v / 100);
              onColorChanged(newState);
            },
            min: minValue.toDouble(),
            max: maxValue.toDouble(),
          ),
        },
        if (isAlphaEnabled && isAlphaTextInputVisible) ...[
          _buildNumberInput(
            localizations.opacityLabel,
            colorState.alpha * 100,
            (v) {
              final newState = colorState.copyWith(alpha: v / 100);
              onColorChanged(newState);
            },
            min: 0,
            max: 100,
          ),
        ],
      ],
    );
  }

  /// Builds a number input field.
  Widget _buildNumberInput(
    String label,
    double value,
    void Function(double) onChanged, {
    required double min,
    required double max,
  }) {
    return Column(
      children: [
        SizedBox(height: _ColorPickerSpacing.small.size),
        Row(
          children: [
            SizedBox(
              width: _ColorPickerSizes.inputBox.size,
              child: NumberBox<double>(
                value: value,
                min: min,
                max: max,
                mode: SpinButtonPlacementMode.none,
                clearButton: false,
                onChanged: (v) {
                  if (v == null || v.isNaN || v.isInfinite) return;
                  onChanged(v);
                },
                format: (v) => v?.round().toString(),
              ),
            ),
            const SizedBox(width: 5),
            Text(label),
          ],
        ),
      ],
    );
  }

  /// Updates the hex color value.
  void _updateHexColor(String text) {
    // Skip if the text is not a valid hex color length
    final expectedLength = isAlphaEnabled ? 9 : 7;
    if (text.length != expectedLength) {
      // Revert to current valid hex
      _updateHexControllerText();
      return;
    }

    try {
      final cleanText = text.startsWith('#') ? text.substring(1) : text;

      // Parse hex string with or without alpha
      int colorValue;
      var a = colorState.alpha; // Preserve existing alpha

      if (cleanText.length == 6) {
        // RGB format: Parse RGB and keep existing alpha
        colorValue = int.parse(cleanText, radix: 16);
      } else {
        // ARGB format: Parse both alpha and RGB
        colorValue = int.parse(cleanText, radix: 16);
        a = ((colorValue >> 24) & 0xFF) / 255.0;
      }

      // Extract color components
      final r = ((colorValue >> 16) & 0xFF) / 255.0;
      final g = ((colorValue >> 8) & 0xFF) / 255.0;
      final b = (colorValue & 0xFF) / 255.0;
      final rgb = RgbComponents(r, g, b);

      // Convert RGB to HSV
      final hsv = ColorState.rgbToHsv(rgb);

      // Create new ColorState
      final newState = ColorState(r, g, b, a, hsv.h, hsv.s, hsv.v);
      onColorChanged(newState);
    } catch (e) {
      debugPrint('Error parsing hex color: $e');
      // Revert to the current color's hex value
      final currentHex = colorState.toHexString(isAlphaEnabled);
      if (hexController.text != currentHex) {
        hexController.text = currentHex;
      }
    }
  }
}
