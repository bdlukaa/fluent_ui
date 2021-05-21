import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

typedef IconThemeButtonStateBuilder = IconThemeData Function(Set<ButtonStates>);

class IconButton extends StatelessWidget {
  const IconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.onLongPress,
    this.style,
    this.iconTheme,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  }) : super(key: key);

  /// The icon of the button
  final Widget icon;

  /// Callback called when the button is pressed.
  /// The button is considered disabled if this is `null`
  final VoidCallback? onPressed;

  /// Callback called when the button is long pressed
  final VoidCallback? onLongPress;

  /// The style of the button.
  final ButtonThemeData? style;

  /// The style applied to the icon.
  final IconThemeButtonStateBuilder? iconTheme;

  /// The semantics label of the button
  final String? semanticLabel;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// Whether the button is enabled or not
  bool get enabled => onPressed != null || onLongPress != null;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<VoidCallback>(
      'onPressed',
      onPressed,
      ifNull: enabled ? 'no on pressed' : 'disabled',
    ));
    properties.add(
      ObjectFlagProperty<VoidCallback>.has('onLongPress', onLongPress),
    );
    properties.add(DiagnosticsProperty<ButtonThemeData>('style', style));
    properties.add(StringProperty('semanticLabel', semanticLabel));
    properties.add(ObjectFlagProperty<FocusNode>.has('focusNode', focusNode));
    properties.add(
        FlagProperty('autofocus', value: autofocus, ifFalse: 'manual focus'));
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return Button(
      autofocus: autofocus,
      focusNode: focusNode,
      builder: (context, states) => IconTheme(
        data: IconTheme.of(context).merge(iconTheme?.call(states)),
        child: icon,
      ),
      onPressed: onPressed,
      onLongPress: onLongPress,
      semanticLabel: semanticLabel,
      style: ButtonThemeData(
        decoration: ButtonState.resolveWith((states) {
          return BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: states.isDisabled
                ? ButtonThemeData.buttonColor(FluentTheme.of(context), states)
                : ButtonThemeData.uncheckedInputColor(
                    FluentTheme.of(context),
                    states,
                  ),
          );
        }),
        padding: const EdgeInsets.all(4),
      ).copyWith(style),
    );
  }
}
