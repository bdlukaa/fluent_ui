import 'package:fluent_ui/fluent_ui.dart';

/// Dialog controls are modal UI overlays that provide contextual
/// app information. They block interactions with the app window
/// until being explicitly dismissed. They often request some kind
/// of action from the user.
///
/// To display a dialog, use the function `showDialog`:
///
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) {
///     return ContentDialog(
///       title: Text('Delete file permanently?'),
///       content: Text(
///         'If you delete this file, you won\'t be able to recover it. Do you want to delete it?',
///       ),
///       actions: [
///         Button(
///           child: Text('Delete'),
///           autofocus: true,
///           onPressed: () {
///             // Delete file here
///           },
///         ),
///         Button(
///           child: Text('Cancel'),
///           onPressed: () => Navigator.pop(context),
///         ),
///       ],
///     );
///   }
/// )
/// ```
///
/// ![ContentDialog example](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/dialogs/dialog_rs2_delete_file.png)
class ContentDialog extends StatelessWidget {
  /// Creates a content dialog.
  const ContentDialog({
    Key? key,
    this.title,
    this.content,
    this.actions,
    this.style,
    this.backgroundDismiss = true,
  }) : super(key: key);

  /// The title of the dialog. Usually, a [Text] widget
  final Widget? title;

  /// The content of the dialog. Usually, a [Text] widget
  final Widget? content;

  /// The actions of the dialog. Usually, a List of [Button]s
  final List<Widget>? actions;

  /// The style used by this dialog. If non-null, it's mescled with
  /// [Style.dialogStyle]
  final ContentDialogStyle? style;

  /// Whether the background is dismissible or not.
  final bool backgroundDismiss;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.dialogStyle?.copyWith(this.style);
    return Dialog(
      backgroundDismiss: backgroundDismiss,
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

  factory ContentDialogStyle.standard(Style style) {
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
          color: ButtonStyle.buttonColor(style, state),
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
