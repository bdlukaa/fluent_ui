import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluent_ui/src/utils/toast/toast.dart';

Future<void> showSnackbar({
  @required BuildContext context,
  @required Widget snackbar,
  Alignment alignment,
  Duration showDuration,
  Duration animationDuration,
  ToastAnimationBuilder animationBuilder,
  VoidCallback onDismiss,
}) {
  debugCheckHasFluentTheme(context);
  final style = context.theme.snackbarStyle;
  return showToast(
    context: context,
    child: snackbar,
    alignment: alignment ?? style?.alignment,
    interactive: true,
    animationDuration: animationDuration ?? style?.animationDuration,
    duration: showDuration ?? style?.showDuration,
    animationBuilder: animationBuilder ?? style?.animationBuilder,
    onDismiss: onDismiss,
    margin: EdgeInsets.zero,
    padding: EdgeInsets.zero,
  );
}

enum _SnackbarType { normal, multiLine }

class Snackbar extends StatelessWidget {
  const Snackbar({
    Key key,
    @required this.title,
    this.button,
    this.style,
  })  : _type = _SnackbarType.normal,
        super(key: key);

  final Widget title;
  final Widget button;

  final SnackbarStyle style;

  final _SnackbarType _type;

  const Snackbar.multiLine({@required this.title, this.button, this.style})
      : _type = _SnackbarType.multiLine;

  Future<void> show({
    @required BuildContext context,
    Alignment alignment,
    Duration showDuration,
    Duration animationDuration,
    ToastAnimationBuilder animationBuilder,
    VoidCallback onDismiss,
  }) =>
      showSnackbar(
        context: context,
        snackbar: this,
        alignment: alignment,
        animationDuration: animationDuration,
        showDuration: showDuration,
        animationBuilder: animationBuilder,
        onDismiss: onDismiss,
      );

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.snackbarStyle.copyWith(this.style);
    return Padding(
      padding: style.margin,
      child: Container(
        padding: style.padding,
        decoration: BoxDecoration(
          borderRadius: style.borderRadius,
          boxShadow: elevationShadow(
            factor: style.elevation,
            color: style.elevationColor,
          ),
          color: style.color,
        ),
        child: _type == _SnackbarType.normal
            ? Row(
                children: [
                  if (title != null)
                    Expanded(
                      child: DefaultTextStyle(
                        child: title,
                        style: style.textStyle,
                      ),
                    ),
                  if (button != null) button,
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (title != null)
                    Row(
                      children: [
                        Expanded(
                          child: DefaultTextStyle(
                            child: title,
                            style: style.textStyle,
                          ),
                        ),
                      ],
                    ),
                  if (button != null) button,
                ],
              ),
      ),
    );
  }

}

class SnackbarStyle {
  final Color color;

  final BorderRadiusGeometry borderRadius;

  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  final double elevation;
  final Color elevationColor;

  final TextStyle textStyle;

  final Duration animationDuration;
  final ToastAnimationBuilder animationBuilder;

  final Duration showDuration;

  final bool dismissible;
  final Alignment alignment;

  SnackbarStyle({
    this.color,
    this.borderRadius,
    this.elevationColor,
    this.elevation,
    this.textStyle,
    this.margin,
    this.padding,
    this.showDuration,
    this.animationDuration,
    this.animationBuilder,
    this.dismissible,
    this.alignment,
  });

  static SnackbarStyle defaultTheme([Brightness brightness]) {
    final def = SnackbarStyle(
      borderRadius: BorderRadius.circular(4),
      margin: EdgeInsets.all(15),
      padding: EdgeInsets.all(12),
      showDuration: Duration(seconds: 3),
      animationBuilder: (_, animation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
          alwaysIncludeSemantics: false,
        );
      },
      animationDuration: Duration(milliseconds: 150),
      elevation: 0,
      textStyle: TextStyle(color: Colors.white),
      dismissible: true,
      alignment: Alignment.bottomCenter,
    );
    if (brightness == null || brightness == Brightness.light)
      return def.copyWith(SnackbarStyle(
        color: Colors.black,
        elevationColor: lightElevationColor,
      ));
    else
      return def.copyWith(SnackbarStyle(
        color: Colors.grey[180],
        elevationColor: darkElevationColor,
      ));
  }

  SnackbarStyle copyWith(SnackbarStyle style) {
    if (style == null) return this;
    return SnackbarStyle(
      color: style?.color ?? color,
      borderRadius: style?.borderRadius ?? borderRadius,
      elevation: style?.elevation ?? elevation,
      elevationColor: style?.elevationColor ?? elevationColor,
      textStyle: style?.textStyle ?? textStyle,
      animationBuilder: style?.animationBuilder ?? animationBuilder,
      animationDuration: style?.animationDuration ?? animationDuration,
      margin: style?.margin ?? margin,
      padding: style?.padding ?? padding,
      showDuration: style?.showDuration ?? showDuration,
      alignment: style?.alignment ?? alignment,
      dismissible: style?.dismissible ?? dismissible,
    );
  }
}
