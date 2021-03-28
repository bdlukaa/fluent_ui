import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as m;
import 'package:fluent_ui/fluent_ui.dart';

class Tooltip extends StatelessWidget {
  const Tooltip({
    Key? key,
    required this.message,
    this.child,
    this.style,
    this.excludeFromSemantics,
  }) : super(key: key);

  final String message;
  final Widget? child;

  final TooltipStyle? style;
  final bool? excludeFromSemantics;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.tooltipStyle?.copyWith(this.style);
    return m.Tooltip(
      message: message,
      child: child,
      preferBelow: style?.preferBelow,
      showDuration: style?.showDuration,
      padding: style?.padding,
      margin: style?.margin,
      decoration: style?.decoration,
      height: style?.height,
      verticalOffset: style?.verticalOffset,
      textStyle: style?.textStyle,
      waitDuration: style?.waitDuration,
      excludeFromSemantics: excludeFromSemantics,
    );
  }
}

class TooltipStyle with Diagnosticable {
  final double? height;
  final double? verticalOffset;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  final bool? preferBelow;

  final Decoration? decoration;

  final Duration? waitDuration;
  final Duration? showDuration;

  final TextStyle? textStyle;

  const TooltipStyle({
    this.height,
    this.verticalOffset,
    this.padding,
    this.margin,
    this.preferBelow,
    this.decoration,
    this.showDuration,
    this.waitDuration,
    this.textStyle,
  });

  static TooltipStyle defaultTheme(Style style) {
    return TooltipStyle(
      height: 32.0,
      verticalOffset: 24.0,
      preferBelow: true,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      showDuration: const Duration(milliseconds: 1500),
      waitDuration: const Duration(seconds: 1),
      textStyle: style.typography?.caption,
      decoration: () {
        final radius = BorderRadius.circular(4.0);
        final shadow = [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(1, 1),
            blurRadius: 10.0,
          ),
        ];
        final border = Border.all(color: Colors.grey[100]!, width: 0.5);
        if (style.brightness == Brightness.light) {
          return BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
            border: border,
            boxShadow: shadow,
          );
        } else {
          return BoxDecoration(
            color: Colors.grey,
            borderRadius: radius,
            border: border,
            boxShadow: shadow,
          );
        }
      }(),
    );
  }

  TooltipStyle copyWith(TooltipStyle? style) {
    if (style == null) return this;
    return style;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('height', height));
    properties.add(DoubleProperty('verticalOffset', verticalOffset));
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry>('margin', margin),
    );
    properties.add(FlagProperty(
      'preferBelow',
      value: preferBelow,
      ifFalse: 'prefer above',
    ));
    properties.add(DiagnosticsProperty<Decoration>('decoration', decoration));
    properties.add(DiagnosticsProperty<Duration>('waitDuration', waitDuration));
    properties.add(DiagnosticsProperty<Duration>('showDuration', showDuration));
    properties.add(DiagnosticsProperty<TextStyle>('textStyle', textStyle));
  }
}
