import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

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
    this.content,
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
  /// with [FluentThemeData.checkboxThemeData]
  final CheckboxThemeData? style;

  /// The content of the radio button.
  ///
  /// This, if non-null, is displayed at the right of the checkbox,
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
      ..add(ObjectFlagProperty('onChanged', onChanged, ifNull: 'disabled'))
      ..add(DiagnosticsProperty<CheckboxThemeData>('style', style))
      ..add(StringProperty('semanticLabel', semanticLabel))
      ..add(DiagnosticsProperty<FocusNode>('focusNode', focusNode))
      ..add(FlagProperty(
        'autofocus',
        value: autofocus,
        defaultValue: false,
        ifFalse: 'manual focus',
      ));
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final style = CheckboxTheme.of(context).merge(this.style);
    const size = 20.0;
    return HoverButton(
      autofocus: autofocus,
      semanticLabel: semanticLabel,
      margin: style.margin,
      focusNode: focusNode,
      onPressed: onChanged == null
          ? null
          : () => onChanged!(checked == null ? null : !checked!),
      builder: (context, state) {
        Widget child = AnimatedContainer(
          alignment: AlignmentDirectional.center,
          duration: FluentTheme.of(context).fastAnimationDuration,
          curve: FluentTheme.of(context).animationCurve,
          padding: style.padding,
          height: size,
          width: size,
          decoration: () {
            if (checked == null) {
              return style.thirdstateDecoration?.resolve(state);
            } else if (checked!) {
              return style.checkedDecoration?.resolve(state);
            } else {
              return style.uncheckedDecoration?.resolve(state);
            }
          }(),
          child: checked == null
              ? _ThirdStateDash(
                  color: style.thirdstateIconColor?.resolve(state) ??
                      style.checkedIconColor?.resolve(state) ??
                      FluentTheme.of(context).inactiveColor,
                )
              : _Icon(
                  style.icon,
                  size: 12,
                  color: () {
                    if (checked == null) {
                      return style.thirdstateIconColor?.resolve(state) ??
                          style.checkedIconColor?.resolve(state);
                    } else if (checked!) {
                      return style.checkedIconColor?.resolve(state);
                    } else {
                      return style.uncheckedIconColor?.resolve(state);
                    }
                  }(),
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
          checked: checked,
          child: FocusBorder(
            renderOutside: true,
            focused: state.isFocused,
            child: child,
          ),
        );
      },
    );
  }
}

class _ThirdStateDash extends StatelessWidget {
  const _ThirdStateDash({Key? key, required this.color}) : super(key: key);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.4,
      width: 8,
      color: color,
    );
  }
}

class CheckboxTheme extends InheritedTheme {
  /// Creates a button theme that controls how descendant [Checkbox]es should
  /// look like.
  const CheckboxTheme({
    Key? key,
    required Widget child,
    required this.data,
  }) : super(key: key, child: child);

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
  /// Defaults to [FluentThemeData.checkboxTheme]
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
    final checkboxTheme =
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

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const CheckboxThemeData({
    this.checkedDecoration,
    this.uncheckedDecoration,
    this.thirdstateDecoration,
    this.padding,
    this.margin,
    this.icon,
    this.checkedIconColor,
    this.uncheckedIconColor,
    this.thirdstateIconColor,
  });

  factory CheckboxThemeData.standard(FluentThemeData theme) {
    final BorderRadiusGeometry radius = BorderRadius.circular(4.0);
    return CheckboxThemeData(
      checkedDecoration: ButtonState.resolveWith(
        (states) => BoxDecoration(
          borderRadius: radius,
          color: ButtonThemeData.checkedInputColor(theme, states),
        ),
      ),
      uncheckedDecoration: ButtonState.resolveWith(
        (states) => BoxDecoration(
          border: Border.all(
            color: states.isDisabled || states.isPressing
                ? theme.resources.controlStrongStrokeColorDisabled
                : theme.resources.controlStrongStrokeColorDefault,
          ),
          color: ButtonThemeData.uncheckedInputColor(theme, states),
          borderRadius: radius,
        ),
      ),
      thirdstateDecoration: ButtonState.resolveWith(
        (states) => BoxDecoration(
          borderRadius: radius,
          color: ButtonThemeData.checkedInputColor(theme, states),
        ),
      ),
      checkedIconColor: ButtonState.resolveWith((states) {
        return FilledButton.foregroundColor(theme, states);
      }),
      uncheckedIconColor: ButtonState.all(Colors.transparent),
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
    properties
      ..add(ObjectFlagProperty<ButtonState<Decoration?>?>.has(
        'thirdstateDecoration',
        thirdstateDecoration,
      ))
      ..add(ObjectFlagProperty<ButtonState<Decoration?>?>.has(
        'uncheckedDecoration',
        uncheckedDecoration,
      ))
      ..add(ObjectFlagProperty<ButtonState<Decoration?>?>.has(
        'checkedDecoration',
        checkedDecoration,
      ))
      ..add(ObjectFlagProperty<ButtonState<Color?>?>.has(
        'thirdstateIconColor',
        thirdstateIconColor,
      ))
      ..add(ObjectFlagProperty<ButtonState<Color?>?>.has(
        'uncheckedIconColor',
        uncheckedIconColor,
      ))
      ..add(ObjectFlagProperty<ButtonState<Color?>?>.has(
        'checkedIconColor',
        checkedIconColor,
      ))
      ..add(IconDataProperty('icon', icon))
      ..add(ObjectFlagProperty<ButtonState<Decoration?>?>.has(
        'checkedDecoration',
        checkedDecoration,
      ))
      ..add(ObjectFlagProperty<ButtonState<Decoration?>?>.has(
        'uncheckedDecoration',
        uncheckedDecoration,
      ))
      ..add(
        DiagnosticsProperty<EdgeInsetsGeometry?>('padding', padding),
      )
      ..add(DiagnosticsProperty<EdgeInsetsGeometry?>('margin', margin));
  }
}

/// Copy if [Icon], with specified font weight
/// See https://github.com/bdlukaa/fluent_ui/issues/471
class _Icon extends StatelessWidget {
  const _Icon(
    this.icon, {
    Key? key,
    this.size,
    this.color,
  }) : super(key: key);

  final IconData? icon;

  final double? size;

  final Color? color;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    final textDirection = Directionality.of(context);

    final iconTheme = IconTheme.of(context);

    final iconSize = size ?? iconTheme.size;

    final iconShadows = iconTheme.shadows;

    if (icon == null) {
      return SizedBox(width: iconSize, height: iconSize);
    }

    final iconOpacity = iconTheme.opacity ?? 1.0;
    var iconColor = color ?? iconTheme.color!;
    if (iconOpacity != 1.0) {
      iconColor = iconColor.withOpacity(iconColor.opacity * iconOpacity);
    }

    Widget iconWidget = RichText(
      overflow: TextOverflow.visible, // Never clip.
      textDirection:
          textDirection, // Since we already fetched it for the assert...
      text: TextSpan(
        text: String.fromCharCode(icon!.codePoint),
        style: TextStyle(
          inherit: false,
          color: iconColor,
          fontSize: iconSize,
          fontWeight: FontWeight.w900,
          fontFamily: icon!.fontFamily,
          package: icon!.fontPackage,
          shadows: iconShadows,
        ),
      ),
    );

    if (icon!.matchTextDirection) {
      switch (textDirection) {
        case TextDirection.rtl:
          iconWidget = Transform(
            transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
            alignment: AlignmentDirectional.center,
            transformHitTests: false,
            child: iconWidget,
          );
          break;
        case TextDirection.ltr:
          break;
      }
    }

    return ExcludeSemantics(
      child: SizedBox(
        width: iconSize,
        height: iconSize,
        child: Center(
          child: iconWidget,
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IconDataProperty('icon', icon, ifNull: '<empty>', showName: false))
      ..add(DoubleProperty('size', size, defaultValue: null))
      ..add(ColorProperty('color', color, defaultValue: null));
  }
}
