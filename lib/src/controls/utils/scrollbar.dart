import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

// TODO: Improve scrollbar (Currently blocked by https://github.com/flutter/flutter/issues/80370)
// - Background color
// - Press color
// - Navigation arrows

/// {@macro flutter.widgets.Scrollbar}
class Scrollbar extends StatefulWidget {
  /// Creates a basic raw scrollbar that wraps the given [child].
  ///
  /// The [child], or a descendant of the [child], should be a
  /// source of [ScrollNotification] notifications, typically a
  /// [Scrollable] widget.
  ///
  /// The [child], [thickness], [thumbColor], [isAlwaysShown],
  /// [fadeDuration], and [timeToFade] arguments must not be null.
  const Scrollbar({
    Key? key,
    required this.child,
    this.controller,
    this.isAlwaysShown = true,
    this.style,
  }) : super(key: key);

  /// {@macro flutter.widgets.Scrollbar.child}
  final Widget child;

  /// {@macro flutter.widgets.Scrollbar.controller}
  final ScrollController? controller;

  /// {@macro flutter.widgets.Scrollbar.isAlwaysShown}
  final bool isAlwaysShown;

  /// The style applied to the scroll bar. If non-null, it's mescled with [Style.scrollbarStyle]
  final ScrollbarStyle? style;

  @override
  _ScrollbarState createState() => _ScrollbarState();
}

class _ScrollbarState extends State<Scrollbar> {
  final _rawKey = GlobalKey<RawScrollbarState>();

  bool _isHovering = false;

  void _handleHoverUpdate(Offset position) {
    setState(
      () => _isHovering =
          // ignore: invalid_use_of_protected_member
          _rawKey.currentState?.isPointerOverScrollbar(position) ?? false,
    );
  }

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.scrollbarStyle?.copyWith(widget.style);
    return MouseRegion(
      onExit: (event) => _handleHoverUpdate(event.position),
      onHover: (event) => _handleHoverUpdate(event.position),
      onEnter: (event) => _handleHoverUpdate(event.position),
      child: Container(
        padding: _isHovering ? EdgeInsets.zero : EdgeInsets.only(right: 2),
        child: TweenAnimationBuilder<double>(
          duration: context.theme.fasterAnimationDuration ?? Duration.zero,
          tween: _isHovering
              ? Tween<double>(
                  begin: style?.thickness ?? 2.0,
                  end: style?.hoveringThickness ?? 16.0,
                )
              : Tween<double>(
                  begin: style?.hoveringThickness ?? 16.0,
                  end: style?.thickness ?? 2.0,
                ),
          builder: (context, thickness, child) => TweenAnimationBuilder<double>(
            duration: context.theme.fasterAnimationDuration ?? Duration.zero,
            tween: _isHovering
                ? Tween<double>(begin: 100, end: 0)
                : Tween<double>(begin: 75, end: 100),
            builder: (context, radius, _) => RawScrollbar(
              key: _rawKey,
              child: child!,
              controller: widget.controller,
              isAlwaysShown: widget.isAlwaysShown,
              thickness: thickness,
              radius: Radius.circular(radius),
              thumbColor: style?.scrollbarColor,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

@immutable
class ScrollbarStyle with Diagnosticable {
  final double? thickness;
  final double? hoveringThickness;

  final Color? backgroundColor;
  final Color? scrollbarColor;
  final Color? scrollbarPressingColor;

  const ScrollbarStyle({
    this.thickness,
    this.hoveringThickness,
    this.backgroundColor,
    this.scrollbarColor,
    this.scrollbarPressingColor,
  });

  factory ScrollbarStyle.standart(Style style) {
    assert(
      style.brightness != null,
      'The brightness must be provided in order to make Scrollbar work',
    );
    return ScrollbarStyle(
      scrollbarColor:
          style.brightness!.isLight ? Color(0xFF8c8c8c) : Color(0xFF767676),
      scrollbarPressingColor:
          style.brightness!.isLight ? Color(0xFF5d5d5d) : Color(0xFFa4a4a4),
      thickness: 2.0,
      hoveringThickness: 16.0,
      backgroundColor:
          style.brightness!.isLight ? Color(0xFFe9e9e9) : Color(0xFF1b1b1b),
    );
  }

  ScrollbarStyle copyWith(ScrollbarStyle? style) {
    if (style == null) return this;
    return ScrollbarStyle(
      backgroundColor: style.backgroundColor ?? backgroundColor,
      scrollbarColor: style.scrollbarColor ?? scrollbarColor,
      scrollbarPressingColor:
          style.scrollbarPressingColor ?? scrollbarPressingColor,
      hoveringThickness: style.hoveringThickness ?? hoveringThickness,
      thickness: style.thickness ?? thickness,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('scrollbarColor', scrollbarColor));
    properties.add(ColorProperty(
      'scrollbarPressingColor',
      scrollbarPressingColor,
    ));
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties.add(DoubleProperty('thickness', thickness, defaultValue: 2.0));
    properties.add(DoubleProperty(
      'hoveringThickness',
      hoveringThickness,
      defaultValue: 16.0,
    ));
  }
}
