import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// A button that can be on or off.
///
/// See also:
///
///   * [Checkbox], which is used to select or deselect action items
///   * [ToggleSwitch], which use used to turn things on and off
class ToggleButton extends StatelessWidget {
  /// Creates a toggle button
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
  /// This style is merged with [ThemeData.toggleButtonThemeData]
  final ToggleButtonThemeData? style;

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
    properties.add(DiagnosticsProperty<ToggleButtonThemeData>('style', style));
    properties.add(StringProperty('semanticLabel', semanticLabel));
    properties.add(ObjectFlagProperty<FocusNode>.has('focusNode', focusNode));
    properties.add(
        FlagProperty('autofocus', value: autofocus, ifFalse: 'manual focus'));
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = ToggleButtonTheme.of(context).merge(style);
    return Button(
      autofocus: autofocus,
      focusNode: focusNode,
      onPressed: onChanged == null ? null : () => onChanged!(!checked),
      style: checked ? theme.checkedButtonStyle : theme.uncheckedButtonStyle,
      child: Semantics(selected: checked, child: child),
    );
  }
}

/// An inherited widget that defines the configuration for
/// [ToggleButton]s in this widget's subtree.
///
/// Values specified here are used for [ToggleButton] properties that are not
/// given an explicit non-null value.
class ToggleButtonTheme extends InheritedTheme {
  /// Creates a toggle button theme that controls the configurations for
  /// [ToggleButton].
  const ToggleButtonTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  /// The properties for descendant [ToggleButton] widgets.
  final ToggleButtonThemeData data;

  /// Creates a button theme that controls how descendant [ToggleButton]s should
  /// look like, and merges in the current toggle button theme, if any.
  static Widget merge({
    Key? key,
    required ToggleButtonThemeData data,
    required Widget child,
  }) {
    return Builder(builder: (BuildContext context) {
      return ToggleButtonTheme(
        key: key,
        data: _getInheritedThemeData(context).merge(data),
        child: child,
      );
    });
  }

  static ToggleButtonThemeData _getInheritedThemeData(BuildContext context) {
    final theme =
        context.dependOnInheritedWidgetOfExactType<ToggleButtonTheme>();
    return theme?.data ?? FluentTheme.of(context).toggleButtonTheme;
  }

  /// Returns the [data] from the closest [ToggleButtonTheme] ancestor. If there is
  /// no ancestor, it returns [ThemeData.toggleButtonTheme]. Applications can assume
  /// that the returned value will not be null.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// ToggleButtonThemeData theme = ToggleButtonTheme.of(context);
  /// ```
  static ToggleButtonThemeData of(BuildContext context) {
    return ToggleButtonThemeData.standard(FluentTheme.of(context)).merge(
      _getInheritedThemeData(context),
    );
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return ToggleButtonTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(ToggleButtonTheme oldWidget) =>
      data != oldWidget.data;
}

@immutable
class ToggleButtonThemeData with Diagnosticable {
  final ButtonStyle? checkedButtonStyle;
  final ButtonStyle? uncheckedButtonStyle;

  const ToggleButtonThemeData({
    this.checkedButtonStyle,
    this.uncheckedButtonStyle,
  });

  factory ToggleButtonThemeData.standard(ThemeData theme) {
    return ToggleButtonThemeData(
      checkedButtonStyle: ButtonStyle(
        backgroundColor: ButtonState.resolveWith(
          (states) => FilledButton.backgroundColor(
            theme,
            states,
          ),
        ),
        shape: ButtonState.all(RoundedRectangleBorder(
          side: const BorderSide(
            color: Colors.transparent,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4.0),
        )),
        foregroundColor: ButtonState.resolveWith(
          (states) => FilledButton.backgroundColor(
            theme,
            states,
          ).basedOnLuminance(),
        ),
      ),
    );
  }

  static ToggleButtonThemeData lerp(
    ToggleButtonThemeData? a,
    ToggleButtonThemeData? b,
    double t,
  ) {
    return ToggleButtonThemeData(
      checkedButtonStyle:
          ButtonStyle.lerp(a?.checkedButtonStyle, b?.checkedButtonStyle, t),
      uncheckedButtonStyle:
          ButtonStyle.lerp(a?.uncheckedButtonStyle, b?.uncheckedButtonStyle, t),
    );
  }

  ToggleButtonThemeData merge(ToggleButtonThemeData? other) {
    if (other == null) return this;
    return ToggleButtonThemeData(
      checkedButtonStyle: other.checkedButtonStyle ?? checkedButtonStyle,
      uncheckedButtonStyle: other.uncheckedButtonStyle ?? uncheckedButtonStyle,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ButtonStyle>(
          'checkedButtonStyle', checkedButtonStyle))
      ..add(DiagnosticsProperty<ButtonStyle>(
          'uncheckedButtonStyle', uncheckedButtonStyle));
  }
}
