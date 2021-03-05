import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart' as m;
import 'package:fluent_ui/fluent_ui.dart';

class Slider extends StatelessWidget {
  const Slider({
    Key? key,
    required this.value,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 100.0,
    this.divisions,
    this.style,
    this.label,
    this.focusNode,
  })  : assert(value >= min && value <= max),
        assert(divisions == null || divisions > 0),
        super(key: key);

  final double value;

  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;

  final double min;
  final double max;

  final int? divisions;
  final SliderStyle? style;

  final String? label;

  final FocusNode? focusNode;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty(
      'enabled',
      value: onChanged != null,
      ifFalse: 'disabled',
    ));
    properties.add(DoubleProperty('value', value));
    properties.add(DoubleProperty('min', min));
    properties.add(DoubleProperty('max', max));
  }

  @override
  Widget build(BuildContext context) {
    final style = context.theme!.sliderStyle!.copyWith(this.style);
    return Padding(
      padding: style.margin ?? EdgeInsets.zero,
      child: m.Material(
        type: m.MaterialType.transparency,
        child: m.SliderTheme(
          data: m.SliderThemeData(
            showValueIndicator: m.ShowValueIndicator.always,
            thumbColor: style.thumbColor ?? style.activeColor,
            overlayShape: m.RoundSliderOverlayShape(overlayRadius: 0),
            thumbShape: m.RoundSliderThumbShape(
              elevation: 0,
              pressedElevation: 0,
            ),
            trackHeight: 0.25,
            trackShape: _CustomTrackShape(),
            disabledThumbColor: style.disabledThumbColor,
            disabledInactiveTrackColor: style.disabledInactiveColor,
            disabledActiveTrackColor: style.disabledActiveColor,
          ),
          child: m.Slider(
            value: value,
            max: max,
            min: min,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
            onChangeStart: onChangeStart,
            activeColor: style.activeColor,
            inactiveColor: style.inactiveColor,
            divisions: divisions,
            mouseCursor: style.cursor,
            // TODO: improve label fidelity
            // Image example: https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls/slider.png
            label: label,
            focusNode: focusNode,
          ),
        ),
      ),
    );
  }
}

class _CustomTrackShape extends m.RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required m.SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

class SliderStyle {
  final Color? thumbColor;
  final Color? disabledThumbColor;

  final MouseCursor? cursor;

  final Color? activeColor;
  final Color? inactiveColor;

  final Color? disabledActiveColor;
  final Color? disabledInactiveColor;

  final EdgeInsetsGeometry? margin;

  final Duration? animationDuration;
  final Curve? animationCurve;

  const SliderStyle({
    this.cursor,
    this.margin,
    this.animationDuration,
    this.animationCurve,
    this.thumbColor,
    this.disabledThumbColor,
    this.activeColor,
    this.disabledActiveColor,
    this.inactiveColor,
    this.disabledInactiveColor,
  });

  static SliderStyle defaultTheme(Style? style) {
    final def = SliderStyle(
      cursor: SystemMouseCursors.click,
      thumbColor: style?.accentColor,
      activeColor: style?.accentColor,
      inactiveColor: style?.inactiveColor,
      margin: EdgeInsets.zero,
      animationDuration: style?.animationDuration,
      animationCurve: style?.animationCurve,
      disabledActiveColor: style?.disabledColor,
      disabledThumbColor: style?.disabledColor?.withOpacity(1),
      disabledInactiveColor: style?.inactiveColor,
    );

    return def;
  }

  SliderStyle copyWith(SliderStyle? style) {
    return SliderStyle(
      margin: style?.margin ?? margin,
      cursor: style?.cursor ?? cursor,
      animationCurve: style?.animationCurve ?? animationCurve,
      animationDuration: style?.animationDuration ?? animationDuration,
      thumbColor: style?.thumbColor ?? thumbColor,
      activeColor: style?.activeColor ?? activeColor,
      inactiveColor: style?.inactiveColor,
      disabledActiveColor: style?.disabledActiveColor ?? disabledActiveColor,
      disabledInactiveColor:
          style?.disabledInactiveColor ?? disabledInactiveColor,
      disabledThumbColor: style?.disabledThumbColor ?? disabledThumbColor,
    );
  }
}
