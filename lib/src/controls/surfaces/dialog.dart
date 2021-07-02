import 'dart:ui' show lerpDouble;

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
  /// [ThemeData.dialogThemeData]
  final ContentDialogThemeData? style;

  /// Whether the background is dismissible or not.
  final bool backgroundDismiss;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final style =
        ContentDialogThemeData.standard(FluentTheme.of(context)).merge(
      FluentTheme.of(context).dialogTheme.merge(this.style),
    );
    return Container(
      constraints: BoxConstraints(maxWidth: 368),
      decoration: style.decoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: style.padding ?? EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Padding(
                    padding: style.titlePadding ?? EdgeInsets.zero,
                    child: DefaultTextStyle(
                      style: style.titleStyle ?? TextStyle(),
                      child: title!,
                    ),
                  ),
                if (content != null)
                  Padding(
                    padding: style.bodyPadding ?? EdgeInsets.zero,
                    child: DefaultTextStyle(
                      style: style.bodyStyle ?? TextStyle(),
                      child: content!,
                    ),
                  ),
              ],
            ),
          ),
          if (actions != null)
            Container(
              decoration: style.actionsDecoration,
              padding: style.actionsPadding,
              child: ButtonTheme.merge(
                data: style.actionThemeData ?? ButtonThemeData(),
                child: () {
                  if (actions!.length == 1) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: actions!.first,
                    );
                  }
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!.map((e) {
                      final index = actions!.indexOf(e);
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: index != (actions!.length - 1)
                                ? style.actionsSpacing ?? 3
                                : 0,
                          ),
                          child: e,
                        ),
                      );
                    }).toList(),
                  );
                }(),
              ),
            ),
        ],
      ),
    );
  }
}

Future<T?> showDialog<T extends Object?>({
  required BuildContext context,
  required WidgetBuilder builder,
  RouteTransitionsBuilder transitionBuilder =
      FluentDialogRoute._defaultTransitionBuilder,
  Duration? transitionDuration,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  String? barrierLabel,
  Color? barrierColor,
  bool barrierDismissible = false,
}) {
  barrierColor ??= Colors.black.withOpacity(0.54);
  return Navigator.of(
    context,
    rootNavigator: useRootNavigator,
  ).push<T>(FluentDialogRoute<T>(
    context: context,
    builder: builder,
    barrierColor: barrierColor,
    barrierDismissible: barrierDismissible,
    barrierLabel: FluentLocalizations.of(context).modalBarrierDismissLabel,
    settings: routeSettings,
    transitionBuilder: transitionBuilder,
    transitionDuration: transitionDuration ??
        FluentTheme.maybeOf(context)?.fastAnimationDuration ??
        Duration(milliseconds: 300),
  ));
}

class FluentDialogRoute<T> extends RawDialogRoute<T> {
  FluentDialogRoute({
    required WidgetBuilder builder,
    required BuildContext context,
    bool barrierDismissible = false,
    Color? barrierColor,
    String? barrierLabel,
    Duration transitionDuration = const Duration(milliseconds: 250),
    RouteTransitionsBuilder? transitionBuilder = _defaultTransitionBuilder,
    RouteSettings? settings,
  }) : super(
          pageBuilder: (BuildContext context, animation, secondaryAnimation) {
            return SafeArea(
              child: Center(child: builder(context)),
            );
          },
          barrierDismissible: barrierDismissible,
          barrierLabel: barrierLabel ?? 'Dismiss',
          barrierColor: barrierColor ?? Colors.black.withOpacity(0.54),
          transitionDuration: transitionDuration,
          transitionBuilder: transitionBuilder,
          settings: settings,
        );

  static Widget _defaultTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: Tween<double>(
            begin: 1,
            end: 0.85,
          ).animate(animation),
          curve: Curves.easeOut,
        ),
        child: child,
      ),
    );
  }
}

@immutable
class ContentDialogThemeData {
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? bodyPadding;

  final Decoration? decoration;
  final Color? barrierColor;

  final ButtonThemeData? actionThemeData;
  final double? actionsSpacing;
  final Decoration? actionsDecoration;
  final EdgeInsetsGeometry? actionsPadding;

  final TextStyle? titleStyle;
  final TextStyle? bodyStyle;

  const ContentDialogThemeData({
    this.decoration,
    this.barrierColor,
    this.titlePadding,
    this.bodyPadding,
    this.padding,
    this.actionsSpacing,
    this.actionThemeData,
    this.actionsDecoration,
    this.actionsPadding,
    this.titleStyle,
    this.bodyStyle,
  });

  factory ContentDialogThemeData.standard(ThemeData style) {
    return ContentDialogThemeData(
      decoration: BoxDecoration(
        color: style.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: kElevationToShadow[8],
      ),
      padding: const EdgeInsets.all(20),
      titlePadding: EdgeInsets.only(bottom: 12),
      actionsSpacing: 10,
      actionsDecoration: BoxDecoration(
        color: style.micaBackgroundColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        boxShadow: kElevationToShadow[1],
      ),
      actionsPadding: EdgeInsets.all(20),
      barrierColor: Colors.grey[200].withOpacity(0.8),
      titleStyle: style.typography.title,
      bodyStyle: style.typography.body,
    );
  }

  static ContentDialogThemeData lerp(
    ContentDialogThemeData? a,
    ContentDialogThemeData? b,
    double t,
  ) {
    return ContentDialogThemeData(
      decoration: Decoration.lerp(a?.decoration, b?.decoration, t),
      barrierColor: Color.lerp(a?.barrierColor, b?.barrierColor, t),
      padding: EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t),
      bodyPadding: EdgeInsetsGeometry.lerp(a?.bodyPadding, b?.bodyPadding, t),
      titlePadding:
          EdgeInsetsGeometry.lerp(a?.titlePadding, b?.titlePadding, t),
      actionsSpacing: lerpDouble(a?.actionsSpacing, b?.actionsSpacing, t),
      actionThemeData:
          ButtonThemeData.lerp(a?.actionThemeData, b?.actionThemeData, t),
      actionsDecoration:
          Decoration.lerp(a?.actionsDecoration, b?.actionsDecoration, t),
      actionsPadding:
          EdgeInsetsGeometry.lerp(a?.actionsPadding, b?.actionsPadding, t),
      titleStyle: TextStyle.lerp(a?.titleStyle, b?.titleStyle, t),
      bodyStyle: TextStyle.lerp(a?.bodyStyle, b?.bodyStyle, t),
    );
  }

  ContentDialogThemeData merge(ContentDialogThemeData? style) {
    if (style == null) return this;
    return ContentDialogThemeData(
      decoration: style.decoration ?? decoration,
      barrierColor: style.barrierColor ?? barrierColor,
      padding: style.padding ?? padding,
      bodyPadding: style.bodyPadding ?? bodyPadding,
      titlePadding: style.titlePadding ?? titlePadding,
      actionsSpacing: style.actionsSpacing ?? actionsSpacing,
      actionThemeData: style.actionThemeData ?? actionThemeData,
      actionsDecoration: style.actionsDecoration ?? actionsDecoration,
      actionsPadding: style.actionsPadding ?? actionsPadding,
      titleStyle: style.titleStyle ?? titleStyle,
      bodyStyle: style.bodyStyle ?? bodyStyle,
    );
  }
}
