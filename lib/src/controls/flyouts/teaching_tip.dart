import 'package:fluent_ui/fluent_ui.dart';

/// https://github.com/microsoft/microsoft-ui-xaml/blob/main/src/controls/dev/TeachingTip/TeachingTip_themeresources.xaml
const kTeachingTipConstraints = BoxConstraints(
  minHeight: 40.0,
  maxHeight: 520.0,
  maxWidth: 336.0,
);

typedef TooltipCloseCallback = void Function(BuildContext context);

/// Displays a Fluent teaching tip at the desired position, with Fluent entrance
/// and exit animations, modal barrier color, and modal barrier behavior
/// (dialog is dismissible with a tap on the barrier).
///
/// This function takes a [builder], which typically builds a [TeachingTip].
///
/// The `context` argument is used to look up the [Navigator] and [FluentTheme]
/// for the dialog. It is only used when the method is called. Its corresponding
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
///  * [TeachingTip], a semi-persistent and content-rich flyout that provides
///                   contextual information.
///  * [ContentDialog], for dialogs that have a row of buttons below a body.
///  * [showDialog], which allows for customization of the dialog popup.
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/dialogs-and-flyouts/teaching-tip>
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
    barrierColor: barrierColor,
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
  /// Creates a teaching tip.
  const TeachingTip({
    super.key,
    this.leading,
    required this.title,
    required this.subtitle,
    this.buttons,
    this.mediaContent,
    this.onClose = defaultCloseCallback,
  }) : assert(
          buttons == null || mediaContent == null,
          'The buttons and mediaContent properties can not coexist',
        );

  /// The leading widget of the teaching tip.
  ///
  /// Usually an [Icon] or [Image].
  final Widget? leading;

  /// The title of the teaching tip.
  ///
  /// Usually a [Text] widget.
  final Widget title;

  /// The subttile of the teaching tip.
  ///
  /// Usually a [Text].
  final Widget subtitle;

  /// The buttons to show at the bottom of the teaching tip.
  ///
  /// It is recommened to show at most two buttons.
  ///
  /// It can not coexist with the [mediaContent] property.
  ///
  /// See also:
  ///
  ///   * [Button], a button widget.
  ///   * [FilledButton], an elevated button widget.
  final List<Widget>? buttons;

  /// The media content of the teaching tip.
  ///
  /// The media content is shown above or below the title and subtitle,
  /// depending on the current flyout placement mode.
  ///
  /// It can not coexist with the [buttons] property.
  ///
  /// Usually an [Image].
  final Widget? mediaContent;

  /// Called when the close button is pressed.
  ///
  /// Set it to `null` to hide the close button.
  ///
  /// By default, it pops the current route. It is recommended to override this
  /// to use `flyoutController.close()`.
  final TooltipCloseCallback? onClose;

  /// The default close callback for the teaching tip.
  static void defaultCloseCallback(BuildContext context) {
    Navigator.of(context).pop();
  }

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
      case FlyoutPlacementMode.leftTop:
      case FlyoutPlacementMode.leftCenter:
      case FlyoutPlacementMode.leftBottom:
        alignment = const Alignment(0.75, 0.0);
        break;
      case FlyoutPlacementMode.rightTop:
      case FlyoutPlacementMode.rightCenter:
      case FlyoutPlacementMode.rightBottom:
        alignment = const Alignment(-0.75, 0.0);
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
    assert(debugCheckHasFluentLocalizations(context));
    assert(debugCheckHasFlyout(context));
    final theme = FluentTheme.of(context);
    final localizations = FluentLocalizations.of(context);
    final flyout = Flyout.of(context);
    const verticalPadding = 12.0;
    const horizontalPadding = 10.0;

    return IntrinsicWidth(
      child: ConstrainedBox(
        constraints: kTeachingTipConstraints,
        child: Acrylic(
          elevation: 1.0,
          shadowColor: Colors.black,
          shape: TeachingTipBorder(
            placement: flyout.placementMode,
            borderColor: theme.resources.surfaceStrokeColorDefault,
            arrowCrossAxisWidth: horizontalPadding,
            arrowMainAxisWidth: verticalPadding,
          ),
          child: Container(
            color: theme.menuColor,
            padding: EdgeInsets.only(
              top: switch (flyout.placementMode) {
                FlyoutPlacementMode.bottomLeft ||
                FlyoutPlacementMode.bottomCenter ||
                FlyoutPlacementMode.bottomRight =>
                  verticalPadding,
                _ => 0.0,
              },
              bottom: switch (flyout.placementMode) {
                FlyoutPlacementMode.topLeft ||
                FlyoutPlacementMode.topCenter ||
                FlyoutPlacementMode.topRight =>
                  verticalPadding,
                _ => 0.0,
              },
              left: switch (flyout.placementMode) {
                FlyoutPlacementMode.rightTop ||
                FlyoutPlacementMode.rightBottom =>
                  horizontalPadding,
                FlyoutPlacementMode.rightCenter => verticalPadding,
                _ => 0.0,
              },
              right: switch (flyout.placementMode) {
                FlyoutPlacementMode.leftTop ||
                FlyoutPlacementMode.leftBottom =>
                  horizontalPadding,
                FlyoutPlacementMode.leftCenter => verticalPadding,
                _ => 0.0,
              },
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Show this at the top if the Flyout is placed at the top
                if (mediaContent != null &&
                    (switch (flyout.placementMode) {
                      FlyoutPlacementMode.topLeft ||
                      FlyoutPlacementMode.topCenter ||
                      FlyoutPlacementMode.topRight =>
                        true,
                      _ => false,
                    }))
                  mediaContent!,
                IntrinsicHeight(
                  child: Row(children: [
                    const SizedBox(width: horizontalPadding),
                    if (leading != null)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          top: verticalPadding,
                          end: 8.0,
                        ),
                        child: leading!,
                      ),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: verticalPadding),
                          DefaultTextStyle(
                            style: theme.typography.bodyStrong ??
                                const TextStyle(),
                            child: title,
                          ),
                          subtitle,
                        ],
                      ),
                    ),
                    if (onClose != null)
                      Align(
                        alignment: AlignmentDirectional.topStart,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(
                            top: verticalPadding / 2,
                            start: 4.0,
                            end: verticalPadding / 2,
                          ),
                          child: Builder(builder: (context) {
                            return Tooltip(
                              message: localizations.closeButtonLabel,
                              child: IconButton(
                                icon: const Icon(
                                  FluentIcons.chrome_close,
                                  size: 12.0,
                                ),
                                onPressed: () => onClose!(context),
                              ),
                            );
                          }),
                        ),
                      )
                    else
                      const SizedBox(width: horizontalPadding)
                  ]),
                ),
                if (buttons != null && buttons!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: horizontalPadding,
                      top: 6.0,
                      end: horizontalPadding,
                    ),
                    child: Row(
                      spacing: 6.0,
                      children: buttons!.map<Widget>((button) {
                        return Expanded(child: button);
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: verticalPadding),

                /// Show this at the bottom if the Flyout is placed at the bottom
                /// or any horizontal placement mode
                if (mediaContent != null &&
                    (switch (flyout.placementMode) {
                          FlyoutPlacementMode.bottomLeft ||
                          FlyoutPlacementMode.bottomCenter ||
                          FlyoutPlacementMode.bottomRight =>
                            true,
                          _ => false,
                        } ||
                        flyout.placementMode.isHorizontal))
                  mediaContent!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TeachingTipBorder extends ShapeBorder {
  /// The placement of the teaching tip.
  final FlyoutPlacementMode placement;

  /// The color of the border.
  final Color borderColor;

  /// The radius of the border.
  final double borderRadius;

  /// The margin between the border and the arrow;
  final double borderMargin;

  /// The width of the arrow in the main axis.
  final double arrowMainAxisWidth;

  /// The width of the arrow in the cross axis.
  final double arrowCrossAxisWidth;

  const TeachingTipBorder({
    required this.placement,
    required this.borderColor,
    this.arrowMainAxisWidth = 14.0,
    this.arrowCrossAxisWidth = 10.0,
    this.borderRadius = 8.0,
    this.borderMargin = 12.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(arrowMainAxisWidth);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path();
    switch (placement) {
      case FlyoutPlacementMode.topLeft:
        path.moveTo(rect.left + borderRadius, rect.top);
        path.lineTo(rect.right - borderRadius, rect.top);
        path.quadraticBezierTo(
            rect.right, rect.top, rect.right, rect.top + borderRadius);
        path.lineTo(
            rect.right, rect.bottom - arrowCrossAxisWidth - borderRadius);
        path.quadraticBezierTo(rect.right, rect.bottom - arrowCrossAxisWidth,
            rect.right - borderRadius, rect.bottom - arrowCrossAxisWidth);
        path.lineTo(rect.left + borderMargin + arrowMainAxisWidth,
            rect.bottom - arrowCrossAxisWidth);
        // make the arrow
        path.lineTo(
            rect.left + borderMargin + arrowMainAxisWidth / 2, rect.bottom);
        path.lineTo(
            rect.left + borderMargin, rect.bottom - arrowCrossAxisWidth);
        // end the arrow
        path.quadraticBezierTo(rect.left, rect.bottom - arrowCrossAxisWidth,
            rect.left, rect.bottom - arrowCrossAxisWidth - borderRadius);
        path.lineTo(rect.left, rect.top + borderRadius);
        path.quadraticBezierTo(
            rect.left, rect.top, rect.left + borderRadius, rect.top);
        path.close();
        break;
      case FlyoutPlacementMode.topCenter:
        path.moveTo(rect.left + borderRadius, rect.top);
        path.lineTo(rect.right - borderRadius, rect.top);
        path.quadraticBezierTo(
            rect.right, rect.top, rect.right, rect.top + borderRadius);
        path.lineTo(
            rect.right, rect.bottom - arrowCrossAxisWidth - borderRadius);
        path.quadraticBezierTo(rect.right, rect.bottom - arrowCrossAxisWidth,
            rect.right - borderRadius, rect.bottom - arrowCrossAxisWidth);
        path.lineTo(rect.left + rect.width / 2 + arrowMainAxisWidth / 2,
            rect.bottom - arrowCrossAxisWidth);
        // make the arrow
        path.lineTo(rect.left + rect.width / 2, rect.bottom);
        path.lineTo(rect.left + rect.width / 2 - arrowMainAxisWidth / 2,
            rect.bottom - arrowCrossAxisWidth);
        // end the arrow
        path.lineTo(
            rect.left + borderMargin, rect.bottom - arrowCrossAxisWidth);
        path.quadraticBezierTo(rect.left, rect.bottom - arrowCrossAxisWidth,
            rect.left, rect.bottom - arrowCrossAxisWidth - borderRadius);
        path.lineTo(rect.left, rect.top + borderRadius);
        path.quadraticBezierTo(
            rect.left, rect.top, rect.left + borderRadius, rect.top);
        path.close();
        break;
      case FlyoutPlacementMode.topRight:
        path.moveTo(rect.left + borderRadius, rect.top);
        path.lineTo(rect.right - borderRadius, rect.top);
        path.quadraticBezierTo(
            rect.right, rect.top, rect.right, rect.top + borderRadius);
        path.lineTo(
            rect.right, rect.bottom - arrowCrossAxisWidth - borderRadius);
        path.quadraticBezierTo(rect.right, rect.bottom - arrowCrossAxisWidth,
            rect.right - borderRadius, rect.bottom - arrowCrossAxisWidth);
        path.lineTo(
            rect.right - borderMargin, rect.bottom - arrowCrossAxisWidth);
        // make the arrow
        path.lineTo(
            rect.right - borderMargin - arrowMainAxisWidth / 2, rect.bottom);
        path.lineTo(rect.right - borderMargin - arrowMainAxisWidth,
            rect.bottom - arrowCrossAxisWidth);
        // end the arrow
        path.lineTo(
            rect.left + borderMargin, rect.bottom - arrowCrossAxisWidth);
        path.quadraticBezierTo(rect.left, rect.bottom - arrowCrossAxisWidth,
            rect.left, rect.bottom - arrowCrossAxisWidth - borderRadius);
        path.lineTo(rect.left, rect.top + borderRadius);
        path.quadraticBezierTo(
            rect.left, rect.top, rect.left + borderRadius, rect.top);

        break;
      case FlyoutPlacementMode.bottomLeft:
        path.moveTo(rect.left + borderRadius, rect.top + arrowCrossAxisWidth);
        path.lineTo(rect.left + borderMargin, rect.top + arrowCrossAxisWidth);
        path.lineTo(
            rect.left + borderMargin + arrowMainAxisWidth / 2, rect.top);
        path.lineTo(rect.left + borderMargin + arrowMainAxisWidth,
            rect.top + arrowCrossAxisWidth);
        path.lineTo(rect.right - borderRadius, rect.top + arrowCrossAxisWidth);
        path.quadraticBezierTo(rect.right, rect.top + arrowCrossAxisWidth,
            rect.right, rect.top + arrowCrossAxisWidth + borderRadius);
        path.lineTo(rect.right, rect.bottom - borderRadius);
        path.quadraticBezierTo(
            rect.right, rect.bottom, rect.right - borderRadius, rect.bottom);
        path.lineTo(rect.left + borderRadius, rect.bottom);
        path.quadraticBezierTo(
            rect.left, rect.bottom, rect.left, rect.bottom - borderRadius);
        path.lineTo(rect.left, rect.top + arrowCrossAxisWidth + borderRadius);
        path.quadraticBezierTo(rect.left, rect.top + arrowCrossAxisWidth,
            rect.left + borderRadius, rect.top + arrowCrossAxisWidth);
        path.close();
        break;
      case FlyoutPlacementMode.bottomCenter:
        path.moveTo(rect.left + borderRadius, rect.top + arrowCrossAxisWidth);
        path.lineTo(rect.left + rect.width / 2 - arrowMainAxisWidth / 2,
            rect.top + arrowCrossAxisWidth);
        // make the arrow
        path.lineTo(rect.left + rect.width / 2, rect.top);
        path.lineTo(rect.left + rect.width / 2 + arrowMainAxisWidth / 2,
            rect.top + arrowCrossAxisWidth);
        // end the arrow
        path.lineTo(rect.right - borderRadius, rect.top + arrowCrossAxisWidth);
        path.quadraticBezierTo(rect.right, rect.top + arrowCrossAxisWidth,
            rect.right, rect.top + borderRadius + arrowCrossAxisWidth);
        path.lineTo(rect.right, rect.bottom - borderRadius);
        path.quadraticBezierTo(
            rect.right, rect.bottom, rect.right - borderRadius, rect.bottom);
        path.lineTo(rect.left + borderRadius, rect.bottom);
        path.quadraticBezierTo(
            rect.left, rect.bottom, rect.left, rect.bottom - borderRadius);
        path.lineTo(rect.left, rect.top + borderRadius + arrowCrossAxisWidth);
        path.quadraticBezierTo(rect.left, rect.top + arrowCrossAxisWidth,
            rect.left + borderRadius, rect.top + arrowCrossAxisWidth);
        path.close();
        break;
      case FlyoutPlacementMode.bottomRight:
        path.moveTo(rect.left + borderRadius, rect.top + arrowCrossAxisWidth);
        path.lineTo(rect.right - borderMargin - arrowMainAxisWidth,
            rect.top + arrowCrossAxisWidth);
        path.lineTo(
            rect.right - borderMargin - arrowMainAxisWidth / 2, rect.top);
        path.lineTo(rect.right - borderMargin, rect.top + arrowCrossAxisWidth);
        path.lineTo(rect.right - borderRadius, rect.top + arrowCrossAxisWidth);
        path.quadraticBezierTo(rect.right, rect.top + arrowCrossAxisWidth,
            rect.right, rect.top + arrowCrossAxisWidth + borderRadius);
        path.lineTo(rect.right, rect.bottom - borderRadius);
        path.quadraticBezierTo(
            rect.right, rect.bottom, rect.right - borderRadius, rect.bottom);
        path.lineTo(rect.left + borderRadius, rect.bottom);
        path.quadraticBezierTo(
            rect.left, rect.bottom, rect.left, rect.bottom - borderRadius);
        path.lineTo(rect.left, rect.top + arrowCrossAxisWidth + borderRadius);
        path.quadraticBezierTo(rect.left, rect.top + arrowCrossAxisWidth,
            rect.left + borderRadius, rect.top + arrowCrossAxisWidth);
        path.close();
        break;
      case FlyoutPlacementMode.leftTop:
        path.moveTo(rect.right - arrowCrossAxisWidth, rect.top + borderRadius);
        path.lineTo(rect.right - arrowCrossAxisWidth, rect.top + borderMargin);
        path.lineTo(
            rect.right, rect.top + borderMargin + arrowMainAxisWidth / 2);
        path.lineTo(rect.right - arrowCrossAxisWidth,
            rect.top + borderMargin + arrowMainAxisWidth);
        path.lineTo(
            rect.right - arrowCrossAxisWidth, rect.bottom - borderRadius);
        path.quadraticBezierTo(rect.right - arrowCrossAxisWidth, rect.bottom,
            rect.right - arrowCrossAxisWidth - borderRadius, rect.bottom);
        path.lineTo(rect.left + borderRadius, rect.bottom);
        path.quadraticBezierTo(
            rect.left, rect.bottom, rect.left, rect.bottom - borderRadius);
        path.lineTo(rect.left, rect.top + borderRadius);
        path.quadraticBezierTo(
            rect.left, rect.top, rect.left + borderRadius, rect.top);
        path.lineTo(rect.right - arrowCrossAxisWidth - borderRadius, rect.top);
        path.quadraticBezierTo(rect.right - arrowCrossAxisWidth, rect.top,
            rect.right - arrowCrossAxisWidth, rect.top + borderRadius);
        path.close();
        break;
      case FlyoutPlacementMode.leftCenter:
        path.moveTo(rect.right - arrowMainAxisWidth, rect.top + borderRadius);
        // create arrow
        path.lineTo(
          rect.right - arrowMainAxisWidth,
          rect.top + rect.size.height / 2 - arrowCrossAxisWidth,
        );
        path.lineTo(
          rect.right,
          rect.top + rect.size.height / 2 + arrowCrossAxisWidth / 8,
        );
        path.lineTo(
          rect.right - arrowMainAxisWidth,
          rect.top + rect.size.height / 2 + arrowCrossAxisWidth,
        );
        // end arrow
        path.lineTo(
            rect.right - arrowMainAxisWidth, rect.bottom - borderRadius);
        path.quadraticBezierTo(rect.right - arrowMainAxisWidth, rect.bottom,
            rect.right - arrowMainAxisWidth - borderRadius, rect.bottom);
        path.lineTo(rect.left + borderRadius, rect.bottom);
        path.quadraticBezierTo(
            rect.left, rect.bottom, rect.left, rect.bottom - borderRadius);
        path.lineTo(rect.left, rect.top + borderRadius);
        path.quadraticBezierTo(
            rect.left, rect.top, rect.left + borderRadius, rect.top);
        path.lineTo(rect.right - arrowMainAxisWidth - borderRadius, rect.top);
        path.quadraticBezierTo(rect.right - arrowMainAxisWidth, rect.top,
            rect.right - arrowMainAxisWidth, rect.top + borderRadius);
        path.close();

        break;
      case FlyoutPlacementMode.leftBottom:
        path.moveTo(rect.right - arrowCrossAxisWidth, rect.top + borderRadius);
        path.lineTo(rect.right - arrowCrossAxisWidth,
            rect.bottom - borderMargin - arrowMainAxisWidth);
        path.lineTo(
            rect.right, rect.bottom - borderMargin - arrowMainAxisWidth / 2);
        path.lineTo(
            rect.right - arrowCrossAxisWidth, rect.bottom - borderMargin);
        path.lineTo(
            rect.right - arrowCrossAxisWidth, rect.bottom - borderRadius);
        path.quadraticBezierTo(rect.right - arrowCrossAxisWidth, rect.bottom,
            rect.right - arrowCrossAxisWidth - borderRadius, rect.bottom);
        path.lineTo(rect.left + borderRadius, rect.bottom);
        path.quadraticBezierTo(
            rect.left, rect.bottom, rect.left, rect.bottom - borderRadius);
        path.lineTo(rect.left, rect.top + borderRadius);
        path.quadraticBezierTo(
            rect.left, rect.top, rect.left + borderRadius, rect.top);
        path.lineTo(rect.right - arrowMainAxisWidth - borderRadius, rect.top);
        path.quadraticBezierTo(rect.right - arrowCrossAxisWidth, rect.top,
            rect.right - arrowCrossAxisWidth, rect.top + borderRadius);
        path.close();
        break;
      case FlyoutPlacementMode.rightTop:
        path.moveTo(rect.left + arrowCrossAxisWidth, rect.top + borderRadius);
        path.lineTo(rect.left + arrowCrossAxisWidth, rect.top + borderMargin);
        path.lineTo(
            rect.left, rect.top + borderMargin + arrowMainAxisWidth / 2);
        path.lineTo(rect.left + arrowCrossAxisWidth,
            rect.top + borderMargin + arrowMainAxisWidth);
        path.lineTo(
            rect.left + arrowCrossAxisWidth, rect.bottom - borderRadius);
        path.quadraticBezierTo(rect.left + arrowMainAxisWidth, rect.bottom,
            rect.left + arrowCrossAxisWidth + borderRadius, rect.bottom);
        path.lineTo(rect.right - borderRadius, rect.bottom);
        path.quadraticBezierTo(
            rect.right, rect.bottom, rect.right, rect.bottom - borderRadius);
        path.lineTo(rect.right, rect.top + borderRadius);
        path.quadraticBezierTo(
            rect.right, rect.top, rect.right - borderRadius, rect.top);
        path.lineTo(rect.left + arrowCrossAxisWidth + borderRadius, rect.top);
        path.quadraticBezierTo(rect.left + arrowCrossAxisWidth, rect.top,
            rect.left + arrowCrossAxisWidth, rect.top + borderRadius);
        path.close();
        break;
      case FlyoutPlacementMode.rightCenter:
        path.moveTo(rect.left + arrowMainAxisWidth, rect.top + borderRadius);
        // create arrow
        path.lineTo(
          rect.left + arrowMainAxisWidth,
          rect.top + rect.size.height / 2 - arrowCrossAxisWidth,
        );
        path.lineTo(
          rect.left,
          rect.top + rect.size.height / 2 + arrowCrossAxisWidth / 8,
        );
        path.lineTo(
          rect.left + arrowMainAxisWidth,
          rect.top + rect.size.height / 2 + arrowCrossAxisWidth,
        );
        // end arrow
        path.lineTo(rect.left + arrowMainAxisWidth, rect.bottom - borderRadius);
        path.quadraticBezierTo(rect.left + arrowMainAxisWidth, rect.bottom,
            rect.left + arrowMainAxisWidth + borderRadius, rect.bottom);
        path.lineTo(rect.right - borderRadius, rect.bottom);
        path.quadraticBezierTo(
            rect.right, rect.bottom, rect.right, rect.bottom - borderRadius);
        path.lineTo(rect.right, rect.top + borderRadius);
        path.quadraticBezierTo(
            rect.right, rect.top, rect.right - borderRadius, rect.top);
        path.lineTo(rect.left + arrowMainAxisWidth + borderRadius, rect.top);
        path.quadraticBezierTo(rect.left + arrowMainAxisWidth, rect.top,
            rect.left + arrowMainAxisWidth, rect.top + borderRadius);
        path.close();
        break;
      case FlyoutPlacementMode.rightBottom:
        path.moveTo(rect.left + arrowCrossAxisWidth, rect.top + borderRadius);
        path.lineTo(rect.left + arrowCrossAxisWidth,
            rect.bottom - borderMargin - arrowMainAxisWidth);
        path.lineTo(
            rect.left, rect.bottom - borderMargin - arrowMainAxisWidth / 2);
        path.lineTo(
            rect.left + arrowCrossAxisWidth, rect.bottom - borderMargin);
        path.quadraticBezierTo(rect.left + arrowCrossAxisWidth, rect.bottom,
            rect.left + arrowCrossAxisWidth + borderRadius, rect.bottom);
        path.lineTo(rect.right - borderRadius, rect.bottom);
        path.quadraticBezierTo(
            rect.right, rect.bottom, rect.right, rect.bottom - borderRadius);
        path.lineTo(rect.right, rect.top + borderRadius);
        path.quadraticBezierTo(
            rect.right, rect.top, rect.right - borderRadius, rect.top);
        path.lineTo(rect.left + arrowMainAxisWidth + borderRadius, rect.top);
        path.quadraticBezierTo(rect.left + arrowCrossAxisWidth, rect.top,
            rect.left + arrowCrossAxisWidth, rect.top + borderRadius);
        path.close();
        break;
      case FlyoutPlacementMode.full:
        path.addRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
        );
        break;
      case FlyoutPlacementMode.auto:
        throw UnsupportedError('Auto placement is not supported');
    }

    return path;
  }

  @override
  ShapeBorder scale(double t) => this;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          rect.deflate(1),
          Radius.circular(borderRadius),
        ),
      );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = getOuterPath(rect, textDirection: textDirection);
    canvas.drawPath(path, paint);
  }
}
