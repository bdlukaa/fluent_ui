import 'package:fluent_ui/fluent_ui.dart';

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
  });

  /// The offset of the target the flyout is positioned near in the global
  /// coordinate system.
  final Offset targetOffset;

  final Size targetSize;

  /// The amount of vertical distance between the target and the displayed
  /// flyout.
  final double additionalOffset;

  final FlyoutPlacementMode placementMode;

  final double margin;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size screenSize, Size flyoutSize) {
    print('$screenSize - $flyoutSize - $placementMode');

    double clampHorizontal(double x) {
      return x.clamp(margin, screenSize.width - flyoutSize.width - margin);
    }

    double clampVertical(double y) {
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
        return Offset(
          clampHorizontal(targetOffset.dx - flyoutSize.width / 4.0),
          bottomY,
        );
      case FlyoutPlacementMode.topCenter:
        return Offset(
          clampHorizontal(targetOffset.dx - flyoutSize.width / 4.0),
          topY,
        );
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
  /// Throws an error if it's already attached
  void _attach(FlyoutAttachState state) {
    assert(
      !isAttached,
      'This FlyoutController is already attached to a controller',
    );

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

  Future<T?> showFlyout<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    FlyoutPlacementMode placementMode = FlyoutPlacementMode.right,
    double additionalOffset = 8.0,
    double margin = 8.0,
  }) async {
    _ensureAttached();
    assert(_attachState!.mounted);

    final context = _attachState!.context;
    final navigator = Navigator.of(context);
    final navigatorBox = navigator.context.findRenderObject() as RenderBox;

    final targetBox = context.findRenderObject() as RenderBox;
    final targetSize = targetBox.size;
    final targetOffset =
        targetBox.localToGlobal(Offset.zero, ancestor: navigatorBox) +
            Offset(0, targetSize.height);
    // final targetRect = placementMode.calculatePosition(
    //   screenSize,
    //   targetOffset,
    //   targetSize,
    // );

    _open = true;
    notifyListeners();

    final result = await navigator.push<T>(PageRouteBuilder<T>(
      opaque: false,
      pageBuilder: (context, animation, secondary) {
        return Stack(children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (barrierDismissible) navigator.pop();
              },
            ),
          ),
          Positioned.fill(
            child: CustomSingleChildLayout(
              delegate: _FlyoutPositionDelegate(
                targetOffset: targetOffset,
                targetSize: targetSize,
                additionalOffset: additionalOffset,
                placementMode: placementMode,
                margin: margin,
              ),
              child: builder(context),
            ),
          ),
        ]);
      },
    ));

    _open = false;
    notifyListeners();

    return result;
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
