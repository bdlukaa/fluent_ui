import 'package:fluent_ui/fluent_ui.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

class RadioButton extends StatelessWidget {
  const RadioButton({
    Key? key,
    required this.checked,
    required this.onChanged,
    this.style,
    this.semanticsLabel,
    this.focusNode,
    this.autofocus = false,
  }) : super(key: key);

  /// Whether the button is checked of not
  final bool checked;

  /// Called when the value of the button is changed.
  /// If this is `null`, the button is considered disabled
  final ValueChanged<bool>? onChanged;

  /// The style of the button.
  /// This is merged with [Style.radioButtonStyle]
  final RadioButtonStyle? style;

  /// The semantics label of the button
  final String? semanticsLabel;

  /// The [FocusNode] of the button
  final FocusNode? focusNode;

  /// Whether the button should be autofocused
  final bool autofocus;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      FlagProperty('checked', value: checked, ifFalse: 'unchecked'),
    );
    properties.add(
      ObjectFlagProperty('onChanged', onChanged, ifNull: 'disabled'),
    );
    properties.add(ObjectFlagProperty.has('style', style));
  }

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.radioButtonStyle?.copyWith(this.style);
    return HoverButton(
      cursor: style?.cursor,
      autofocus: autofocus,
      focusNode: focusNode,
      semanticsLabel: semanticsLabel,
      onPressed: onChanged == null ? null : () => onChanged!(!checked),
      builder: (context, state) {
        Widget child = AnimatedContainer(
          duration: style?.animationDuration ?? Duration(milliseconds: 300),
          height: 20,
          width: 20,
          decoration: checked
              ? style?.checkedDecoration!(state)
              : style?.uncheckedDecoration!(state),
        );
        return Semantics(
          child: FocusBorder(
            focused: state.isFocused,
            child: child,
          ),
          selected: checked,
        );
      },
    );
  }
}

@immutable
class RadioButtonStyle with Diagnosticable {
  final ButtonState<Decoration>? checkedDecoration;
  final ButtonState<Decoration>? uncheckedDecoration;

  final ButtonState<MouseCursor>? cursor;

  final Duration? animationDuration;
  final Curve? animationCurve;

  const RadioButtonStyle({
    this.cursor,
    this.animationDuration,
    this.animationCurve,
    this.checkedDecoration,
    this.uncheckedDecoration,
  });

  factory RadioButtonStyle.standard(Style style) {
    return RadioButtonStyle(
      cursor: buttonCursor,
      animationDuration: style.mediumAnimationDuration,
      animationCurve: style.animationCurve,
      checkedDecoration: (state) => BoxDecoration(
        border: Border.all(
          color: checkedInputColor(style, state),
          width: 4.5,
        ),
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      uncheckedDecoration: (state) => BoxDecoration(
        color: uncheckedInputColor(style, state),
        border: Border.all(
          style: state.isNone ? BorderStyle.solid : BorderStyle.none,
          width: 1,
          color: state.isNone
              ? style.disabledColor!
              : uncheckedInputColor(style, state),
        ),
        shape: BoxShape.circle,
      ),
    );
  }

  RadioButtonStyle copyWith(RadioButtonStyle? style) {
    return RadioButtonStyle(
      cursor: style?.cursor ?? cursor,
      animationCurve: style?.animationCurve ?? animationCurve,
      animationDuration: style?.animationDuration ?? animationDuration,
      checkedDecoration: style?.checkedDecoration ?? checkedDecoration,
      uncheckedDecoration: style?.uncheckedDecoration ?? uncheckedDecoration,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<ButtonState<MouseCursor>?>.has('cursor', cursor),
    );
    properties.add(ObjectFlagProperty<ButtonState<Decoration>?>.has(
      'checkedDecoration',
      checkedDecoration,
    ));
    properties.add(ObjectFlagProperty<ButtonState<Decoration>?>.has(
      'uncheckedDecoration',
      uncheckedDecoration,
    ));
    properties.add(
      DiagnosticsProperty<Duration?>('animationDuration', animationDuration),
    );
    properties.add(
      DiagnosticsProperty<Curve?>('animationCurve', animationCurve),
    );
  }
}
