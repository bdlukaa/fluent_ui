import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

import '../../../utils/popup.dart';

export 'controller.dart';

enum FlyoutPlacement { left, center, right }

class Flyout extends StatefulWidget {
  const Flyout({
    Key? key,
    required this.child,
    required this.content,
    required this.contentWidth,
    required this.controller,
    this.verticalOffset = 24,
  }) : super(key: key);

  final Widget child;

  final Widget content;
  final double contentWidth;
  final FlyoutController controller;
  final double verticalOffset;

  @override
  _FlyoutState createState() => _FlyoutState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('contentWidth', contentWidth));
    properties.add(DiagnosticsProperty<FlyoutController>(
      'controller',
      controller,
    ));
  }
}

class _FlyoutState extends State<Flyout> {
  final popupKey = GlobalKey<PopUpState>();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleStateChanged);
  }

  void _handleStateChanged() {
    final open = widget.controller.open;
    final isOpen = popupKey.currentState?.isOpen ?? false;
    if (!isOpen && open) {
      popupKey.currentState?.openPopup();
    } else if (isOpen && !open) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return PopUp(
      key: popupKey,
      child: widget.child,
      content: (context) => widget.content,
      contentWidth: widget.contentWidth,
      verticalOffset: widget.verticalOffset,
    );
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
  }) : super(key: key);

  final Widget child;

  final Color? color;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry padding;

  final Color? shadowColor;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final ThemeData theme = FluentTheme.of(context);
    return PhysicalModel(
      elevation: elevation,
      color: Colors.transparent,
      shadowColor: Colors.black,
      child: Container(
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
            Expanded(
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
          content = Tooltip(
            message: tooltip,
            child: content,
          );
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
