import 'dart:ui' show lerpDouble;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The default constraints for [ContentDialog].
///
/// The dialog is constrained to 368 logical pixels wide and 756 logical pixels
/// tall by default, following the Windows design guidelines.
const kDefaultContentDialogConstraints = BoxConstraints(
  maxWidth: 368,
  maxHeight: 756,
);

/// A modal dialog that displays contextual information and requires user action.
///
/// Content dialogs block interactions with the app window until explicitly
/// dismissed. They are typically used to request user confirmation, display
/// important information, or gather input before proceeding.
///
/// ![ContentDialog example](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/dialogs/dialog_rs2_delete_file.png)
///
/// {@tool snippet}
/// This example shows a confirmation dialog:
///
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) {
///     return ContentDialog(
///       title: Text('Delete file permanently?'),
///       content: Text(
///         'If you delete this file, you won\'t be able to recover it. '
///         'Do you want to delete it?',
///       ),
///       actions: [
///         Button(
///           child: Text('Delete'),
///           onPressed: () {
///             // Delete file here
///             Navigator.pop(context, 'delete');
///           },
///         ),
///         FilledButton(
///           child: Text('Cancel'),
///           onPressed: () => Navigator.pop(context),
///         ),
///       ],
///     );
///   },
/// );
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [showDialog], used to display dialogs on top of the app content
///  * [Flyout], for non-modal contextual UI
///  * [TeachingTip], for educational or guidance content
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/dialogs-and-flyouts/dialogs>
class ContentDialog extends StatelessWidget {
  /// Creates a content dialog.
  const ContentDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.style,
    this.constraints = kDefaultContentDialogConstraints,
  });

  /// The title of the dialog. Usually, a [Text] widget
  final Widget? title;

  /// The content of the dialog. Usually, a [Text] widget
  final Widget? content;

  /// The actions of the dialog. Usually, a List of [Button]s
  final List<Widget>? actions;

  /// The style used by this dialog. If non-null, it's merged with
  /// [FluentThemeData.dialogTheme]
  final ContentDialogThemeData? style;

  /// The constraints of the dialog. It defaults to `BoxConstraints(maxWidth: 368)`
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final style = ContentDialogTheme.of(context).merge(this.style);

    return Align(
      alignment: AlignmentDirectional.center,
      child: Container(
        constraints: constraints,
        decoration: style.decoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Padding(
                padding: style.padding ?? EdgeInsetsDirectional.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Padding(
                        padding:
                            style.titlePadding ?? EdgeInsetsDirectional.zero,
                        child: DefaultTextStyle.merge(
                          style: style.titleStyle,
                          child: title!,
                        ),
                      ),
                    if (content != null)
                      Flexible(
                        child: Padding(
                          padding:
                              style.bodyPadding ?? EdgeInsetsDirectional.zero,
                          child: DefaultTextStyle.merge(
                            style: style.bodyStyle,
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
                        alignment: AlignmentDirectional.centerEnd,
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

/// Displays a Fluent dialog above the current contents of the app, with fluent
/// entrance and exit animations, modal barrier color, and modal barrier
/// behavior (dialog is dismissible with a tap on the barrier).
///
/// This function takes a `builder` which typically builds a [ContentDialog] widget.
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
/// barrier will dismiss the dialog. It is `false` by default.
///
/// The `dismissWithEsc` argument is used to indicate whether pressing the escape
/// key will dismiss the dialog. It is `true` by default.
///
/// The `barrierColor` argument is used to specify the color of the modal
/// barrier that darkens everything below the dialog. If `null` the default color
/// faded black is used.
///
/// The `useSafeArea` argument is used to indicate if the dialog should only
/// display in 'safe' areas of the screen not used by the operating system
/// (see [SafeArea] for more details). It is `true` by default, which means
/// the dialog will not overlap operating system areas. If it is set to `false`
/// the dialog will only be constrained by the screen size.
///
/// The `useRootNavigator` argument is used to determine whether to push the
/// dialog to the [Navigator] furthest from or nearest to the given `context`.
/// By default, `useRootNavigator` is `true` and the dialog route created by
/// this method is pushed to the root navigator.
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
  bool dismissWithEsc = true,
}) {
  assert(debugCheckHasFluentLocalizations(context));

  final themes = InheritedTheme.capture(
    from: context,
    to: Navigator.of(context, rootNavigator: useRootNavigator).context,
  );

  return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
    FluentDialogRoute<T>(
      context: context,
      builder: builder,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      barrierLabel: FluentLocalizations.of(context).modalBarrierDismissLabel,
      dismissWithEsc: dismissWithEsc,
      settings: routeSettings,
      transitionBuilder: transitionBuilder,
      transitionDuration:
          transitionDuration ??
          FluentTheme.maybeOf(context)?.fastAnimationDuration ??
          const Duration(milliseconds: 300),
      themes: themes,
    ),
  );
}

/// A dialog route with Windows entrance and exit animations.
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
  /// A dialog route with Windows entrance and exit animations,
  /// modal barrier color
  FluentDialogRoute({
    required WidgetBuilder builder,
    required BuildContext context,
    CapturedThemes? themes,
    super.barrierDismissible,
    super.barrierColor = const Color(0x8A000000),
    String? barrierLabel,
    super.transitionDuration,
    super.transitionBuilder = _defaultTransitionBuilder,
    super.settings,
    bool dismissWithEsc = true,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) {
           final pageChild = Builder(builder: builder);
           final dialog = themes?.wrap(pageChild) ?? pageChild;
           return SafeArea(
             child: Actions(
               actions: {
                 if (dismissWithEsc) DismissIntent: _DismissAction(context),
               },
               child: FocusScope(autofocus: true, child: dialog),
             ),
           );
         },
         barrierLabel:
             barrierLabel ??
             FluentLocalizations.of(context).modalBarrierDismissLabel,
       );

  static Widget _defaultTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: Tween<double>(begin: 1, end: 0.85).animate(animation),
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

/// An inherited widget that defines the configuration for
/// [ContentDialog]s in this widget's subtree.
///
/// Values specified here are used for [ContentDialog] properties that are not
/// given an explicit non-null value.
class ContentDialogTheme extends InheritedTheme {
  /// Creates a theme that controls how descendant [ContentDialog]s should
  /// look like.
  const ContentDialogTheme({
    required this.data,
    required super.child,
    super.key,
  });

  /// The properties for descendant [ContentDialog] widgets.
  final ContentDialogThemeData data;

  /// Creates a theme that merges the nearest [ContentDialogTheme] with [data].
  static Widget merge({
    required ContentDialogThemeData data,
    required Widget child,
    Key? key,
  }) {
    return Builder(
      builder: (context) {
        return ContentDialogTheme(
          key: key,
          data: ContentDialogTheme.of(context).merge(data),
          child: child,
        );
      },
    );
  }

  /// Returns the closest [ContentDialogThemeData] which encloses the given
  /// context.
  ///
  /// Resolution order:
  /// 1. Defaults from [ContentDialogThemeData.standard]
  /// 2. Global theme from [FluentThemeData.dialogTheme]
  /// 3. Local [ContentDialogTheme] ancestor
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// ContentDialogThemeData theme = ContentDialogTheme.of(context);
  /// ```
  static ContentDialogThemeData of(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final inheritedTheme = context
        .dependOnInheritedWidgetOfExactType<ContentDialogTheme>();
    return ContentDialogThemeData.standard(
      theme,
    ).merge(theme.dialogTheme).merge(inheritedTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return ContentDialogTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(ContentDialogTheme oldWidget) =>
      data != oldWidget.data;
}

/// Theme data for [ContentDialog] widgets.
///
/// This class defines the visual appearance of content dialogs, including
/// their decoration, padding, and action button styling.
@immutable
class ContentDialogThemeData with Diagnosticable {
  /// The padding around the entire dialog content.
  final EdgeInsetsGeometry? padding;

  /// The padding around the title.
  final EdgeInsetsGeometry? titlePadding;

  /// The padding around the body content.
  final EdgeInsetsGeometry? bodyPadding;

  /// The decoration of the dialog background.
  final Decoration? decoration;

  /// The color of the barrier behind the dialog.
  final Color? barrierColor;

  /// The theme data for action buttons in the dialog.
  final ButtonThemeData? actionThemeData;

  /// The spacing between action buttons.
  final double? actionsSpacing;

  /// The decoration of the actions area.
  final Decoration? actionsDecoration;

  /// The padding around the actions area.
  final EdgeInsetsGeometry? actionsPadding;

  /// The text style for the dialog title.
  final TextStyle? titleStyle;

  /// The text style for the dialog body.
  final TextStyle? bodyStyle;

  /// Creates content dialog theme data.
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

  /// Creates the standard [ContentDialogThemeData] based on the given [theme].
  factory ContentDialogThemeData.standard(FluentThemeData theme) {
    return ContentDialogThemeData(
      decoration: BoxDecoration(
        color: theme.menuColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: kElevationToShadow[6],
      ),
      padding: const EdgeInsetsDirectional.all(20),
      titlePadding: const EdgeInsetsDirectional.only(bottom: 12),
      actionsSpacing: 10,
      actionsDecoration: BoxDecoration(
        color: theme.micaBackgroundColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        // boxShadow: kElevationToShadow[1],
      ),
      actionsPadding: const EdgeInsetsDirectional.all(20),
      barrierColor: Colors.grey[200].withValues(alpha: 0.8),
      titleStyle: theme.typography.title,
      bodyStyle: theme.typography.body,
    );
  }

  /// Linearly interpolates between two [ContentDialogThemeData] objects.
  ///
  /// {@macro fluent_ui.lerp.t}
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
      titlePadding: EdgeInsetsGeometry.lerp(
        a?.titlePadding,
        b?.titlePadding,
        t,
      ),
      actionsSpacing: lerpDouble(a?.actionsSpacing, b?.actionsSpacing, t),
      actionThemeData: ButtonThemeData.lerp(
        a?.actionThemeData,
        b?.actionThemeData,
        t,
      ),
      actionsDecoration: Decoration.lerp(
        a?.actionsDecoration,
        b?.actionsDecoration,
        t,
      ),
      actionsPadding: EdgeInsetsGeometry.lerp(
        a?.actionsPadding,
        b?.actionsPadding,
        t,
      ),
      titleStyle: TextStyle.lerp(a?.titleStyle, b?.titleStyle, t),
      bodyStyle: TextStyle.lerp(a?.bodyStyle, b?.bodyStyle, t),
    );
  }

  /// Merges this [ContentDialogThemeData] with another, with the other taking
  /// precedence.
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Decoration>('decoration', decoration))
      ..add(ColorProperty('barrierColor', barrierColor))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>('bodyPadding', bodyPadding))
      ..add(
        DiagnosticsProperty<EdgeInsetsGeometry>('titlePadding', titlePadding),
      )
      ..add(DoubleProperty('actionsSpacing', actionsSpacing))
      ..add(
        DiagnosticsProperty<ButtonThemeData>(
          'actionThemeData',
          actionThemeData,
        ),
      )
      ..add(
        DiagnosticsProperty<Decoration>('actionsDecoration', actionsDecoration),
      )
      ..add(
        DiagnosticsProperty<EdgeInsetsGeometry>(
          'actionsPadding',
          actionsPadding,
        ),
      )
      ..add(DiagnosticsProperty<TextStyle>('titleStyle', titleStyle))
      ..add(DiagnosticsProperty<TextStyle>('bodyStyle', bodyStyle));
  }
}
