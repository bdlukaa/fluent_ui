import 'package:fluent_ui/fluent_ui.dart';

Future<void> showDialog({
  @required BuildContext context,
  @required Widget Function(BuildContext) builder,
}) {
  assert(context != null);
  assert(builder != null);
  return showGeneralDialog(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: false,
    pageBuilder: (context, _, a) => builder(context),
  );
}

class Dialog extends StatelessWidget {
  const Dialog({
    Key key,
    this.title,
    this.body,
    this.footer,
    this.backgroundDismiss = true,
    this.style,
  })  : assert(backgroundDismiss != null),
        super(key: key);

  final bool backgroundDismiss;

  final Widget title;
  final Widget body;
  final List<Widget> footer;

  final DialogStyle style;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.dialogStyle.copyWith(this.style);
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              if (backgroundDismiss) Navigator.pop(context);
            },
            child: Container(color: style.barrierColor),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  DefaultTextStyle(
                    style: style.titleStyle,
                    child: title,
                  ),
                if (body != null)
                  Container(
                    padding: style.bodyPadding,
                    child: DefaultTextStyle(
                      style: style.bodyStyle,
                      child: body,
                    ),
                  ),
                if (footer != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(children: footer),
                  ),
              ],
            ),
            style: CardStyle(
              borderRadius: style.borderRadius,
              color: style.color,
              elevation: 0,
              elevationColor: Colors.transparent,
              highlightColor: style.highlightColor,
              highlightPosition: style.highlightPosition,
              highlightSize: style.highlightSize,
              margin: style.margin,
              padding: style.padding,
            ),
          ),
        ),
      ],
    );
  }
}

class DialogStyle {
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry bodyPadding;
  final EdgeInsetsGeometry margin;

  final Color barrierColor;
  final Color color;

  final Color highlightColor;
  final HighlightPosition highlightPosition;
  final double highlightSize;

  final TextStyle titleStyle;
  final TextStyle bodyStyle;

  DialogStyle({
    this.barrierColor,
    this.borderRadius,
    this.bodyPadding,
    this.padding,
    this.margin,
    this.color,
    this.highlightColor,
    this.highlightPosition,
    this.highlightSize,
    this.titleStyle,
    this.bodyStyle,
  });

  static DialogStyle defaultTheme([Brightness brightness]) {
    final def = DialogStyle(
      borderRadius: BorderRadius.circular(2),
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      padding: EdgeInsets.all(12),
      bodyPadding: EdgeInsets.symmetric(vertical: 12),
      highlightPosition: HighlightPosition.top,
      highlightColor: Colors.blue,
      highlightSize: 2.5,
      barrierColor: Colors.grey[200].withOpacity(0.8),
    );
    if (brightness == null || brightness == Brightness.light)
      return def.copyWith(DialogStyle(
        color: Colors.white,
        titleStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.blue,
        ),
        bodyStyle: TextStyle(color: Colors.grey[100]),
      ));
    else
      return def.copyWith(DialogStyle(
        color: Colors.grey,
        titleStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
        bodyStyle: TextStyle(color: Colors.grey[80]),
      ));
  }

  DialogStyle copyWith(DialogStyle style) {
    if (style == null) return this;
    return DialogStyle(
      borderRadius: style?.borderRadius ?? borderRadius,
      padding: style?.padding ?? padding,
      bodyPadding: style?.bodyPadding ?? bodyPadding,
      margin: style?.margin ?? margin,
      color: style?.color ?? color,
      highlightColor: style?.highlightColor ?? highlightColor,
      highlightPosition: style?.highlightPosition ?? highlightPosition,
      highlightSize: style?.highlightSize ?? highlightSize,
      barrierColor: style?.barrierColor ?? barrierColor,
      titleStyle: style?.titleStyle ?? titleStyle,
      bodyStyle: style?.bodyStyle ?? bodyStyle,
    );
  }
}
