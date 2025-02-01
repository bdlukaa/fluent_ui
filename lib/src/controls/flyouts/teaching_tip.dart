import 'package:fluent_ui/fluent_ui.dart';

const kTeachingTipConstraints = BoxConstraints(
  minHeight: 40.0,
  maxHeight: 520.0,
  minWidth: 320.0,
  maxWidth: 336.0,
);

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
  required WidgetBuilder builder,
  required FlyoutController flyoutController,
  Alignment? nonTargetedAlignment,
  FlyoutPlacementMode placementMode = FlyoutPlacementMode.full,
  Duration? transitionDuration,
  FlyoutTransitionBuilder transitionBuilder =
      TeachingTip.defaultTransitionBuilder,
  Color? barrierColor = Colors.transparent,
  bool barrierDismissible = true,
}) {
  return flyoutController.showFlyout<T>(
    placementMode: placementMode,
    transitionDuration: transitionDuration,
    transitionBuilder: TeachingTip.defaultTransitionBuilder,
    builder: (context) {
      final teachingTip = builder(context);

      if (nonTargetedAlignment != null) {
        return Align(
          alignment: nonTargetedAlignment,
          child: teachingTip,
        );
      }

      return teachingTip;
    },
  );
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
    super.key,
    required this.title,
    required this.subtitle,
    this.buttons = const [],
  });

  /// The title of the teaching tip
  ///
  /// Usually a [Text]
  final Widget title;

  /// The subttile of the teaching tip
  ///
  /// Usually a [Text]
  final Widget subtitle;

  final List<Widget> buttons;

  static Widget defaultTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    FlyoutPlacementMode placementMode,
    Widget flyout,
  ) {
    late Alignment alignment;
    switch (placementMode) {
      case FlyoutPlacementMode.bottomCenter:
        alignment = const Alignment(0.0, 0.75);
        break;
      case FlyoutPlacementMode.bottomLeft:
        alignment = const Alignment(-0.65, 0.75);
        break;
      case FlyoutPlacementMode.bottomRight:
        alignment = const Alignment(0.75, 0.75);
        break;
      case FlyoutPlacementMode.topCenter:
        alignment = const Alignment(0.0, -0.75);
        break;
      case FlyoutPlacementMode.topLeft:
        alignment = const Alignment(-0.65, -0.75);
        break;
      case FlyoutPlacementMode.topRight:
        alignment = const Alignment(0.75, -0.75);
        break;
      case FlyoutPlacementMode.left:
      case FlyoutPlacementMode.right:
        alignment = Alignment.center;
        break;
      default:
        return flyout;
    }

    return ScaleTransition(
      alignment: alignment,
      scale: CurvedAnimation(
        curve: Curves.ease,
        parent: animation,
      ),
      child: flyout,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return ConstrainedBox(
      constraints: kTeachingTipConstraints,
      child: Acrylic(
        elevation: 1.0,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
          side: BorderSide(
            color: theme.resources.surfaceStrokeColorDefault,
          ),
        ),
        child: Container(
          color: theme.menuColor.withValues(alpha: 0.6),
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
                    children: buttons.indexed.map<Widget>((element) {
                      var (int index, Widget button) = element;
                      final isLast = buttons.length - 1 == index;
                      if (isLast) return Expanded(child: button);
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(end: 6.0),
                          child: button,
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
