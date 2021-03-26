import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:fluent_ui/fluent_ui.dart';

class Checkbox extends StatelessWidget {
  const Checkbox({
    Key? key,
    required this.checked,
    required this.onChanged,
    this.style,
    this.semanticsLabel,
    this.focusNode,
  }) : super(key: key);

  final bool? checked;
  final ValueChanged<bool?>? onChanged;

  final CheckboxStyle? style;

  final String? semanticsLabel;
  final FocusNode? focusNode;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('checked', value: checked));
    properties
        .add(ObjectFlagProperty('onChanged', onChanged, ifNull: 'disabled'));
    properties.add(DiagnosticsProperty<CheckboxStyle>('style', style));
    properties.add(StringProperty('semanticsLabel', semanticsLabel));
    properties.add(DiagnosticsProperty<FocusNode>('focusNode', focusNode));
  }

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.checkboxStyle!.copyWith(this.style);
    final double size = 22;
    return HoverButton(
      semanticsLabel: semanticsLabel,
      margin: style.margin,
      focusNode: focusNode,
      cursor: style.cursor,
      onPressed: onChanged == null
          ? null
          : () => onChanged!(checked == null ? null : !(checked!)),
      builder: (context, state) {
        Widget child = AnimatedContainer(
          alignment: Alignment.center,
          duration: style.animationDuration!,
          curve: style.animationCurve!,
          padding: style.padding,
          height: size,
          width: size,
          decoration: () {
            if (checked == null)
              return style.thirdstateDecoration!(state);
            else if (checked!)
              return style.checkedDecoration!(state);
            else
              return style.uncheckedDecoration!(state);
          }(),
          child: Icon(
            style.icon,
            size: 18,
            color: () {
              if (checked == null)
                return style.thirdstateIconColor!(state);
              else if (checked!)
                return style.checkedIconColor!(state);
              else
                return style.uncheckedIconColor!(state);
            }(),
          ),
        );
        return Semantics(
          checked: checked,
          child: child,
        );
      },
    );
  }
}

@immutable
class CheckboxStyle with Diagnosticable {
  final ButtonState<Decoration>? checkedDecoration;
  final ButtonState<Decoration>? uncheckedDecoration;
  final ButtonState<Decoration>? thirdstateDecoration;

  final IconData? icon;
  final ButtonState<Color?>? checkedIconColor;
  final ButtonState<Color>? uncheckedIconColor;
  final ButtonState<Color>? thirdstateIconColor;

  final ButtonState<MouseCursor>? cursor;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  final Duration? animationDuration;
  final Curve? animationCurve;

  const CheckboxStyle({
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
    this.animationDuration,
    this.animationCurve,
  });

  static CheckboxStyle defaultTheme(Style style, [Brightness? brightness]) {
    final radius = BorderRadius.circular(3);
    return CheckboxStyle(
      cursor: buttonCursor,
      checkedDecoration: (state) => BoxDecoration(
        borderRadius: radius,
        color: checkedInputColor(style, state),
      ),
      uncheckedDecoration: (state) => BoxDecoration(
        border: Border.all(
          width: 0.6,
          color: state.isDisabled ? style.disabledColor! : style.inactiveColor!,
        ),
        color: checkedInputColor(style, state).withOpacity(0),
        borderRadius: radius,
      ),
      thirdstateDecoration: (state) => BoxDecoration(
        borderRadius: radius,
        color: Colors.white,
        border: Border.all(width: 6.5, color: checkedInputColor(style, state)),
      ),
      checkedIconColor: (_) => style.activeColor,
      uncheckedIconColor: (state) {
        if (state.isHovering || state.isPressing)
          return style.inactiveColor!.withOpacity(0.8);
        return Colors.transparent;
      },
      thirdstateIconColor: (_) => Colors.transparent,
      margin: EdgeInsets.all(4),
      icon: Icons.checkmark,
      animationDuration: style.mediumAnimationDuration,
      animationCurve: style.animationCurve,
    );
  }

  CheckboxStyle copyWith(CheckboxStyle? style) {
    return CheckboxStyle(
      margin: style?.margin ?? margin,
      padding: style?.padding ?? padding,
      cursor: style?.cursor ?? cursor,
      icon: style?.icon ?? icon,
      checkedIconColor: style?.checkedIconColor ?? checkedIconColor,
      uncheckedIconColor: style?.uncheckedIconColor ?? uncheckedIconColor,
      thirdstateIconColor: style?.thirdstateIconColor ?? thirdstateIconColor,
      animationCurve: style?.animationCurve ?? animationCurve,
      animationDuration: style?.animationDuration ?? animationDuration,
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
    properties.add(
      DiagnosticsProperty<Duration?>('animationDuration', animationDuration),
    );
    properties.add(
      DiagnosticsProperty<Curve?>('animationCurve', animationCurve),
    );
  }
}
