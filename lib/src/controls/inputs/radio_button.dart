import 'package:fluent_ui/fluent_ui.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// Radio buttons, also called option buttons, let users select
/// one option from a collection of two or more mutually exclusive,
/// but related, options. Radio buttons are always used in groups,
/// and each option is represented by one radio button in the group.
///
/// In the default state, no radio button in a RadioButtons group is
/// selected. That is, all radio buttons are cleared. However, once a
/// user has selected a radio button, the user can't deselect the
/// button to restore the group to its initial cleared state.
///
/// The singular behavior of a RadioButtons group distinguishes it
/// from check boxes, which support multi-selection and deselection,
/// or clearing.
///
/// ![RadioButton](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls/radio-button.png)
///
/// See also:
///   - [ToggleSwitch]
///   - [Checkbox]
///   - [ToggleButton]
class RadioButton extends StatelessWidget {
  const RadioButton({
    Key? key,
    required this.checked,
    required this.onChanged,
    this.style,
    this.content,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  }) : super(key: key);

  /// Whether the button is checked of not
  final bool checked;

  /// Called when the value of the button is changed.
  /// If this is `null`, the button is considered disabled
  final ValueChanged<bool>? onChanged;

  /// The style of the button. If non-null, this is merged
  /// with [ThemeData.radioButtonThemeData]
  final RadioButtonThemeData? style;

  final Widget? content;

  /// {@macro fluent_ui.controls.inputs.HoverButton.semanticLabel}
  final String? semanticLabel;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(FlagProperty('checked', value: checked, ifFalse: 'unchecked'))
      ..add(FlagProperty('disabled',
          value: onChanged == null, ifFalse: 'enabled'))
      ..add(ObjectFlagProperty.has('style', style))
      ..add(
          FlagProperty('autofocus', value: autofocus, ifFalse: 'manual focus'))
      ..add(StringProperty('semanticLabel', semanticLabel));
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final style = RadioButtonTheme.of(context).merge(this.style);
    return HoverButton(
      cursor: style.cursor,
      autofocus: autofocus,
      focusNode: focusNode,
      semanticLabel: semanticLabel,
      onPressed: onChanged == null ? null : () => onChanged!(!checked),
      builder: (context, state) {
        final BoxDecoration decoration = (checked
                ? style.checkedDecoration?.resolve(state)
                : style.uncheckedDecoration?.resolve(state)) ??
            BoxDecoration(shape: BoxShape.circle);
        Widget child = AnimatedContainer(
          duration: FluentTheme.of(context).fastAnimationDuration,
          curve: FluentTheme.of(context).animationCurve,
          height: 20,
          width: 20,
          decoration: decoration.copyWith(color: Colors.transparent),

          /// We need two boxes here because flutter draws the color
          /// behind the border, and it results in an weird effect. This
          /// way, the inner color will only be rendered within the
          /// bounds of the border.
          child: AnimatedContainer(
            duration: FluentTheme.of(context).fastAnimationDuration,
            curve: FluentTheme.of(context).animationCurve,
            decoration: BoxDecoration(
              color: decoration.color ?? Colors.transparent,
              shape: decoration.shape,
            ),
          ),
        );
        if (content != null) {
          child = Row(mainAxisSize: MainAxisSize.min, children: [
            child,
            const SizedBox(width: 6.0),
            content!,
          ]);
        }
        return Semantics(
          selected: checked,
          child: FocusBorder(focused: state.isFocused, child: child),
        );
      },
    );
  }
}

/// An inherited widget that defines the configuration for
/// [RadioButton]s in this widget's subtree.
///
/// Values specified here are used for [RadioButton] properties that are not
/// given an explicit non-null value.
class RadioButtonTheme extends InheritedTheme {
  /// Creates a radio button theme that controls the configurations for
  /// [RadioButton].
  const RadioButtonTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  /// The properties for descendant [RadioButton] widgets.
  final RadioButtonThemeData data;

  /// Creates a button theme that controls how descendant [RadioButton]s should
  /// look like, and merges in the current radio button theme, if any.
  static Widget merge({
    Key? key,
    required RadioButtonThemeData data,
    required Widget child,
  }) {
    return Builder(builder: (BuildContext context) {
      return RadioButtonTheme(
        key: key,
        data: _getInheritedThemeData(context).merge(data),
        child: child,
      );
    });
  }

  static RadioButtonThemeData _getInheritedThemeData(BuildContext context) {
    final RadioButtonTheme? theme =
        context.dependOnInheritedWidgetOfExactType<RadioButtonTheme>();
    return theme?.data ?? FluentTheme.of(context).radioButtonTheme;
  }

  /// Returns the [data] from the closest [RadioButtonTheme] ancestor. If there is
  /// no ancestor, it returns [ThemeData.radioButtonTheme]. Applications can assume
  /// that the returned value will not be null.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// RadioButtonThemeData theme = RadioButtonTheme.of(context);
  /// ```
  static RadioButtonThemeData of(BuildContext context) {
    return RadioButtonThemeData.standard(FluentTheme.of(context)).merge(
      _getInheritedThemeData(context),
    );
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return RadioButtonTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(RadioButtonTheme oldWidget) => data != oldWidget.data;
}

@immutable
class RadioButtonThemeData with Diagnosticable {
  final ButtonState<BoxDecoration?>? checkedDecoration;
  final ButtonState<BoxDecoration?>? uncheckedDecoration;

  final ButtonState<MouseCursor>? cursor;

  const RadioButtonThemeData({
    this.cursor,
    this.checkedDecoration,
    this.uncheckedDecoration,
  });

  factory RadioButtonThemeData.standard(ThemeData style) {
    return RadioButtonThemeData(
      cursor: ButtonState.all(MouseCursor.defer),
      checkedDecoration: ButtonState.resolveWith((states) {
        return BoxDecoration(
          border: Border.all(
            color: style.accentColor.light,
            width: states.isHovering && !states.isPressing ? 3.4 : 5.0,
          ),
          shape: BoxShape.circle,
          color: style.brightness.isLight ? Colors.white : Colors.black,
        );
      }),
      uncheckedDecoration: ButtonState.resolveWith((states) {
        final backgroundColor = style.inactiveBackgroundColor;
        return BoxDecoration(
          color: states.isPressing
              ? backgroundColor
              : states.isHovering
                  ? backgroundColor.withOpacity(0.8)
                  : backgroundColor.withOpacity(0.0),
          border: Border.all(
            width: states.isPressing ? 4.5 : 1,
            color: states.isPressing
                ? style.accentColor
                : style.inactiveColor.withOpacity(0.5),
          ),
          shape: BoxShape.circle,
        );
      }),
    );
  }

  static RadioButtonThemeData lerp(
      RadioButtonThemeData? a, RadioButtonThemeData? b, double t) {
    return RadioButtonThemeData(
      cursor: t < 0.5 ? a?.cursor : b?.cursor,
      checkedDecoration: ButtonState.lerp(
          a?.checkedDecoration, b?.checkedDecoration, t, BoxDecoration.lerp),
      uncheckedDecoration: ButtonState.lerp(a?.uncheckedDecoration,
          b?.uncheckedDecoration, t, BoxDecoration.lerp),
    );
  }

  RadioButtonThemeData merge(RadioButtonThemeData? style) {
    return RadioButtonThemeData(
      cursor: style?.cursor ?? cursor,
      checkedDecoration: style?.checkedDecoration ?? checkedDecoration,
      uncheckedDecoration: style?.uncheckedDecoration ?? uncheckedDecoration,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<ButtonState<MouseCursor>?>('cursor', cursor));
    properties.add(DiagnosticsProperty<ButtonState<BoxDecoration?>?>(
        'checkedDecoration', checkedDecoration));
    properties.add(DiagnosticsProperty<ButtonState<BoxDecoration?>?>(
        'uncheckedDecoration', uncheckedDecoration));
  }
}
