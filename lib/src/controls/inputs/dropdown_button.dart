import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

const double _kVerticalOffset = 20.0;
const double _kInnerPadding = 5.0;

/// A DropDownButton is a button that shows a chevron as a visual indicator that
/// it has an attached flyout that contains more options. It has the same
/// behavior as a standard Button control with a flyout; only the appearance is
/// different.
///
/// ![DropDownButton Showcase](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/drop-down-button-align.png)
///
/// See also:
///
///   * [Flyout], a light dismiss container that can show arbitrary UI as its
///  content
///   * [Combobox], a list of items that a user can select from
///   * <https://docs.microsoft.com/en-us/windows/apps/design/controls/buttons#create-a-drop-down-button>
class DropDownButton extends StatefulWidget {
  /// Creates a dropdown button.
  const DropDownButton({
    Key? key,
    required this.items,
    this.leading,
    this.title,
    this.trailing,
    this.verticalOffset = _kVerticalOffset,
    this.closeAfterClick = true,
    this.disabled = false,
    this.focusNode,
    this.autofocus = false,
    this.buttonStyle,
    this.placement = FlyoutPlacement.center,
    this.menuDecoration,
  })  : assert(items.length > 0, 'You must provide at least one item'),
        super(key: key);

  /// The content at the left of this widget.
  ///
  /// Usually an [Icon]
  final Widget? leading;

  /// Title show a content at the center of this widget.
  ///
  /// Usually a [Text]
  final Widget? title;

  /// Trailing show a content at the right of this widget.
  ///
  /// If null, a chevron_down is displayed.
  final Widget? trailing;

  /// The space between the button and the flyout.
  ///
  /// 20.0 is used by default
  final double verticalOffset;

  /// The items in the flyout. Must not be empty
  final List<DropDownButtonItem> items;

  /// Whether the flyout will be closed after an item is tapped
  final bool closeAfterClick;

  /// If `true`, the button won't be clickable.
  final bool disabled;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// Customizes the button's appearance.
  final ButtonStyle? buttonStyle;

  /// The placement of the overlay. Centered by default
  final FlyoutPlacement placement;

  /// The menu decoration
  final Decoration? menuDecoration;

  @override
  State<DropDownButton> createState() => _DropDownButtonState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<DropDownButtonItem>('items', items))
      ..add(DoubleProperty(
        'verticalOffset',
        verticalOffset,
        defaultValue: _kVerticalOffset,
      ))
      ..add(FlagProperty(
        'close after click',
        value: closeAfterClick,
        defaultValue: false,
        ifFalse: 'do not close after click',
      ))
      ..add(EnumProperty<FlyoutPlacement>('placement', placement))
      ..add(DiagnosticsProperty('menu decoration', menuDecoration));
  }
}

class _DropDownButtonState extends State<DropDownButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 87),
      // reverseDuration: _fadeOutDuration,
      vsync: this,
    );
    // Listen to see when a mouse is added.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _createNewEntry(Widget child) {
    final OverlayState overlayState = Overlay.of(
      context,
      debugRequiredFor: widget,
    )!;

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

    // We create this widget outside of the overlay entry's builder to prevent
    // updated values from happening to leak into the overlay when the overlay
    // rebuilds.
    final Widget overlay = Directionality(
      textDirection: Directionality.of(context),
      child: _DropDownButtonOverlay(
        child: child,
        height: 50.0,
        width: 100.0,
        decoration: widget.menuDecoration ??
            BoxDecoration(
              color: FluentTheme.of(context).micaBackgroundColor,
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(
                width: 0.25,
                color: FluentTheme.of(context).inactiveBackgroundColor,
              ),
              boxShadow: kElevationToShadow[4],
            ),
        animation: CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        ),
        target: {
          FlyoutPlacement.left: leftTarget,
          FlyoutPlacement.center: centerTarget,
          FlyoutPlacement.right: rightTarget,
        },
        verticalOffset: widget.verticalOffset,
        preferBelow: true,
        onClose: _removeEntry,
        placement: widget.placement,
      ),
    );
    Navigator.of(context).push(FluentDialogRoute(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: Duration.zero,
      builder: (context) {
        return overlay;
      },
    ));
    _controller.forward();
  }

  void _removeEntry() {
    Navigator.maybeOf(context)?.pop();
    _controller.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));

    final buttonChildren = <Widget>[
      if (widget.leading != null)
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconTheme.merge(
            data: const IconThemeData(size: 20.0),
            child: widget.leading!,
          ),
        ),
      if (widget.title != null) widget.title!,
      Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: widget.trailing ??
            const Icon(
              FluentIcons.chevron_down,
              size: 10,
            ),
      ),
    ];

    return Button(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: buttonChildren,
      ),
      onPressed: widget.disabled
          ? null
          : () {
              _createNewEntry(_DropdownMenu(
                items: widget.items.map((item) {
                  if (widget.closeAfterClick) {
                    return DropDownButtonItem(
                      onTap: () {
                        item.onTap();
                        _removeEntry();
                      },
                      key: item.key,
                      leading: item.leading,
                      title: item.title,
                      trailing: item.trailing,
                    );
                  }
                  return item;
                }).toList(),
              ));
            },
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      style: widget.buttonStyle,
    );
  }
}

/// An item used by [DropDownButton].
class DropDownButtonItem {
  /// Creates a drop down button item
  const DropDownButtonItem({
    this.key,
    required this.onTap,
    this.leading,
    this.title,
    this.trailing,
  }) : assert(
          leading != null || title != null || trailing != null,
          'You must provide at least one property: leading, title or trailing',
        );

  /// Controls how one widget replaces another widget in the tree.
  final Key? key;

  /// Show a content at the left of this button.
  ///
  /// Usually an [Icon]
  final Widget? leading;

  /// Show a content at the center of this button.
  ///
  /// Usually a [Text]
  final Widget? title;

  /// Show a content at the right of this widget.
  final Widget? trailing;

  /// When the button is clicked, onTap is executed.
  final VoidCallback onTap;

  Widget build(BuildContext context) {
    return HoverButton(
      key: key,
      onPressed: onTap,
      builder: (context, states) {
        final theme = FluentTheme.of(context);
        final radius = BorderRadius.circular(4.0);
        return Padding(
          padding: const EdgeInsets.only(bottom: _kInnerPadding),
          child: FocusBorder(
            focused: states.isFocused,
            renderOutside: true,
            style: FocusThemeData(borderRadius: radius),
            child: Container(
              decoration: BoxDecoration(
                color: ButtonThemeData.uncheckedInputColor(theme, states),
                borderRadius: radius,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (leading != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: leading!,
                  ),
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: title!,
                  ),
                if (trailing != null) trailing!,
              ]),
            ),
          ),
        );
      },
    );
  }
}

class _DropdownMenu extends StatefulWidget {
  const _DropdownMenu({Key? key, required this.items}) : super(key: key);

  final List<DropDownButtonItem> items;

  @override
  State<_DropdownMenu> createState() => __DropdownMenuState();
}

class __DropdownMenuState extends State<_DropdownMenu> {
  final _key = GlobalKey();
  Size? size;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final context = _key.currentContext;
      if (context == null) return;
      final box = context.findRenderObject() as RenderBox;
      setState(() => size = box.size);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      autofocus: true,
      child: Padding(
        padding: const EdgeInsets.only(
          top: _kInnerPadding,
          left: _kInnerPadding,
          right: _kInnerPadding,
        ),
        child: Column(
          key: _key,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.items.length, (index) {
            final item = widget.items[index];
            return SizedBox(
              width: size?.width,
              child: Builder(builder: item.build),
            );
          }),
        ),
      ),
    );
  }
}

/// A delegate for computing the layout of a menu to be displayed above or
/// bellow a target specified in the global coordinate system.
class _DropDownButtonPositionDelegate extends SingleChildLayoutDelegate {
  /// Creates a delegate for computing the layout of a menu.
  ///
  /// The arguments must not be null.
  const _DropDownButtonPositionDelegate({
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
  bool shouldRelayout(_DropDownButtonPositionDelegate oldDelegate) {
    return centerTarget != oldDelegate.centerTarget ||
        verticalOffset != oldDelegate.verticalOffset ||
        preferBelow != oldDelegate.preferBelow;
  }
}

class _DropDownButtonOverlay extends StatelessWidget {
  const _DropDownButtonOverlay({
    Key? key,
    required this.height,
    required this.width,
    required this.child,
    this.padding,
    this.margin,
    this.decoration,
    required this.animation,
    required this.target,
    required this.verticalOffset,
    required this.preferBelow,
    required this.onClose,
    this.menuKey,
    required this.placement,
  }) : super(key: key);

  final Widget child;
  final double height;
  final double width;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final Animation<double> animation;
  final Map<FlyoutPlacement, Offset> target;
  final double verticalOffset;
  final bool preferBelow;
  final VoidCallback onClose;
  final Key? menuKey;
  final FlyoutPlacement placement;

  @override
  Widget build(BuildContext context) {
    return CustomSingleChildLayout(
      key: menuKey,
      delegate: _DropDownButtonPositionDelegate(
        leftTarget: target[FlyoutPlacement.left]!,
        centerTarget: target[FlyoutPlacement.center]!,
        rightTarget: target[FlyoutPlacement.right]!,
        verticalOffset: verticalOffset,
        preferBelow: preferBelow,
        placement: placement,
      ),
      child: ClipRect(
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(animation),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: height,
              minWidth: width,
            ),
            child: DefaultTextStyle(
              style: FluentTheme.of(context).typography.body!,
              child: Container(
                decoration: decoration,
                padding: padding,
                margin: margin,
                child: Center(
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
