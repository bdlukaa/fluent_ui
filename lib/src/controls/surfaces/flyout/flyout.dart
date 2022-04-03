import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

import '../../../utils/popup.dart';

export 'controller.dart';

part 'content.dart';
part 'menu.dart';

/// Where the flyout will be placed vertically relativelly the child
enum FlyoutPosition {
  /// The flyout will be above the child, if there is enough space available
  above,

  /// The flyout will be below the child, if there is enough space available
  below,

  /// The flyout will be by the side of the child, if there is enough space
  /// available
  side,
}

/// How the flyout will be placed relatively to the child
enum FlyoutPlacement {
  /// The flyout will be placed on the start point of the child.
  ///
  /// If the current directionality it's left-to-right, it's left. Otherwise,
  /// it's right
  start,

  /// The flyout will be placed on the center of the child.
  center,

  /// The flyout will be placed on the end point of the child.
  ///
  /// If the current directionality it's left-to-right, it's right. Otherwise,
  /// it's left
  end,

  /// The flyout will be streched and positioned on the whole app window. A
  /// [Align] can be used to align the flyout to a certain place of the
  /// window.
  full,
}

/// How the flyout will be opened by the end-user
enum FlyoutOpenMode {
  /// The flyout will not be opened automatically
  none,

  /// The flyout will opened when the user hover the child
  hover,

  /// The flyout will opened when the user press the child
  press,

  /// The flyout will be opened when the user long-press the child
  longPress,
}

/// A flyout is a light dismiss container that can show arbitrary UI as its
/// content. Flyouts can contain other flyouts or context menus to create a
/// nested experience.
///
/// ![Context Menu Showcase](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/contextmenu_rs2_icons.png)
///
/// See also:
///
///  * <https://docs.microsoft.com/en-us/windows/apps/design/controls/dialogs-and-flyouts/flyouts>
///  * [FlyoutContent]
///  * [PopUp], which is used by this under the hood to perform the flyout
///    positioning
///  * [Tooltip], which is a short description linked to a widget in form of an
///    overlay
class Flyout extends StatefulWidget {
  /// Creates a flyout.
  const Flyout({
    Key? key,
    required this.child,
    required this.content,
    this.controller,
    this.verticalOffset = 24,
    this.horizontalOffset = 10.0,
    this.placement = FlyoutPlacement.center,
    this.openMode = FlyoutOpenMode.none,
    this.position = FlyoutPosition.above,
  }) : super(key: key);

  /// The child that will be attached to the flyout.
  final Widget child;

  /// The content that will be displayed on the flyout.
  ///
  /// Usually a [FlyoutContent] is used
  final WidgetBuilder content;

  /// Holds the state of the flyout. Can be useful to open or close the flyout
  /// programatically.
  ///
  /// Call `controller.dispose()` to clean up resources when no longer necessary
  ///
  /// See also:
  ///   * [openMode], which can open the flyout on hover, press and long press
  final FlyoutController? controller;

  /// The vertical gap between the [child] and the displayed flyout.
  final double verticalOffset;

  /// The horizontal gap between the [child] and the displayed flyout.
  final double horizontalOffset;

  /// How the flyout will be placed horizontally relatively to the [child].
  ///
  /// Defaults to [FlyoutPlacement.center]
  final FlyoutPlacement placement;

  /// How the flyout will be opened by the end-user without needing to use a
  /// controller.
  ///
  /// Defaults to none
  final FlyoutOpenMode openMode;

  /// Where the flyout will be placed vertically relatively to the child
  ///
  /// Defaults to [FlyoutPosition.above]
  final FlyoutPosition position;

  @override
  _FlyoutState createState() => _FlyoutState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<FlyoutController>('controller', controller))
      ..add(DoubleProperty(
        'verticalOffset',
        verticalOffset,
        defaultValue: 24.0,
      ))
      ..add(EnumProperty<FlyoutPlacement>(
        'placement',
        placement,
        defaultValue: FlyoutPlacement.center,
      ))
      ..add(EnumProperty<FlyoutOpenMode>(
        'open mode',
        openMode,
        defaultValue: FlyoutOpenMode.none,
      ));
  }
}

class _FlyoutState extends State<Flyout> {
  final popupKey = GlobalKey<PopUpState>();

  late FlyoutController controller;

  @override
  void initState() {
    super.initState();

    controller = widget.controller ?? FlyoutController();

    controller.addListener(_handleStateChanged);
  }

  @override
  void didUpdateWidget(covariant Flyout oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller == null && widget.controller != null) {
      // Dispose the current controller
      controller.dispose();

      // Assign to the new controller
      controller = widget.controller!;
      controller.addListener(_handleStateChanged);
    }
  }

  void _handleStateChanged() {
    final isOpen = popupKey.currentState?.isOpen ?? false;
    if (!isOpen && controller.isOpen) {
      popupKey.currentState?.openPopup();
    } else if (isOpen && controller.isClosed) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    controller.removeListener(_handleStateChanged);
    // Dispose the controller if null
    if (widget.controller == null) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final popup = PopUp(
      key: popupKey,
      child: widget.child,
      content: widget.content,
      verticalOffset: widget.verticalOffset,
      horizontalOffset: widget.horizontalOffset,
      placement: widget.placement,
      position: widget.position,
    );

    switch (widget.openMode) {
      case FlyoutOpenMode.none:
        return popup;
      case FlyoutOpenMode.hover:
        return MouseRegion(
          opaque: false,
          onEnter: (event) => controller.open(),
          child: popup,
        );
      case FlyoutOpenMode.press:
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: controller.open,
          child: popup,
        );
      case FlyoutOpenMode.longPress:
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onLongPress: controller.open,
          child: popup,
        );
    }
  }
}
