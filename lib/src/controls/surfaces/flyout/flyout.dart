import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

import 'controller.dart';
import '../../../utils/popup.dart';

export 'controller.dart';

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
    this.padding = const EdgeInsets.all(12.0),
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
    return Acrylic(
      elevation: elevation,
      tintAlpha: 1.0,
      tint: color ?? theme.acrylicBackgroundColor,
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
            side: BorderSide(
              color: theme.inactiveBackgroundColor,
              width: 0.9,
            ),
          ),
      child: Padding(
        padding: padding,
        child: DefaultTextStyle(
          style: theme.typography.body ?? const TextStyle(),
          child: child,
        ),
      ),
    );
  }
}
