import 'package:fluent_ui/fluent_ui.dart';

class ContentDialog extends StatelessWidget {
  const ContentDialog({
    Key? key,
    this.title,
    this.content,
    this.actions,
    this.style,
    this.backgroundDismiss,
  }) : super(key: key);

  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;

  final ContentDialogStyle? style;

  final bool? backgroundDismiss;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.dialogStyle?.copyWith(this.style);
    return Dialog(
      backgroundDismiss: backgroundDismiss ?? true,
      barrierColor: style?.barrierColor,
      child: PhysicalModel(
        color: style?.elevationColor ?? Colors.black,
        elevation: style?.elevation ?? 0,
        child: Container(
          constraints: BoxConstraints(maxWidth: 408),
          decoration: style?.decoration,
          padding: style?.padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Padding(
                  padding: style?.titlePadding ?? EdgeInsets.zero,
                  child: DefaultTextStyle(
                    style: style?.titleStyle ?? TextStyle(),
                    child: title!,
                  ),
                ),
              if (content != null)
                Padding(
                  padding: style?.bodyPadding ?? EdgeInsets.zero,
                  child: DefaultTextStyle(
                    style: style?.bodyStyle ?? TextStyle(),
                    child: content!,
                  ),
                ),
              if (actions != null)
                Theme(
                  data: context.theme.copyWith(Style(
                    buttonStyle: style?.actionStyle,
                  )),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: () {
                      if (actions!.length >= 2)
                        return actions!.map((e) {
                          final index = actions!.indexOf(e);
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: index != (actions!.length - 1)
                                    ? style?.actionsSpacing ?? 3
                                    : 0,
                              ),
                              child: e,
                            ),
                          );
                        }).toList();
                      return [
                        Spacer(),
                        Expanded(child: actions!.first),
                      ];
                    }(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<T?> showDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  RouteTransitionsBuilder? transitionBuilder,
  Duration? transitionDuration,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: false,
    pageBuilder: (context, primary, secondary) {
      return builder(context);
    },
    useRootNavigator: useRootNavigator,
    transitionBuilder: transitionBuilder,
    routeSettings: routeSettings,
    transitionDuration: transitionDuration ??
        context.maybeTheme?.mediumAnimationDuration ??
        Duration(milliseconds: 300),
  );
}

class Dialog extends StatelessWidget {
  const Dialog({
    Key? key,
    required this.child,
    this.backgroundDismiss = false,
    this.barrierColor,
    this.barrierLabel,
  }) : super(key: key);

  final bool backgroundDismiss;
  final Color? barrierColor;

  final Widget child;
  final String? barrierLabel;

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Positioned.fill(
        child: Semantics(
          label: barrierLabel,
          focusable: false,
          child: GestureDetector(
            onTap: () {
              if (backgroundDismiss) Navigator.pop(context);
            },
            child: Container(
              color: barrierColor ?? Colors.black.withOpacity(0.8),
            ),
          ),
        ),
      ),
      child,
    ]);
  }
}

class ContentDialogStyle {
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? bodyPadding;
  final double? actionsSpacing;

  final Decoration? decoration;
  final Color? barrierColor;

  final TextStyle? titleStyle;
  final TextStyle? bodyStyle;
  final ButtonStyle? actionStyle;

  final double? elevation;
  final Color? elevationColor;

  const ContentDialogStyle({
    this.decoration,
    this.barrierColor,
    this.titlePadding,
    this.bodyPadding,
    this.padding,
    this.actionsSpacing,
    this.titleStyle,
    this.bodyStyle,
    this.actionStyle,
    this.elevation,
    this.elevationColor,
  });

  static ContentDialogStyle defaultTheme(Style style) {
    return ContentDialogStyle(
      decoration: BoxDecoration(
        color: style.scaffoldBackgroundColor,
        border: Border.all(
          color: style.disabledColor!,
          width: 1.2,
        ),
      ),
      padding: EdgeInsets.all(20),
      titlePadding: EdgeInsets.only(bottom: 12),
      bodyPadding: EdgeInsets.only(bottom: 30),
      actionsSpacing: 3,
      barrierColor: Colors.grey[200]!.withOpacity(0.8),
      titleStyle: style.typography?.title,
      bodyStyle: style.typography?.body,
      actionStyle: ButtonStyle(
        margin: EdgeInsets.zero,
        decoration: (state) => BoxDecoration(
          color: buttonColor(style, state),
          border: state.isFocused ? focusedButtonBorder(style) : null,
        ),
      ),
      elevation: 8,
      elevationColor: Colors.black,
    );
  }

  ContentDialogStyle copyWith(ContentDialogStyle? style) {
    if (style == null) return this;
    return ContentDialogStyle(
      decoration: style.decoration ?? decoration,
      padding: style.padding ?? padding,
      bodyPadding: style.bodyPadding ?? bodyPadding,
      barrierColor: style.barrierColor ?? barrierColor,
      titleStyle: style.titleStyle ?? titleStyle,
      bodyStyle: style.bodyStyle ?? bodyStyle,
      titlePadding: style.titlePadding ?? titlePadding,
      actionsSpacing: style.actionsSpacing ?? actionsSpacing,
      actionStyle: style.actionStyle ?? actionStyle,
    );
  }
}
