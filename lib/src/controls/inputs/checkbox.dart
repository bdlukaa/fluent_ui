import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// A check box is used to select or deselect action items.
///
/// It can be used for a single item or for a list of multiple items that a user
/// can choose from. The control has three selection states: unselected (`false`),
/// selected (`true`), and indeterminate (`null`). Use the indeterminate state
/// when a collection of sub-choices have both unselected and selected states.
///
/// ![Checkbox Preview](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/templates-checkbox-states-default.png)
///
/// {@tool snippet}
/// This example shows a basic checkbox:
///
/// ```dart
/// bool isChecked = false;
///
/// Checkbox(
///   checked: isChecked,
///   onChanged: (value) => setState(() => isChecked = value ?? false),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// This example shows a checkbox with a label:
///
/// ```dart
/// Checkbox(
///   checked: isAccepted,
///   content: Text('I accept the terms and conditions'),
///   onChanged: (value) => setState(() => isAccepted = value ?? false),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// This example shows a three-state checkbox used to represent a group:
///
/// ```dart
/// // null = indeterminate (some children checked)
/// // true = all children checked
/// // false = no children checked
/// bool? parentChecked;
///
/// Checkbox(
///   checked: parentChecked,
///   content: Text('Select all'),
///   onChanged: (value) {
///     setState(() {
///       // When clicked, toggle between checked and unchecked
///       parentChecked = value == true ? true : false;
///     });
///   },
/// )
/// ```
/// {@end-tool}
///
/// ## Checkbox vs other controls
///
/// Use a checkbox when:
/// * Users can select zero, one, or multiple items from a list
/// * Items in the list are independent (selecting one doesn't affect others)
/// * You want to show the current selection state at a glance
///
/// Consider using:
/// * [RadioButton] when users must select exactly one option
/// * [ToggleSwitch] for binary on/off settings that take effect immediately
/// * [ToggleButton] for a button that maintains a toggled state
///
/// See also:
///
///  * [ToggleSwitch], which represents a physical switch that allows users to
///    turn things on or off immediately
///  * [RadioButton], lets users select one option from a collection of two or
///    more mutually exclusive, visible options
///  * [ToggleButton], a button that can be toggled on or off
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/checkbox>
class Checkbox extends StatelessWidget {
  /// Creates a checkbox.
  const Checkbox({
    required this.checked, required this.onChanged, super.key,
    this.style,
    this.content,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  });

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
      ..add(
        FlagProperty(
          'autofocus',
          value: autofocus,
          defaultValue: false,
          ifFalse: 'manual focus',
        ),
      );
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
        Widget child = Container(
          alignment: AlignmentDirectional.center,
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
                  color:
                      style.thirdstateIconColor?.resolve(state) ??
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
          child = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              child,
              const SizedBox(width: 8),
              DefaultTextStyle.merge(
                style: TextStyle(color: style.foregroundColor?.resolve(state)),
                child: IconTheme.merge(
                  data: IconThemeData(
                    color: style.foregroundColor?.resolve(state),
                  ),
                  child: content!,
                ),
              ),
            ],
          );
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
  const _ThirdStateDash({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(height: 1.4, width: 8, color: color);
  }
}

class CheckboxTheme extends InheritedTheme {
  /// Creates a theme that controls how descendant [Checkbox]es should
  /// look like.
  const CheckboxTheme({required super.child, required this.data, super.key});

  final CheckboxThemeData data;

  /// Creates a theme that merges the nearest [CheckboxTheme] with [data].
  static Widget merge({
    required CheckboxThemeData data, required Widget child, Key? key,
  }) {
    return Builder(
      builder: (context) {
        return CheckboxTheme(
          key: key,
          data: CheckboxTheme.of(context).merge(data),
          child: child,
        );
      },
    );
  }

  /// Returns the closest [CheckboxThemeData] which encloses the given context.
  ///
  /// Resolution order:
  /// 1. Defaults from [CheckboxThemeData.standard]
  /// 2. Global theme from [FluentThemeData.checkboxTheme]
  /// 3. Local [CheckboxTheme] ancestor
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// CheckboxThemeData theme = CheckboxTheme.of(context);
  /// ```
  static CheckboxThemeData of(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final inheritedTheme = context
        .dependOnInheritedWidgetOfExactType<CheckboxTheme>();
    return CheckboxThemeData.standard(
      theme,
    ).merge(theme.checkboxTheme).merge(inheritedTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return CheckboxTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(CheckboxTheme oldWidget) => data != oldWidget.data;
}

@immutable
class CheckboxThemeData with Diagnosticable {
  /// The decoration of the checkbox when it's checked
  final WidgetStateProperty<Decoration?>? checkedDecoration;

  /// The decoration of the checkbox when it's unchecked
  final WidgetStateProperty<Decoration?>? uncheckedDecoration;

  /// The decoration of the checkbox when it's in its third state
  final WidgetStateProperty<Decoration?>? thirdstateDecoration;

  /// The icon displayed in the checkbox when it's checked
  final IconData? icon;

  /// The color of the [icon] when the checkbox is checked
  final WidgetStateProperty<Color?>? checkedIconColor;

  /// The color of the [icon] when the checkbox is unchecked
  final WidgetStateProperty<Color?>? uncheckedIconColor;

  /// The color of the [icon] when the checkbox is in its third state
  final WidgetStateProperty<Color?>? thirdstateIconColor;

  /// The color of the content of the checkbox
  final WidgetStateProperty<Color?>? foregroundColor;

  /// The padding around the checkbox
  final EdgeInsetsGeometry? padding;

  /// The margin around the checkbox
  final EdgeInsetsGeometry? margin;

  /// Creates a [CheckboxThemeData]
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
    this.foregroundColor,
  });

  factory CheckboxThemeData.standard(FluentThemeData theme) {
    final BorderRadiusGeometry radius = BorderRadius.circular(6);
    return CheckboxThemeData(
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        return states.isDisabled ? theme.resources.textFillColorDisabled : null;
      }),
      checkedDecoration: WidgetStateProperty.resolveWith(
        (states) => BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: states.isDisabled
                ? theme.resources.controlStrongStrokeColorDisabled
                : ButtonThemeData.checkedInputColor(theme, states),
          ),
          color: ButtonThemeData.checkedInputColor(theme, states),
        ),
      ),
      uncheckedDecoration: WidgetStateProperty.resolveWith(
        (states) => BoxDecoration(
          border: Border.all(
            color: states.isDisabled || states.isPressed
                ? theme.resources.controlStrongStrokeColorDisabled
                : theme.resources.controlStrongStrokeColorDefault,
          ),
          color: WidgetStateExtension.forStates<Color>(
            states,
            disabled: theme.resources.controlAltFillColorDisabled,
            pressed: theme.resources.controlAltFillColorQuarternary,
            hovering: theme.resources.controlAltFillColorTertiary,
            none: theme.resources.controlAltFillColorSecondary,
          ),
          borderRadius: radius,
        ),
      ),
      thirdstateDecoration: WidgetStateProperty.resolveWith(
        (states) => BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: states.isDisabled
                ? theme.resources.controlStrongStrokeColorDisabled
                : ButtonThemeData.checkedInputColor(theme, states),
          ),
          color: ButtonThemeData.checkedInputColor(theme, states),
        ),
      ),
      checkedIconColor: WidgetStateProperty.resolveWith((states) {
        return FilledButton.foregroundColor(theme, states);
      }),
      uncheckedIconColor: const WidgetStatePropertyAll(Colors.transparent),
      icon: FluentIcons.check_mark,
    );
  }

  /// Linearly interpolate between two checkbox themes.
  static CheckboxThemeData lerp(
    CheckboxThemeData? a,
    CheckboxThemeData? b,
    double t,
  ) {
    return CheckboxThemeData(
      margin: EdgeInsetsGeometry.lerp(a?.margin, b?.margin, t),
      padding: EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t),
      icon: t < 0.5 ? a?.icon : b?.icon,
      checkedIconColor: lerpWidgetStateProperty<Color?>(
        a?.checkedIconColor,
        b?.checkedIconColor,
        t,
        Color.lerp,
      ),
      uncheckedIconColor: lerpWidgetStateProperty<Color?>(
        a?.uncheckedIconColor,
        b?.uncheckedIconColor,
        t,
        Color.lerp,
      ),
      thirdstateIconColor: lerpWidgetStateProperty<Color?>(
        a?.thirdstateIconColor,
        b?.thirdstateIconColor,
        t,
        Color.lerp,
      ),
      checkedDecoration: lerpWidgetStateProperty<Decoration?>(
        a?.checkedDecoration,
        b?.checkedDecoration,
        t,
        Decoration.lerp,
      ),
      uncheckedDecoration: lerpWidgetStateProperty<Decoration?>(
        a?.uncheckedDecoration,
        b?.uncheckedDecoration,
        t,
        Decoration.lerp,
      ),
      thirdstateDecoration: lerpWidgetStateProperty<Decoration?>(
        a?.thirdstateDecoration,
        b?.thirdstateDecoration,
        t,
        Decoration.lerp,
      ),
      foregroundColor: lerpWidgetStateProperty<Color?>(
        a?.foregroundColor,
        b?.foregroundColor,
        t,
        Color.lerp,
      ),
    );
  }

  /// Merge this checkbox theme data with another
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
      foregroundColor: style?.foregroundColor ?? foregroundColor,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        ObjectFlagProperty<WidgetStateProperty<Decoration?>?>.has(
          'thirdstateDecoration',
          thirdstateDecoration,
        ),
      )
      ..add(
        ObjectFlagProperty<WidgetStateProperty<Decoration?>?>.has(
          'uncheckedDecoration',
          uncheckedDecoration,
        ),
      )
      ..add(
        ObjectFlagProperty<WidgetStateProperty<Decoration?>?>.has(
          'checkedDecoration',
          checkedDecoration,
        ),
      )
      ..add(
        ObjectFlagProperty<WidgetStateProperty<Color?>?>.has(
          'thirdstateIconColor',
          thirdstateIconColor,
        ),
      )
      ..add(
        ObjectFlagProperty<WidgetStateProperty<Color?>?>.has(
          'uncheckedIconColor',
          uncheckedIconColor,
        ),
      )
      ..add(
        ObjectFlagProperty<WidgetStateProperty<Color?>?>.has(
          'checkedIconColor',
          checkedIconColor,
        ),
      )
      ..add(IconDataProperty('icon', icon))
      ..add(
        ObjectFlagProperty<WidgetStateProperty<Decoration?>?>.has(
          'checkedDecoration',
          checkedDecoration,
        ),
      )
      ..add(
        ObjectFlagProperty<WidgetStateProperty<Decoration?>?>.has(
          'uncheckedDecoration',
          uncheckedDecoration,
        ),
      )
      ..add(DiagnosticsProperty<EdgeInsetsGeometry?>('padding', padding))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry?>('margin', margin))
      ..add(DiagnosticsProperty('foregroundColor', foregroundColor));
  }
}

/// Copy if [Icon], with specified font weight
/// See https://github.com/bdlukaa/fluent_ui/issues/471
class _Icon extends StatelessWidget {
  const _Icon(this.icon, {this.size, this.color});

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
      iconColor = iconColor.withValues(alpha: iconColor.a * iconOpacity);
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
            transform: Matrix4.identity()
              ..scaleByDouble(
                -1, // Flip X axis (horizontal flip)
                1, // Keep Y axis (no vertical flip)
                1, // Keep Z axis (no depth flip)
                1, // No perspective
              ),
            alignment: AlignmentDirectional.center,
            transformHitTests: false,
            child: iconWidget,
          );
        case TextDirection.ltr:
          break;
      }
    }

    return ExcludeSemantics(
      child: SizedBox(
        width: iconSize,
        height: iconSize,
        child: Center(child: iconWidget),
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
