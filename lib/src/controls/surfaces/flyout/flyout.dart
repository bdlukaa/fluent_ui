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
  }) : super(key: key);

  final Widget child;

  final Widget content;
  final double contentWidth;
  final FlyoutController controller;

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
      contentHeight: 0,
      contentWidth: widget.contentWidth,
    );
  }
}

class FlyoutContent extends StatelessWidget {
  const FlyoutContent({
    Key? key,
    required this.child,
    this.decoration,
    this.padding,
    this.shadowColor,
    this.elevation = 8,
  }) : super(key: key);

  final Widget child;

  final Decoration? decoration;
  final EdgeInsetsGeometry? padding;

  final Color? shadowColor;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return PhysicalModel(
      color: shadowColor ?? Colors.black,
      elevation: elevation,
      borderRadius: BorderRadius.circular(4.0),
      child: Acrylic(
        decoration: decoration ??
            BoxDecoration(
              color: context.theme.navigationPanelBackgroundColor,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: context.theme.scaffoldBackgroundColor,
                width: 0.6,
              ),
            ),
        padding: padding ?? const EdgeInsets.all(12.0),
        child: DefaultTextStyle(
          style: context.theme.typography.body ?? TextStyle(),
          child: child,
        ),
      ),
    );
  }
}
