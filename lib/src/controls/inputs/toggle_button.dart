import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// A button that can be on or off.
///
/// See also:
/// - [Checkbox](https://github.com/bdlukaa/fluent_ui#checkbox)
/// - [ToggleSwitch](https://github.com/bdlukaa/fluent_ui#toggle-switches)
class ToggleButton extends StatelessWidget {
  const ToggleButton({
    Key? key,
    required this.checked,
    required this.onChanged,
    this.child,
    this.style,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  }) : super(key: key);

  /// The content of the button
  final Widget? child;

  /// Whether this [ToggleButton] is checked
  final bool checked;

  /// Whenever the value of this [ToggleButton] should change
  final ValueChanged<bool>? onChanged;

  /// The style of the button.
  /// This style is merged with [Style.toggleButtonStyle]
  final ToggleButtonStyle? style;

  /// The semantics label of the button
  final String? semanticLabel;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty(
      'checked',
      value: checked,
      ifFalse: 'unchecked',
    ));
    properties.add(
      ObjectFlagProperty('onChanged', onChanged, ifNull: 'disabled'),
    );
    properties.add(DiagnosticsProperty<ToggleButtonStyle>('style', style));
    properties.add(StringProperty('semanticLabel', semanticLabel));
    properties.add(ObjectFlagProperty<FocusNode>.has('focusNode', focusNode));
    properties.add(FlagProperty('autofocus', value: autofocus));
  }

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.toggleButtonStyle?.copyWith(this.style);
    return Button(
      autofocus: autofocus,
      focusNode: focusNode,
      child: Semantics(child: child, selected: checked),
      onPressed: onChanged == null ? null : () => onChanged!(!checked),
      style: ButtonStyle(
        decoration: (state) => checked
            ? style?.checkedDecoration!(state)
            : style?.uncheckedDecoration!(state),
        padding: style?.padding,
        animationCurve: style?.animationCurve,
        animationDuration: style?.animationDuration,
        cursor: style?.cursor,
        margin: style?.margin,
        scaleFactor: style?.scaleFactor,
      ),
    );
  }
}

@immutable
class ToggleButtonStyle with Diagnosticable {
  final ButtonState<MouseCursor>? cursor;

  final ButtonState<Decoration>? checkedDecoration;
  final ButtonState<Decoration>? uncheckedDecoration;

  final double? scaleFactor;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  final Duration? animationDuration;
  final Curve? animationCurve;

  const ToggleButtonStyle({
    this.cursor,
    this.padding,
    this.margin,
    this.animationDuration,
    this.animationCurve,
    this.checkedDecoration,
    this.uncheckedDecoration,
    this.scaleFactor,
  });

  factory ToggleButtonStyle.standard(Style style) {
    final defaultDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(2),
    );
    return ToggleButtonStyle(
      scaleFactor: 0.95,
      cursor: buttonCursor,
      checkedDecoration: (state) => defaultDecoration.copyWith(
        color: checkedInputColor(style, state),
        border: Border.all(width: 0.6, color: checkedInputColor(style, state)),
      ),
      uncheckedDecoration: (state) {
        if (state.isHovering || state.isPressing)
          return defaultDecoration.copyWith(
            color: uncheckedInputColor(style, state),
            border: Border.all(
              width: 0.6,
              color: uncheckedInputColor(style, state),
            ),
          );
        return defaultDecoration.copyWith(
          color: ButtonStyle.buttonColor(style, state),
          border: Border.all(width: 0.6, color: Colors.transparent),
        );
      },
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: EdgeInsets.all(4),
      animationDuration: style.fastAnimationDuration,
      animationCurve: style.animationCurve,
    );
  }

  ToggleButtonStyle copyWith(ToggleButtonStyle? style) {
    if (style == null) return this;
    return ToggleButtonStyle(
      margin: style.margin ?? margin,
      padding: style.padding ?? padding,
      cursor: style.cursor ?? cursor,
      animationCurve: style.animationCurve ?? animationCurve,
      animationDuration: style.animationDuration ?? animationDuration,
      checkedDecoration: style.checkedDecoration ?? checkedDecoration,
      uncheckedDecoration: style.uncheckedDecoration ?? uncheckedDecoration,
      scaleFactor: style.scaleFactor ?? scaleFactor,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry?>('margin', margin));
    properties
        .add(DiagnosticsProperty<EdgeInsetsGeometry?>('padding', padding));
    properties.add(
      ObjectFlagProperty<ButtonState<MouseCursor>?>.has('cursor', cursor),
    );
    properties
        .add(DiagnosticsProperty<Curve?>('animationCurve', animationCurve));
    properties.add(
        DiagnosticsProperty<Duration?>('animationDuration', animationDuration));
    properties.add(ObjectFlagProperty<ButtonState<Decoration>?>.has(
      'checkedDecoration',
      checkedDecoration,
    ));
    properties.add(ObjectFlagProperty<ButtonState<Decoration>?>.has(
      'uncheckedDecoration',
      uncheckedDecoration,
    ));
    properties.add(DoubleProperty('scaleFactor', scaleFactor));
  }
}
