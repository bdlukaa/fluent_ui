import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

/// Defines constants that specify the preferred location for positioning a
/// [Flyout] derived control relative to a visual element.
///
/// See also:
///
///  * <https://learn.microsoft.com/en-us/windows/windows-app-sdk/api/winrt/microsoft.ui.xaml.controls.primitives.flyoutplacementmode>
enum FlyoutPlacementMode {
  /// Preferred location is determined automatically.
  auto,

  /// Preferred location is below the target element.
  bottomCenter,

  /// Preferred location is below the target element, with the left edge of
  /// flyout aligned with left edge of the target element.
  bottomLeft,

  /// Preferred location is below the target element, with the right edge of
  /// flyout aligned with right edge of the target element.
  bottomRight,

  /// Preferred location is to the left of the target element.
  left,

  /// Preferred location is to the right of the target element.
  right,

  /// Preferred location is above the target element.
  topCenter,

  /// Preferred location is above the target element, with the left edge of
  /// flyout aligned with left edge of the target element.
  topLeft,

  /// Preferred location is above the target element, with the right edge of
  /// flyout aligned with right edge of the target element.
  topRight;
}

/// A delegate for computing the layout of a flyout to be displayed above or
/// bellow a target specified in the global coordinate system.
class _FlyoutPositionDelegate extends SingleChildLayoutDelegate {
  /// Creates a delegate for computing the layout of a flyout.
  ///
  /// The arguments must not be null.
  const _FlyoutPositionDelegate({
    required this.targetOffset,
    required this.targetSize,
    required this.additionalOffset,
    required this.placementMode,
    required this.margin,
    required this.shouldConstrainToRootBounds,
  });

  final Offset targetOffset;
  final Size targetSize;
  final double additionalOffset;
  final FlyoutPlacementMode placementMode;
  final double margin;
  final bool shouldConstrainToRootBounds;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size screenSize, Size flyoutSize) {
    // print('$screenSize - $flyoutSize - $placementMode');

    double clampHorizontal(double x) {
      if (!shouldConstrainToRootBounds) return x;

      return x.clamp(margin, screenSize.width - flyoutSize.width - margin);
    }

    double clampVertical(double y) {
      if (!shouldConstrainToRootBounds) return y;

      return y.clamp(margin, screenSize.height - flyoutSize.height - margin);
    }

    final topY = clampVertical(
      targetOffset.dy -
          targetSize.height -
          additionalOffset -
          flyoutSize.height,
    );

    final bottomY = clampVertical(targetOffset.dy + additionalOffset);

    final horizontalY = clampVertical(
      targetOffset.dy - targetSize.height - flyoutSize.height / 4,
    );

    final centerX = clampHorizontal(
      (targetOffset.dx + targetSize.width / 2) - (flyoutSize.width / 2.0),
    );

    switch (placementMode) {
      case FlyoutPlacementMode.bottomLeft:
        return Offset(clampHorizontal(targetOffset.dx), bottomY);
      case FlyoutPlacementMode.topLeft:
        return Offset(clampHorizontal(targetOffset.dx), topY);
      case FlyoutPlacementMode.bottomRight:
        return Offset(
          clampHorizontal(
            targetOffset.dx + targetSize.width - flyoutSize.width,
          ),
          bottomY,
        );
      case FlyoutPlacementMode.topRight:
        return Offset(
          clampHorizontal(
            targetOffset.dx + targetSize.width - flyoutSize.width,
          ),
          topY,
        );
      case FlyoutPlacementMode.bottomCenter:
        return Offset(centerX, bottomY);
      case FlyoutPlacementMode.topCenter:
        return Offset(centerX, topY);
      case FlyoutPlacementMode.left:
        return Offset(
          clampHorizontal(
            targetOffset.dx - flyoutSize.width - additionalOffset,
          ),
          horizontalY,
        );
      case FlyoutPlacementMode.right:
        return Offset(
          clampHorizontal(
            targetOffset.dx + targetSize.width + additionalOffset,
          ),
          horizontalY,
        );
      case FlyoutPlacementMode.auto:
      default:
        return targetOffset;
    }
  }

  @override
  bool shouldRelayout(_FlyoutPositionDelegate oldDelegate) {
    return targetOffset != oldDelegate.targetOffset ||
        additionalOffset != oldDelegate.additionalOffset ||
        placementMode != oldDelegate.placementMode;
  }
}

class FlyoutController with ChangeNotifier {
  FlyoutAttachState? _attachState;
  bool _open = false;

  /// Whether this flyout controller is attached to any [FlyoutAttach]
  bool get isAttached => _attachState != null;

  /// Attaches this controller to a [FlyoutAttach] widget.
  ///
  /// If already attached, the current state is detached and replaced by the
  /// provided [state]
  void _attach(FlyoutAttachState state) {
    if (isAttached) _detach();

    _attachState = state;
  }

  void _detach() {
    _ensureAttached();
    _attachState = null;
  }

  /// Makes sure the controller is attached to a [FlyoutAttach]. Usually used
  /// when [_attachState] is necessary
  void _ensureAttached() {
    assert(isAttached, 'This controller must be attached to a FlyoutAttach');
  }

  /// Whether the flyout is open
  ///
  /// See also:
  ///
  ///  * [showFlyout], which opens the flyout
  bool get isOpen => _open;

  /// Shows a flyout.
  ///
  /// If [barrierDismissible] is true, tapping outside of the flyout will close
  /// it.
  ///
  /// [barrierColor] is the color of the barrier.
  ///
  /// When [dismissWithEsc] is true, the flyout can be dismissed by pressing the
  /// ESC key.
  ///
  /// If [dismissOnPointerMoveAway] is enabled, the flyout is dismissed when the
  /// cursor moves away from either the target or the flyout. It's disabled by
  /// default.
  ///
  /// [placementMode] describes where the flyout will be placed. Defaults to top
  /// center
  ///
  /// [shouldConstrainToRootBounds], when true, the flyout is limited to the
  /// bounds of the closest [Navigator]. If false, the flyout may overflow the
  /// screen.
  ///
  /// [additionalOffset] is the offset of the flyout around the attached target
  ///
  /// [margin] is the margin of the flyout to the root bounds
  ///
  /// If there isn't a [Navigator] in the tree, a [navigatorKey] can be used to
  /// display the flyout. If null, [Navigator.of] is used.
  Future<T?> showFlyout<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    bool dismissWithEsc = true,
    bool dismissOnPointerMoveAway = false,
    FlyoutPlacementMode placementMode = FlyoutPlacementMode.topCenter,
    bool shouldConstrainToRootBounds = true,
    double additionalOffset = 8.0,
    double margin = 8.0,
    Color? barrierColor,
    NavigatorState? navigatorKey,
  }) async {
    _ensureAttached();
    assert(_attachState!.mounted);

    final context = _attachState!.context;
    final navigator = navigatorKey ?? Navigator.of(context);
    final navigatorBox = navigator.context.findRenderObject() as RenderBox;

    final targetBox = context.findRenderObject() as RenderBox;
    final targetSize = targetBox.size;
    final targetOffset =
        targetBox.localToGlobal(Offset.zero, ancestor: navigatorBox) +
            Offset(0, targetSize.height);

    _open = true;
    notifyListeners();

    final flyoutKey = GlobalKey();

    final result = await navigator.push<T>(PageRouteBuilder<T>(
      opaque: false,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondary) {
        Widget box = Stack(children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: barrierDismissible ? navigator.pop : null,
              child: ColoredBox(
                color: barrierColor ?? Colors.black.withOpacity(0.3),
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: CustomSingleChildLayout(
                delegate: _FlyoutPositionDelegate(
                  targetOffset: targetOffset,
                  targetSize: targetSize,
                  additionalOffset: additionalOffset,
                  placementMode: placementMode,
                  margin: margin,
                  shouldConstrainToRootBounds: shouldConstrainToRootBounds,
                ),
                child: KeyedSubtree(
                  key: flyoutKey,
                  child: builder(context),
                ),
              ),
            ),
          ),
        ]);

        if (dismissOnPointerMoveAway) {
          // TODO: additional offset should only be used on the side the flyout is used
          final targetRect = (targetBox.localToGlobal(
                    Offset.zero,
                    ancestor: navigatorBox,
                  ) -
                  Offset(additionalOffset, additionalOffset)) &
              Size(
                targetSize.width + additionalOffset,
                targetSize.height + additionalOffset,
              );

          box = MouseRegion(
            onHover: (hover) {
              final flyoutBox =
                  flyoutKey.currentContext!.findRenderObject() as RenderBox;
              final flyoutRect =
                  flyoutBox.localToGlobal(Offset.zero) & flyoutBox.size;

              if (!flyoutRect.contains(hover.position) &&
                  !targetRect.contains(hover.localPosition)) {
                navigator.pop();
              }
            },
            child: box,
          );
        }

        if (dismissWithEsc) {
          box = Actions(
            actions: {DismissIntent: _DismissAction(navigator.pop)},
            child: FocusScope(
              autofocus: true,
              child: box,
            ),
          );
        }

        return FadeTransition(
          opacity: CurvedAnimation(
            curve: Curves.ease,
            parent: animation,
          ),
          child: box,
        );
      },
    ));

    _open = false;
    notifyListeners();

    return result;
  }
}

class _DismissAction extends DismissAction {
  _DismissAction(this.onDismiss);

  final VoidCallback onDismiss;

  @override
  void invoke(covariant DismissIntent intent) {
    onDismiss();
  }
}

class FlyoutAttach extends StatefulWidget {
  final FlyoutController controller;
  final Widget child;

  const FlyoutAttach({
    Key? key,
    required this.controller,
    required this.child,
  }) : super(key: key);

  @override
  State<FlyoutAttach> createState() => FlyoutAttachState();
}

class FlyoutAttachState extends State<FlyoutAttach> {
  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);
  }

  @override
  void dispose() {
    widget.controller._detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
