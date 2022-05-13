import 'dart:ui' show lerpDouble;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

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
///
/// See also:
///
///   * <showDialog>, used to display dialogs on top of the app content
///   * <https://docs.microsoft.com/en-us/windows/apps/design/controls/dialogs-and-flyouts/dialogs>
class ContentDialog extends StatelessWidget {
  /// Creates a content dialog.
  const ContentDialog({
    Key? key,
    this.title,
    this.content,
    this.actions,
    this.style,
    this.backgroundDismiss = true,
    this.constraints = const BoxConstraints(maxWidth: 368),
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

  /// The constraints of the dialog. It defaults to `BoxConstraints(maxWidth: 368)`
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final style = ContentDialogThemeData.standard(FluentTheme.of(
      context,
    )).merge(
      FluentTheme.of(context).dialogTheme.merge(this.style),
    );
    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: constraints,
        decoration: style.decoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Padding(
                padding: style.padding ?? EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Padding(
                        padding: style.titlePadding ?? EdgeInsets.zero,
                        child: DefaultTextStyle(
                          style: style.titleStyle ?? const TextStyle(),
                          child: title!,
                        ),
                      ),
                    if (content != null)
                      Flexible(
                        child: Padding(
                          padding: style.bodyPadding ?? EdgeInsets.zero,
                          child: DefaultTextStyle(
                            style: style.bodyStyle ?? const TextStyle(),
                            child: content!,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (actions != null)
              Container(
                decoration: style.actionsDecoration,
                padding: style.actionsPadding,
                child: ButtonTheme.merge(
                  data: style.actionThemeData ?? const ButtonThemeData(),
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
                            padding: EdgeInsetsDirectional.only(
                              end: index != (actions!.length - 1)
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
      ),
    );
  }
}

/// Displays a Material dialog above the current contents of the app, with
/// Material entrance and exit animations, modal barrier color, and modal
/// barrier behavior (dialog is dismissible with a tap on the barrier).
///
/// This function takes a `builder` which typically builds a [Dialog] widget.
/// Content below the dialog is dimmed with a [ModalBarrier]. The widget
/// returned by the `builder` does not share a context with the location that
/// `showDialog` is originally called from. Use a [StatefulBuilder] or a
/// custom [StatefulWidget] if the dialog needs to update dynamically.
///
/// The `context` argument is used to look up the [Navigator] and [Theme] for
/// the dialog. It is only used when the method is called. Its corresponding
/// widget can be safely removed from the tree before the dialog is closed.
///
/// The `barrierDismissible` argument is used to indicate whether tapping on the
/// barrier will dismiss the dialog. It is `true` by default and can not be `null`.
///
/// The `barrierColor` argument is used to specify the color of the modal
/// barrier that darkens everything below the dialog. If `null` the default color
/// `Colors.black54` is used.
///
/// The `useSafeArea` argument is used to indicate if the dialog should only
/// display in 'safe' areas of the screen not used by the operating system
/// (see [SafeArea] for more details). It is `true` by default, which means
/// the dialog will not overlap operating system areas. If it is set to `false`
/// the dialog will only be constrained by the screen size. It can not be `null`.
///
/// The `useRootNavigator` argument is used to determine whether to push the
/// dialog to the [Navigator] furthest from or nearest to the given `context`.
/// By default, `useRootNavigator` is `true` and the dialog route created by
/// this method is pushed to the root navigator. It can not be `null`.
///
/// The `routeSettings` argument is passed to [showGeneralDialog],
/// see [RouteSettings] for details.
///
/// If the application has multiple [Navigator] objects, it may be necessary to
/// call `Navigator.of(context, rootNavigator: true).pop(result)` to close the
/// dialog rather than just `Navigator.pop(context, result)`.
///
/// Returns a [Future] that resolves to the value (if any) that was passed to
/// [Navigator.pop] when the dialog was closed.
///
/// ### State Restoration in Dialogs
///
/// Using this method will not enable state restoration for the dialog. In order
/// to enable state restoration for a dialog, use [Navigator.restorablePush]
/// or [Navigator.restorablePushNamed] with [FluentDialogRoute].
///
/// For more information about state restoration, see [RestorationManager].
///
/// See also:
///
///  * [ContentDialog], for dialogs that have a row of buttons below a body.
///  * [showGeneralDialog], which allows for customization of the dialog popup.
///  * <https://docs.microsoft.com/en-us/windows/apps/design/controls/dialogs-and-flyouts/dialogs>
Future<T?> showDialog<T extends Object?>({
  required BuildContext context,
  required WidgetBuilder builder,
  RouteTransitionsBuilder transitionBuilder =
      FluentDialogRoute._defaultTransitionBuilder,
  Duration? transitionDuration,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  String? barrierLabel,
  Color? barrierColor = const Color(0x8A000000),
  bool barrierDismissible = false,
}) {
  assert(debugCheckHasFluentLocalizations(context));

  final CapturedThemes themes = InheritedTheme.capture(
    from: context,
    to: Navigator.of(
      context,
      rootNavigator: useRootNavigator,
    ).context,
  );

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
        const Duration(milliseconds: 300),
    themes: themes,
  ));
}

/// A dialog route with Fluent entrance and exit animations.
///
/// It is used internally by [showDialog] or can be directly pushed
/// onto the [Navigator] stack to enable state restoration. See
/// [showDialog] for a state restoration app example.
///
/// This function takes a `builder` which typically builds a [Dialog] widget.
/// Content below the dialog is dimmed with a [ModalBarrier]. The widget
/// returned by the `builder` does not share a context with the location that
/// `showDialog` is originally called from. Use a [StatefulBuilder] or a
/// custom [StatefulWidget] if the dialog needs to update dynamically.
///
/// The `context` argument is used to look up
/// [FluentLocalizations.modalBarrierDismissLabel], which provides the
/// modal with a localized accessibility label that will be used for the
/// modal's barrier. However, a custom `barrierLabel` can be passed in as well.
///
/// The `barrierDismissible` argument is used to indicate whether tapping on the
/// barrier will dismiss the dialog. It is `true` by default and cannot be `null`.
///
/// The `barrierColor` argument is used to specify the color of the modal
/// barrier that darkens everything below the dialog. If `null`, the default
/// color `Colors.black54` is used.
///
/// The `useSafeArea` argument is used to indicate if the dialog should only
/// display in 'safe' areas of the screen not used by the operating system
/// (see [SafeArea] for more details). It is `true` by default, which means
/// the dialog will not overlap operating system areas. If it is set to `false`
/// the dialog will only be constrained by the screen size. It can not be `null`.
///
/// The `settings` argument define the settings for this route. See
/// [RouteSettings] for details.
///
/// See also:
///
///  * [showDialog], which is a way to display a DialogRoute.
///  * [showGeneralDialog], which allows for customization of the dialog popup.
class FluentDialogRoute<T> extends RawDialogRoute<T> {
  /// A dialog route with Material entrance and exit animations,
  /// modal barrier color
  FluentDialogRoute({
    required WidgetBuilder builder,
    required BuildContext context,
    CapturedThemes? themes,
    bool barrierDismissible = false,
    Color? barrierColor = const Color(0x8A000000),
    String? barrierLabel,
    Duration transitionDuration = const Duration(milliseconds: 250),
    RouteTransitionsBuilder? transitionBuilder = _defaultTransitionBuilder,
    RouteSettings? settings,
  }) : super(
          pageBuilder: (BuildContext context, animation, secondaryAnimation) {
            final pageChild = Builder(builder: builder);
            final dialog = themes?.wrap(pageChild) ?? pageChild;
            return SafeArea(
              child: Actions(
                actions: {DismissIntent: _DismissAction(context)},
                child: FocusScope(
                  autofocus: true,
                  child: dialog,
                ),
              ),
            );
          },
          barrierDismissible: barrierDismissible,
          barrierLabel: barrierLabel ??
              FluentLocalizations.of(context).modalBarrierDismissLabel,
          barrierColor: barrierColor,
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

class _DismissAction extends DismissAction {
  _DismissAction(this.context);

  final BuildContext context;

  @override
  void invoke(covariant DismissIntent intent) {
    Navigator.of(context).pop();
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
        color: style.menuColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: kElevationToShadow[6],
      ),
      padding: const EdgeInsets.all(20),
      titlePadding: const EdgeInsets.only(bottom: 12),
      actionsSpacing: 10,
      actionsDecoration: BoxDecoration(
        color: style.micaBackgroundColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        boxShadow: kElevationToShadow[1],
      ),
      actionsPadding: const EdgeInsets.all(20),
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
