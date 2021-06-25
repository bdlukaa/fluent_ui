import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'package:fluent_ui/fluent_ui.dart';

/// A check box is used to select or deselect action items. It can
/// be used for a single item or for a list of multiple items that
/// a user can choose from. The control has three selection states:
/// unselected, selected, and indeterminate. Use the indeterminate
/// state when a collection of sub-choices have both unselected and
/// selected states.
///
/// ![Checkbox Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/templates-checkbox-states-default.png)
///
/// See also:
/// - [ToggleSwitch](https://pub.dev/packages/fluent_ui#toggle-switches)
/// - [RadioButton](https://pub.dev/packages/fluent_ui#radio-buttons)
/// - [ToggleButton]
class Checkbox extends StatelessWidget {
  /// Creates a checkbox.
  const Checkbox({
    Key? key,
    required this.checked,
    required this.onChanged,
    this.style,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  }) : super(key: key);

  /// Whether the checkbox is checked or not.
  ///
  /// If `null`, the checkbox is in its third state.
  final bool? checked;

  /// Called when the value of the [Checkbox] should change.
  ///
  /// This callback passes a new value, but doesn't update its
  /// state internally.
  ///
  /// If null, the checkbox is considered disabled.
  final ValueChanged<bool?>? onChanged;

  /// The style applied to the checkbox. If non-null, it's mescled
  /// with [ThemeData.checkboxThemeData]
  final CheckboxThemeData? style;

  /// {@macro fluent_ui.controls.inputs.HoverButton.semanticLabel}
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
    properties.add(ObjectFlagProperty(
      'onChanged',
      onChanged,
      ifNull: 'disabled',
    ));
    properties.add(DiagnosticsProperty<CheckboxThemeData>('style', style));
    properties.add(StringProperty('semanticLabel', semanticLabel));
    properties.add(DiagnosticsProperty<FocusNode>('focusNode', focusNode));
    properties.add(FlagProperty(
      'autofocus',
      value: autofocus,
      defaultValue: false,
      ifFalse: 'manual focus',
    ));
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final CheckboxThemeData style = CheckboxTheme.of(context).merge(this.style);
    final double size = 22;
    return HoverButton(
      autofocus: autofocus,
      semanticLabel: semanticLabel,
      margin: style.margin,
      focusNode: focusNode,
      cursor: style.cursor,
      onPressed: onChanged == null
          ? null
          : () => onChanged!(checked == null ? null : !(checked!)),
      builder: (context, state) {
        Widget child = AnimatedContainer(
          alignment: Alignment.center,
          duration: FluentTheme.of(context).mediumAnimationDuration,
          curve: FluentTheme.of(context).animationCurve,
          padding: style.padding,
          height: size,
          width: size,
          decoration: () {
            if (checked == null)
              return style.thirdstateDecoration?.resolve(state);
            else if (checked!)
              return style.checkedDecoration?.resolve(state);
            else
              return style.uncheckedDecoration?.resolve(state);
          }(),
          child: Icon(
            style.icon,
            size: 18,
            color: () {
              if (checked == null)
                return style.thirdstateIconColor?.resolve(state);
              else if (checked!)
                return style.checkedIconColor?.resolve(state);
              else
                return style.uncheckedIconColor?.resolve(state);
            }(),
          ),
        );
        return Semantics(
          checked: checked,
          child: FocusBorder(
            focused: state.isFocused,
            child: child,
          ),
        );
      },
    );
  }
}

class CheckboxTheme extends InheritedTheme {
  /// Creates a button theme that controls how descendant [Checkbox]es should
  /// look like.
  const CheckboxTheme({
    Key? key,
    required this.child,
    required this.data,
  }) : super(key: key, child: child);

  final Widget child;
  final CheckboxThemeData data;

  /// Creates a button theme that controls how descendant [Checkbox]es should
  /// look like, and merges in the current button theme, if any.
  static Widget merge({
    Key? key,
    required CheckboxThemeData data,
    required Widget child,
  }) {
    return Builder(builder: (BuildContext context) {
      return CheckboxTheme(
        key: key,
        data: _getInheritedCheckboxThemeData(context).merge(data),
        child: child,
      );
    });
  }

  /// The data from the closest instance of this class that encloses the given
  /// context.
  ///
  /// Defaults to [ThemeData.checkboxTheme]
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// CheckboxThemeData theme = CheckboxTheme.of(context);
  /// ```
  static CheckboxThemeData of(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return CheckboxThemeData.standard(FluentTheme.of(context)).merge(
      _getInheritedCheckboxThemeData(context),
    );
  }

  static CheckboxThemeData _getInheritedCheckboxThemeData(
      BuildContext context) {
    final CheckboxTheme? checkboxTheme =
        context.dependOnInheritedWidgetOfExactType<CheckboxTheme>();
    return checkboxTheme?.data ?? FluentTheme.of(context).checkboxTheme;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return CheckboxTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(CheckboxTheme oldWidget) {
    return oldWidget.data != data;
  }
}

@immutable
class CheckboxThemeData with Diagnosticable {
  final ButtonState<Decoration?>? checkedDecoration;
  final ButtonState<Decoration?>? uncheckedDecoration;
  final ButtonState<Decoration?>? thirdstateDecoration;

  final IconData? icon;
  final ButtonState<Color?>? checkedIconColor;
  final ButtonState<Color?>? uncheckedIconColor;
  final ButtonState<Color?>? thirdstateIconColor;

  final ButtonState<MouseCursor>? cursor;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const CheckboxThemeData({
    this.checkedDecoration,
    this.uncheckedDecoration,
    this.thirdstateDecoration,
    this.cursor,
    this.padding,
    this.margin,
    this.icon,
    this.checkedIconColor,
    this.uncheckedIconColor,
    this.thirdstateIconColor,
  });

  factory CheckboxThemeData.standard(ThemeData style) {
    final BorderRadiusGeometry radius = BorderRadius.circular(3);
    return CheckboxThemeData(
      cursor: style.inputMouseCursor,
      checkedDecoration: ButtonState.resolveWith(
        (states) => BoxDecoration(
          borderRadius: radius,
          color: ButtonThemeData.checkedInputColor(style, states),
        ),
      ),
      uncheckedDecoration: ButtonState.resolveWith(
        (states) => BoxDecoration(
          border: Border.all(
            width: 0.6,
            color:
                states.isDisabled ? style.disabledColor : style.inactiveColor,
          ),
          color:
              ButtonThemeData.checkedInputColor(style, states).withOpacity(0),
          borderRadius: radius,
        ),
      ),
      thirdstateDecoration: ButtonState.resolveWith(
        (states) => BoxDecoration(
          borderRadius: radius,
          color: Colors.white,
          border: Border.all(
            width: 6.5,
            color: ButtonThemeData.checkedInputColor(style, states),
          ),
        ),
      ),
      checkedIconColor: ButtonState.resolveWith((states) {
        return states.isDisabled
            ? ButtonThemeData.checkedInputColor(
                style,
                states,
              ).basedOnLuminance()
            : style.activeColor;
      }),
      uncheckedIconColor: ButtonState.resolveWith(
        (states) => states.isHovering || states.isPressing
            ? style.inactiveColor.withOpacity(0.8)
            : Colors.transparent,
      ),
      thirdstateIconColor: ButtonState.all(Colors.transparent),
      icon: FluentIcons.check_mark,
      margin: const EdgeInsets.all(4.0),
    );
  }

  static CheckboxThemeData lerp(
    CheckboxThemeData? a,
    CheckboxThemeData? b,
    double t,
  ) {
    return CheckboxThemeData(
      margin: EdgeInsetsGeometry.lerp(a?.margin, b?.margin, t),
      padding: EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t),
      cursor: t < 0.5 ? a?.cursor : b?.cursor,
      icon: t < 0.5 ? a?.icon : b?.icon,
      checkedIconColor: ButtonState.lerp(
          a?.checkedIconColor, b?.checkedIconColor, t, Color.lerp),
      uncheckedIconColor: ButtonState.lerp(
          a?.uncheckedIconColor, b?.uncheckedIconColor, t, Color.lerp),
      thirdstateIconColor: ButtonState.lerp(
          a?.thirdstateIconColor, b?.thirdstateIconColor, t, Color.lerp),
      checkedDecoration: ButtonState.lerp(
          a?.checkedDecoration, b?.checkedDecoration, t, Decoration.lerp),
      uncheckedDecoration: ButtonState.lerp(
          a?.uncheckedDecoration, b?.uncheckedDecoration, t, Decoration.lerp),
      thirdstateDecoration: ButtonState.lerp(
          a?.thirdstateDecoration, b?.thirdstateDecoration, t, Decoration.lerp),
    );
  }

  CheckboxThemeData merge(CheckboxThemeData? style) {
    return CheckboxThemeData(
      margin: style?.margin ?? margin,
      padding: style?.padding ?? padding,
      cursor: style?.cursor ?? cursor,
      icon: style?.icon ?? icon,
      checkedIconColor: style?.checkedIconColor ?? checkedIconColor,
      uncheckedIconColor: style?.uncheckedIconColor ?? uncheckedIconColor,
      thirdstateIconColor: style?.thirdstateIconColor ?? thirdstateIconColor,
      checkedDecoration: style?.checkedDecoration ?? checkedDecoration,
      uncheckedDecoration: style?.uncheckedDecoration ?? uncheckedDecoration,
      thirdstateDecoration: style?.thirdstateDecoration ?? thirdstateDecoration,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<ButtonState<Decoration?>?>.has(
      'thirdstateDecoration',
      thirdstateDecoration,
    ));
    properties.add(ObjectFlagProperty<ButtonState<Decoration?>?>.has(
      'uncheckedDecoration',
      uncheckedDecoration,
    ));
    properties.add(ObjectFlagProperty<ButtonState<Decoration?>?>.has(
      'checkedDecoration',
      checkedDecoration,
    ));
    properties.add(ObjectFlagProperty<ButtonState<Color?>?>.has(
      'thirdstateIconColor',
      thirdstateIconColor,
    ));
    properties.add(ObjectFlagProperty<ButtonState<Color?>?>.has(
      'uncheckedIconColor',
      uncheckedIconColor,
    ));
    properties.add(ObjectFlagProperty<ButtonState<Color?>?>.has(
      'checkedIconColor',
      checkedIconColor,
    ));
    properties.add(IconDataProperty('icon', icon));
    properties.add(IconDataProperty('icon', icon));
    properties.add(ObjectFlagProperty<ButtonState<Decoration?>?>.has(
      'checkedDecoration',
      checkedDecoration,
    ));
    properties.add(ObjectFlagProperty<ButtonState<Decoration?>?>.has(
      'uncheckedDecoration',
      uncheckedDecoration,
    ));
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry?>('padding', padding),
    );
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry?>('margin', margin));
    properties.add(
      ObjectFlagProperty<ButtonState<MouseCursor>?>.has('cursor', cursor),
    );
  }
}
