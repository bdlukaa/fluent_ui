import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// Radio buttons, also called option buttons, let users select one option from
/// a collection of two or more mutually exclusive, but related, options.
///
/// Radio buttons are always used in groups, and each option is represented by
/// one radio button in the group. In the default state, no radio button in a
/// group is selected. However, once a user has selected a radio button, the user
/// can't deselect it to restore the group to its initial cleared state—they can
/// only select a different option.
///
/// The singular behavior of a radio button group distinguishes it from checkboxes,
/// which support multi-selection and deselection.
///
/// ![RadioButton](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/controls/radio-button.png)
///
/// {@tool snippet}
/// This example shows a group of radio buttons:
///
/// ```dart
/// int selectedOption = 0;
///
/// Column(
///   children: [
///     RadioButton(
///       checked: selectedOption == 0,
///       content: Text('Option 1'),
///       onChanged: (checked) {
///         if (checked) setState(() => selectedOption = 0);
///       },
///     ),
///     RadioButton(
///       checked: selectedOption == 1,
///       content: Text('Option 2'),
///       onChanged: (checked) {
///         if (checked) setState(() => selectedOption = 1);
///       },
///     ),
///     RadioButton(
///       checked: selectedOption == 2,
///       content: Text('Option 3'),
///       onChanged: (checked) {
///         if (checked) setState(() => selectedOption = 2);
///       },
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
///
/// See also:
///
///  * [Slider], which lets the user select from a range of values
///  * [Checkbox], which lets the user select multiple options
///  * [ComboBox], which lets the user select from a dropdown list
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/radio-button>
class RadioButton extends StatelessWidget {
  /// Creates a radio button.
  const RadioButton({
    required this.checked,
    required this.onChanged,
    super.key,
    this.style,
    this.content,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  });

  /// Whether this radio button is checked.
  final bool checked;

  /// Called when the value of the radio button should change.
  ///
  /// The radio button passes the new value to the callback but does
  /// not actually change state until the parent widget rebuilds the
  /// radio button with the new value.
  ///
  /// If this callback is null, the radio button will be displayed as
  /// disabled and will not respond to input gestures.
  final ValueChanged<bool>? onChanged;

  /// The style of the radio buttonbutton.
  ///
  /// If non-null, this is merged with the closest [RadioButtonTheme].
  /// If null, the closest [RadioButtonTheme] is used.
  final RadioButtonThemeData? style;

  /// The content of the radio button.
  ///
  /// This, if non-null, is displayed at the right of the radio button,
  /// and is affected by user touch.
  ///
  /// Usually a [Text] or [Icon] widget
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
      ..add(
        FlagProperty('disabled', value: onChanged == null, ifFalse: 'enabled'),
      )
      ..add(ObjectFlagProperty.has('style', style))
      ..add(
        FlagProperty('autofocus', value: autofocus, ifFalse: 'manual focus'),
      )
      ..add(StringProperty('semanticLabel', semanticLabel));
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final style = RadioButtonTheme.of(context).merge(this.style);
    return HoverButton(
      autofocus: autofocus,
      focusNode: focusNode,
      onPressed: onChanged == null ? null : () => onChanged!(!checked),
      semanticLabel: semanticLabel,
      builder: (context, state) {
        final decoration =
            (checked
                ? style.checkedDecoration?.resolve(state)
                : style.uncheckedDecoration?.resolve(state)) ??
            const BoxDecoration(shape: BoxShape.circle);
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
          child = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              child,
              const SizedBox(width: 6),
              Flexible(
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    color: style.foregroundColor?.resolve(state),
                  ),
                  child: IconTheme.merge(
                    data: IconThemeData(
                      color: style.foregroundColor?.resolve(state),
                    ),
                    child: content!,
                  ),
                ),
              ),
            ],
          );
        }
        return Semantics(
          checked: checked,
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
  /// Creates a theme that controls how descendant [RadioButton]s should
  /// look like.
  const RadioButtonTheme({required this.data, required super.child, super.key});

  /// The properties for descendant [RadioButton] widgets.
  final RadioButtonThemeData data;

  /// Creates a theme that merges the nearest [RadioButtonTheme] with [data].
  static Widget merge({
    required RadioButtonThemeData data,
    required Widget child,
    Key? key,
  }) {
    return Builder(
      builder: (context) {
        return RadioButtonTheme(
          key: key,
          data: RadioButtonTheme.of(context).merge(data),
          child: child,
        );
      },
    );
  }

  /// Returns the closest [RadioButtonThemeData] which encloses the given
  /// context.
  ///
  /// Resolution order:
  /// 1. Defaults from [RadioButtonThemeData.standard]
  /// 2. Global theme from [FluentThemeData.radioButtonTheme]
  /// 3. Local [RadioButtonTheme] ancestor
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// RadioButtonThemeData theme = RadioButtonTheme.of(context);
  /// ```
  static RadioButtonThemeData of(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final inheritedTheme = context
        .dependOnInheritedWidgetOfExactType<RadioButtonTheme>();
    return RadioButtonThemeData.standard(
      theme,
    ).merge(theme.radioButtonTheme).merge(inheritedTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return RadioButtonTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(RadioButtonTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for [RadioButton] widgets.
///
/// This class defines the default styles for different states of a radio button.
///
/// See also:
///
/// * [RadioButtonTheme], which is the theme that uses this data.
/// * [RadioButton], which is the widget that uses this data.
/// * [WidgetStateProperty], which is the property that controls the style of the radio button.
@immutable
class RadioButtonThemeData with Diagnosticable {
  /// The decoration of the radio button when it's checked.
  final WidgetStateProperty<BoxDecoration?>? checkedDecoration;

  /// The decoration of the radio button when it's unchecked.
  final WidgetStateProperty<BoxDecoration?>? uncheckedDecoration;

  /// The color of the radio button's content.
  final WidgetStateProperty<Color?>? foregroundColor;

  /// Creates a theme that can be used for [RadioButtonTheme]
  const RadioButtonThemeData({
    this.checkedDecoration,
    this.uncheckedDecoration,
    this.foregroundColor,
  });

  /// Creates the standard [RadioButtonThemeData] based on the given [theme].
  factory RadioButtonThemeData.standard(FluentThemeData theme) {
    return RadioButtonThemeData(
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        return states.isDisabled ? theme.resources.textFillColorDisabled : null;
      }),
      checkedDecoration: WidgetStateProperty.resolveWith((states) {
        return BoxDecoration(
          border: Border.all(
            color: ButtonThemeData.checkedInputColor(theme, states),
            width: !states.isDisabled
                ? states.isHovered && !states.isPressed
                      ? 3.4
                      : 5.0
                : 4.0,
          ),
          shape: BoxShape.circle,
          color: theme.resources.textOnAccentFillColorPrimary,
        );
      }),
      uncheckedDecoration: WidgetStateProperty.resolveWith((states) {
        return BoxDecoration(
          color: WidgetStateExtension.forStates<Color>(
            states,
            disabled: theme.resources.controlAltFillColorDisabled,
            pressed: theme.resources.controlAltFillColorQuarternary,
            hovering: theme.resources.controlAltFillColorTertiary,
            none: theme.resources.controlAltFillColorSecondary,
          ),
          border: Border.all(
            width: states.isPressed ? 4.5 : 1,
            color: WidgetStateExtension.forStates<Color>(
              states,
              disabled: theme.resources.textFillColorDisabled,
              pressed: theme.accentColor.defaultBrushFor(theme.brightness),
              none: theme.resources.textFillColorTertiary,
            ),
          ),
          shape: BoxShape.circle,
        );
      }),
    );
  }

  /// Linearly interpolates between two [RadioButtonThemeData] objects.
  ///
  /// {@macro fluent_ui.lerp.t}
  static RadioButtonThemeData lerp(
    RadioButtonThemeData? a,
    RadioButtonThemeData? b,
    double t,
  ) {
    return RadioButtonThemeData(
      checkedDecoration: lerpWidgetStateProperty<BoxDecoration?>(
        a?.checkedDecoration,
        b?.checkedDecoration,
        t,
        BoxDecoration.lerp,
      ),
      uncheckedDecoration: lerpWidgetStateProperty<BoxDecoration?>(
        a?.uncheckedDecoration,
        b?.uncheckedDecoration,
        t,
        BoxDecoration.lerp,
      ),
      foregroundColor: lerpWidgetStateProperty<Color?>(
        a?.foregroundColor,
        b?.foregroundColor,
        t,
        Color.lerp,
      ),
    );
  }

  /// Merges this [RadioButtonThemeData] with another, with the other taking
  /// precedence.
  RadioButtonThemeData merge(RadioButtonThemeData? style) {
    return RadioButtonThemeData(
      checkedDecoration: style?.checkedDecoration ?? checkedDecoration,
      uncheckedDecoration: style?.uncheckedDecoration ?? uncheckedDecoration,
      foregroundColor: style?.foregroundColor ?? foregroundColor,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<WidgetStateProperty<BoxDecoration?>?>(
          'checkedDecoration',
          checkedDecoration,
        ),
      )
      ..add(
        DiagnosticsProperty<WidgetStateProperty<BoxDecoration?>?>(
          'uncheckedDecoration',
          uncheckedDecoration,
        ),
      )
      ..add(DiagnosticsProperty('foregroundDecoration', foregroundColor));
  }
}
