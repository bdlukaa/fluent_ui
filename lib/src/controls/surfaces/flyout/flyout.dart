import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

import '../../../utils/popup.dart';

export 'controller.dart';

part 'content.dart';
part 'menu.dart';

const kDefaultLongHoverDuration = Duration(milliseconds: 400);

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

  /// The flyout will be opened when the user long hover the child
  longHover,

  /// The flyout will opened when the user press the child
  press,

  /// The flyout will be opened when the user long-press the child
  longPress,

  /// The flyout will opened when the user secondary press the child
  secondaryPress,
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
    this.longHoverDuration = kDefaultLongHoverDuration,
    this.onOpen,
    this.onClose,
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

  /// The duration of the hover if [openMode] is [FlyoutOpenMode.longHover].
  ///
  /// 800 milliseconds are used by default
  final Duration longHoverDuration;

  /// Where the flyout will be placed vertically relatively to the child
  ///
  /// Defaults to [FlyoutPosition.above]
  final FlyoutPosition position;

  /// Called when the flyout is opened, either by [controller] or [openMode]
  final VoidCallback? onOpen;

  /// Called when the flyout is closed, either by [controller] or by the user
  final VoidCallback? onClose;

  @override
  _FlyoutState createState() => _FlyoutState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<FlyoutController>('controller', controller))
      ..add(DoubleProperty(
        'vertical offset',
        verticalOffset,
        defaultValue: 24.0,
      ))
      ..add(DoubleProperty(
        'horizontal offset',
        horizontalOffset,
        defaultValue: 10.0,
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
      ))
      ..add(EnumProperty<FlyoutPosition>(
        'position',
        position,
        defaultValue: FlyoutPosition.above,
      ))
      ..add(DiagnosticsProperty<Duration>(
        'long hover duration',
        longHoverDuration,
        defaultValue: kDefaultLongHoverDuration,
      ));
  }
}

class _FlyoutState extends State<Flyout> {
  final popupKey = GlobalKey<PopUpState>();

  late FlyoutController controller;
  Timer? longHoverTimer;

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
      // Dispose the current controller, which was created locally
      controller.dispose();

      // Assign to the new controller
      controller = widget.controller!;
      controller.addListener(_handleStateChanged);
    }
  }

  void _handleStateChanged() {
    if (!mounted) return;
    final isOpen = popupKey.currentState?.isOpen ?? false;
    if (!isOpen && controller.isOpen) {
      popupKey.currentState?.openPopup().then((value) {
        widget.onClose?.call();
      });
      widget.onOpen?.call();
    } else if (isOpen && controller.isClosed) {
      Navigator.pop(context);
      widget.onClose?.call();
    }
  }

  @override
  void dispose() {
    controller.removeListener(_handleStateChanged);
    // Dispose the controller if null
    if (widget.controller == null) {
      controller.dispose();
    }
    longHoverTimer?.cancel();
    longHoverTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final popup = PopUp(
      key: popupKey,
      content: widget.content,
      verticalOffset: widget.verticalOffset,
      horizontalOffset: widget.horizontalOffset,
      placement: widget.placement,
      position: widget.position,
      child: widget.child,
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
      case FlyoutOpenMode.longHover:
        return MouseRegion(
          opaque: true,
          onEnter: (event) {
            longHoverTimer = Timer(widget.longHoverDuration, controller.open);
          },
          onExit: (event) {
            if (longHoverTimer?.isActive ?? false) longHoverTimer?.cancel();
          },
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
      case FlyoutOpenMode.secondaryPress:
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onSecondaryTap: controller.open,
          child: popup,
        );
    }
  }
}
