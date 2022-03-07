import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

enum SpinButtonPlacementMode {
  inline,
  compact,
}

class NumberBox extends StatefulWidget {
  const NumberBox({
    Key? key,
    required this.value,
    required this.onChanged,
    this.spinButtonPlacementMode = SpinButtonPlacementMode.compact,
    this.smallChange = 1,
    this.largeChange = 10,
  }) : super(key: key);

  final int? value;
  final ValueChanged<int?>? onChanged;
  final SpinButtonPlacementMode spinButtonPlacementMode;

  final int smallChange;
  final int largeChange;

  @override
  State<StatefulWidget> createState() => _NumberBoxState();
}

class _NumberBoxState extends State<NumberBox> {
  final controller = TextEditingController();
  final focus = FocusNode();
  bool clearBox = false;

  @override
  void initState() {
    controller.text = widget.value?.toString() ?? "";
    focus.addListener(() {
      if(focus.hasFocus && widget.spinButtonPlacementMode == SpinButtonPlacementMode.compact) {
        _createNewEntry(_NumberBoxMenu());
      }else{
        // _removeEntry();
      }
    });
    super.initState();
  }

  void _createNewEntry(Widget child) {
    final OverlayState overlayState =
        Overlay.of(context, debugRequiredFor: widget)!;
    final RenderBox box = context.findRenderObject()! as RenderBox;
    Offset leftTarget = box.localToGlobal(
      box.size.centerLeft(Offset.zero),
      ancestor: overlayState.context.findRenderObject(),
    );
    Offset centerTarget = box.localToGlobal(
      box.size.center(Offset.zero),
      ancestor: overlayState.context.findRenderObject(),
    );
    Offset rightTarget = box.localToGlobal(
      box.size.centerRight(Offset.zero),
      ancestor: overlayState.context.findRenderObject(),
    );

    final Widget overlay = _NumberBoxOverlay(
      child: child,
      target: {
        FlyoutPlacement.left: leftTarget,
        FlyoutPlacement.center: centerTarget,
        FlyoutPlacement.right: rightTarget,
      },
      onClose: _removeEntry,
    );

    Navigator.of(context).push(FluentDialogRoute(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: Duration.zero,
      builder: (_) => overlay,
    ));
  }

  void _removeEntry(){
    Navigator.maybeOf(context)?.pop();
  }

  @override
  void dispose() {
    controller.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Row? suffix;

    if (widget.spinButtonPlacementMode == SpinButtonPlacementMode.inline) {
      suffix = Row(children: [
        if (clearBox)
          IconButton(
            icon: const Icon(
              FluentIcons.clear,
              size: 8,
            ),
            iconButtonMode: IconButtonMode.large,
            onPressed: () {
              _updateValue(null, true);
            },
          ),
        IconButton(
          icon: const Icon(FluentIcons.chevron_up, size: 12),
          onPressed: _incrementSmall,
          iconButtonMode: IconButtonMode.large,
        ),
        IconButton(
          icon: const Icon(FluentIcons.chevron_down, size: 12),
          onPressed: _decrementSmall,
          iconButtonMode: IconButtonMode.large,
        ),
      ]);
    }

    return RawKeyboardListener(
      focusNode: FocusNode(skipTraversal: true),
      onKey: (key) {
        if (key.isAltPressed ||
            key.isShiftPressed ||
            key.isControlPressed ||
            key.isMetaPressed ||
            !key.isKeyPressed(key.logicalKey)) {
          return;
        }

        if (key.logicalKey == LogicalKeyboardKey.pageUp) {
          _incrementLarge();
        } else if (key.logicalKey == LogicalKeyboardKey.pageDown) {
          _decrementLarge();
        }
      },
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: Listener(
          onPointerSignal: (pointerSignal) {
            if (pointerSignal is PointerScrollEvent) {
              pointerSignal.scrollDelta.dy > 0
                  ? _decrementSmall()
                  : _incrementSmall();
            }
          },
          child: TextBox(
            controller: controller,
            focusNode: focus,
            suffix: suffix,
          ),
        ),
      ),
    );
  }

  Widget _clearIcon(FocusNode focus, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 10),
      child: IconButton(
        icon: const Icon(
          FluentIcons.clear,
          size: 8,
        ),
        iconButtonMode: IconButtonMode.large,
        onPressed: onPressed,
      ),
    );
  }

  void _incrementSmall() {
    _updateValue(
        (int.tryParse(controller.text) ?? 0) + widget.smallChange, true);
  }

  void _decrementSmall() {
    _updateValue(
        (int.tryParse(controller.text) ?? 0) - widget.smallChange, true);
  }

  void _incrementLarge() {
    _updateValue(
        (int.tryParse(controller.text) ?? 0) + widget.largeChange, true);
  }

  void _decrementLarge() {
    _updateValue(
        (int.tryParse(controller.text) ?? 0) - widget.largeChange, true);
  }

  void _updateValue(int? value, bool bt) {
    if (value == null && controller.text.isNotEmpty) {
      controller.clear();
    } else if (value != null && controller.text != value.toString()) {
      controller.text = value.toString();
    }
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }

    if (bt) {
      focus.requestFocus();
    }
  }
}

class _NumberBoxMenu extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => __NumberBoxMenuState();
}

class __NumberBoxMenuState extends State<_NumberBoxMenu> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: PhysicalModel(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        shadowColor: Colors.black,
        elevation: 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 100,
            width: 50,
            decoration: BoxDecoration(
              color: FluentTheme.of(context).menuColor,
              border: Border.all(
                width: 0.25,
                color: FluentTheme.of(context).inactiveBackgroundColor,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(
                    FluentIcons.chevron_up,
                    size: 16,
                  ),
                  onPressed: () {
                    print('Increment small');
                  },
                  iconButtonMode: IconButtonMode.large,
                ),
                IconButton(
                  icon: const Icon(
                    FluentIcons.chevron_down,
                    size: 16,
                  ),
                  onPressed: () {
                    print('Decrement small');
                  },
                  iconButtonMode: IconButtonMode.large,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberBoxOverlay extends StatefulWidget {
  const _NumberBoxOverlay({
    Key? key,
    required this.target,
    required this.child,
    required this.onClose,
  }) : super(key: key);

  final Widget child;
  final Map<FlyoutPlacement, Offset> target;
  final VoidCallback onClose;

  @override
  State<StatefulWidget> createState() => __NumberBoxOverlayState();
}

class __NumberBoxOverlayState extends State<_NumberBoxOverlay> {
  @override
  Widget build(BuildContext context) {
    return CustomSingleChildLayout(
      delegate: _NumberBoxPositionDelegate(
        leftTarget: widget.target[FlyoutPlacement.left]!,
        centerTarget: widget.target[FlyoutPlacement.center]!,
        rightTarget: widget.target[FlyoutPlacement.right]!,
        verticalOffset: 20,
        preferBelow: false,
        placement: FlyoutPlacement.right,
      ),
      child: widget.child,
    );
  }
}

/// A delegate for computing the layout of a menu to be displayed above or
/// bellow a target specified in the global coordinate system.
class _NumberBoxPositionDelegate extends SingleChildLayoutDelegate {
  /// Creates a delegate for computing the layout of a menu.
  ///
  /// The arguments must not be null.
  const _NumberBoxPositionDelegate({
    required this.centerTarget,
    required this.leftTarget,
    required this.rightTarget,
    required this.verticalOffset,
    required this.preferBelow,
    required this.placement,
  });

  /// The offset of the target the menu is positioned near in the global
  /// coordinate system.
  final Offset centerTarget;
  final Offset leftTarget;
  final Offset rightTarget;

  /// The amount of vertical distance between the target and the displayed
  /// menu.
  final double verticalOffset;

  /// Whether the menu is displayed below its widget by default.
  ///
  /// If there is insufficient space to display the menu in the preferred
  /// direction, the menu will be displayed in the opposite direction.
  final bool preferBelow;

  final FlyoutPlacement placement;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final defaultOffset = positionDependentBox(
      size: size,
      childSize: childSize,
      target: centerTarget,
      verticalOffset: verticalOffset,
      preferBelow: preferBelow,
    );
    switch (placement) {
      case FlyoutPlacement.left:
        return Offset(leftTarget.dx, defaultOffset.dy);
      case FlyoutPlacement.right:
        return Offset(rightTarget.dx - childSize.width, defaultOffset.dy);
      default:
        return defaultOffset;
    }
  }

  @override
  bool shouldRelayout(_NumberBoxPositionDelegate oldDelegate) {
    return centerTarget != oldDelegate.centerTarget ||
        verticalOffset != oldDelegate.verticalOffset ||
        preferBelow != oldDelegate.preferBelow;
  }
}
