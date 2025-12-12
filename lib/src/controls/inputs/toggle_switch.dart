import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// A builder function that creates a custom knob widget for [ToggleSwitch].
///
/// The [states] parameter contains the current interaction states of the switch.
typedef ToggleSwitchKnobBuilder =
    Widget Function(BuildContext context, Set<WidgetState> states);

/// A toggle switch represents a physical switch that allows users to turn
/// things on or off, like a light switch.
///
/// Use toggle switch controls to present users with two mutually exclusive
/// options (such as on/off), where choosing an option provides immediate results.
/// Think of the toggle switch as a physical power switch for a device: you flip
/// it on or off when you want to enable or disable the action performed by the device.
///
/// ![ToggleSwitch Preview](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/toggleswitches01.png)
///
/// {@tool snippet}
/// This example shows a basic toggle switch:
///
/// ```dart
/// bool isEnabled = false;
///
/// ToggleSwitch(
///   checked: isEnabled,
///   onChanged: (value) => setState(() => isEnabled = value),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// This example shows a toggle switch with a label:
///
/// ```dart
/// ToggleSwitch(
///   checked: isDarkMode,
///   content: Text('Dark mode'),
///   onChanged: (value) => setState(() => isDarkMode = value),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// This example shows a toggle switch with the label before the switch:
///
/// ```dart
/// ToggleSwitch(
///   checked: isWifiEnabled,
///   content: Text('Wi-Fi'),
///   leadingContent: true,
///   onChanged: (value) => setState(() => isWifiEnabled = value),
/// )
/// ```
/// {@end-tool}
///
/// ## Toggle switch vs checkbox
///
/// Both toggle switches and checkboxes let users select between two states.
/// Use the following guidelines to choose between them:
///
/// Use a **toggle switch** when:
/// * The setting is a binary on/off choice
/// * The change takes effect immediately
/// * The metaphor of a physical switch makes sense
///
/// Use a **checkbox** when:
/// * Users are making a selection from a list
/// * The change requires a separate "Submit" or "Apply" action
/// * You need to support a third "indeterminate" state
///
/// See also:
///
///  * [Checkbox], which lets the user select multiple items from a collection
///  * [ToggleButton], which lets the user toggle a button on or off
///  * [RadioButton], which lets the user select one item from multiple options
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/toggles>
class ToggleSwitch extends StatefulWidget {
  /// Creates a toggle switch.
  const ToggleSwitch({
    required this.checked,
    required this.onChanged,
    super.key,
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
      ..add(
        FlagProperty(
          'leadingContent',
          value: leadingContent,
          ifFalse: 'trailingContent',
        ),
      )
      ..add(ObjectFlagProperty('onChanged', onChanged, ifNull: 'disabled'))
      ..add(
        FlagProperty('autofocus', value: autofocus, ifFalse: 'manual focus'),
      )
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
          alignment:
              _alignment ??
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
          child:
              widget.knob ??
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
                    ? [widget.content!, const SizedBox(width: 10), child]
                    : [child, const SizedBox(width: 10), widget.content!],
              ),
            ),
          );
        }
        return Semantics(
          toggled: widget.checked,
          child: FocusBorder(focused: states.isFocused, child: child),
        );
      },
    );
  }
}

/// The default knob widget used by [ToggleSwitch].
///
/// This knob animates its size based on hover and press states.
class DefaultToggleSwitchKnob extends StatelessWidget {
  /// Creates a default toggle switch knob.
  const DefaultToggleSwitchKnob({
    required this.checked,
    required this.style,
    required this.states,
    super.key,
  });

  /// Whether the toggle switch is checked.
  final bool checked;

  /// The theme data for styling the knob.
  final ToggleSwitchThemeData? style;

  /// The current interaction states.
  final Set<WidgetState> states;

  @override
  Widget build(BuildContext context) {
    const checkedFactor = 1;
    return AnimatedContainer(
      duration: style?.animationDuration ?? Duration.zero,
      curve: style?.animationCurve ?? Curves.linear,
      margin: states.isHovered
          ? const EdgeInsetsDirectional.all(1.0 + checkedFactor)
          : const EdgeInsetsDirectional.symmetric(
              horizontal: 2.0 + checkedFactor,
              vertical: 2.0 + checkedFactor,
            ),
      height: 18,
      width:
          12.0 + (states.isHovered ? 2.0 : 0.0) + (states.isPressed ? 5.0 : 0),
      decoration: checked
          ? style?.checkedKnobDecoration?.resolve(states)
          : style?.uncheckedKnobDecoration?.resolve(states),
    );
  }
}

/// An inherited widget that defines the configuration for
/// [ToggleSwitch]s in this widget's subtree.
///
/// Values specified here are used for [ToggleSwitch] properties that are not
/// given an explicit non-null value.
class ToggleSwitchTheme extends InheritedTheme {
  /// Creates a theme that controls how descendant [ToggleSwitch]es should
  /// look like.
  const ToggleSwitchTheme({
    required super.child,
    required this.data,
    super.key,
  });

  /// The theme data for the toggle switch theme.
  final ToggleSwitchThemeData data;

  /// Creates a theme that merges the nearest [ToggleSwitchTheme] with [data].
  static Widget merge({
    required ToggleSwitchThemeData data,
    required Widget child,
    Key? key,
  }) {
    return Builder(
      builder: (context) {
        return ToggleSwitchTheme(
          key: key,
          data: ToggleSwitchTheme.of(context).merge(data),
          child: child,
        );
      },
    );
  }

  /// Returns the closest [ToggleSwitchThemeData] which encloses the given
  /// context.
  ///
  /// Resolution order:
  /// 1. Defaults from [ToggleSwitchThemeData.standard]
  /// 2. Global theme from [FluentThemeData.toggleSwitchTheme]
  /// 3. Local [ToggleSwitchTheme] ancestor
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// ToggleSwitchThemeData theme = ToggleSwitchTheme.of(context);
  /// ```
  static ToggleSwitchThemeData of(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final inheritedTheme = context
        .dependOnInheritedWidgetOfExactType<ToggleSwitchTheme>();
    return ToggleSwitchThemeData.standard(
      theme,
    ).merge(theme.toggleSwitchTheme).merge(inheritedTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return ToggleSwitchTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(ToggleSwitchTheme oldWidget) =>
      data != oldWidget.data;
}

/// Theme data for [ToggleSwitch] widgets.
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

  /// Creates the standard [ToggleSwitchThemeData] based on the given [theme].
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

  /// Linearly interpolates between two [ToggleSwitchThemeData] objects.
  ///
  /// {@macro fluent_ui.lerp.t}
  static ToggleSwitchThemeData lerp(
    ToggleSwitchThemeData? a,
    ToggleSwitchThemeData? b,
    double t,
  ) {
    return ToggleSwitchThemeData(
      margin: EdgeInsetsGeometry.lerp(a?.margin, b?.margin, t),
      padding: EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t),
      animationCurve: t < 0.5 ? a?.animationCurve : b?.animationCurve,
      animationDuration: lerpDuration(
        a?.animationDuration ?? Duration.zero,
        b?.animationDuration ?? Duration.zero,
        t,
      ),
      checkedKnobDecoration: lerpWidgetStateProperty<Decoration?>(
        a?.checkedKnobDecoration,
        b?.checkedKnobDecoration,
        t,
        Decoration.lerp,
      ),
      uncheckedKnobDecoration: lerpWidgetStateProperty<Decoration?>(
        a?.uncheckedKnobDecoration,
        b?.uncheckedKnobDecoration,
        t,
        Decoration.lerp,
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
      foregroundColor: lerpWidgetStateProperty<Color?>(
        a?.foregroundColor,
        b?.foregroundColor,
        t,
        Color.lerp,
      ),
    );
  }

  /// Merges this [ToggleSwitchThemeData] with another, with the other taking
  /// precedence.
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
      ..add(
        DiagnosticsProperty<Duration?>('animationDuration', animationDuration),
      )
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
      ..add(
        ObjectFlagProperty<WidgetStateProperty<Decoration?>?>.has(
          'checkedKnobDecoration',
          checkedKnobDecoration,
        ),
      )
      ..add(
        ObjectFlagProperty<WidgetStateProperty<Decoration?>?>.has(
          'uncheckedKnobDecoration',
          uncheckedKnobDecoration,
        ),
      )
      ..add(DiagnosticsProperty('foregroundColor', foregroundColor));
  }
}
