import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

class ToggleSwitch extends StatelessWidget {
  const ToggleSwitch({
    Key? key,
    required this.checked,
    required this.onChanged,
    this.style,
    this.semanticsLabel,
    this.thumb,
    this.focusNode,
  }) : super(key: key);

  final bool checked;
  final ValueChanged<bool>? onChanged;

  final Widget? thumb;

  final ToggleSwitchStyle? style;

  final String? semanticsLabel;
  final FocusNode? focusNode;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('checked', value: checked));
    properties.add(ObjectFlagProperty('onChanged', onChanged));
    properties.add(DiagnosticsProperty<ToggleSwitchStyle>('style', style));
    properties.add(StringProperty('semanticsLabel', semanticsLabel));
    properties.add(DiagnosticsProperty<FocusNode>('focusNode', focusNode));
  }

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.toggleSwitchStyle!.copyWith(this.style);
    return HoverButton(
      semanticsLabel: semanticsLabel,
      margin: style.margin,
      focusNode: focusNode,
      cursor: style.cursor,
      onPressed: onChanged == null ? null : () => onChanged!(!checked),
      builder: (context, state) {
        final Widget child = AnimatedContainer(
          alignment: checked ? Alignment.centerRight : Alignment.centerLeft,
          height: 20,
          width: 45,
          duration: style.animationDuration!,
          curve: style.animationCurve!,
          padding: style.padding,
          decoration: checked
              ? style.checkedDecoration!(state)
              : style.uncheckedDecoration!(state),
          child: thumb ??
              DefaultToggleSwitchThumb(
                checked: checked,
                style: style,
                state: state,
              ),
        );
        return Semantics(
          child: child,
          checked: checked,
        );
      },
    );
  }
}

class DefaultToggleSwitchThumb extends StatelessWidget {
  const DefaultToggleSwitchThumb({
    Key? key,
    required this.checked,
    required this.style,
    required this.state,
  }) : super(key: key);

  final bool checked;
  final ToggleSwitchStyle style;
  final ButtonStates state;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: style.animationDuration ?? Duration.zero,
      curve: style.animationCurve!,
      constraints: BoxConstraints(
        minHeight: 8,
        minWidth: 8,
        maxHeight: 12,
        maxWidth: 12,
      ),
      decoration: checked
          ? style.checkedThumbDecoration!(state)
          : style.uncheckedThumbDecoration!(state),
    );
  }
}

@immutable
class ToggleSwitchStyle with Diagnosticable {
  final ButtonState<Decoration>? checkedThumbDecoration;
  final ButtonState<Decoration>? uncheckedThumbDecoration;

  final ButtonState<MouseCursor>? cursor;

  final ButtonState<Decoration>? checkedDecoration;
  final ButtonState<Decoration>? uncheckedDecoration;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  final Duration? animationDuration;
  final Curve? animationCurve;

  const ToggleSwitchStyle({
    this.cursor,
    this.padding,
    this.margin,
    this.animationDuration,
    this.animationCurve,
    this.checkedThumbDecoration,
    this.uncheckedThumbDecoration,
    this.checkedDecoration,
    this.uncheckedDecoration,
  });

  static ToggleSwitchStyle defaultTheme(Style style) {
    final defaultThumbDecoration = BoxDecoration(shape: BoxShape.circle);

    final defaultDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(30),
    );

    return ToggleSwitchStyle(
      cursor: buttonCursor,
      checkedDecoration: (state) => defaultDecoration.copyWith(
        color: checkedInputColor(style, state),
        border: Border.all(style: BorderStyle.none),
      ),
      uncheckedDecoration: (state) {
        return defaultDecoration.copyWith(
          color: uncheckedInputColor(style, state),
          border: Border.all(
            width: 0.8,
            color: state.isNone
                ? style.inactiveColor!
                : uncheckedInputColor(style, state),
          ),
        );
      },
      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      margin: EdgeInsets.all(4),
      animationDuration: style.mediumAnimationDuration,
      animationCurve: style.animationCurve,
      checkedThumbDecoration: (_) => defaultThumbDecoration.copyWith(color: () {
        if (style.brightness == Brightness.light)
          return style.activeColor;
        else
          return style.inactiveColor;
      }()),
      uncheckedThumbDecoration: (_) =>
          defaultThumbDecoration.copyWith(color: style.inactiveColor),
    );
  }

  ToggleSwitchStyle copyWith(ToggleSwitchStyle? style) {
    return ToggleSwitchStyle(
      margin: style?.margin ?? margin,
      padding: style?.padding ?? padding,
      cursor: style?.cursor ?? cursor,
      animationCurve: style?.animationCurve ?? animationCurve,
      animationDuration: style?.animationDuration ?? animationDuration,
      checkedThumbDecoration:
          style?.checkedThumbDecoration ?? checkedThumbDecoration,
      uncheckedThumbDecoration:
          style?.uncheckedThumbDecoration ?? uncheckedThumbDecoration,
      checkedDecoration: style?.checkedDecoration ?? checkedDecoration,
      uncheckedDecoration: style?.uncheckedDecoration ?? uncheckedDecoration,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry?>('margin', margin));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry?>('padding', padding));
    properties.add(ObjectFlagProperty<ButtonState<MouseCursor>?>('cursor', cursor));
    properties.add(DiagnosticsProperty<Curve?>('animationCurve', animationCurve));
    properties.add(DiagnosticsProperty<Duration?>('animationDuration', animationDuration));
    properties.add(ObjectFlagProperty<ButtonState<Decoration>?>('checkedDecoration', checkedDecoration));
    properties.add(ObjectFlagProperty<ButtonState<Decoration>?>('uncheckedDecoration', uncheckedDecoration));
    properties.add(ObjectFlagProperty<ButtonState<Decoration>?>('checkedThumbDecoration', checkedThumbDecoration));
    properties.add(ObjectFlagProperty<ButtonState<Decoration>?>('uncheckedThumbDecoration', uncheckedThumbDecoration));
  }
}
