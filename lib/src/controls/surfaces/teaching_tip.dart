import 'package:fluent_ui/fluent_ui.dart';

/// Displays a Fluent teaching tip at the desired position, with Fluent entrance
/// and exit animations, modal barrier color, and modal barrier behavior
/// (dialog is dismissible with a tap on the barrier).
///
/// This function takes a `teachingTip`, which typically builds a [TeachingTip]
///
/// The `context` argument is used to look up the [Navigator] and [FluentTheme] for
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
/// ### State Restoration in Popups
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
Future<T?> showTeachingTip<T extends Object?>({
  required BuildContext context,
  required Widget teachingTip,
  Duration? transitionDuration,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  String? barrierLabel,
  Color? barrierColor = Colors.transparent,
  bool barrierDismissible = true,
  Offset? at,
}) {
  assert(debugCheckHasFluentLocalizations(context));

  final CapturedThemes themes = InheritedTheme.capture(
    from: context,
    to: Navigator.of(
      context,
      rootNavigator: useRootNavigator,
    ).context,
  );

  final alignment =
      teachingTip is TeachingTip ? teachingTip.alignment : Alignment.center;

  return Navigator.of(
    context,
    rootNavigator: useRootNavigator,
  ).push<T>(FluentDialogRoute<T>(
    context: context,
    builder: (context) {
      final placementMargin = teachingTip is TeachingTip
          ? teachingTip.placementMargin
          : EdgeInsets.zero;

      return Align(
        alignment: alignment,
        child: Padding(
          padding: placementMargin,
          child: teachingTip,
        ),
      );
    },
    barrierColor: barrierColor,
    barrierDismissible: barrierDismissible,
    barrierLabel: FluentLocalizations.of(context).modalBarrierDismissLabel,
    settings: routeSettings,
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return TeachingTip._defaultTransitionBuilder(
        context,
        animation,
        secondaryAnimation,
        Alignment.center,
        child,
      );
    },
    transitionDuration: transitionDuration ??
        FluentTheme.maybeOf(context)?.fastAnimationDuration ??
        const Duration(milliseconds: 300),
    themes: themes,
  ));
}

/// A teaching tip is a semi-persistent and content-rich flyout that provides
/// contextual information. It is often used for informing, reminding, and
/// teaching users about important and new features that may enhance their
/// experience.
///
/// A teaching tip may be light-dismiss or require explicit action to close. A
/// teaching tip can target a specific UI element with its tail and also be used
/// without a tail or target.
///
/// See also:
///
///  * [ContentDialog], modal UI overlays that provide contextual app information.
///  * [Tooltip], a popup that contains additional information about another object.
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/dialogs-and-flyouts/teaching-tip>
class TeachingTip extends StatelessWidget {
  /// Creates a teaching tip
  const TeachingTip({
    Key? key,
    required this.title,
    required this.subtitle,
    this.buttons = const [],
    this.alignment = Alignment.center,
    this.placementMargin = EdgeInsets.zero,
  }) : super(key: key);

  /// The title of the teaching tip
  ///
  /// Usually a [Text]
  final Widget title;

  /// The subttile of the teaching tip
  ///
  /// Usually a [Text]
  final Widget subtitle;

  final List<Widget> buttons;

  /// Where the teaching tip should be displayed
  final Alignment alignment;

  final EdgeInsetsGeometry placementMargin;

  static Widget _defaultTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Alignment alignment,
    Widget child,
  ) {
    return ScaleTransition(
      alignment: alignment,
      scale: animation,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 40.0,
        maxHeight: 520.0,
        minWidth: 320.0,
        maxWidth: 336.0,
      ),
      child: Acrylic(
        elevation: 1.0,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
          side: BorderSide(
            color: theme.resources.surfaceStrokeColorDefault,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultTextStyle(
                style: theme.typography.bodyStrong ?? const TextStyle(),
                child: title,
              ),
              subtitle,
              if (buttons.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Row(
                    children: List.generate(buttons.length, (index) {
                      final isLast = buttons.length - 1 == index;
                      final button = buttons[index];
                      if (isLast) return Expanded(child: button);
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(end: 6.0),
                          child: button,
                        ),
                      );
                    }),
                    // children: buttons.map((button) {
                    //   return Expanded(child: button);
                    // }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class TeachingTipTarget extends StatefulWidget {
  const TeachingTipTarget({
    Key? key,
    required this.teachingTip,
    required this.child,
  }) : super(key: key);

  final Widget teachingTip;

  final Widget child;

  @override
  State<TeachingTipTarget> createState() => TeachingTipTargetState();
}

class TeachingTipTargetState extends State<TeachingTipTarget> {
  final _targetKey = GlobalKey();

  void showTeachingTip() {
    final box = _targetKey.currentContext!.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    print(offset);
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _targetKey,
      child: widget.child,
    );
  }
}
