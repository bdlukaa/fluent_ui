import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as m;
import 'package:fluent_ui/fluent_ui.dart';

/// A tooltip is a short description that is linked to another
/// control or object. Tooltips help users understand unfamiliar
/// objects that aren't described directly in the UI. They display
/// automatically when the user moves focus to, presses and holds,
/// or hovers the mouse pointer over a control. The tooltip disappears
/// after a few seconds, or when the user moves the finger, pointer
/// or keyboard/gamepad focus.
///
/// ![Tooltip Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls/tool-tip.png)
class Tooltip extends StatelessWidget {
  /// Creates a tooltip.
  ///
  /// Wrap any widget in a [Tooltip] to show a message on mouse hover
  const Tooltip({
    Key? key,
    required this.message,
    this.child,
    this.style,
    this.excludeFromSemantics,
  }) : super(key: key);

  /// The text to display in the tooltip.
  final String message;

  /// The widget the tooltip will be displayed, either above or below,
  /// when the mouse is hovering or whenever it gets long pressed.
  final Widget? child;

  /// The style of the tooltip. If non-null, it's mescled with [ThemeData.tooltipThemeData]
  final TooltipThemeData? style;

  /// Whether the tooltip's [message] should be excluded from the
  /// semantics tree.
  ///
  /// Defaults to false. A tooltip will add a [Semantics] label that
  /// is set to [Tooltip.message]. Set this property to true if the
  /// app is going to provide its own custom semantics label.
  final bool? excludeFromSemantics;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final style = TooltipThemeData.standard(context.theme).copyWith(
      context.theme.tooltipTheme.copyWith(this.style),
    );
    return m.Tooltip(
      message: message,
      child: child,
      preferBelow: style.preferBelow,
      showDuration: style.showDuration,
      padding: style.padding,
      margin: style.margin,
      decoration: style.decoration,
      height: style.height,
      verticalOffset: style.verticalOffset,
      textStyle: style.textStyle,
      waitDuration: style.waitDuration,
      excludeFromSemantics: excludeFromSemantics,
    );
  }
}

class TooltipThemeData with Diagnosticable {
  /// The height of the tooltip's [child].
  ///
  /// If the [child] is null, then this is the tooltip's intrinsic height.
  final double? height;

  /// The vertical gap between the widget and the displayed tooltip.
  ///
  /// When [preferBelow] is set to true and tooltips have sufficient space
  /// to display themselves, this property defines how much vertical space
  /// tooltips will position themselves under their corresponding widgets.
  /// Otherwise, tooltips will position themselves above their corresponding
  /// widgets with the given offset.
  final double? verticalOffset;

  /// The amount of space by which to inset the tooltip's [child].
  ///
  /// Defaults to 10.0 logical pixels in each direction.
  final EdgeInsetsGeometry? padding;

  /// The empty space that surrounds the tooltip.
  ///
  /// Defines the tooltip's outer [Container.margin]. By default, a long
  /// tooltip will span the width of its window. If long enough, a tooltip
  /// might also span the window's height. This property allows one to define
  /// how much space the tooltip must be inset from the edges of their display
  /// window.
  final EdgeInsetsGeometry? margin;

  /// Whether the tooltip defaults to being displayed below the widget.
  ///
  /// Defaults to true. If there is insufficient space to display the tooltip
  /// in the preferred direction, the tooltip will be displayed in the opposite
  /// direction.
  final bool? preferBelow;

  /// Specifies the tooltip's shape and background color.
  ///
  /// The tooltip shape defaults to a rounded rectangle with a border radius of 4.0.
  /// Tooltips will also default to an opacity of 90% and with the color [Colors.grey]
  /// if [ThemeData.brightness] is [Brightness.dark], and [Colors.white] if it is
  /// [Brightness.light].
  final Decoration? decoration;

  /// The length of time that a pointer must hover over a tooltip's widget before
  /// the tooltip will be shown.
  ///
  /// Once the pointer leaves the widget, the tooltip will immediately disappear.
  ///
  /// Defaults to 0 milliseconds (tooltips are shown immediately upon hover).
  final Duration? waitDuration;

  /// The length of time that the tooltip will be shown after a long press is released.
  ///
  /// Defaults to 1.5 seconds.
  final Duration? showDuration;

  /// The style to use for the message of the tooltip.
  ///
  /// If null, [Typography.caption] is used
  final TextStyle? textStyle;

  const TooltipThemeData({
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

  factory TooltipThemeData.standard(ThemeData style) {
    return TooltipThemeData(
      height: 32.0,
      verticalOffset: 24.0,
      preferBelow: true,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      showDuration: const Duration(milliseconds: 1500),
      waitDuration: const Duration(seconds: 1),
      textStyle: style.typography.caption,
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

  TooltipThemeData copyWith(TooltipThemeData? style) {
    if (style == null) return this;
    return TooltipThemeData(
      decoration: style.decoration ?? decoration,
      height: style.height ?? height,
      margin: style.margin ?? margin,
      padding: style.padding ?? padding,
      preferBelow: style.preferBelow ?? preferBelow,
      showDuration: style.showDuration ?? showDuration,
      textStyle: style.textStyle ?? textStyle,
      verticalOffset: style.verticalOffset ?? verticalOffset,
      waitDuration: style.waitDuration ?? waitDuration,
    );
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
