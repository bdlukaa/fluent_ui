import 'dart:ui' show lerpDouble;

import 'package:fluent_ui/fluent_ui.dart';

import 'package:flutter/foundation.dart';

const double _kChipSpacing = 6.0;

enum _ChipType {
  normal,
  selected,
}

/// Chips are compact representations of entities (most commonly, people)
/// that can be clicked, deleted, or dragged easily.
///
/// See also:
///
///   * [Button], a widget similar to [Chip], but adapted to larger screens
@Deprecated(
  'Chip is deprecated, use Button instead. This was deprecated in 4.7.0',
)
class Chip extends StatelessWidget {
  /// Creates a normal chip.
  const Chip({
    super.key,
    this.image,
    this.text,
    this.onPressed,
    this.semanticLabel,
  }) : _type = _ChipType.normal;

  /// Creates a selected chip
  const Chip.selected({
    super.key,
    this.image,
    this.text,
    this.onPressed,
    this.semanticLabel,
  }) : _type = _ChipType.selected;

  /// The chip image. It's rendered before [text]
  ///
  /// If disabled, a opacity of 0.6 is applied
  ///
  /// It's usually a:
  ///
  ///   * [Icon]
  ///   * [CircleAvatar]
  ///   * [Image]
  final Widget? image;

  /// The text of the chip. It's rendered after [image]
  ///
  /// Typically a [Text]
  final Widget? text;

  /// Called when the chip is pressed. If null, the chip will be considered disabled
  final VoidCallback? onPressed;

  /// {@macro fluent_ui.controls.inputs.HoverButton.semanticLabel}
  final String? semanticLabel;

  final _ChipType _type;

  bool get isEnabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = ChipTheme.of(context);
    final visualDensity = FluentTheme.of(context).visualDensity;
    final spacing = theme.spacing ?? _kChipSpacing;
    return HoverButton(
      semanticLabel: semanticLabel,
      onPressed: onPressed,
      builder: (context, states) {
        final textStyle = _type == _ChipType.normal
            ? theme.textStyle
            : theme.selectedTextStyle;
        final decoration = _type == _ChipType.normal
            ? theme.decoration
            : theme.selectedDecoration;
        return AnimatedContainer(
          duration: FluentTheme.of(context).fastAnimationDuration,
          curve: FluentTheme.of(context).animationCurve,
          constraints: const BoxConstraints(
            minHeight: 24.0,
            maxHeight: 32.0,
            minWidth: 24,
          ),
          decoration: decoration?.resolve(states),
          padding: EdgeInsetsDirectional.only(
            start: spacing + visualDensity.horizontal,
            top: spacing,
            bottom: spacing,
          ),
          child: AnimatedDefaultTextStyle(
            duration: FluentTheme.of(context).fastAnimationDuration,
            curve: FluentTheme.of(context).animationCurve,
            style: textStyle?.resolve(states) ?? const TextStyle(),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (image != null)
                AnimatedOpacity(
                  duration: FluentTheme.of(context).fastAnimationDuration,
                  curve: FluentTheme.of(context).animationCurve,
                  opacity: isEnabled || _type == _ChipType.selected ? 1.0 : 0.6,
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      end: spacing + visualDensity.horizontal,
                    ),
                    child: image,
                  ),
                ),
              if (text != null)
                Flexible(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      end: spacing + visualDensity.horizontal,
                    ),
                    child: text,
                  ),
                ),
            ]),
          ),
        );
      },
    );
  }
}

/// An inherited widget that defines the configuration for
/// Chips in this widget's subtree.
///
/// Values specified here are used for Chip properties that are not
/// given an explicit non-null value.
class ChipTheme extends InheritedTheme {
  /// Creates a button theme that controls the configurations for
  /// Chip.
  const ChipTheme({
    super.key,
    required super.child,
    required this.data,
  });

  /// The properties for descendant Chip widgets.
  final ChipThemeData data;

  /// Creates a button theme that controls how descendant Chips should
  /// look like, and merges in the current button theme, if any.
  static Widget merge({
    Key? key,
    required ChipThemeData data,
    required Widget child,
  }) {
    return Builder(builder: (BuildContext context) {
      return ChipTheme(
        key: key,
        data: _getInheritedChipThemeData(context).merge(data),
        child: child,
      );
    });
  }

  /// The data from the closest instance of this class that encloses the given
  /// context.
  ///
  /// Defaults to [FluentThemeData.chipTheme]
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// ChipThemeData theme = ChipTheme.of(context);
  /// ```
  static ChipThemeData of(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return ChipThemeData.standard(FluentTheme.of(context)).merge(
      _getInheritedChipThemeData(context),
    );
  }

  static ChipThemeData _getInheritedChipThemeData(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<ChipTheme>();
    return theme?.data ?? FluentTheme.of(context).chipTheme;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return ChipTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(ChipTheme oldWidget) {
    return oldWidget.data != data;
  }
}

@immutable
class ChipThemeData with Diagnosticable {
  final ButtonState<Decoration?>? decoration;
  final ButtonState<TextStyle?>? textStyle;

  final ButtonState<Decoration?>? selectedDecoration;
  final ButtonState<TextStyle?>? selectedTextStyle;

  final double? spacing;

  final ButtonState<MouseCursor>? cursor;

  const ChipThemeData({
    this.decoration,
    this.spacing,
    this.selectedDecoration,
    this.selectedTextStyle,
    this.cursor,
    this.textStyle,
  });

  factory ChipThemeData.standard(FluentThemeData theme) {
    Color normalColor(Set<ButtonStates> states) => theme.brightness.isLight
        ? states.isPressing
            ? const Color(0xFFc1c1c1)
            : states.isFocused || states.isHovering
                ? const Color(0xFFe1e1e1)
                : const Color(0xFFf1f1f1)
        : states.isPressing
            ? const Color(0xFF292929)
            : states.isFocused || states.isHovering
                ? const Color(0xFF383838)
                : const Color(0xFF212121);
    return ChipThemeData(
      spacing: _kChipSpacing,
      decoration: ButtonState.resolveWith((states) {
        return BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: normalColor(states),
        );
      }),
      textStyle: ButtonState.resolveWith((states) {
        return TextStyle(
          color: states.isDisabled
              ? theme.resources.textFillColorDisabled
              : normalColor(states).basedOnLuminance(),
        );
      }),
      selectedDecoration: ButtonState.resolveWith((states) {
        return BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: ButtonThemeData.checkedInputColor(theme, states),
        );
      }),
      selectedTextStyle: ButtonState.resolveWith((states) {
        return TextStyle(color: FilledButton.foregroundColor(theme, states));
      }),
    );
  }

  static ChipThemeData lerp(
    ChipThemeData? a,
    ChipThemeData? b,
    double t,
  ) {
    return ChipThemeData(
      decoration:
          ButtonState.lerp(a?.decoration, b?.decoration, t, Decoration.lerp),
      selectedDecoration: ButtonState.lerp(
          a?.selectedDecoration, b?.selectedDecoration, t, Decoration.lerp),
      cursor: t < 0.5 ? a?.cursor : b?.cursor,
      textStyle:
          ButtonState.lerp(a?.textStyle, b?.textStyle, t, TextStyle.lerp),
      selectedTextStyle: ButtonState.lerp(
          a?.selectedTextStyle, b?.selectedTextStyle, t, TextStyle.lerp),
      spacing: lerpDouble(a?.spacing, b?.spacing, t),
    );
  }

  ChipThemeData merge(ChipThemeData? style) {
    if (style == null) return this;
    return ChipThemeData(
      decoration: style.decoration ?? decoration,
      selectedDecoration: style.selectedDecoration ?? selectedDecoration,
      selectedTextStyle: style.selectedTextStyle ?? selectedTextStyle,
      cursor: style.cursor ?? cursor,
      textStyle: style.textStyle ?? textStyle,
      spacing: style.spacing ?? spacing,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ButtonState<Decoration?>?>(
          'decoration', decoration))
      ..add(DiagnosticsProperty<ButtonState<Decoration?>?>(
          'selectedDecoration', selectedDecoration))
      ..add(DoubleProperty('spacing', spacing, defaultValue: _kChipSpacing))
      ..add(DiagnosticsProperty<ButtonState<MouseCursor>?>('cursor', cursor))
      ..add(
          DiagnosticsProperty<ButtonState<TextStyle?>?>('textStyle', textStyle))
      ..add(DiagnosticsProperty<ButtonState<TextStyle?>?>(
          'selectedTextStyle', selectedTextStyle));
  }
}
