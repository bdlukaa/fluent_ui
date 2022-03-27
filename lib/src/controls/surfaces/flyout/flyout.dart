import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

import '../../../utils/popup.dart';

export 'controller.dart';

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
    this.placement = FlyoutPlacement.center,
    this.openMode = FlyoutOpenMode.none,
  }) : super(key: key);

  /// The child that will be attached to the flyout.
  ///
  /// Usually a [FlyoutContent]
  final Widget child;

  /// The content that will be displayed on the route
  final WidgetBuilder content;

  /// Holds the state of the flyout. Can be useful to open or close the flyout
  /// programatically.
  ///
  /// Call `controller.dispose` to clean up resources when no longer necessary
  final FlyoutController? controller;

  /// The vertical gap between the [child] and the displayed flyout.
  final double verticalOffset;

  /// How the flyout will be placed relatively to the [child].
  ///
  /// Defaults to center
  final FlyoutPlacement placement;

  /// How the flyout will be opened by the end-user without needing to use a
  /// controller.
  ///
  /// Defaults to none
  final FlyoutOpenMode openMode;

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

/// The content of the flyout.
///
/// See also:
///
///   * [Flyout]
///   * [FlyoutListTile]
class FlyoutContent extends StatelessWidget {
  /// Creates a flyout content
  const FlyoutContent({
    Key? key,
    required this.child,
    this.color,
    this.shape,
    this.padding = const EdgeInsets.all(8.0),
    this.shadowColor = Colors.black,
    this.elevation = 8,
    this.constraints,
    this.margin = const EdgeInsets.symmetric(horizontal: 10.0),
  }) : super(key: key);

  final Widget child;

  /// The background color of the box.
  final Color? color;

  /// The shape to fill the [color] of the box.
  final ShapeBorder? shape;

  /// Empty space to inscribe around the [child]
  final EdgeInsetsGeometry padding;

  /// The shadow color.
  final Color shadowColor;

  /// The z-coordinate relative to the box at which to place this physical
  /// object.
  final double elevation;

  /// The amount of space by which to inset the box.
  final EdgeInsets margin;

  /// Additional constraints to apply to the child.

  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final ThemeData theme = FluentTheme.of(context);
    return Padding(
      padding: margin,
      child: PhysicalModel(
        elevation: elevation,
        color: Colors.transparent,
        shadowColor: shadowColor,
        child: Container(
          constraints: constraints,
          decoration: ShapeDecoration(
            color: color ?? theme.menuColor,
            shape: shape ??
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                  side: BorderSide(
                    width: 0.25,
                    color: theme.inactiveBackgroundColor,
                  ),
                ),
          ),
          padding: padding,
          child: DefaultTextStyle(
            style: theme.typography.body ?? const TextStyle(),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A tile that is used inside of [FlyoutContent]
class FlyoutListTile extends StatelessWidget {
  /// Creates a flyout list tile.
  const FlyoutListTile({
    Key? key,
    this.onPressed,
    this.tooltip,
    this.icon,
    required this.text,
    this.trailing,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  }) : super(key: key);

  final VoidCallback? onPressed;

  /// The tile tooltip text
  final String? tooltip;

  /// The leading widget.
  ///
  /// Usually an [Icon]
  final Widget? icon;

  /// The title widget.
  ///
  /// Usually a [Text]
  final Widget text;

  /// The leading widget.
  final Widget? trailing;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// {@macro fluent_ui.controls.inputs.HoverButton.semanticLabel}
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return HoverButton(
      key: key,
      onPressed: onPressed,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticLabel: semanticLabel,
      builder: (context, states) {
        final theme = FluentTheme.of(context);
        final radius = BorderRadius.circular(4.0);

        Widget content = Container(
          decoration: BoxDecoration(
            color: ButtonThemeData.uncheckedInputColor(theme, states),
            borderRadius: radius,
          ),
          padding: const EdgeInsetsDirectional.only(
            top: 4.0,
            bottom: 4.0,
            start: 10.0,
            end: 8.0,
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 10.0),
                child: IconTheme.merge(
                  data: const IconThemeData(size: 16.0),
                  child: icon!,
                ),
              ),
            Flexible(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 10.0),
                child: DefaultTextStyle(
                  child: text,
                  style: TextStyle(
                    inherit: false,
                    fontSize: 14.0,
                    letterSpacing: -0.15,
                    color: theme.inactiveColor,
                  ),
                ),
              ),
            ),
            if (trailing != null)
              DefaultTextStyle(
                child: trailing!,
                style: TextStyle(
                  inherit: false,
                  fontSize: 12.0,
                  color: theme.borderInputColor,
                  height: 0.7,
                ),
              ),
          ]),
        );

        if (tooltip != null) {
          content = Tooltip(message: tooltip, child: content);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: FocusBorder(
            focused: states.isFocused,
            renderOutside: true,
            style: FocusThemeData(borderRadius: radius),
            child: content,
          ),
        );
      },
    );
  }
}
