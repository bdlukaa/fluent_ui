import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

typedef ToggleSwitchKnobBuilder = Widget Function(
  BuildContext context,
  Set<WidgetState> states,
);

/// The toggle switch represents a physical switch that allows users to turn
/// things on or off, like a light switch. Use toggle switch controls to present
/// users with two mutually exclusive options (such as on/off), where choosing
/// an option provides immediate results.
///
/// Use a toggle switch for binary operations that take effect right after the
/// user flips the toggle switch
///
/// ![ToggleSwitch Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/toggleswitches01.png)
///
/// Think of the toggle switch as a physical power switch for a device: you flip
/// it on or off when you want to enable or disable the action performed by the device.
///
/// See also:
///
///  * [Checkbox], which let the user select multiple items from a collection of
///    two or more items
///  * [ToggleButton], which let the user toggle a option on or off
///  * [RadioButton], which let the user select one item from a collection of two
///    or more options
///  * <https://docs.microsoft.com/en-us/windows/apps/design/controls/toggles>
class ToggleSwitch extends StatefulWidget {
  /// Creates a toggle switch.
  const ToggleSwitch({
    super.key,
    required this.checked,
    required this.onChanged,
    this.style,
    this.content,
    this.leadingContent = false,
    this.semanticLabel,
    this.knob,
    this.knobBuilder,
    this.focusNode,
    this.autofocus = false,
  });

  /// Whether this toggle switch is checked
  final bool checked;

  /// Called when the value of the switch should change.
  ///
  /// This callback updates a new value, but doesn't update its state internally.
  ///
  /// If this callback is null, the switch is considered disabled.
  final ValueChanged<bool>? onChanged;

  /// The knob of the switch
  ///
  /// [DefaultToggleSwitchKnob] is used by default
  ///
  /// See also:
  ///
  ///   * [knobBuilder], which builds the knob based on the current state
  ///   * [DefaultToggleSwitchKnob], used when both [knob] and [knobBuilder] are null
  final Widget? knob;

  /// Build the knob of the switch based on the current state
  ///
  /// See also:
  ///   * [knob], a static knob
  ///   * [DefaultToggleSwitchKnob], used when both [knob] and [knobBuilder] are null
  final ToggleSwitchKnobBuilder? knobBuilder;

  /// The style of the toggle switch
  final ToggleSwitchThemeData? style;

  /// The content of the radio button.
  ///
  /// This, if non-null, is displayed at the right of the switcher,
  /// and is affected by user touch.
  ///
  /// Usually a [Text] or [Icon] widget
  final Widget? content;

  /// Whether to position [content] before the switch, if provided
  ///
  /// Defaults to `false`
  final bool leadingContent;

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
      ..add(FlagProperty('leadingContent',
          value: leadingContent, ifFalse: 'trailingContent'))
      ..add(ObjectFlagProperty('onChanged', onChanged, ifNull: 'disabled'))
      ..add(
          FlagProperty('autofocus', value: autofocus, ifFalse: 'manual focus'))
      ..add(DiagnosticsProperty<ToggleSwitchThemeData>('style', style))
      ..add(StringProperty('semanticLabel', semanticLabel))
      ..add(ObjectFlagProperty<FocusNode>.has('focusNode', focusNode));
  }

  @override
  State<ToggleSwitch> createState() => _ToggleSwitchState();
}

class _ToggleSwitchState extends State<ToggleSwitch> {
  bool get isDisabled => widget.onChanged == null;
  bool _dragging = false;

  Alignment? _alignment;

  void _handleAlignmentChanged(
    Offset localPosition,
    double sliderGestureWidth,
  ) {
    setState(() {
      _alignment = Alignment(
        (localPosition.dx / sliderGestureWidth).clamp(-1, 1),
        0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final style = ToggleSwitchTheme.of(context).merge(widget.style);
    final sliderGestureWidth = 45.0 + (style.padding?.horizontal ?? 0.0);
    return HoverButton(
      autofocus: widget.autofocus,
      semanticLabel: widget.semanticLabel,
      margin: style.margin,
      focusNode: widget.focusNode,
      onPressed: isDisabled ? null : () => widget.onChanged!(!widget.checked),
      onHorizontalDragStart: isDisabled
          ? null
          : (e) {
              _handleAlignmentChanged(e.localPosition, sliderGestureWidth);
              setState(() => _dragging = true);
            },
      onHorizontalDragUpdate: isDisabled
          ? null
          : (e) {
              _handleAlignmentChanged(e.localPosition, sliderGestureWidth);
              if (!_dragging) setState(() => _dragging = true);
            },
      onHorizontalDragEnd: isDisabled
          ? null
          : (e) {
              if (_alignment != null) {
                if (_alignment!.x >= 0.5) {
                  widget.onChanged!(true);
                } else {
                  widget.onChanged!(false);
                }
                setState(() {
                  _alignment = null;
                  _dragging = false;
                });
              }
            },
      builder: (context, states) {
        Widget child = AnimatedContainer(
          alignment: _alignment ??
              (widget.checked
                  ? AlignmentDirectional.centerEnd
                  : AlignmentDirectional.centerStart),
          height: 20,
          width: 40,
          duration: style.animationDuration ?? Duration.zero,
          curve: style.animationCurve ?? Curves.linear,
          padding: style.padding,
          decoration: widget.checked
              ? style.checkedDecoration?.resolve(states)
              : style.uncheckedDecoration?.resolve(states),
          child: widget.knob ??
              widget.knobBuilder?.call(context, states) ??
              DefaultToggleSwitchKnob(
                checked: widget.checked,
                style: style,
                states: _dragging ? {WidgetState.pressed} : states,
              ),
        );
        if (widget.content != null) {
          child = DefaultTextStyle.merge(
            style: TextStyle(color: style.foregroundColor?.resolve(states)),
            child: IconTheme.merge(
              data: IconThemeData(
                color: style.foregroundColor?.resolve(states),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: widget.leadingContent
                    ? [
                        widget.content!,
                        const SizedBox(width: 10.0),
                        child,
                      ]
                    : [
                        child,
                        const SizedBox(width: 10.0),
                        widget.content!,
                      ],
              ),
            ),
          );
        }
        return Semantics(
          toggled: widget.checked,
          child: FocusBorder(
            focused: states.isFocused,
            child: child,
          ),
        );
      },
    );
  }
}

class DefaultToggleSwitchKnob extends StatelessWidget {
  const DefaultToggleSwitchKnob({
    super.key,
    required this.checked,
    required this.style,
    required this.states,
  });

  final bool checked;
  final ToggleSwitchThemeData? style;
  final Set<WidgetState> states;

  @override
  Widget build(BuildContext context) {
    const checkedFactor = 1;
    return AnimatedContainer(
      duration: style?.animationDuration ?? Duration.zero,
      curve: style?.animationCurve ?? Curves.linear,
      margin: states.isHovered
          ? const EdgeInsets.all(1.0 + checkedFactor)
          : const EdgeInsets.symmetric(
              horizontal: 2.0 + checkedFactor,
              vertical: 2.0 + checkedFactor,
            ),
      height: 18.0,
      width:
          12.0 + (states.isHovered ? 2.0 : 0.0) + (states.isPressed ? 5.0 : 0),
      decoration: checked
          ? style?.checkedKnobDecoration?.resolve(states)
          : style?.uncheckedKnobDecoration?.resolve(states),
    );
  }
}

class ToggleSwitchTheme extends InheritedTheme {
  /// Creates a button theme that controls how descendant [ToggleSwitch]es should
  /// look like.
  const ToggleSwitchTheme({
    super.key,
    required super.child,
    required this.data,
  });

  final ToggleSwitchThemeData data;

  /// Creates a button theme that controls how descendant [ToggleSwitch]es should
  /// look like, and merges in the current button theme, if any.
  static Widget merge({
    Key? key,
    required ToggleSwitchThemeData data,
    required Widget child,
  }) {
    return Builder(builder: (BuildContext context) {
      return ToggleSwitchTheme(
        key: key,
        data: _getInheritedToggleSwitchThemeData(context).merge(data),
        child: child,
      );
    });
  }

  /// The data from the closest instance of this class that encloses the given
  /// context.
  ///
  /// Defaults to [FluentThemeData.toggleSwitchTheme]
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// ToggleSwitchThemeData theme = ToggleSwitchTheme.of(context);
  /// ```
  static ToggleSwitchThemeData of(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return ToggleSwitchThemeData.standard(FluentTheme.of(context)).merge(
      _getInheritedToggleSwitchThemeData(context),
    );
  }

  static ToggleSwitchThemeData _getInheritedToggleSwitchThemeData(
      BuildContext context) {
    final checkboxTheme =
        context.dependOnInheritedWidgetOfExactType<ToggleSwitchTheme>();
    return checkboxTheme?.data ?? FluentTheme.of(context).toggleSwitchTheme;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return ToggleSwitchTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(ToggleSwitchTheme oldWidget) {
    return oldWidget.data != data;
  }
}

@immutable
class ToggleSwitchThemeData with Diagnosticable {
  /// The decoration of the knob when the switch is checked
  final WidgetStateProperty<Decoration?>? checkedKnobDecoration;

  /// The decoration of the knob when the switch is unchecked
  final WidgetStateProperty<Decoration?>? uncheckedKnobDecoration;

  /// The decoration of the switch when the it is checked
  final WidgetStateProperty<Decoration?>? checkedDecoration;

  /// The decoration of the switch when the it is unchecked
  final WidgetStateProperty<Decoration?>? uncheckedDecoration;

  /// The padding of the switch
  final EdgeInsetsGeometry? padding;

  /// The margin of the switch
  final EdgeInsetsGeometry? margin;

  /// The duration of the animation
  final Duration? animationDuration;

  /// The curve of the animation
  final Curve? animationCurve;

  /// The foreground color of the content of the switch
  final WidgetStateProperty<Color?>? foregroundColor;

  /// Creates a theme that can be used for [ToggleSwitchTheme]
  const ToggleSwitchThemeData({
    this.padding,
    this.margin,
    this.animationDuration,
    this.animationCurve,
    this.checkedKnobDecoration,
    this.uncheckedKnobDecoration,
    this.checkedDecoration,
    this.uncheckedDecoration,
    this.foregroundColor,
  });

  factory ToggleSwitchThemeData.standard(FluentThemeData theme) {
    final defaultKnobDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(100),
    );

    final defaultDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(100),
    );

    return ToggleSwitchThemeData(
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        return states.isDisabled ? theme.resources.textFillColorDisabled : null;
      }),
      checkedDecoration: WidgetStateProperty.resolveWith((states) {
        return defaultDecoration.copyWith(
          color: ButtonThemeData.checkedInputColor(theme, states),
          border: Border.all(
            color: ButtonThemeData.checkedInputColor(theme, states),
          ),
        );
      }),
      uncheckedDecoration: WidgetStateProperty.resolveWith((states) {
        return defaultDecoration.copyWith(
          color: WidgetStateExtension.forStates<Color>(
            states,
            disabled: theme.resources.controlAltFillColorDisabled,
            pressed: theme.resources.controlAltFillColorQuarternary,
            hovering: theme.resources.controlAltFillColorTertiary,
            none: theme.resources.controlAltFillColorSecondary,
          ),
          border: Border.all(
            color: WidgetStateExtension.forStates<Color>(
              states,
              disabled: theme.resources.controlStrongFillColorDisabled,
              none: theme.resources.controlStrongFillColorDefault,
            ),
          ),
        );
      }),
      animationDuration: theme.fasterAnimationDuration,
      animationCurve: Curves.fastOutSlowIn,
      checkedKnobDecoration: WidgetStateProperty.resolveWith((states) {
        return defaultKnobDecoration.copyWith(
          color: states.isDisabled
              ? theme.resources.textOnAccentFillColorDisabled
              : theme.resources.textOnAccentFillColorPrimary,
        );
      }),
      uncheckedKnobDecoration: WidgetStateProperty.resolveWith((states) {
        return defaultKnobDecoration.copyWith(
          color: states.isDisabled
              ? theme.resources.textFillColorDisabled
              : theme.resources.textFillColorSecondary,
        );
      }),
    );
  }

  static ToggleSwitchThemeData lerp(
    ToggleSwitchThemeData? a,
    ToggleSwitchThemeData? b,
    double t,
  ) {
    return ToggleSwitchThemeData(
      margin: EdgeInsetsGeometry.lerp(a?.margin, b?.margin, t),
      padding: EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t),
      animationCurve: t < 0.5 ? a?.animationCurve : b?.animationCurve,
      animationDuration: lerpDuration(a?.animationDuration ?? Duration.zero,
          b?.animationDuration ?? Duration.zero, t),
      checkedKnobDecoration: WidgetStateProperty.lerp<Decoration?>(
          a?.checkedKnobDecoration,
          b?.checkedKnobDecoration,
          t,
          Decoration.lerp),
      uncheckedKnobDecoration: WidgetStateProperty.lerp<Decoration?>(
          a?.uncheckedKnobDecoration,
          b?.uncheckedKnobDecoration,
          t,
          Decoration.lerp),
      checkedDecoration: WidgetStateProperty.lerp<Decoration?>(
          a?.checkedDecoration, b?.checkedDecoration, t, Decoration.lerp),
      uncheckedDecoration: WidgetStateProperty.lerp<Decoration?>(
          a?.uncheckedDecoration, b?.uncheckedDecoration, t, Decoration.lerp),
      foregroundColor: WidgetStateProperty.lerp<Color?>(
          a?.foregroundColor, b?.foregroundColor, t, Color.lerp),
    );
  }

  ToggleSwitchThemeData merge(ToggleSwitchThemeData? style) {
    return ToggleSwitchThemeData(
      margin: style?.margin ?? margin,
      padding: style?.padding ?? padding,
      animationCurve: style?.animationCurve ?? animationCurve,
      animationDuration: style?.animationDuration ?? animationDuration,
      checkedKnobDecoration:
          style?.checkedKnobDecoration ?? checkedKnobDecoration,
      uncheckedKnobDecoration:
          style?.uncheckedKnobDecoration ?? uncheckedKnobDecoration,
      checkedDecoration: style?.checkedDecoration ?? checkedDecoration,
      uncheckedDecoration: style?.uncheckedDecoration ?? uncheckedDecoration,
      foregroundColor: style?.foregroundColor ?? foregroundColor,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<EdgeInsetsGeometry?>('margin', margin))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry?>('padding', padding))
      ..add(DiagnosticsProperty<Curve?>('animationCurve', animationCurve))
      ..add(DiagnosticsProperty<Duration?>(
          'animationDuration', animationDuration))
      ..add(ObjectFlagProperty<WidgetStateProperty<Decoration?>?>.has(
        'checkedDecoration',
        checkedDecoration,
      ))
      ..add(ObjectFlagProperty<WidgetStateProperty<Decoration?>?>.has(
        'uncheckedDecoration',
        uncheckedDecoration,
      ))
      ..add(ObjectFlagProperty<WidgetStateProperty<Decoration?>?>.has(
        'checkedKnobDecoration',
        checkedKnobDecoration,
      ))
      ..add(ObjectFlagProperty<WidgetStateProperty<Decoration?>?>.has(
        'uncheckedKnobDecoration',
        uncheckedKnobDecoration,
      ))
      ..add(DiagnosticsProperty('foregroundColor', foregroundColor));
  }
}
