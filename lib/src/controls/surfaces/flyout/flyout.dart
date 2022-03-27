import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

import '../../../utils/popup.dart';

export 'controller.dart';

enum FlyoutPlacement { left, center, right }

enum FlyoutOpenMode { none, hover, press, longPress }

class Flyout extends StatefulWidget {
  const Flyout({
    Key? key,
    required this.child,
    required this.content,
    this.controller,
    this.verticalOffset = 24,
    this.placement = FlyoutPlacement.center,
    this.openMode = FlyoutOpenMode.none,
  }) : super(key: key);

  final Widget child;

  final WidgetBuilder content;
  final FlyoutController? controller;
  final double verticalOffset;

  final FlyoutPlacement placement;

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
          onEnter: (event) => controller.open(),
          onExit: (event) => controller.close(),
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

class FlyoutContent extends StatelessWidget {
  const FlyoutContent({
    Key? key,
    required this.child,
    this.color,
    this.shape,
    this.padding = const EdgeInsets.all(8.0),
    this.shadowColor,
    this.elevation = 8,
    this.constraints,
  }) : super(key: key);

  final Widget child;

  final Color? color;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry padding;

  final Color? shadowColor;
  final double elevation;

  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final ThemeData theme = FluentTheme.of(context);
    return PhysicalModel(
      elevation: elevation,
      color: Colors.transparent,
      shadowColor: Colors.black,
      child: Container(
        constraints: constraints,
        decoration: BoxDecoration(
          color: theme.menuColor,
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(
            width: 0.25,
            color: theme.inactiveBackgroundColor,
          ),
        ),
        padding: padding,
        child: DefaultTextStyle(
          style: theme.typography.body ?? const TextStyle(),
          child: child,
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
  }) : super(key: key);

  final VoidCallback? onPressed;

  final String? tooltip;
  final Widget? icon;
  final Widget text;
  final Widget? trailing;

  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return HoverButton(
      key: key,
      onPressed: onPressed,
      focusNode: focusNode,
      autofocus: autofocus,
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
